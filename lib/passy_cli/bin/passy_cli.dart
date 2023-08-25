import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:passy/passy_cli/lib/common.dart' as cn;
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_cli/lib/common.dart';
import 'package:passy/passy_cli/lib/dart_app_data.dart';
import 'package:passy/passy_data/account_credentials.dart';
import 'package:passy/passy_data/account_settings.dart';
import 'package:passy/passy_data/common.dart' as pcommon;
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/favorites.dart';
import 'package:passy/passy_data/history.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/legacy/legacy.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_entries_encrypted_csv_file.dart';
import 'package:passy/passy_data/passy_entries_file_collection.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/synchronization.dart';
import 'package:qr_terminal/qr_terminal.dart' as qr;

const String helpMsg = '''

Passy Password Manager CLI.

Usage: passy_cli [arguments] [command]

If no command is supplied, Passy CLI starts in interactive mode.

Commands:

  General
    help           Display this message.
    exit           Exit the interactive mode.
    run <file>     Execute commands separated by newlines from file.

  Version
    version shell  Show shell version.
    version passy  Show Passy version.
    version data   Show account data version.
    version sync   Show synchronization version.

  Accounts
    accounts list
        - List available account credentials.
          Each line is in CSV format and provides a username and a SHA512 password hash.
    accounts verify <username> <password>
        - Returns `true` if the password is correct, `false` otherwise.
    accounts login <username> <password>
        - Save account encrypter for the current interactive session.
          Returns `true` if the password is correct, `false` otherwise.
    accounts is_logged_in <username>
        - Check if account encrypter is loaded for the specified username
    accounts logout <username>
        - Forget account encrypter.
    accounts logout_all
        - Unload all account encrypters.

  Entries
    For all commands in this section, <entry type> argument is one of the following:
    password, paymentCard, note, idCard, identity.

    entries list <username> <entry type>
        - List all entry metadata.
    entries get <username> <entry type> <key>
        - Get a decrypted CSV string for the entry under the specified key.
          Returns `null` if no value is found.
    entries set <username> <entry type> <csv>
        - Set a new value for password.
          Creates a new password if none exists under the provided key.
          Returns `true` on success.
    entries remove <username> <entry type> <entry key>
        - Remove entry under the specified key.

  Favorites
    For all commands in this section, <entry type> argument is one of the following:
    password, paymentCard, note, idCard, identity.

    favorites list <username> <entry type>
        - List all favorites of entry type.
    favorites toggle <username> <entry type> <entry key> <toggle>
        - Toggle a favorite.
          The allowed value for toggle is `true` or `false`.

  Installation
    install temp
        - Copy the executable to a temporary directory and assign it a random name
          Returns the file path on success.

  Development
    native_messaging start
        - Start in native messaging mode.

  Synchronization
    sync host classic <address> <port> <username> [detached]
        - Host the default synchronization server used in Passy.
          Can only synchronize one account.
          Supports one connection over its lifetime, stops once first synchronization is finished.
          The [detached] argument is `false` by default, if `true` then the server starts in detached mode.

    sync close <address>:<port>
        - Close synchronization server.
          Returns `false` if server is not running, `true` otherwise.

    sync report get <address>:<port>
        - Get synchronization report JSON for the specified server.
          Returns `false` if no report was found.
    sync report del <address>:<port>
        - Delete synchronization report for the specified server.

''';

const String passyShellVersion = '1.0.0';
// Worst case scenario: all characters weigh 4 bytes and each is escaped
// (1000000/4)/2
// + minus the extra messaging space
const int maxNativeMessageLength = 120000;

bool _isBigEndian = Endian.host == Endian.big;
bool _isBusy = false;
bool _isInteractive = false;
bool _isNativeMessaging = false;
bool _stdinEchoMode = stdin.echoMode;
bool _stdinLineMode = stdin.lineMode;

bool _shouldMoveLine = false;
bool _logDisabled = false;
late String _passyDataPath;
late String _accountsPath;
Map<String, AccountCredentialsFile> _accounts = {};
Map<String, Encrypter> _encrypters = {};
Map<String, Encrypter> _syncEncrypters = {};
Map<String, Map<String, dynamic> Function()> _syncReportGetters = {};
Map<String, Future Function()> _syncCloseMethods = {};

void nativeMessagingLog(dynamic id, String msg) {
  List<String> msgSplit = [];
  if (msg.length < maxNativeMessageLength) {
    msgSplit.add(msg);
  } else {
    for (int i = 0; i < msg.length; i += maxNativeMessageLength) {
      int end = i + maxNativeMessageLength;
      end = end > msg.length ? msg.length : end;
      msgSplit.add(msg.substring(i, end));
    }
  }
  for (int i = 0; i != msgSplit.length; i++) {
    String msgPart = msgSplit[i];
    msgPart = jsonEncode({
      'id': id.toString(),
      'part': (i + 1).toString(),
      'partsTotal': msgSplit.length.toString(),
      'data': msgPart,
    });
    List<int> bytes = utf8.encode(msgPart);
    List<int> nativeLength = _isBigEndian
        ? [
            (bytes.length >> 24) & 0xFF,
            (bytes.length >> 16) & 0xFF,
            (bytes.length >> 8) & 0xFF,
            (bytes.length >> 0) & 0xFF,
          ]
        : [
            (bytes.length >> 0) & 0xFF,
            (bytes.length >> 8) & 0xFF,
            (bytes.length >> 16) & 0xFF,
            (bytes.length >> 24) & 0xFF,
          ];
    stdout.add([
      ...nativeLength,
      ...bytes,
    ]);
  }
}

void log(Object? object, {dynamic id}) {
  if (_logDisabled) return;
  String msg = object.toString();
  if (_isNativeMessaging) {
    nativeMessagingLog(id, msg);
    return;
  }
  if (_shouldMoveLine) {
    _shouldMoveLine = false;
    msg = '\n$msg';
  }
  stdout.write(msg);
  _shouldMoveLine = true;
}

void refreshAccounts() {
  _accounts.clear();
  Directory _accountsDirectory = Directory(_accountsPath);
  _accountsDirectory.createSync(recursive: true);
  List<FileSystemEntity> _accountDirectories = _accountsDirectory.listSync();
  for (FileSystemEntity d in _accountDirectories) {
    String _username = d.path.split(Platform.pathSeparator).last;
    _accounts[_username] = AccountCredentials.fromFile(
      File(_accountsDirectory.path +
          Platform.pathSeparator +
          _username +
          Platform.pathSeparator +
          'credentials.json'),
      value: AccountCredentials(username: _username, passwordHash: 'corrupted'),
    );
  }
}

Future<void> load() async {
  _passyDataPath = await Locator.getPlatformSpecificCachePath() +
      Platform.pathSeparator +
      'Passy';
  _accountsPath = _passyDataPath + Platform.pathSeparator + 'accounts';
  refreshAccounts();
}

Future<void> cleanup() async {
  _logDisabled = true;
  stdin.echoMode = _stdinEchoMode;
  stdin.lineMode = _stdinLineMode;
  exit(0);
}

Future<void> onInterrupt() async {
  log('I:Interrupt received.');
  log('');
  cleanup();
}

Function(List<int>)? _secondaryInput;
bool _pauseMainInput = false;

StreamSubscription<List<int>> startInteractive() {
  stdin.lineMode = true;
  stdin.echoMode = true;
  return stdin.listen((List<int> event) async {
    _secondaryInput?.call(event);
    if (_pauseMainInput) return;
    _shouldMoveLine = false;
    String commandEncoded;
    List<String> command;
    String? id;
    if (_isNativeMessaging) {
      if (event.length < 5) return;
      commandEncoded = utf8.decode(event.sublist(4), allowMalformed: true);
      dynamic commandJson;
      try {
        dynamic commandDecoded = jsonDecode(commandEncoded);
        commandJson = commandDecoded['command'];
        id = commandDecoded['id'];
      } catch (_) {}
      if (commandJson is! List<dynamic>) return;
      command = commandJson.map((e) => e.toString()).toList();
    } else {
      commandEncoded = utf8.decode(event);
      commandEncoded = commandEncoded.replaceAll('\n', '').replaceAll('\r', '');
      command = parseCommand(commandEncoded);
    }
    if (command.isNotEmpty) {
      if (_isBusy) return;
      _isBusy = true;
      try {
        await executeCommand(command,
            id: id ?? pcommon.getPassyHash(jsonEncode(command)).toString());
      } catch (_) {}
      _isBusy = false;
    }
    if (_isInteractive) log('[passy]\$ ');
  });
}

PassyEntriesEncryptedCSVFile getEntriesFile(File file,
    {required EntryType type, required Encrypter encrypter}) {
  switch (type) {
    case EntryType.password:
      return PasswordsFile.fromFile(
        file,
        encrypter: encrypter,
      );

    case EntryType.paymentCard:
      return PaymentCardsFile.fromFile(
        file,
        encrypter: encrypter,
      );
    case EntryType.note:
      return NotesFile.fromFile(
        file,
        encrypter: encrypter,
      );
    case EntryType.idCard:
      return IDCardsFile.fromFile(
        file,
        encrypter: encrypter,
      );
    case EntryType.identity:
      return IdentitiesFile.fromFile(
        file,
        encrypter: encrypter,
      );
  }
}

Future<String> _login(String username, String password) async {
  AccountCredentials? _credentials = _accounts[username]?.value;
  if (_credentials == null) {
    return 'false';
  }
  bool match = _credentials.passwordHash ==
      (await cn.getPasswordHash(password,
              derivationType: _credentials.keyDerivationType,
              derivationInfo: _credentials.keyDerivationInfo))
          .toString();
  if (match) {
    _encrypters[username] = await cn.getPasswordEncrypter(
      password,
      derivationType: _credentials.keyDerivationType,
      derivationInfo: _credentials.keyDerivationInfo,
    );
    _syncEncrypters[username] = await cn.getSyncEncrypter(
      password,
      derivationType: _credentials.keyDerivationType,
      derivationInfo: _credentials.keyDerivationInfo,
    );
    try {
      loadLegacyAccount(
          path: _accountsPath + Platform.pathSeparator + username,
          encrypter: _encrypters[username]!,
          syncEncrypter: _syncEncrypters[username]!);
    } catch (e, s) {
      return 'accounts:login:Failed to load account:\n$e\n$s';
    }
  }
  return match.toString();
}

Future<void> executeCommand(List<String> command, {dynamic id}) async {
  switch (command[0]) {
    case 'help':
      log(helpMsg, id: id);
      return;
    case 'exit':
      log('Have a splendid day!\n', id: id);
      cleanup();
      return;
    case 'run':
      if (command.length == 1) break;
      File file = File(command[1]);
      List<List<String>> commands = [];
      try {
        String contents = await file.readAsString();
        List<String> lines;
        if (contents.contains('\r\n')) {
          lines = contents.split('\r\n');
        } else {
          lines = contents.split('\n');
        }
        for (String line in lines) {
          commands.add(parseCommand(line));
        }
      } catch (e, s) {
        log('passy:run:Could not parse file:\n$e\n$s', id: id);
        return;
      }
      for (List<String> command in commands) {
        await executeCommand(command);
      }
      return;
    case 'version':
      if (command.length == 1) break;
      String? version;
      switch (command[1]) {
        case 'shell':
          version = passyShellVersion;
          break;
        case 'passy':
          version = pcommon.passyVersion;
          break;
        case 'data':
          version = pcommon.accountVersion;
          break;
        case 'sync':
          version = pcommon.syncVersion;
          break;
      }
      if (version == null) {
        log('passy:version:Unknown version type provided: ${command[1]}.',
            id: id);
        return;
      }
      log('v$version', id: id);
      return;
    case 'accounts':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'list':
          refreshAccounts();
          log(
              _accounts.values
                  .map<String>((e) =>
                      '${e.value.username},${e.value.passwordHash},${e.value.keyDerivationType.name},${e.value.keyDerivationInfo == null ? null : '[${pcommon.csvEncode(e.value.keyDerivationInfo!.toCSV())}]'}')
                  .join('\n'),
              id: id);
          return;
        case 'verify':
          refreshAccounts();
          if (command.length < 4) break;
          String accountName = command[2];
          AccountCredentials? _credentials = _accounts[accountName]?.value;
          if (_credentials == null) {
            log('false', id: id);
            return;
          }
          String password = command[3];
          bool match = _credentials.passwordHash ==
              (await cn.getPasswordHash(password,
                      derivationType: _credentials.keyDerivationType,
                      derivationInfo: _credentials.keyDerivationInfo))
                  .toString();
          log(match.toString(), id: id);
          return;
        case 'login':
          refreshAccounts();
          if (command.length < 4) break;
          String accountName = command[2];
          String password = command[3];
          log(await _login(accountName, password), id: id);
          return;
        case 'is_logged_in':
          if (command.length == 2) break;
          String accountName = command[2];
          if (_encrypters.containsKey(accountName)) {
            log('true', id: id);
          } else {
            log('false', id: id);
          }
          return;
        case 'logout':
          if (command.length == 2) break;
          String accountName = command[2];
          _encrypters.remove(accountName);
          _syncEncrypters.remove(accountName);
          log('true', id: id);
          return;
        case 'logout_all':
          _encrypters.clear();
          log('true', id: id);
          return;
      }
      break;
    case 'entries':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'list':
          if (command.length < 4) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:entries:list:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:entries:list:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          PassyEntriesEncryptedCSVFile entriesFile = getEntriesFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  entryTypeToFilename(entryType)),
              type: entryType,
              encrypter: encrypter);
          log(
              entriesFile.metadata.values
                  .map<String>((e) => jsonEncode(e.toJson()))
                  .join('\n'),
              id: id);
          return;
        case 'get':
          if (command.length < 5) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:entries:get:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:entries:list:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          String entryKey = command[4];
          PassyEntriesEncryptedCSVFile entriesFile = getEntriesFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  entryTypeToFilename(entryType)),
              type: entryType,
              encrypter: encrypter);
          log(entriesFile.getEntryString(entryKey), id: id);
          return;
        case 'set':
          if (command.length < 5) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:entries:set:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:entries:set:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          String csvEntry = command[4];
          PassyEntry entry;
          try {
            entry = PassyEntry.fromCSV(entryType)(
                pcommon.csvDecode(csvEntry, recursive: true));
          } catch (e, s) {
            log('passy:entries:set:Failed to decode entry:\n$e\n$s', id: id);
            return;
          }
          PassyEntriesEncryptedCSVFile entriesFile = getEntriesFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  entryTypeToFilename(entryType)),
              type: entryType,
              encrypter: encrypter);
          try {
            await entriesFile.setEntry(entry.key, entry: entry);
          } catch (e, s) {
            log('passy:entries:set:Failed to set entry:\n$e\n$s', id: id);
            return;
          }
          HistoryFile historyFile = History.fromFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  'history.enc'),
              encrypter: encrypter);
          historyFile.value.getEvents(entryType)[entry.key] = EntryEvent(
            entry.key,
            status: EntryStatus.alive,
            lastModified: DateTime.now().toUtc(),
          );
          try {
            await historyFile.save();
          } catch (e, s) {
            log('passy:entries:set:Failed to save history:\n$e\n$s', id: id);
            return;
          }
          log(true, id: id);
          return;
        case 'remove':
          if (command.length < 5) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:entries:remove:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:entries:remove:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          String entryKey = command[4];
          PassyEntriesEncryptedCSVFile entriesFile = getEntriesFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  entryTypeToFilename(entryType)),
              type: entryType,
              encrypter: encrypter);
          try {
            await entriesFile.setEntry(entryKey, entry: null);
          } catch (e, s) {
            log('passy:entries:remove:Failed to remove entry:\n$e\n$s', id: id);
            return;
          }
          HistoryFile historyFile = History.fromFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  'history.enc'),
              encrypter: encrypter);
          Map<String, EntryEvent> historyEntries =
              historyFile.value.getEvents(entryType);
          if (historyEntries.containsKey(entryKey)) {
            historyEntries[entryKey] = EntryEvent(
              entryKey,
              status: EntryStatus.removed,
              lastModified: DateTime.now().toUtc(),
            );
            try {
              await historyFile.save();
            } catch (e, s) {
              log('passy:entries:remove:Failed to save history:\n$e\n$s',
                  id: id);
              return;
            }
          }
          log(true, id: id);
          return;
      }
      break;
    case 'favorites':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'list':
          if (command.length < 4) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:favorites:list:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:favorites:list:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          FavoritesFile favoritesFile = Favorites.fromFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  'favorites.enc'),
              encrypter: encrypter);
          List<String> result = [];
          dynamic entries =
              favoritesFile.value.toJson()[entryTypeToNamePlural(entryType)];
          if (entries is! Map<String, dynamic>) {
            log('', id: id);
            return;
          }
          for (dynamic value in entries.values) {
            result.add(jsonEncode(value));
          }
          log(result.join('\n'), id: id);
          return;
        case 'toggle':
          if (command.length < 6) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:favorites:toggle:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          EntryType? entryType = entryTypeFromName(command[3]);
          if (entryType == null) {
            log('passy:favorites:toggle:Unknown entry type provided: ${command[3]}.',
                id: id);
            return;
          }
          String entryKey = command[4];
          bool? toggle = pcommon.boolFromString(command[5]);
          if (toggle == null) {
            log('passy:favorites:toggle:Invalid toggle value provided: expected `true` or `false`, received ${command[4]}.',
                id: id);
            return;
          }
          FavoritesFile favoritesFile = Favorites.fromFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  'favorites.enc'),
              encrypter: encrypter);
          favoritesFile.value.getEvents(entryType)[entryKey] = EntryEvent(
            entryKey,
            status: toggle ? EntryStatus.alive : EntryStatus.removed,
            lastModified: DateTime.now().toUtc(),
          );
          try {
            await favoritesFile.save();
          } catch (e, s) {
            log('passy:favorites:toggle:Failed to save favorites:\n$e\n$s',
                id: id);
            return;
          }
          log(true, id: id);
          return;
      }
      break;
    case 'sync':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'host':
          if (command.length == 2) break;
          switch (command[2]) {
            case 'classic':
              if (command.length < 6) break;
              String accountName = command[5];
              Encrypter? encrypter = _encrypters[accountName];
              Encrypter? syncEncrypter = _syncEncrypters[accountName];
              if (encrypter == null || syncEncrypter == null) {
                log('passy:host:classic:No account credentials provided, please use `accounts login` first.',
                    id: id);
                return;
              }
              String host = command[3];
              String portString = command[4];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:host:classic:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              bool detached;
              if (command.length < 7) {
                detached = false;
              } else {
                String detachedString = command[6];
                try {
                  detached = pcommon.boolFromString(detachedString)!;
                } catch (_) {
                  log('passy:host:classic:`$detachedString` is not a valid boolean.',
                      id: id);
                  return;
                }
              }
              String accPath = _accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator;
              AccountSettingsFile settings = AccountSettings.fromFile(
                  File('${accPath}settings.enc'),
                  encrypter: encrypter);
              Completer<void> syncCompleter = Completer();
              Completer<void> detachedCompleter = Completer();
              HostAddress? addr;
              Synchronization? serverNullable;
              serverNullable = Synchronization(
                encrypter: syncEncrypter,
                username: accountName,
                passyEntries: FullPassyEntriesFileCollection(
                  idCards: IDCards.fromFile(File('${accPath}idCards.enc'),
                      encrypter: encrypter),
                  identities: Identities.fromFile(
                      File('${accPath}identities.enc'),
                      encrypter: encrypter),
                  notes: Notes.fromFile(File('${accPath}notes.enc'),
                      encrypter: encrypter),
                  passwords: Passwords.fromFile(File('${accPath}passwords.enc'),
                      encrypter: encrypter),
                  paymentCards: PaymentCards.fromFile(
                      File('${accPath}paymentCards.enc'),
                      encrypter: encrypter),
                ),
                history: History.fromFile(File('${accPath}history.enc'),
                    encrypter: encrypter),
                favorites: Favorites.fromFile(File('${accPath}favorites.enc'),
                    encrypter: encrypter),
                rsaKeypair: await settings.value.rsaKeypairCompleter.future,
                onError: (err) {
                  if (detached) return;
                  log('Synchronization error:', id: id);
                  log(err, id: id);
                },
                onComplete: (p0) {
                  _syncCloseMethods.remove('${addr!.ip.address}:${addr.port}');
                  syncCompleter.complete();
                  if (detached) return;
                  log('Synchronization server stopped.', id: id);
                  log('Entries set: ${serverNullable!.entriesAdded}', id: id);
                  log('Entries removed: ${serverNullable.entriesRemoved}',
                      id: id);
                },
              );
              Synchronization server = serverNullable;
              addr = await server.host(
                  address: host == '0' ? null : host, port: port);
              if (addr == null) {
                log('passy:host:classic:Server failed to start, unknown error.',
                    id: id);
                return;
              }
              String fullAddr = '${addr.ip.address}:${addr.port}';
              _syncReportGetters[fullAddr] = () {
                return {
                  'mode': 'classic',
                  ...server.getReport().toJson(),
                };
              };
              _syncCloseMethods[fullAddr] = server.close;
              if (detached) {
                log(fullAddr, id: id);
                return;
              }
              log('', id: id);
              qr.generate(fullAddr, typeNumber: 2, small: true);
              log('Server started, running at `$fullAddr`.', id: id);
              log('Hotkeys | `c` - close server | `d` - detach', id: id);
              _pauseMainInput = true;
              stdin.lineMode = false;
              stdin.echoMode = false;
              void syncServerCli(List<int> event) async {
                String command = utf8.decode(event);
                if (command == 'c') {
                  log('Server close requested.', id: id);
                  server.close();
                }
                if (command == 'd') {
                  detachedCompleter.complete();
                  detached = true;
                  _secondaryInput = null;
                  log('Detached.', id: id);
                }
              }
              _secondaryInput = syncServerCli;
              await Future.any(
                  [syncCompleter.future, detachedCompleter.future]);
              stdin.lineMode = true;
              stdin.echoMode = true;
              _pauseMainInput = false;
              return;
          }
          break;
        case 'close':
          if (command.length == 2) break;
          Future<void> Function()? close = _syncCloseMethods[command[2]];
          if (close == null) {
            log('false', id: id);
            return;
          }
          await close();
          log('true', id: id);
          return;
        case 'report':
          if (command.length == 2) break;
          switch (command[2]) {
            case 'get':
              if (command.length == 3) break;
              Map<String, dynamic> Function()? report =
                  _syncReportGetters[command[3]];
              if (report == null) {
                log('false', id: id);
                return;
              }
              log(jsonEncode(report()), id: id);
              return;
            case 'del':
              if (command.length == 3) break;
              _syncReportGetters.remove(command[3]);
              log('true', id: id);
              return;
          }
          break;
      }
      break;
    case 'install':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'temp':
          File copy;
          try {
            Directory copyDir = Directory(Directory.systemTemp.path +
                Platform.pathSeparator +
                'passy_cli' +
                Platform.pathSeparator +
                'bin' +
                Platform.pathSeparator +
                'passy_cli');
            if (await copyDir.exists()) {
              List<FileSystemEntity> files = await copyDir.list().toList();
              for (FileSystemEntity file in files) {
                try {
                  // Write to test if the file is locked (required on Unix systems)
                  await File(file.path).writeAsString('');
                  await file.delete();
                } catch (_) {}
              }
            } else {
              await copyDir.create(recursive: true);
            }
            String copyPath = copyDir.path +
                Platform.pathSeparator +
                'passy_cli_' +
                DateTime.now().toIso8601String().replaceAll(':', ';');
            if (Platform.isWindows) copyPath += '.exe';
            copy = await File(Platform.resolvedExecutable).copy(copyPath);
          } catch (e, s) {
            log('passy:install:temp:Failed to install executable:\n$e\n$s',
                id: id);
            return;
          }
          log(copy.path, id: id);
          return;
      }
      break;
    case 'native_messaging':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'start':
          _isNativeMessaging = true;
          startInteractive();
          return;
      }
      break;
  }
  if (_isNativeMessaging) return;
  log('passy:Unknown command:${command.join(' ')}.', id: id);
  if (!_isInteractive) log(helpMsg, id: id);
}

void main(List<String> arguments) {
  _stdinEchoMode = stdin.echoMode;
  _stdinLineMode = stdin.lineMode;
  if (arguments.isNotEmpty) {
    load().then((value) async {
      await executeCommand(arguments);
      if (!_isNativeMessaging) log('');
    });
    return;
  }
  log('''
       ____                     
      |  _ \\ __ _ ___ ___ _   _ 
      | |_) / _` / __/ __| | | |
      |  __/ (_| \\__ \\__ \\ |_| |
      |_|   \\__,_|___/___/\\__, |
                          |___/ 

 Manage personal data on all platforms
   with military grade security. 🔒

  https://glitterware.github.io/Passy
${getBoxMessage('''

Welcome to Passy interactive shell!
${DateTime.now().toUtc().toString()} UTC.

Shell v$passyShellVersion
Passy v${pcommon.passyVersion}
Account data v${pcommon.accountVersion}
Synchronization v${pcommon.syncVersion}''')}

Type `help` for guidance.
Type `exit` to quit.
''');
  _isInteractive = true;
  ProcessSignal.sigint.watch().listen((event) => onInterrupt());
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((event) => onInterrupt());
  }
  load().then((value) {
    return startInteractive();
  });
  log('[passy]\$ ');
}
