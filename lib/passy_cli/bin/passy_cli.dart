import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypton/crypton.dart';
import 'package:passy/passy_cli/lib/common.dart' as cn;
import 'package:passy/passy_cli/lib/qr.dart' as qr;
import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_cli/lib/dart_app_data.dart';
import 'package:passy/passy_data/account_credentials.dart';
import 'package:passy/passy_data/account_settings.dart';
import 'package:passy/passy_data/common.dart' as pcommon;
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/favorites.dart';
import 'package:passy/passy_data/glare/glare_module.dart';
import 'package:passy/passy_data/glare/glare_server.dart';
import 'package:passy/passy_data/glare/line_stream_subscription.dart';
import 'package:passy/passy_data/history.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/legacy/legacy.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/passy_entries_encrypted_csv_file.dart';
import 'package:passy/passy_data/passy_entries_file_collection.dart';
import 'package:passy/passy_data/passy_entry.dart';
import 'package:passy/passy_data/passy_info.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/synchronization.dart';
import 'package:passy/passy_data/synchronization_2d0d0_modules.dart';
import 'package:passy/passy_data/autostart.dart';
import 'package:passy/passy_data/synchronization_2d0d0_utils.dart' as util;
import 'package:passy/passy_data/trusted_connection_data.dart';

const String helpMsg = '''

Passy Password Manager CLI.

Usage: passy_cli [arguments] [command]

If no command is supplied, Passy CLI starts in interactive mode.

Commands:

  General
    help [page]    Display this message.
    exit           Exit the interactive mode.
    run <file> [index]
        - Execute commands separated by newlines from file.
          Skips all commands before [index], if specified
    sleep <ms>     Pause execution for <ms> milliseconds.
    exec <command> [[arguments]]
        - Execute native command in detached mode.
    \$0             Get current executable path.
    dirname <path>
        - Remove file suffix from path.
    echo [[arguments]]
        - Print out supplied arguments.

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
    install full <path>
        - Copy all Passy CLI files to the specified path.
    install server <path> <address> <port>
        - Copy all Passy CLI files to the specified path and include a server autorun script.
          Recommended port: 5592.

    uninstall full <path>
        - Remove all Passy CLI files from the specified path.
    uninstall dir <path>
        - Recursively delete a directory.

    upgrade full <path>
        - Replace self with files from the specified path.
          CLI will exit during this process.
          If part of the `run` command, CLI will be relaunched to execute the remaining `run` commands.

  Development
    native_messaging start
        - Start in native messaging mode.

  Synchronization
    sync host classic <address> <port> <username> [detached]
        - Host the default synchronization server used in Passy.
          Can only synchronize one account.
          Supports one connection over its lifetime, stops once first synchronization is finished.
          The [detached] argument is `false` by default, if `true` then the server starts in detached mode.
    sync host 2d0d0 <address> <port> [detached]
        - Host the pure 2.0.0+ Passy synchronization server.
          Supports multiple accounts and unlimited connections over its lifetime.
          The [detached] argument is `false` by default, if `true` then the server starts in detached mode.

    sync connect classic <address> <port> <username> [detached]
        - Connect to the default synchronization server used in Passy.
          The [detached] argument is `false` by default, if `true` then the server starts in detached mode.
    sync connect 2d0d0 <address> <port> <username> <password> [detached]
        - Connect to a pure 2.0.0+ Passy synchronization server.
          The [detached] argument is `false` by default, if `true` then the server starts in detached mode.

    sync close <address>:<port>
        - Close synchronization server.
          Returns `false` if server is not running, `true` otherwise.

    sync report get <address>:<port>
        - Get synchronization report JSON for the specified server.
          Returns `false` if no report was found.
    sync report del <address>:<port>
        - Delete synchronization report for the specified server.

  Interprocess Communication
    ipc server start [save]
        - Start the default IPC server.
          Returns the server address on success, `false` otherwise.
          [save] argument:
              - `false` - default, save off.
              - `true` - saves server address as `.ipc-address` in same directory as CLI executable's.
              - Any other string is used as custom path for the save.
    ipc server connect <address>:<port>
        - Connect to a default IPC server.
          Allows sending commands to another CLI instance.
    ipc server run <address>:<port> <command>
        - Run specified command on a default IPC server.
          Disconnects when command completes.
    ipc server disconnect
        - Disconnect from an IPC server.

  Autostart
    autostart add <name> <path>
        - Add the specified path to autostart.
          Returns `true` on success.
    autostart del <name>
        - Remove path from autostart by name.
          Returns `true` on success.
''';

final List<String> upgradeCommands = [
  'sleep',
  '500',
  ';',
  'install',
  'full',
  File(Platform.resolvedExecutable).parent.path,
  ';',
  'exec',
  Platform.resolvedExecutable,
  '--no-autorun',
  'sleep',
  '500',
  ';;',
  'uninstall',
  'dir',
  '\$',
  'dirname \$ \$0 \$',
  '\$',
];

const String passyShellVersion = '2.0.0';
// Worst case scenario: all characters weigh 4 bytes and each is escaped
// (1000000/4)/2
// + minus the extra messaging space
const int maxNativeMessageLength = 120000;

bool _isBigEndian = Endian.host == Endian.big;
bool _isBusy = false;
bool _isInteractive = false;
bool _isNativeMessaging = false;
bool _stdinEchoMode = false;
bool _stdinLineMode = false;

bool _shouldMoveLine = false;
bool _logDisabled = false;
late String _passyDataPath;
late String _accountsPath;
Map<String, AccountCredentialsFile> _accounts = {};
Map<String, Encrypter> _encrypters = {};
Map<String, Encrypter> _syncEncrypters = {};
Map<String, Map<String, dynamic> Function()> _syncReportGetters = {};
Map<String, Future Function()> _syncCloseMethods = {};
String _curRunFile = '';
int _curRunIndex = 0;

Future<List<String>> parseCommand(List<String> command) async {
  List<String> parsedCommand = [];
  bool isCommand = false;
  bool insertLeft = false;
  bool insertRight = false;
  String commandWord = '';

  Future<String> _execute() async {
    String execResult = '';
    try {
      await executeCommand(
        await parseCommand(cn.parseCommand(commandWord)[0]),
        log: (object, {id}) {
          execResult += object.toString();
        },
      );
    } catch (e) {
      execResult = e.toString();
    }
    return execResult;
  }

  for (String word in command) {
    switch (word) {
      case '\$':
        if (!isCommand) {
          isCommand = true;
          continue;
        }
        String execResult = await _execute();
        if (insertLeft) {
          if (parsedCommand.isNotEmpty) {
            parsedCommand.last += execResult;
            isCommand = false;
            continue;
          }
        }
        parsedCommand.add(execResult);
        isCommand = false;
        continue;
      case '<\$':
        if (isCommand) {
          parsedCommand.add('passy:Incorrect use of the `<\$` operator.');
          continue;
        }
        insertLeft = true;
        isCommand = true;
        continue;
      case '\$>':
        if (!isCommand) {
          parsedCommand.add('passy:Incorrect use of the `\$>` operator.');
          continue;
        }
        String execResult = await _execute();
        insertRight = true;
        if (insertLeft) {
          if (parsedCommand.isNotEmpty) {
            parsedCommand.last += execResult;
            isCommand = false;
            continue;
          }
        }
        parsedCommand.add(execResult);
        isCommand = false;
        continue;
      case '\$\$':
        parsedCommand.add('\$');
        continue;
      case '<\$\$':
        parsedCommand.add('<\$');
        continue;
      case '\$\$>':
        parsedCommand.add('\$>');
        continue;
      case '&&&':
        parsedCommand.add('&&');
        continue;
      case ';;':
        parsedCommand.add(';');
        continue;
    }
    if (!isCommand) {
      if (insertRight) {
        parsedCommand.last += word;
        insertRight = false;
        continue;
      }
      parsedCommand.add(word);
      continue;
    }
    commandWord = word;
  }
  return parsedCommand;
}

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

Future<void> _autorun() async {
  File autorun = File(File(Platform.resolvedExecutable).parent.path +
      Platform.pathSeparator +
      'autorun.pcli');
  if (!await autorun.exists()) return;
  await executeCommand(['run', autorun.path]);
}

bool _isAutorunEnabled = true;
Future<void> load() async {
  _passyDataPath = await Locator.getPlatformSpecificCachePath() +
      Platform.pathSeparator +
      'Passy';
  _accountsPath = _passyDataPath + Platform.pathSeparator + 'accounts';
  refreshAccounts();
  try {
    stdin.lineMode = true;
    stdin.echoMode = true;
  } catch (_) {}
  if (_isAutorunEnabled) await _autorun();
}

Future<void> cleanup() async {
  _logDisabled = true;
  try {
    stdin.echoMode = _stdinEchoMode;
    stdin.lineMode = _stdinLineMode;
  } catch (_) {}
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
  try {
    stdin.lineMode = true;
    stdin.echoMode = true;
  } catch (_) {}
  return stdin.listen((List<int> event) async {
    _secondaryInput?.call(event);
    if (_pauseMainInput) return;
    _shouldMoveLine = false;
    String commandEncoded;
    List<List<String>> commands = [];
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
      commands.add(commandJson.map((e) => e.toString()).toList());
    } else {
      commandEncoded = utf8.decode(event);
      commandEncoded = commandEncoded.replaceAll('\n', '').replaceAll('\r', '');
      commands = cn.parseCommand(commandEncoded);
    }
    if (commands.isNotEmpty) {
      if (_isBusy) return;
      _isBusy = true;
      try {
        for (List<String> command in commands) {
          await executeCommand(command,
              id: id ?? pcommon.getPassyHash(jsonEncode(commands)).toString());
        }
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
  refreshAccounts();
  AccountCredentialsFile? _credentialsFile = _accounts[username];
  AccountCredentials? _credentials = _credentialsFile?.value;
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
      PassyInfoFile infoFile = PassyInfo.fromFile(
          File(_passyDataPath + Platform.pathSeparator + 'passy.json'));
      LoadedAccount acc = loadLegacyAccount(
          path: _accountsPath + Platform.pathSeparator + username,
          encrypter: _encrypters[username]!,
          syncEncrypter: _syncEncrypters[username]!,
          deviceId: infoFile.value.deviceId,
          credentials: _credentialsFile!)!;
      while (!acc.isRSAKeypairLoaded) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e, s) {
      return 'accounts:login:Failed to load account:\n$e\n$s';
    }
  }
  return match.toString();
}

Future<void> _ipcConnect(
  dynamic host,
  int port, {
  required void Function(Object object) log,
  List<List<String>> commandsOnJoin = const [],
}) async {
  Completer<void> onDone = Completer<void>();
  Socket clientSocket = await Socket.connect(host, port);
  LineByteStreamSubscription subscription =
      LineByteStreamSubscription(clientSocket.listen(null, onError: (e, s) {
    log('IPC server error:\n$e\n$s');
    if (!onDone.isCompleted) onDone.complete();
  }, onDone: () {
    log('IPC connection closed.');
    if (!onDone.isCompleted) onDone.complete();
  }));
  bool serverInfoReceived = false;
  subscription.onData((event) {
    String eventString = utf8.decode(event);
    if (!serverInfoReceived) {
      serverInfoReceived = true;
      log(eventString);
      if (commandsOnJoin.isNotEmpty) {
        List<String> command = commandsOnJoin.removeAt(0);
        clientSocket.writeln(jsonEncode({'command': command}));
      }
      if (_isInteractive) {
        log('\nYou\'re now executing commands remotely.\nTo log out of the IPC server, use `ipc server disconnect`.\nUsing `exit` while logged in will terminate the remote IPC server.\n\n[ipc]\$ ');
      }
      return;
    }
    Map<String, dynamic> eventJson = jsonDecode(eventString);
    String? response = eventJson['response'];
    if (response != null) log(response);
    if (eventJson['inputAvailable'] == true) {
      if (_isInteractive) log('[ipc]\$ ');
      if (commandsOnJoin.isNotEmpty) {
        List<String> command = commandsOnJoin.removeAt(0);
        if (command.join(' ') == 'ipc server disconnect') {
          _secondaryInput = null;
          onDone.complete();
          subscription.cancel();
          clientSocket.destroy();
          return;
        }
        clientSocket.writeln(jsonEncode({'command': command}));
      }
    }
  });
  _pauseMainInput = true;
  _secondaryInput = (List<int> event) async {
    if (event.isNotEmpty) {
      try {
        String command =
            utf8.decode(event).replaceAll('\n', '').replaceAll('\r', '');
        if (command == 'ipc server disconnect') {
          _secondaryInput = null;
          onDone.complete();
          subscription.cancel();
          clientSocket.destroy();
          return;
        }
        List<List<String>> commandsParsed = cn.parseCommand(command);
        for (List<String> command in commandsParsed) {
          clientSocket.writeln(jsonEncode({'command': command}));
        }
      } catch (_) {}
    }
  };
  await onDone.future;
  _secondaryInput = null;
  _pauseMainInput = false;
}

Future<File> installCLITemp({Directory? from}) async {
  from ??= File(Platform.resolvedExecutable).parent;
  File copy;
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
  copy = await pcommon.copyPassyCLI(from, Directory(copyPath));
  return copy;
}

Future<void> executeCommand(List<String> command,
    {dynamic id, void Function(Object? object, {dynamic id}) log = log}) async {
  command = await parseCommand(command);
  switch (command[0]) {
    case 'help':
      int index;
      if (command.length == 1) {
        log(helpMsg, id: id);
        return;
      } else {
        String indexString = command[1];
        try {
          index = int.parse(indexString);
        } catch (_) {
          log('passy:help:`$indexString` is not a valid integer.', id: id);
          return;
        }
      }
      List<String> helpList = helpMsg.split('\n');
      int maxIndex = (helpList.length.toDouble() / 30.toDouble()).ceil();
      if (index < 1) {
        log('passy:help:Index must be 1 or bigger.', id: id);
        return;
      }
      if (index > maxIndex) {
        log('passy:help:Maximum page index exceeded: $index > $maxIndex.',
            id: id);
        return;
      }
      int upToIndex = index * 30;
      String help = '';
      for (int i = upToIndex - 30;
          (i != upToIndex) && (i != helpList.length);
          i++) {
        help += helpList[i] + '\n';
      }
      help += '\n[Page $index/$maxIndex]';
      log(help, id: id);
      return;
    case 'exit':
      log('Have a splendid day!\n', id: id);
      cleanup();
      return;
    case 'run':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      File file = File(command[1]);
      int index;
      if (command.length == 2) {
        index = 0;
      } else {
        String indexString = command[2];
        try {
          index = int.parse(indexString);
        } catch (_) {
          log('passy:run:`$indexString` is not a valid integer.', id: id);
          return;
        }
      }
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
          if (line.isEmpty) continue;
          if (line.startsWith('//')) continue;
          commands.addAll(cn.parseCommand(line));
        }
      } catch (e, s) {
        log('passy:run:Could not parse file:\n$e\n$s', id: id);
        return;
      }
      if (index != 0) {
        if (index < commands.length) {
          commands = commands.sublist(index);
        } else {
          log('passy:run:Specified index is same as or bigger than commands length: $index >= ${commands.length}.',
              id: id);
          return;
        }
      }
      _curRunFile = file.path;
      _curRunIndex = index;
      for (List<String> command in commands) {
        _curRunIndex++;
        await executeCommand(command);
      }
      _curRunFile = '';
      _curRunIndex = 0;
      return;
    case 'sleep':
      if (command.length == 1) break;
      String msString = command[1];
      int ms;
      try {
        ms = int.parse(msString);
      } catch (_) {
        log('passy:sleep:`$msString` is not a valid integer.', id: id);
        return;
      }
      await Future.delayed(Duration(milliseconds: ms));
      return;
    case 'exec':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      String program = command[1];
      List<String> args;
      if (command.length == 2) {
        args = [];
      } else {
        args = command.sublist(2);
      }
      await Process.start(program, args, mode: ProcessStartMode.detached);
      return;
    case '\$0':
      log(Platform.resolvedExecutable, id: id);
      return;
    case 'dirname':
      if (command.length == 1) break;
      File file = File(command[1]);
      try {
        if (await file.exists()) {
          log(file.parent.path, id: id);
          return;
        }
        log('.', id: id);
      } catch (_) {
        log('.', id: id);
      }
      return;
    case 'echo':
      if (command.length == 1) break;
      log(command.sublist(1).join(' '), id: id);
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
                log('passy:sync:host:classic:No account credentials provided, please use `accounts login` first.',
                    id: id);
                return;
              }
              String host = command[3];
              if (_isNativeMessaging) {
                host = await pcommon.getInternetAddress();
              } else if (host == '0') {
                host = await pcommon.getInternetAddress();
              }
              String portString = command[4];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:sync:host:classic:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:sync:host:classic:Port must be 0 or bigger.',
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
                  log('passy:sync:host:classic:`$detachedString` is not a valid boolean.',
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
                settings: settings,
                rsaKeypair: settings.value.rsaKeypair!,
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
                log('passy:sync:host:classic:Server failed to start, unknown error.',
                    id: id);
                return;
              }
              String fullAddr = '${addr.ip.address}:${addr.port}';
              _syncReportGetters[fullAddr] = () {
                return {
                  'command': 'host',
                  'mode': 'classic',
                  ...server.getReport().toJson(),
                };
              };
              _syncCloseMethods[fullAddr] = server.close;
              if (detached) {
                log(fullAddr, id: id);
                return;
              }
              log(qr.generate(fullAddr, typeNumber: 2, small: true));
              log('Server started, running at `$fullAddr`.', id: id);
              log('Hotkeys | `c` - close server | `d` - detach', id: id);
              _pauseMainInput = true;
              stdin.lineMode = false;
              stdin.echoMode = false;
              void syncServerCli(List<int> event) async {
                String command = utf8.decode(event);
                if (command == 'c') {
                  _secondaryInput = null;
                  log('Server close requested.', id: id);
                  server.close();
                  return;
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
            case '2d0d0':
              if (command.length < 5) break;
              String host = command[3];
              if (_isNativeMessaging) {
                host = await pcommon.getInternetAddress();
              } else if (host == '0') {
                host = await pcommon.getInternetAddress();
              }
              String portString = command[4];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:sync:host:2d0d0:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:sync:host:2d0d0:Port must be 0 or bigger.', id: id);
                return;
              }
              Completer<void> onStop = Completer<void>();
              bool detached;
              if (command.length < 6) {
                detached = false;
              } else {
                String detachedString = command[5];
                try {
                  detached = pcommon.boolFromString(detachedString)!;
                } catch (_) {
                  log('passy:sync:host:2d0d0:`$detachedString` is not a valid boolean.',
                      id: id);
                  return;
                }
              }
              Map<String, GlareModule> loadedModules = {};
              for (MapEntry<String, Encrypter> encrypterEntry
                  in _encrypters.entries) {
                String username = encrypterEntry.key;
                String accPath = _accountsPath +
                    Platform.pathSeparator +
                    username +
                    Platform.pathSeparator;
                Encrypter encrypter = encrypterEntry.value;
                Encrypter syncEncrypter = _syncEncrypters[encrypterEntry.key]!;
                Map<String, GlareModule> syncModules =
                    buildSynchronization2d0d0Modules(
                  username: username,
                  passyEntries: FullPassyEntriesFileCollection(
                    idCards: IDCards.fromFile(File('${accPath}idCards.enc'),
                        encrypter: encrypter),
                    identities: Identities.fromFile(
                        File('${accPath}identities.enc'),
                        encrypter: encrypter),
                    notes: Notes.fromFile(File('${accPath}notes.enc'),
                        encrypter: encrypter),
                    passwords: Passwords.fromFile(
                        File('${accPath}passwords.enc'),
                        encrypter: encrypter),
                    paymentCards: PaymentCards.fromFile(
                        File('${accPath}paymentCards.enc'),
                        encrypter: encrypter),
                  ),
                  encrypter: syncEncrypter,
                  history: History.fromFile(File('${accPath}history.enc'),
                      encrypter: encrypter),
                  favorites: Favorites.fromFile(File('${accPath}favorites.enc'),
                      encrypter: encrypter),
                  settings: AccountSettings.fromFile(
                      File('${accPath}settings.enc'),
                      encrypter: encrypter),
                );
                for (MapEntry<String, GlareModule> module
                    in syncModules.entries) {
                  loadedModules['${module.key}_$username'] = module.value;
                }
              }
              GlareServer glareHost = await GlareServer.bind(
                maxBindTries: 0,
                address: host,
                port: port,
                keypair: RSAKeypair.fromRandom(keySize: 4096),
                modules: {
                  ...loadedModules,
                  'authenticate': GlareModule(
                    name: 'authenticate',
                    target: (args, {required addModule}) async {
                      if (args.length < 5) {
                        throw {
                          'error': {'type': 'Missing arguments'},
                        };
                      }
                      dynamic username = args[3];
                      dynamic auth = args[4];
                      if (username is! String) {
                        throw {
                          'error': {'type': 'Username is not of type String'},
                        };
                      }
                      if (auth is! String) {
                        throw {
                          'error': {'type': 'Auth is not of type String'},
                        };
                      }
                      Encrypter? encrypter = _syncEncrypters[username];
                      if (encrypter == null) {
                        return {
                          'error': {'type': 'Failed to authenticate'},
                        };
                      }
                      Encrypter usernameEncrypter =
                          pcommon.getPassyEncrypter(username);
                      try {
                        util.verifyAuth(auth,
                            encrypter: encrypter,
                            usernameEncrypter: usernameEncrypter,
                            withIV: true);
                      } catch (_) {
                        return {
                          'error': {'type': 'Failed to authenticate'},
                        };
                      }
                      return {
                        'status': {'type': 'Success'},
                        'auth': util.generateAuth(
                            encrypter: encrypter,
                            usernameEncrypter: usernameEncrypter,
                            withIV: true),
                      };
                    },
                  ),
                  'login': GlareModule(
                    name: 'login',
                    target: (args, {required addModule}) async {
                      if (args.length < 5) {
                        throw {
                          'error': {'type': 'Missing arguments'},
                        };
                      }
                      dynamic username = args[3];
                      dynamic password = args[4];
                      if (username is! String) {
                        throw {
                          'error': {'type': 'Username is not of type String'},
                        };
                      }
                      if (password is! String) {
                        throw {
                          'error': {'type': 'Password is not of type String'},
                        };
                      }
                      if (loadedModules.containsKey('2d0d1_$username')) {
                        AccountCredentialsFile creds = _accounts[username]!;
                        if (creds.value.passwordHash ==
                            (await cn.getPasswordHash(password,
                                    derivationType:
                                        creds.value.keyDerivationType,
                                    derivationInfo:
                                        creds.value.keyDerivationInfo))
                                .toString()) {
                          return {
                            'status': {'type': 'Success'},
                          };
                        }
                        return {
                          'error': {'type': 'Failed to login'},
                        };
                      }
                      String result = await _login(username, password);
                      if (result != 'true') {
                        return {
                          'error': {'type': 'Failed to login'},
                        };
                      }
                      Encrypter encrypter = _encrypters[username]!;
                      Encrypter syncEncrypter = _syncEncrypters[username]!;
                      String accPath = _accountsPath +
                          Platform.pathSeparator +
                          username +
                          Platform.pathSeparator;
                      Map<String, GlareModule> syncModules =
                          buildSynchronization2d0d0Modules(
                        username: username,
                        passyEntries: FullPassyEntriesFileCollection(
                          idCards: IDCards.fromFile(
                              File('${accPath}idCards.enc'),
                              encrypter: encrypter),
                          identities: Identities.fromFile(
                              File('${accPath}identities.enc'),
                              encrypter: encrypter),
                          notes: Notes.fromFile(File('${accPath}notes.enc'),
                              encrypter: encrypter),
                          passwords: Passwords.fromFile(
                              File('${accPath}passwords.enc'),
                              encrypter: encrypter),
                          paymentCards: PaymentCards.fromFile(
                              File('${accPath}paymentCards.enc'),
                              encrypter: encrypter),
                        ),
                        encrypter: syncEncrypter,
                        history: History.fromFile(File('${accPath}history.enc'),
                            encrypter: encrypter),
                        favorites: Favorites.fromFile(
                            File('${accPath}favorites.enc'),
                            encrypter: encrypter),
                        settings: AccountSettings.fromFile(
                            File('${accPath}settings.enc'),
                            encrypter: encrypter),
                      );
                      for (MapEntry<String, GlareModule> module
                          in syncModules.entries) {
                        loadedModules['${module.key}_$username'] = module.value;
                        addModule('${module.key}_$username', module.value);
                      }
                      return {
                        'status': {'type': 'Success'},
                      };
                    },
                  ),
                  'getDeviceId': GlareModule(
                    name: 'getDeviceId',
                    target: (args, {required addModule}) async {
                      PassyInfoFile infoFile = PassyInfo.fromFile(File(
                          _passyDataPath +
                              Platform.pathSeparator +
                              'passy.json'));
                      if (infoFile.value.deviceId.isEmpty) {
                        Random random = Random.secure();
                        infoFile.value.deviceId =
                            '${DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c')}-${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}';
                        await infoFile.save();
                      }
                      return {
                        'hostDeviceId': infoFile.value.deviceId,
                      };
                    },
                  ),
                  'getTrustedConnection': GlareModule(
                    name: 'getTrustedConnection',
                    target: (args, {required addModule}) async {
                      if (args.length < 5) {
                        throw {
                          'error': {'type': 'Missing arguments'},
                        };
                      }
                      dynamic username = args[3];
                      dynamic deviceId = args[4];
                      if (username is! String) {
                        throw {
                          'error': {'type': 'Username is not of type String'},
                        };
                      }
                      if (deviceId is! String) {
                        throw {
                          'error': {'type': 'Device id is not of type String'},
                        };
                      }
                      if (deviceId.length < 16) {
                        throw {
                          'error': {'type': 'Invalid device id'},
                        };
                      }
                      PassyInfoFile infoFile = PassyInfo.fromFile(File(
                          _passyDataPath +
                              Platform.pathSeparator +
                              'passy.json'));
                      if (infoFile.value.deviceId.isEmpty) {
                        Random random = Random.secure();
                        infoFile.value.deviceId =
                            '${DateTime.now().toUtc().toIso8601String().replaceAll(':', 'c')}-${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}${random.nextInt(9)}';
                        await infoFile.save();
                      }
                      File hashFile = File(_accountsPath +
                          Platform.pathSeparator +
                          username +
                          Platform.pathSeparator +
                          'trusted_connections' +
                          Platform.pathSeparator +
                          '${infoFile.value.deviceId}--$deviceId');
                      String? fileData;
                      if (await hashFile.exists()) {
                        fileData = await hashFile.readAsString();
                      }
                      return {
                        'hostDeviceId': infoFile.value.deviceId,
                        'connectionData': fileData,
                      };
                    },
                  ),
                  'setTrustedConnection': GlareModule(
                    name: 'setTrustedConnection',
                    target: (args, {required addModule}) async {
                      if (args.length < 7) {
                        throw {
                          'error': {'type': 'Missing arguments'},
                        };
                      }
                      dynamic username = args[3];
                      dynamic deviceId = args[4];
                      dynamic auth = args[5];
                      dynamic connectionData = args[6];
                      if (username is! String) {
                        throw {
                          'error': {'type': 'Username is not of type String'},
                        };
                      }
                      if (deviceId is! String) {
                        throw {
                          'error': {'type': 'Device id is not of type String'},
                        };
                      }
                      if (auth is! String) {
                        throw {
                          'error': {'type': 'Auth is not of type String'},
                        };
                      }
                      if (connectionData is! String) {
                        throw {
                          'error': {
                            'type': 'Connection data is not of type String'
                          },
                        };
                      }
                      if (deviceId.length < 16) {
                        throw {
                          'error': {'type': 'Invalid device id'},
                        };
                      }
                      Encrypter? encrypter = _syncEncrypters[username];
                      Encrypter usernameEncrypter =
                          pcommon.getPassyEncrypter(username);
                      if (encrypter == null) {
                        return {
                          'error': {'type': 'Failed to authenticate'},
                        };
                      }
                      try {
                        util.verifyAuth(auth,
                            encrypter: encrypter,
                            usernameEncrypter: usernameEncrypter,
                            withIV: true);
                      } catch (_) {
                        return {
                          'error': {'type': 'Failed to authenticate'},
                        };
                      }
                      PassyInfoFile infoFile = PassyInfo.fromFile(File(
                          _passyDataPath +
                              Platform.pathSeparator +
                              'passy.json'));
                      File hashFile = File(_accountsPath +
                          Platform.pathSeparator +
                          username +
                          Platform.pathSeparator +
                          'trusted_connections' +
                          Platform.pathSeparator +
                          '${infoFile.value.deviceId}--$deviceId');
                      TrustedConnectionData connectionDataDecrypted =
                          TrustedConnectionData.fromEncrypted(
                              data: connectionData, encrypter: encrypter);
                      connectionDataDecrypted.version = connectionDataDecrypted
                          .version
                          .add(const Duration(milliseconds: 1));
                      if (!await hashFile.exists()) {
                        await hashFile.create(recursive: true);
                      }
                      await hashFile.writeAsString(
                          connectionDataDecrypted.toEncrypted(encrypter));
                      return {
                        'status': {'type': 'Success'},
                      };
                    },
                  ),
                },
                serviceInfo:
                    'Passy cross-platform password manager dedicated entry synchronization server v${pcommon.syncVersion}',
              );
              _syncCloseMethods['$host:$port'] = () async {
                await glareHost.stop();
                onStop.complete();
              };
              if (!detached) {
                await onStop.future;
              }
              log('$host:$port');
              return;
          }
          break;
        case 'connect':
          if (command.length == 2) break;
          switch (command[2]) {
            case 'classic':
              if (command.length == 5) break;
              String accountName = command[5];
              Encrypter? encrypter = _encrypters[accountName];
              Encrypter? syncEncrypter = _syncEncrypters[accountName];
              if (encrypter == null || syncEncrypter == null) {
                log('passy:sync:connect:classic:No account credentials provided, please use `accounts login` first.',
                    id: id);
                return;
              }
              String portString = command[4];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:sync:connect:classic:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:sync:connect:classic:Port must be 0 or bigger.',
                    id: id);
                return;
              }
              String hostString = command[3];
              HostAddress host;
              try {
                InternetAddress addr = InternetAddress(hostString);
                host = HostAddress(addr, port);
              } catch (e) {
                log('passy:sync:connect:classic:`$hostString` is not a valid address:$e',
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
                  log('passy:sync:connect:classic:`$detachedString` is not a valid boolean.',
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
                settings: settings,
                rsaKeypair: settings.value.rsaKeypair!,
                onError: (err) {
                  if (detached) return;
                  log('Synchronization error:', id: id);
                  log(err, id: id);
                },
                onComplete: (p0) {
                  syncCompleter.complete();
                  if (detached) return;
                  log('Synchronization client stopped.', id: id);
                  log('Entries set: ${serverNullable!.entriesAdded}', id: id);
                  log('Entries removed: ${serverNullable.entriesRemoved}',
                      id: id);
                },
              );
              Synchronization server = serverNullable;
              String fullAddr = '${host.ip.address}:${host.port}';
              _syncReportGetters[fullAddr] = () {
                return {
                  'command': 'connect',
                  'mode': 'classic',
                  ...server.getReport().toJson(),
                };
              };
              if (detached) {
                server.connect(host);
                log(fullAddr, id: id);
                return;
              } else {
                await server.connect(host);
                log('', id: id);
              }
              return;
            case '2d0d0':
              if (command.length == 6) break;
              Synchronization? serverNullable;
              String portString = command[4];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:sync:connect:2d0d0:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:sync:connect:2d0d0:Port must be 0 or bigger.',
                    id: id);
                return;
              }
              String hostString = command[3];
              HostAddress host;
              try {
                InternetAddress addr = InternetAddress(hostString);
                host = HostAddress(addr, port);
              } catch (e) {
                log('passy:sync:connect:2d0d0:`$hostString` is not a valid address:$e',
                    id: id);
                return;
              }
              bool detached;
              if (command.length < 8) {
                detached = false;
              } else {
                String detachedString = command[7];
                try {
                  detached = pcommon.boolFromString(detachedString)!;
                } catch (_) {
                  log('passy:sync:connect:2d0d0:`$detachedString` is not a valid boolean.',
                      id: id);
                  return;
                }
              }
              String accountName = command[5];
              String password = command[6];
              Encrypter? encrypter = _encrypters[accountName];
              if (encrypter == null) {
                String loginResponse = await _login(accountName, password);
                if (loginResponse != 'true') {
                  log('passy:sync:connect:2d0d0:Failed to login:$loginResponse',
                      id: id);
                  return;
                }
                encrypter = _encrypters[accountName]!;
              }
              Encrypter syncEncrypter = _syncEncrypters[accountName]!;
              String accPath = _accountsPath +
                  Platform.pathSeparator +
                  accountName +
                  Platform.pathSeparator;
              AccountSettingsFile settings = AccountSettings.fromFile(
                  File('${accPath}settings.enc'),
                  encrypter: encrypter);
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
                settings: settings,
                rsaKeypair: settings.value.rsaKeypair!,
                onError: (err) {
                  if (detached) return;
                  log('Synchronization error:', id: id);
                  log(err, id: id);
                },
                onComplete: (p0) {
                  if (detached) return;
                  log('Synchronization client stopped.', id: id);
                  log('Entries set: ${serverNullable!.entriesAdded}', id: id);
                  log('Entries removed: ${serverNullable.entriesRemoved}',
                      id: id);
                },
              );
              Synchronization client = serverNullable;
              String fullAddr = '${host.ip.address}:${host.port}';
              _syncReportGetters[fullAddr] = () {
                return {
                  'command': 'connect',
                  'mode': '2d0d0',
                  ...client.getReport().toJson(),
                };
              };
              PassyInfoFile infoFile = PassyInfo.fromFile(
                  File(_passyDataPath + Platform.pathSeparator + 'passy.json'));
              if (detached) {
                client.connect2d0d0(host,
                    password: password,
                    deviceId: infoFile.value.deviceId,
                    verifyTrustedConnectionData: true,
                    trustedConnectionsDir:
                        Directory('${accPath}trusted_connections'));
                log(fullAddr, id: id);
              } else {
                await client.connect2d0d0(host,
                    password: password,
                    deviceId: infoFile.value.deviceId,
                    verifyTrustedConnectionData: true,
                    trustedConnectionsDir:
                        Directory('${accPath}trusted_connections'));
              }
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
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      switch (command[1]) {
        case 'temp':
          File copy;
          try {
            copy = await installCLITemp();
          } catch (e, s) {
            log('passy:install:temp:Failed to install executable:\n$e\n$s',
                id: id);
            return;
          }
          log(copy.path, id: id);
          return;
        case 'full':
          if (command.length == 2) break;
          String installPath = command[2];
          File exe;
          try {
            exe = await pcommon.copyPassyCLI(
                File(Platform.resolvedExecutable).parent,
                Directory(installPath));
          } catch (e, s) {
            log('passy:install:full:Failed to install executable:\n$e\n$s',
                id: id);
            return;
          }
          log(exe.path, id: id);
          return;
        case 'server':
          if (command.length < 5) break;
          String address = command[3];
          String portString = command[4];
          int port;
          try {
            port = int.parse(portString);
          } catch (_) {
            log('passy:install:server:`$portString` is not a valid integer.',
                id: id);
            return;
          }
          if (port < 0) {
            log('passy:install:server:Port must be 0 or bigger.', id: id);
            return;
          }
          String path = command[2];
          File exeFile;
          try {
            exeFile = await pcommon.copyPassyCLIServer(
              from: File(Platform.resolvedExecutable).parent,
              to: Directory(path),
              address: address,
              port: port,
            );
          } catch (e, s) {
            log('passy:install:server:Failed to install executable:\n$e\n$s',
                id: id);
            return;
          }
          log(exeFile.path, id: id);
          return;
      }
      break;
    case 'uninstall':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      switch (command[1]) {
        case 'full':
          if (command.length == 2) break;
          Directory installPath = Directory(command[2]);
          try {
            await pcommon.removePassyCLI(installPath);
          } catch (e, s) {
            log('passy:uninstall:full:Failed to uninstall:\n$e\n$s');
          }
          log('true', id: id);
          return;
        case 'dir':
          if (command.length == 2) break;
          Directory installPath = Directory(command[2]);
          try {
            await installPath.delete(recursive: true);
          } catch (e, s) {
            log('passy:uninstall:dir:Failed to uninstall:\n$e\n$s');
            return;
          }
          log('true', id: id);
          return;
      }
      break;
    case 'upgrade':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      switch (command[1]) {
        case 'full':
          if (command.length == 2) break;
          File copy;
          try {
            copy = await installCLITemp(from: Directory(command[2]));
          } catch (e, s) {
            log('passy:upgrade:full:Failed to install executable:\n$e\n$s',
                id: id);
            return;
          }
          await Process.start(
              copy.path,
              [
                ...upgradeCommands,
                if (_curRunFile.isNotEmpty) ...[
                  ';;',
                  'run',
                  _curRunFile,
                  _curRunIndex.toString(),
                ],
              ],
              mode: ProcessStartMode.detached);
          log(copy.path + '\n', id: id);
          cleanup();
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
    case 'ipc':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      switch (command[1]) {
        case 'server':
          if (command.length == 2) break;
          switch (command[2]) {
            case 'start':
              File? save;
              if (command.length == 3) {
                save = null;
              } else {
                String detachedString = command[3];
                try {
                  if (pcommon.boolFromString(detachedString)!) {
                    save = File(File(Platform.resolvedExecutable).parent.path +
                        Platform.pathSeparator +
                        '.ipc-address');
                  }
                } catch (_) {
                  save = File(detachedString);
                }
              }
              ServerSocket serverSocket =
                  await ServerSocket.bind('127.0.0.1', 0);
              serverSocket.listen((Socket socket) {
                socket.done.catchError((Object error) {});
                LineByteStreamSubscription subscription =
                    LineByteStreamSubscription(
                        socket.listen(null, onError: (Object error) {}));
                subscription.onData((event) async {
                  void ipcLog(Object? object, {dynamic id}) {
                    try {
                      socket.writeln(jsonEncode({
                        'inputAvailable': _secondaryInput != null,
                        'response': object.toString(),
                      }));
                    } catch (_) {}
                  }

                  String eventString;
                  try {
                    eventString = utf8.decode(event);
                  } catch (e) {
                    ipcLog('IPC:Could not decode command string.');
                    return;
                  }
                  Map<String, dynamic> eventJson;
                  try {
                    eventJson = jsonDecode(eventString);
                  } catch (e) {
                    ipcLog('IPC:Could not decode command JSON.');
                    return;
                  }
                  dynamic ipcCommand = eventJson['command'];
                  if (ipcCommand is! List<dynamic>) {
                    socket.writeln(jsonEncode({'inputAvailable': true}));
                    return;
                  }
                  ipcCommand =
                      ipcCommand.map<String>((e) => e.toString()).toList();
                  _secondaryInput?.call(utf8.encode(ipcCommand.join(' ')));
                  if (_pauseMainInput) return;
                  if (ipcCommand.isEmpty) {
                    socket.writeln(jsonEncode({'inputAvailable': true}));
                    return;
                  }
                  await executeCommand(ipcCommand as List<String>, log: ipcLog);
                  socket.writeln(jsonEncode({'inputAvailable': true}));
                });
                socket
                    .writeln('Passy CLI Shell v$passyShellVersion IPC server.');
              }, onError: (Object error) => {});
              if (save != null) {
                try {
                  await save.writeAsString(
                      "${serverSocket.address.address}:${serverSocket.port}");
                } catch (e, s) {
                  log('passy:ipc:server:start:Failed to save to file:\n$e\n$s',
                      id: id);
                  try {
                    await serverSocket.close();
                  } catch (_) {}
                  return;
                }
              }
              log("${serverSocket.address.address}:${serverSocket.port}",
                  id: id);
              return;
            case 'connect':
              if (command.length == 3) break;
              List<String> arg4 = command[3].split(':');
              if (arg4.length < 2) {
                log('passy:ipc:server:connect:Invalid address provided.',
                    id: id);
                return;
              }
              String host = arg4.first;
              String portString = arg4[1];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:ipc:server:connect:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:ipc:server:connect:Port must be 0 or bigger.',
                    id: id);
                return;
              }
              try {
                await _ipcConnect(host, port,
                    log: (object) => log(object, id: id));
              } catch (e, s) {
                log('passy:ipc:server:connect:Failed to connect to IPC server:\n$e\n$s');
                return;
              }
              return;
            case 'run':
              if (command.length < 5) break;
              List<String> arg4 = command[3].split(':');
              if (arg4.length < 2) {
                log('passy:ipc:server:run:Invalid address provided.', id: id);
                return;
              }
              String host = arg4.first;
              String portString = arg4[1];
              int port;
              try {
                port = int.parse(portString);
              } catch (_) {
                log('passy:ipc:server:run:`$portString` is not a valid integer.',
                    id: id);
                return;
              }
              if (port < 0) {
                log('passy:ipc:server:run:Port must be 0 or bigger.', id: id);
                return;
              }
              try {
                await _ipcConnect(host, port,
                    log: (object) => log(object, id: id),
                    commandsOnJoin: [
                      command.sublist(4),
                      ['ipc', 'server', 'disconnect'],
                    ]);
              } catch (e, s) {
                log('passy:ipc:server:run:Failed to connect to IPC server:\n$e\n$s');
                return;
              }
              return;
          }
          break;
      }
      break;
    case 'autostart':
      if (_isNativeMessaging) break;
      if (command.length == 1) break;
      switch (command[1]) {
        case 'add':
          if (command.length < 4) break;
          String name = command[2];
          String path = command[3];
          Autostart autostart = Autostart()
            ..setup(appName: name, appPath: path);
          try {
            await autostart.enable();
          } catch (e, s) {
            log('passy:autostart:add:Failed to enable autostart:\n$e\n$s');
            return;
          }
          log('true');
          return;
        case 'del':
          if (command.length == 2) break;
          String name = command[2];
          Autostart autostart = Autostart()..setup(appName: name, appPath: '');
          try {
            await autostart.disable();
          } catch (e, s) {
            log('passy:autostart:del:Failed to disable autostart:\n$e\n$s');
            return;
          }
          log('true');
          return;
      }
      break;
  }
  if (_isNativeMessaging) return;
  log('passy:Unknown command:${command.join(' ')}.', id: id);
  if (!_isInteractive) log('Use `help` for guidance.', id: id);
}

void main(List<String> arguments) {
  try {
    _stdinEchoMode = stdin.echoMode;
    _stdinLineMode = stdin.lineMode;
  } catch (_) {}
  List<String> args = List<String>.from(arguments);
  if (args.isNotEmpty) {
    if (args.first == '--no-autorun') {
      _isAutorunEnabled = false;
      args.removeAt(0);
    }
  }
  if (args.isNotEmpty) {
    List<List<String>> commands = [[]];
    int commandsIndex = 0;
    for (String arg in args) {
      switch (arg) {
        case ';':
          commands.add([]);
          commandsIndex++;
          continue;
        case '&&':
          commands.add([]);
          commandsIndex++;
          continue;
      }
      commands[commandsIndex].add(arg);
    }
    load().then((value) async {
      for (List<String> command in commands) {
        await executeCommand(command);
      }
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
${cn.getBoxMessage('''

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
    log('[passy]\$ ');
    return startInteractive();
  });
}
