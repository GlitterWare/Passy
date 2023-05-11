import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_cli/lib/common.dart';
import 'package:passy/passy_cli/lib/dart_app_data.dart';
import 'package:passy/passy_data/account_credentials.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/history.dart';
import 'package:passy/passy_data/password.dart';

const String helpMsg = '''

Passy Password Manager CLI.

Usage: passy_cli [arguments] [command]

If no command is supplied, Passy CLI starts in interactive mode.

Commands:

  General
    help           Display this message.
    exit           Exit the interactive mode.

  Accounts
    accounts list
        - List available account credentials.
          Each line is in CSV format and provides a username and a SHA512 password hash.
    accounts verify <username> <password>
        - Returns `true` if the password is correct, `false` otherwise.
    accounts login <username> <password>
        - Save account encrypter for the current interactive session.
          Returns `true` if the password is correct, `false` otherwise.
    accounts logout <username>
        - Forget account encrypter.
    accounts logout_all
        - Unload all account encrypters.

  Passwords
    passwords list <username>
        - List all password metadata.
    passwords get <username> <key>
        - Get a decrypted CSV string for the password under the specified key.
          Returns `null` if no value is found.
    passwords set <username> <csv>
        - Set a new value for password.
          Returns `true` on success.

  Development
    native_messaging start
        - Start in native messaging mode.
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

bool _shouldMoveLine = false;
bool _logDisabled = false;
late String _passyDataPath;
late String _accountsPath;
Map<String, AccountCredentialsFile> _accounts = {};
Map<String, Encrypter> _encrypters = {};

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
  _passyDataPath =
      Locator.getPlatformSpecificCachePath() + Platform.pathSeparator + 'Passy';
  _accountsPath = _passyDataPath + Platform.pathSeparator + 'accounts';
  refreshAccounts();
}

Future<void> cleanup() async {
  _logDisabled = true;
  exit(0);
}

Future<void> onInterrupt() async {
  log('I:Interrupt received.');
  log('');
  cleanup();
}

StreamSubscription<List<int>> startInteractive() {
  return stdin.listen((List<int> event) async {
    _shouldMoveLine = false;
    String commandEncoded = utf8.decode(event);
    if (_isNativeMessaging) {
      if (commandEncoded.length < 5) return;
      commandEncoded = commandEncoded.substring(4);
      commandEncoded = jsonDecode(commandEncoded)['command'];
    }
    List<String> command = parseCommand(commandEncoded.replaceFirst('\n', ''));
    if (command.isNotEmpty) {
      if (_isBusy) return;
      _isBusy = true;
      await executeCommand(command, id: getPassyHash(commandEncoded));
      _isBusy = false;
    }
    if (_isInteractive) log('[passy]\$ ');
  });
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
    case 'accounts':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'list':
          log(
              _accounts.values
                  .map<String>(
                      (e) => '${e.value.username},${e.value.passwordHash}')
                  .join('\n'),
              id: id);
          return;
        case 'verify':
          if (command.length < 4) break;
          String accountName = command[2];
          AccountCredentials? _credentials = _accounts[accountName]?.value;
          if (_credentials == null) {
            log('false', id: id);
            return;
          }
          String password = command[3];
          bool match =
              _credentials.passwordHash == getPassyHash(password).toString();
          log(match.toString(), id: id);
          return;
        case 'login':
          if (command.length < 4) break;
          String accountName = command[2];
          AccountCredentials? _credentials = _accounts[accountName]?.value;
          if (_credentials == null) {
            log('false', id: id);
            return;
          }
          String password = command[3];
          bool match =
              _credentials.passwordHash == getPassyHash(password).toString();
          if (match) _encrypters[accountName] = getPassyEncrypter(password);
          log(match.toString(), id: id);
          return;
        case 'logout':
          if (command.length < 3) break;
          String accountName = command[2];
          _encrypters.remove(accountName);
          log('true');
          return;
        case 'logout_all':
          _encrypters.clear();
          log('true');
          return;
      }
      break;
    case 'passwords':
      if (command.length == 1) break;
      switch (command[1]) {
        case 'list':
          if (command.length < 3) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:passwords:list:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          PasswordsFile passwords = PasswordsFile.fromFile(
            File(_accountsPath +
                Platform.pathSeparator +
                accountName +
                Platform.pathSeparator +
                'passwords.enc'),
            encrypter: encrypter,
          );
          log(
              passwords.metadata.values
                  .map<String>((e) => jsonEncode(e.toJson()))
                  .join('\n'),
              id: id);
          return;
        case 'get':
          if (command.length < 4) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:passwords:get:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          String entryKey = command[3];
          PasswordsFile passwords = PasswordsFile.fromFile(
            File(_accountsPath +
                Platform.pathSeparator +
                accountName +
                Platform.pathSeparator +
                'passwords.enc'),
            encrypter: encrypter,
          );
          log(passwords.getEntryString(entryKey), id: id);
          return;
        case 'set':
          if (command.length < 4) break;
          String accountName = command[2];
          Encrypter? encrypter = _encrypters[accountName];
          if (encrypter == null) {
            log('passy:passwords:get:No account credentials provided, please use `accounts login` first.',
                id: id);
            return;
          }
          String csvEntry = command[3];
          Password password;
          try {
            password = Password.fromCSV(csvDecode(csvEntry, recursive: true));
          } catch (e, s) {
            log('passy:passwords:set:Failed to decode password:\n$e\n$s',
                id: id);
            return;
          }
          PasswordsFile passwordsFile = PasswordsFile.fromFile(
            File(_accountsPath +
                Platform.pathSeparator +
                accountName +
                Platform.pathSeparator +
                'passwords.enc'),
            encrypter: encrypter,
          );
          try {
            await passwordsFile.setEntry(password.key, entry: password);
          } catch (e, s) {
            log('passy:passwords:set:Failed to set password entry:\n$e\n$s',
                id: id);
            return;
          }
          HistoryFile historyFile = History.fromFile(
              File(_accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator +
                  'history.enc'),
              encrypter: encrypter);
          historyFile.value.passwords[password.key] = EntryEvent(
            password.key,
            status: EntryStatus.alive,
            lastModified: DateTime.now().toUtc(),
          );
          try {
            await historyFile.save();
          } catch (e, s) {
            log('passy:passwords:set:Failed to save history:\n$e\n$s', id: id);
            return;
          }
          log(true, id: id);
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
Passy v$passyVersion
Account data v$accountVersion
Synchronization v$syncVersion''')}

Type `help` for guidance.
Type `exit` to quit.
''');
  _isInteractive = true;
  ProcessSignal.sigint.watch().listen((event) => onInterrupt());
  ProcessSignal.sigterm.watch().listen((event) => onInterrupt());
  load().then((value) {
    return startInteractive();
  });
  log('[passy]\$ ');
}
