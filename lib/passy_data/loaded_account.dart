import 'dart:async';
import 'dart:convert';

import 'package:compute/compute.dart';
import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'package:kdbx/kdbx.dart';
import 'package:passy/passy_data/argon2_info.dart';
import 'package:passy/passy_data/custom_field.dart';
import 'package:passy/passy_data/json_file.dart';
import 'package:passy/passy_data/local_settings.dart';
import 'package:passy/passy_data/passy_entires_json_file.dart';
import 'package:passy/passy_data/passy_entries_file_collection.dart';
import 'package:archive/archive_io.dart';
import 'package:passy/passy_data/tfa.dart';
import 'dart:io';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'auto_backup_settings.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'favorites.dart';
import 'glare/glare_client.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'key_derivation_info.dart';
import 'key_derivation_type.dart';
import 'note.dart';
import 'password.dart';
import 'passy_entries.dart';
import 'passy_entry.dart';
import 'payment_card.dart';
import 'sync_2d0d0_server_info.dart';
import 'synchronization.dart';

class LoadedAccount {
  Encrypter _encrypter;
  Encrypter _syncEncrypter;
  final String _deviceId;
  final File _versionFile;
  final AccountCredentialsFile _credentials;
  final LocalSettingsFile _localSettings;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final FavoritesFile _favorites;
  final PasswordsFile _passwords;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;
  Completer<void>? _autoSyncCompleter;
  final Map<String, Sync2d0d0ServerInfo> _serversToTrust = {};
  final Map<String, Completer<void>> _serversToTrustCompleters = {};
  final Map<DateTime, String> _synchronizationLogs = {};

  LoadedAccount({
    required Encrypter encrypter,
    required Encrypter syncEncrypter,
    required String deviceId,
    required File versionFile,
    required AccountCredentialsFile credentials,
    required LocalSettingsFile localSettings,
    required AccountSettingsFile settings,
    required HistoryFile history,
    required FavoritesFile favorites,
    required PasswordsFile passwords,
    required NotesFile notes,
    required PaymentCardsFile paymentCards,
    required IDCardsFile idCards,
    required IdentitiesFile identities,
  })  : _deviceId = deviceId,
        _encrypter = encrypter,
        _syncEncrypter = syncEncrypter,
        _versionFile = versionFile,
        _credentials = credentials,
        _localSettings = localSettings,
        _settings = settings,
        _history = history,
        _favorites = favorites,
        _passwords = passwords,
        _notes = notes,
        _paymentCards = paymentCards,
        _idCards = idCards,
        _identities = identities {
    Future(() async {
      if (_settings.value.rsaKeypair == null) {
        RSAKeypair keypair = await compute(
            (message) => RSAKeypair.fromRandom(keySize: 4096), null);
        _settings.value.rsaKeypair = keypair;
        await _settings.save();
      }
    });
    bool shouldSaveHistory = false;
    {
      List<String> passwordKeys = this.passwordKeys;
      for (EntryEvent value in _history.value.passwords.values) {
        if (value.status == EntryStatus.removed) continue;
        if (passwordKeys.contains(value.key)) continue;
        value.status = EntryStatus.removed;
        shouldSaveHistory = true;
      }
    }
    {
      List<String> paymentCardKeys = this.paymentCardKeys;
      for (EntryEvent value in _history.value.paymentCards.values) {
        if (value.status == EntryStatus.removed) continue;
        if (paymentCardKeys.contains(value.key)) continue;
        value.status = EntryStatus.removed;
        shouldSaveHistory = true;
      }
    }
    {
      List<String> notesKeys = this.notesKeys;
      for (EntryEvent value in _history.value.notes.values) {
        if (value.status == EntryStatus.removed) continue;
        if (notesKeys.contains(value.key)) continue;
        value.status = EntryStatus.removed;
        shouldSaveHistory = true;
      }
    }
    {
      List<String> idCardsKeys = this.idCardsKeys;
      for (EntryEvent value in _history.value.idCards.values) {
        if (value.status == EntryStatus.removed) continue;
        if (idCardsKeys.contains(value.key)) continue;
        value.status = EntryStatus.removed;
        shouldSaveHistory = true;
      }
    }
    {
      List<String> identitiesKeys = this.identitiesKeys;
      for (EntryEvent value in _history.value.identities.values) {
        if (value.status == EntryStatus.removed) continue;
        if (identitiesKeys.contains(value.key)) continue;
        value.status = EntryStatus.removed;
        shouldSaveHistory = true;
      }
    }
    if (shouldSaveHistory) _history.saveSync();
  }

  factory LoadedAccount.fromDirectory({
    required String path,
    required Encrypter encrypter,
    required Encrypter syncEncrypter,
    required String deviceId,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    AccountSettingsFile? settings,
    HistoryFile? history,
    FavoritesFile? favorites,
    PasswordsFile? passwords,
    NotesFile? notes,
    PaymentCardsFile? paymentCards,
    IDCardsFile? idCards,
    IdentitiesFile? identities,
  }) {
    versionFile ??= File(path + Platform.pathSeparator + 'version.txt');
    credentials ??= AccountCredentials.fromFile(
        File(path + Platform.pathSeparator + 'credentials.json'));
    localSettings ??= LocalSettings.fromFile(
        File(path + Platform.pathSeparator + 'local_settings.json'));
    settings ??= AccountSettings.fromFile(
        File(path + Platform.pathSeparator + 'settings.enc'),
        encrypter: encrypter);
    history ??= History.fromFile(
        File(path + Platform.pathSeparator + 'history.enc'),
        encrypter: encrypter);
    favorites ??= Favorites.fromFile(
        File(path + Platform.pathSeparator + 'favorites.enc'),
        encrypter: encrypter);
    passwords ??= Passwords.fromFile(
        File(path + Platform.pathSeparator + 'passwords.enc'),
        encrypter: encrypter);
    notes ??= Notes.fromFile(File(path + Platform.pathSeparator + 'notes.enc'),
        encrypter: encrypter);
    paymentCards ??= PaymentCards.fromFile(
        File(path + Platform.pathSeparator + 'payment_cards.enc'),
        encrypter: encrypter);
    idCards ??= IDCards.fromFile(
        File(path + Platform.pathSeparator + 'id_cards.enc'),
        encrypter: encrypter);
    identities ??= Identities.fromFile(
        File(path + Platform.pathSeparator + 'identities.enc'),
        encrypter: encrypter);
    return LoadedAccount(
        encrypter: encrypter,
        syncEncrypter: syncEncrypter,
        deviceId: deviceId,
        versionFile: versionFile,
        credentials: credentials,
        localSettings: localSettings,
        settings: settings,
        history: history,
        favorites: favorites,
        passwords: passwords,
        notes: notes,
        paymentCards: paymentCards,
        idCards: idCards,
        identities: identities);
  }

  Future<void> setAccountPassword(
    String password, {
    bool doNotReencryptEntries = false,
    KeyDerivationType? derivationType,
    KeyDerivationInfo? derivationInfo,
  }) async {
    if (derivationType != null) {
      _credentials.value.keyDerivationType = derivationType;
      _credentials.value.keyDerivationInfo = derivationInfo;
    }
    _credentials.value.passwordHash = (await getPasswordHash(
      password,
      derivationType: _credentials.value.keyDerivationType,
      derivationInfo: _credentials.value.keyDerivationInfo,
    ))
        .toString();
    await _credentials.save();
    Encrypter oldEncrypter = _encrypter;
    _encrypter = await getPasswordEncrypter(
      password,
      derivationType: _credentials.value.keyDerivationType,
      derivationInfo: _credentials.value.keyDerivationInfo,
    );
    _syncEncrypter = await getSyncEncrypter(
      password,
      derivationType: _credentials.value.keyDerivationType,
      derivationInfo: _credentials.value.keyDerivationInfo,
    );
    await _settings.reload();
    _settings.encrypter = _encrypter;
    await _settings.save();
    await _history.reload();
    _history.encrypter = _encrypter;
    await _history.save();
    await _favorites.reload();
    _favorites.encrypter = _encrypter;
    await _favorites.save();
    if (doNotReencryptEntries) {
      _passwords.encrypter = _encrypter;
      _notes.encrypter = _encrypter;
      _paymentCards.encrypter = _encrypter;
      _idCards.encrypter = _encrypter;
      _identities.encrypter = _encrypter;
      return;
    }
    await _passwords.setEncrypter(_encrypter, oldEncrypter: oldEncrypter);
    await _notes.setEncrypter(_encrypter, oldEncrypter: oldEncrypter);
    await _paymentCards.setEncrypter(_encrypter, oldEncrypter: oldEncrypter);
    await _idCards.setEncrypter(_encrypter, oldEncrypter: oldEncrypter);
    await _identities.setEncrypter(_encrypter, oldEncrypter: oldEncrypter);
  }

  KeyDerivationType get keyDerivationType =>
      _credentials.value.keyDerivationType;

  KeyDerivationInfo? get keyDerivationInfo {
    KeyDerivationType type = _credentials.value.keyDerivationType;
    switch (type) {
      case KeyDerivationType.none:
        return null;
      case KeyDerivationType.argon2:
        Argon2Info info = _credentials.value.keyDerivationInfo as Argon2Info;
        return Argon2Info(
          salt: info.salt,
          parallelism: info.parallelism,
          memory: info.memory,
          iterations: info.iterations,
        );
    }
  }

  Future<void> save() => Future.wait([
        _versionFile.writeAsString(accountVersion),
        _credentials.save(),
        _localSettings.save(),
        _settings.save(),
        _history.save(),
        _favorites.save(),
      ]);

  void saveSync() {
    _versionFile.writeAsStringSync(accountVersion);
    _credentials.saveSync();
    _localSettings.saveSync();
    _settings.saveSync();
    _history.saveSync();
    _favorites.saveSync();
  }

  Synchronization? getSynchronization({
    void Function()? onConnected,
    void Function(SynchronizationResults results)? onComplete,
    void Function(String log)? onError,
  }) {
    RSAKeypair? rsaKeypair = _settings.value.rsaKeypair;
    if (rsaKeypair == null) return null;
    return Synchronization(
      username: username,
      passyEntries: FullPassyEntriesFileCollection(
        passwords: _passwords,
        notes: _notes,
        paymentCards: _paymentCards,
        idCards: _idCards,
        identities: _identities,
      ),
      history: _history,
      favorites: _favorites,
      settings: _settings,
      encrypter: _syncEncrypter,
      rsaKeypair: rsaKeypair,
      authWithIV:
          _credentials.value.keyDerivationType != KeyDerivationType.none,
      synchronizationType:
          _credentials.value.keyDerivationType == KeyDerivationType.none
              ? SynchronizationType.classic
              : SynchronizationType.v2d0d0,
      onComplete: (results) {
        _synchronizationLogs[DateTime.now().toUtc()] = results.log;
        onComplete?.call(results);
      },
      onError: onError,
    );
  }

  Map<DateTime, String> get synchronizationLogs =>
      Map.from(_synchronizationLogs);

  Future<void> testSynchronizationConnection2d0d0(
      String address, int port) async {
    GlareClient? client;
    client = await connectTo2d0d0Server(address, port,
        keypair: _settings.value.rsaKeypair);
    try {
      await client.disconnect();
    } catch (_) {
      return;
    }
  }

  Future<HostAddress?> host({
    void Function()? onConnected,
    void Function(SynchronizationResults results)? onComplete,
    void Function(String log)? onError,
  }) async =>
      await getSynchronization(
              onConnected: onConnected,
              onComplete: onComplete,
              onError: onError)
          ?.host(onConnected: onConnected);

  Future<void> connect(
    HostAddress address, {
    void Function()? onConnected,
    void Function(SynchronizationResults results)? onComplete,
    void Function(String log)? onError,
  }) async {
    onConnected?.call();
    return await getSynchronization(
            onConnected: onConnected, onComplete: onComplete, onError: onError)
        ?.connect(address);
  }

  Future<void> trustServer(Sync2d0d0ServerInfo server) async {
    _serversToTrust[server.nickname] = server;
    Completer<void> completer = Completer<void>();
    _serversToTrustCompleters[server.nickname] = completer;
    await completer.future;
  }

  Future<void> _autoSyncCycle(
      String password, Completer<void> completer) async {
    Map<String, Sync2d0d0ServerInfo> serverInfo = sync2d0d0ServerInfo;
    serverInfo.addAll(_serversToTrust);
    if (serverInfo.isNotEmpty) {
      String passwordDecrypted;
      try {
        passwordDecrypted = decrypt(password, encrypter: _encrypter);
      } catch (_) {
        await Future.delayed(
            Duration(milliseconds: _settings.value.serverSyncInterval));
        if (!completer.isCompleted) _autoSyncCycle(password, completer);
        return;
      }
      for (Sync2d0d0ServerInfo info in serverInfo.values) {
        Synchronization? syncClient = getSynchronization();
        if (syncClient == null) continue;
        try {
          bool verifyTrustedConnectionData;
          Completer? trustCompleter;
          if (_serversToTrust.containsKey(info.nickname)) {
            verifyTrustedConnectionData = false;
            _serversToTrust.remove(info.address);
            trustCompleter = _serversToTrustCompleters[info.nickname];
            _serversToTrustCompleters.remove(info.nickname);
          } else {
            verifyTrustedConnectionData = true;
          }
          await syncClient.connect2d0d0(
              HostAddress(InternetAddress(info.address), info.port),
              password: passwordDecrypted,
              deviceId: _deviceId,
              verifyTrustedConnectionData: verifyTrustedConnectionData,
              trustedConnectionsDir: Directory(_versionFile.parent.path +
                  Platform.pathSeparator +
                  'trusted_connections'),
              onTrustSaveComplete: () => trustCompleter?.complete(),
              onTrustSaveFailed: () => trustCompleter?.completeError(
                  'Failed to complete server trust saving procedures.'));
        } catch (_) {}
      }
    }
    await Future.delayed(
        Duration(milliseconds: _settings.value.serverSyncInterval));
    if (!completer.isCompleted) _autoSyncCycle(password, completer);
  }

  void startAutoSync(String password) {
    String passwordEncrypted = encrypt(password, encrypter: _encrypter);
    if (_autoSyncCompleter != null) return;
    Completer completer = Completer<void>();
    _autoSyncCompleter = completer;
    _autoSyncCycle(passwordEncrypted, completer);
  }

  void stopAutoSync() {
    Completer<void>? completer = _autoSyncCompleter;
    if (completer == null) return;
    if (completer.isCompleted) return;
    completer.complete();
    _autoSyncCompleter = null;
  }

  Future<String> exportPassy({
    required Directory outputDirectory,
    String? fileName,
  }) async {
    if (fileName == null) {
      fileName = outputDirectory.path +
          Platform.pathSeparator +
          'passy-export-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
    } else {
      fileName = outputDirectory.path + Platform.pathSeparator + fileName;
    }
    Directory _tempDir = Directory(Directory.systemTemp.path +
        Platform.pathSeparator +
        'passy-export-' +
        DateTime.now().toUtc().toIso8601String().replaceAll(':', ';'));
    Directory _tempAccDir =
        Directory(_tempDir.path + Platform.pathSeparator + username);
    if (await _tempDir.exists()) {
      await _tempDir.delete(recursive: true);
    }
    await _tempAccDir.create(recursive: true);
    Directory _accDir = Directory(_versionFile.parent.path);
    await copyDirectory(_accDir, _tempAccDir);
    {
      JSONLoadedAccount _jsonAcc = JSONLoadedAccount.fromEncryptedCSVDirectory(
          path: _tempAccDir.path, encrypter: _encrypter, deviceId: _deviceId);
      await _tempAccDir.delete(recursive: true);
      await _tempAccDir.create();
      _jsonAcc.saveSync();
    }
    ZipFileEncoder _encoder = ZipFileEncoder();
    _encoder.create(fileName, level: 9);
    await _encoder.addDirectory(_tempAccDir);
    _encoder.close();
    await _tempDir.delete(recursive: true);
    return fileName;
  }

  Future<String> exportCSV({
    required Directory outputDirectory,
    String? fileName,
  }) async {
    if (fileName == null) {
      fileName = outputDirectory.path +
          Platform.pathSeparator +
          'passy-csv-export-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
    } else {
      fileName = outputDirectory.path + Platform.pathSeparator + fileName;
    }
    Directory _tempDir = Directory(Directory.systemTemp.path +
        Platform.pathSeparator +
        'passy-csv-export-' +
        DateTime.now().toUtc().toIso8601String().replaceAll(':', ';'));
    Directory _tempAccDir =
        Directory(_tempDir.path + Platform.pathSeparator + username);
    if (await _tempDir.exists()) {
      await _tempDir.delete(recursive: true);
    }
    await _tempAccDir.create(recursive: true);
    String tempPath = '${_tempAccDir.path}${Platform.pathSeparator}';
    {
      await _passwords.export(
        File('${tempPath}passwords.csv'),
        annotation:
            '"key","customFields","additionalInfo","tags","nickname","iconName","username","email","password","tfa","website"',
      );
      await _paymentCards.export(
        File('${tempPath}payment_cards.csv'),
        annotation:
            '"key","customFields","additionalInfo","tags","nickname","cardNumber","cardholderName","cvv","exp"',
      );
      await _notes.export(
        File('${tempPath}notes.csv'),
        annotation: '"key","title","note","isMarkdown"',
      );
      await _idCards.export(
        File('${tempPath}id_cards.csv'),
        annotation:
            '"key","customFields","additionalInfo","tags","nickname","pictures","type","idNumber","name","issDate","expDate","country"',
      );
      await _identities.export(
        File('${tempPath}identities.csv'),
        annotation:
            '"key","customFields","additionalInfo","tags","nickname","title","firstName","middleName","lastName","gender","email","number","firstAddressLine","secondAddressLine","zipCode","city","country"',
      );
      await _versionFile.copy('${tempPath}version.txt');
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      await File('${tempPath}history.json')
          .writeAsString(encoder.convert(_history.value.toJson()));
      await File('${tempPath}favorites.json')
          .writeAsString(encoder.convert(_favorites.value.toJson()));
    }
    ZipFileEncoder _encoder = ZipFileEncoder();
    _encoder.create(fileName, level: 9);
    await _encoder.addDirectory(_tempAccDir);
    _encoder.close();
    await _tempDir.delete(recursive: true);
    return fileName;
  }

  Future<String> exportKdbx({
    required String password,
    required Directory outputDirectory,
    String? fileName,
  }) async {
    if (fileName == null) {
      fileName = outputDirectory.path +
          Platform.pathSeparator +
          'passy-kdbx-export-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
    } else {
      fileName = outputDirectory.path + Platform.pathSeparator + fileName;
    }
    Directory _tempDir = Directory(Directory.systemTemp.path +
        Platform.pathSeparator +
        'passy-csv-export-' +
        DateTime.now().toUtc().toIso8601String().replaceAll(':', ';'));
    Directory _tempAccDir =
        Directory(_tempDir.path + Platform.pathSeparator + username);
    if (await _tempDir.exists()) {
      await _tempDir.delete(recursive: true);
    }
    await _tempAccDir.create(recursive: true);
    String tempPath = '${_tempAccDir.path}${Platform.pathSeparator}';
    {
      final kdbx = KdbxFormat()
          .create(Credentials(ProtectedValue.fromString(password)), username);
      // Passwords
      KdbxGroup passwordsGroup = KdbxGroup.create(
          ctx: kdbx.ctx, parent: kdbx.body.rootGroup, name: 'Passwords');
      await _passwords.exportKdbx(kdbx, group: passwordsGroup);
      kdbx.body.rootGroup.addGroup(passwordsGroup);
      // Payment cards
      KdbxGroup paymentCardsGroup = KdbxGroup.create(
          ctx: kdbx.ctx, parent: kdbx.body.rootGroup, name: 'Payment cards');
      await _paymentCards.exportKdbx(kdbx, group: paymentCardsGroup);
      kdbx.body.rootGroup.addGroup(paymentCardsGroup);
      // Notes
      KdbxGroup notesGroup = KdbxGroup.create(
          ctx: kdbx.ctx, parent: kdbx.body.rootGroup, name: 'Notes');
      await _notes.exportKdbx(kdbx, group: notesGroup);
      kdbx.body.rootGroup.addGroup(notesGroup);
      // ID Cards
      KdbxGroup idCardsGroup = KdbxGroup.create(
          ctx: kdbx.ctx, parent: kdbx.body.rootGroup, name: 'ID cards');
      await _idCards.exportKdbx(kdbx, group: idCardsGroup);
      kdbx.body.rootGroup.addGroup(idCardsGroup);
      // Identities
      KdbxGroup identitiesGroup = KdbxGroup.create(
          ctx: kdbx.ctx, parent: kdbx.body.rootGroup, name: 'Identities');
      await _identities.exportKdbx(kdbx, group: identitiesGroup);
      kdbx.body.rootGroup.addGroup(identitiesGroup);
      await File('$tempPath$username.kdbx').writeAsBytes(await kdbx.save());
      await _versionFile.copy('${tempPath}version.txt');
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      await File('${tempPath}history.json')
          .writeAsString(encoder.convert(_history.value.toJson()));
      await File('${tempPath}favorites.json')
          .writeAsString(encoder.convert(_favorites.value.toJson()));
    }
    ZipFileEncoder _encoder = ZipFileEncoder();
    _encoder.create(fileName, level: 9);
    await _encoder.addDirectory(_tempAccDir);
    _encoder.close();
    await _tempDir.delete(recursive: true);
    return fileName;
  }

  Future<void> importKDBXPasswords(List<KdbxEntry> entries) async {
    String keyPrefix = '${DateTime.now().toUtc().toIso8601String()}-import';
    Map<String, Password> passwords = {};
    for (int i = 0; i != entries.length; i++) {
      KdbxEntry entry = entries[i];
      List<CustomField> customFields = [];
      String? additionalInfo;
      String? nickname;
      String? username;
      String? email;
      String? password;
      TFA? tfa;
      String? website;
      for (var e in entry.stringEntries) {
        String? val = e.value?.getText();
        if (val == null) continue;
        switch (e.key.key) {
          case 'Additional info':
            additionalInfo = val;
            continue;
          case KdbxKeyCommon.KEY_TITLE:
            nickname = val;
            continue;
          case KdbxKeyCommon.KEY_USER_NAME:
            username = val;
            continue;
          case 'Email':
            email = val;
            continue;
          case KdbxKeyCommon.KEY_PASSWORD:
            password = val;
            continue;
          case KdbxKeyCommon.KEY_OTP:
            tfa = TFA(secret: val);
            continue;
          case KdbxKeyCommon.KEY_URL:
            website = val;
            continue;
        }
        customFields.add(CustomField(
          title: e.key.key,
          value: val,
        ));
      }
      String key = '$keyPrefix-$i';
      passwords[key] = Password(
        key: key,
        customFields: customFields,
        additionalInfo: additionalInfo ?? '',
        nickname: nickname ?? '',
        username: username ?? '',
        email: email ?? '',
        password: password ?? '',
        tfa: tfa,
        website: website ?? '',
      );
    }
    await _history.reload();
    for (Password password in passwords.values) {
      _history.value.passwords[password.key] = EntryEvent(
        password.key,
        status: EntryStatus.alive,
        lastModified: DateTime.now().toUtc(),
      );
    }
    try {
      _passwords.setEntries(passwords);
    } catch (_) {
      await _history.reload();
      rethrow;
    }
    await _history.save();
  }

  Future<void> Function(PassyEntry value) setEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return (PassyEntry value) => setPassword(value as Password);
      case EntryType.paymentCard:
        return (PassyEntry value) => setPaymentCard(value as PaymentCard);
      case EntryType.note:
        return (PassyEntry value) => setNote(value as Note);
      case EntryType.idCard:
        return (PassyEntry value) => setIDCard(value as IDCard);
      case EntryType.identity:
        return (PassyEntry value) => setIdentity(value as Identity);
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  PassyEntry? Function(String key) getEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return getPassword;
      case EntryType.paymentCard:
        return getPaymentCard;
      case EntryType.note:
        return getNote;
      case EntryType.idCard:
        return getIDCard;
      case EntryType.identity:
        return getIdentity;
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  Future<void> Function(String key) removeEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return removePassword;
      case EntryType.paymentCard:
        return removePaymentCard;
      case EntryType.note:
        return removeNote;
      case EntryType.idCard:
        return removeIDCard;
      case EntryType.identity:
        return removeIdentity;
      default:
        throw Exception('Unsupported entry type \'${type.name}\'');
    }
  }

  // Account Credentials wrappers
  String get username => _credentials.value.username;
  set username(String value) => _credentials.value.username = value;
  String get passwordHash => _credentials.value.passwordHash;
  bool get bioAuthEnabled => _credentials.value.bioAuthEnabled;
  set bioAuthEnabled(bool value) => _credentials.value.bioAuthEnabled = value;
  Future<void> saveCredentials() => _credentials.save();
  void saveCredentialsSync() => _credentials.saveSync();

  // Local Settings wrappers
  AutoBackupSettings? get autoBackup => _localSettings.value.autoBackup;
  set autoBackup(AutoBackupSettings? value) =>
      _localSettings.value.autoBackup = value;
  Future<void> saveLocalSettings() => _localSettings.save();
  void saveLocalSettingsSync() => _localSettings.saveSync();

  // Account Settings wrappers
  bool get protectScreen => _settings.value.protectScreen;
  set protectScreen(bool value) => _settings.value.protectScreen = value;
  bool get autoScreenLock => _settings.value.autoScreenLock;
  set autoScreenLock(bool value) => _settings.value.autoScreenLock = value;
  bool get isRSAKeypairLoaded {
    return _settings.value.rsaKeypair != null;
  }

  int get serverSyncInterval => _settings.value.serverSyncInterval;
  set serverSyncInterval(int value) =>
      _settings.value.serverSyncInterval = value;
  Map<String, Sync2d0d0ServerInfo> get sync2d0d0ServerInfo =>
      _settings.value.serverInfo.map((key, value) => MapEntry(
          key,
          Sync2d0d0ServerInfo(
            nickname: value.nickname,
            address: value.address,
            port: value.port,
          )));
  void addSync2d0d0ServerInfo(Iterable<Sync2d0d0ServerInfo> info) =>
      _settings.value.serverInfo.addEntries(info.map((e) => MapEntry(
          e.nickname,
          Sync2d0d0ServerInfo(
            nickname: e.nickname,
            address: e.address,
            port: e.port,
          ))));
  void removeSync2d0d0ServerInfo(String nickname) {
    _settings.value.serverInfo.remove(nickname);
  }

  set lastSyncDate(DateTime? value) => _settings.value.lastSyncDate = value;
  DateTime? get lastSyncDate => _settings.value.lastSyncDate;

  Future<void> saveSettings() => _settings.save();
  void saveSettingsSync() => _settings.saveSync();

  // History wrappers
  void clearRemovedHistory() => _history.value.clearRemoved();
  void renewHistory() => _history.value.renew();
  Future<void> reloadHistory() => _history.reload();
  void reloadHistorySync() => _history.reloadSync();
  Future<void> saveHistory() => _history.save();
  void saveHistorySync() => _history.saveSync();
  Digest get historyHash => getPassyHash(jsonEncode(_history.value.toJson()));

  // Favorites wrappers
  void clearRemovedFavorites() => _favorites.value.clearRemoved();
  void renewFavorites() => _favorites.value.renew();
  Future<void> reloadFavorites() => _favorites.reload();
  void reloadFavoritesSync() => _favorites.reloadSync();
  Future<void> saveFavorites() => _favorites.save();
  void saveFavoritesSync() => _favorites.saveSync();
  int get favoritesLength => _favorites.value.length;
  bool get hasFavorites => _favorites.value.hasFavorites;
  Digest get favoritesHash =>
      getPassyHash(jsonEncode(_favorites.value.toJson()));
  Map<String, EntryEvent> get favoritePasswords => _favorites.value.passwords
      .map((key, value) => MapEntry(key, EntryEvent.fromJson(value.toJson())));
  Map<String, EntryEvent> get favoritePaymentCards => _favorites
      .value.paymentCards
      .map((key, value) => MapEntry(key, EntryEvent.fromJson(value.toJson())));
  Map<String, EntryEvent> get favoriteNotes => _favorites.value.notes
      .map((key, value) => MapEntry(key, EntryEvent.fromJson(value.toJson())));
  Map<String, EntryEvent> get favoriteIDCards => _favorites.value.idCards
      .map((key, value) => MapEntry(key, EntryEvent.fromJson(value.toJson())));
  Map<String, EntryEvent> get favoriteIdentities => _favorites.value.identities
      .map((key, value) => MapEntry(key, EntryEvent.fromJson(value.toJson())));
  Map<String, EntryEvent> getFavoriteEntries(EntryType type) {
    switch (type) {
      case EntryType.password:
        return favoritePasswords;
      case EntryType.paymentCard:
        return favoritePaymentCards;
      case EntryType.note:
        return favoriteNotes;
      case EntryType.idCard:
        return favoriteIDCards;
      case EntryType.identity:
        return favoriteIdentities;
    }
  }

  Future<void> addFavoritePassword(String key) async {
    await _favorites.reload();
    if (getPassword(key) == null) return;
    _favorites.value.passwords[key] = EntryEvent(
      key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _favorites.save();
  }

  Future<void> removeFavoritePassword(String key) async {
    await _favorites.reload();
    EntryEvent? _password = _favorites.value.passwords[key];
    if (_password == null) return;
    if (_password.status == EntryStatus.removed) return;
    _password.lastModified = DateTime.now().toUtc();
    _password.status = EntryStatus.removed;
    await _favorites.save();
  }

  Future<void> addFavoritePaymentCard(String key) async {
    await _favorites.reload();
    if (getPaymentCard(key) == null) return;
    _favorites.value.paymentCards[key] = EntryEvent(
      key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _favorites.save();
  }

  Future<void> removeFavoritePaymentCard(String key) async {
    await _favorites.reload();
    EntryEvent? _paymentCard = _favorites.value.paymentCards[key];
    if (_paymentCard == null) return;
    if (_paymentCard.status == EntryStatus.removed) return;
    _paymentCard.lastModified = DateTime.now().toUtc();
    _paymentCard.status = EntryStatus.removed;
    await _favorites.save();
  }

  Future<void> addFavoriteNote(String key) async {
    await _favorites.reload();
    if (getNote(key) == null) return;
    _favorites.value.notes[key] = EntryEvent(
      key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _favorites.save();
  }

  Future<void> removeFavoriteNote(String key) async {
    await _favorites.reload();
    EntryEvent? _note = _favorites.value.notes[key];
    if (_note == null) return;
    if (_note.status == EntryStatus.removed) return;
    _note.lastModified = DateTime.now().toUtc();
    _note.status = EntryStatus.removed;
    await _favorites.save();
  }

  Future<void> addFavoriteIDCard(String key) async {
    await _favorites.reload();
    if (getIDCard(key) == null) return;
    _favorites.value.idCards[key] = EntryEvent(
      key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _favorites.save();
  }

  Future<void> removeFavoriteIDCard(String key) async {
    await _favorites.reload();
    EntryEvent? _idCard = _favorites.value.idCards[key];
    if (_idCard == null) return;
    if (_idCard.status == EntryStatus.removed) return;
    _idCard.lastModified = DateTime.now().toUtc();
    _idCard.status = EntryStatus.removed;
    await _favorites.save();
  }

  Future<void> addFavoriteIdentity(String key) async {
    await _favorites.reload();
    if (getIdentity(key) == null) return;
    _favorites.value.identities[key] = EntryEvent(
      key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _favorites.save();
  }

  Future<void> removeFavoriteIdentity(String key) async {
    await _favorites.reload();
    EntryEvent? _identity = _favorites.value.identities[key];
    if (_identity == null) return;
    if (_identity.status == EntryStatus.removed) return;
    _identity.lastModified = DateTime.now().toUtc();
    _identity.status = EntryStatus.removed;
    await _favorites.save();
  }

  Future<void> Function(String key) addFavoriteEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return addFavoritePassword;
      case EntryType.paymentCard:
        return addFavoritePaymentCard;
      case EntryType.note:
        return addFavoriteNote;
      case EntryType.idCard:
        return addFavoriteIDCard;
      case EntryType.identity:
        return addFavoriteIdentity;
    }
  }

  Future<void> Function(String key) removeFavoriteEntry(EntryType type) {
    switch (type) {
      case EntryType.password:
        return removeFavoritePassword;
      case EntryType.paymentCard:
        return removeFavoritePaymentCard;
      case EntryType.note:
        return removeFavoriteNote;
      case EntryType.idCard:
        return removeFavoriteIDCard;
      case EntryType.identity:
        return removeFavoriteIdentity;
    }
  }

  void removeDeletedFavorites() async {
    await _favorites.reload();
    {
      List<String> keys = _passwords.keys;
      _favorites.value.passwords.forEach((key, value) {
        if (!keys.contains(key)) removeFavoritePassword(key);
      });
    }
    {
      List<String> keys = _paymentCards.keys;
      _favorites.value.paymentCards.forEach((key, value) {
        if (!keys.contains(key)) removeFavoritePaymentCard(key);
      });
    }
    {
      List<String> keys = _notes.keys;
      _favorites.value.notes.forEach((key, value) {
        if (!keys.contains(key)) removeFavoriteNote(key);
      });
    }
    {
      List<String> keys = _idCards.keys;
      _favorites.value.idCards.forEach((key, value) {
        if (!keys.contains(key)) removeFavoriteIDCard(key);
      });
    }
    {
      List<String> keys = _identities.keys;
      _favorites.value.identities.forEach((key, value) {
        if (!keys.contains(key)) removeFavoriteIdentity(key);
      });
    }
  }

  // Passwords wrappers
  List<String> get passwordKeys => _passwords.keys;
  Map<String, PasswordMeta> get passwordsMetadata {
    bool _isHistoryChanged = false;
    _history.reloadSync();
    Map<String, PasswordMeta> result = _passwords.metadata.map((key, e) {
      PasswordMeta meta = e as PasswordMeta;
      if (!_history.value.passwords.containsKey(key)) {
        _history.value.passwords[key] = EntryEvent(key,
            status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
        _isHistoryChanged = true;
      }
      return MapEntry(key, meta);
    });
    if (_isHistoryChanged) _history.saveSync();
    return result;
  }

  Map<String, Password> get passwords => _passwords.entries;

  Password? getPassword(String key) => _passwords.getEntry(key);

  Future<void> setPassword(Password password) async {
    await _history.reload();
    _history.value.passwords[password.key] = EntryEvent(password.key,
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    Future<void> _saveFuture =
        _passwords.setEntry(password.key, entry: password);
    await _history.save();
    await _saveFuture;
  }

  Future<void> removePassword(String key) async {
    await _history.reload();
    EntryEvent? _event = _history.value.passwords[key];
    if (_event == null) return;
    _event
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    Future<void> _saveFuture = _passwords.setEntry(key);
    await _history.save();
    await removeFavoritePassword(key);
    await _saveFuture;
  }

  // Notes wrappers
  List<String> get notesKeys => _notes.keys;
  Map<String, NoteMeta> get notesMetadata {
    bool _isHistoryChanged = false;
    _history.reloadSync();
    Map<String, NoteMeta> result = _notes.metadata.map((key, e) {
      NoteMeta meta = e as NoteMeta;
      if (!_history.value.notes.containsKey(key)) {
        _history.value.notes[key] = EntryEvent(key,
            status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
        _isHistoryChanged = true;
      }
      return MapEntry(key, meta);
    });
    if (_isHistoryChanged) _history.saveSync();
    return result;
  }

  Map<String, Note> get notes => _notes.entries;

  Note? getNote(String key) => _notes.getEntry(key);

  Future<void> setNote(Note note) async {
    await _history.reload();
    _history.value.notes[note.key] = EntryEvent(
      note.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    Future<void> _saveFuture = _notes.setEntry(note.key, entry: note);
    await _history.save();
    await _saveFuture;
  }

  Future<void> removeNote(String key) async {
    await _history.reload();
    EntryEvent? _event = _history.value.notes[key];
    if (_event == null) return;
    _event
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    Future<void> _saveFuture = _notes.setEntry(key);
    await _history.save();
    await removeFavoriteNote(key);
    await _saveFuture;
  }

  // Payment Cards wrappers
  List<String> get paymentCardKeys => _paymentCards.keys;
  Map<String, PaymentCardMeta> get paymentCardsMetadata {
    bool _isHistoryChanged = false;
    _history.reloadSync();
    Map<String, PaymentCardMeta> result = _paymentCards.metadata.map((key, e) {
      PaymentCardMeta meta = e as PaymentCardMeta;
      if (!_history.value.paymentCards.containsKey(key)) {
        _history.value.paymentCards[key] = EntryEvent(key,
            status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
        _isHistoryChanged = true;
      }
      return MapEntry(key, meta);
    });
    if (_isHistoryChanged) _history.saveSync();
    return result;
  }

  Map<String, PaymentCard> get paymentCards => _paymentCards.entries;

  PaymentCard? getPaymentCard(String key) => _paymentCards.getEntry(key);

  Future<void> setPaymentCard(PaymentCard paymentCard) async {
    await _history.reload();
    _history.value.paymentCards[paymentCard.key] = EntryEvent(
      paymentCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    Future<void> _saveFuture =
        _paymentCards.setEntry(paymentCard.key, entry: paymentCard);
    await _history.save();
    await _saveFuture;
  }

  Future<void> removePaymentCard(String key) async {
    await _history.reload();
    EntryEvent? _event = _history.value.paymentCards[key];
    if (_event == null) return;
    _event
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    Future<void> _saveFuture = _paymentCards.setEntry(key);
    await _history.save();
    await removeFavoritePaymentCard(key);
    await _saveFuture;
  }

  // ID Cards wrappers
  List<String> get idCardsKeys => _idCards.keys;
  Map<String, IDCardMeta> get idCardsMetadata {
    bool _isHistoryChanged = false;
    _history.reloadSync();
    Map<String, IDCardMeta> result = _idCards.metadata.map((key, e) {
      IDCardMeta meta = e as IDCardMeta;
      if (!_history.value.idCards.containsKey(key)) {
        _history.value.idCards[key] = EntryEvent(key,
            status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
        _isHistoryChanged = true;
      }
      return MapEntry(key, meta);
    });
    if (_isHistoryChanged) _history.saveSync();
    return result;
  }

  Map<String, IDCard> get idCards => _idCards.entries;

  IDCard? getIDCard(String key) => _idCards.getEntry(key);

  Future<void> setIDCard(IDCard idCard) async {
    await _history.reload();
    _history.value.idCards[idCard.key] = EntryEvent(
      idCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    await _idCards.setEntry(idCard.key, entry: idCard);
    await _history.save();
  }

  Future<void> removeIDCard(String key) async {
    await _history.reload();
    EntryEvent? _event = _history.value.idCards[key];
    if (_event == null) return;
    _event
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    Future<void> _saveFuture = _idCards.setEntry(key);
    await _history.save();
    await removeFavoriteIDCard(key);
    await _saveFuture;
  }

  // Identities wrappers
  List<String> get identitiesKeys => _identities.keys;
  Map<String, IdentityMeta> get identitiesMetadata {
    bool _isHistoryChanged = false;
    _history.reloadSync();
    Map<String, IdentityMeta> result = _identities.metadata.map((key, e) {
      IdentityMeta meta = e as IdentityMeta;
      if (!_history.value.identities.containsKey(key)) {
        _history.value.identities[key] = EntryEvent(key,
            status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
        _isHistoryChanged = true;
      }
      return MapEntry(key, meta);
    });
    if (_isHistoryChanged) _history.saveSync();
    return result;
  }

  Map<String, Identity> get identities => _identities.entries;

  Identity? getIdentity(String key) => _identities.getEntry(key);

  Future<void> setIdentity(Identity identity) async {
    await _history.reload();
    _history.value.identities[identity.key] = EntryEvent(
      identity.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    Future<void> _saveFuture =
        _identities.setEntry(identity.key, entry: identity);
    await _history.save();
    await _saveFuture;
  }

  Future<void> removeIdentity(String key) async {
    await _history.reload();
    EntryEvent? _event = _history.value.identities[key];
    if (_event == null) return;
    _event
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    Future<void> _saveFuture = _identities.setEntry(key);
    await _history.save();
    await removeFavoriteIdentity(key);
    await _saveFuture;
  }
}

class JSONLoadedAccount {
  final String _deviceId;
  final File _versionFile;
  final AccountCredentialsFile _credentials;
  final LocalSettingsFile _localSettings;
  final JsonFile<AccountSettings> _settings;
  final JsonFile<History> _history;
  final JsonFile<Favorites> _favorites;
  final PassyEntriesJSONFile<Password> _passwords;
  final PassyEntriesJSONFile<Note> _notes;
  final PassyEntriesJSONFile<PaymentCard> _paymentCards;
  final PassyEntriesJSONFile<IDCard> _idCards;
  final PassyEntriesJSONFile<Identity> _identities;

  JSONLoadedAccount({
    required String deviceId,
    required File versionFile,
    required AccountCredentialsFile credentials,
    required LocalSettingsFile localSettings,
    required JsonFile<AccountSettings> settings,
    required JsonFile<History> history,
    required JsonFile<Favorites> favorites,
    required PassyEntriesJSONFile<Password> passwords,
    required PassyEntriesJSONFile<Note> notes,
    required PassyEntriesJSONFile<PaymentCard> paymentCards,
    required PassyEntriesJSONFile<IDCard> idCards,
    required PassyEntriesJSONFile<Identity> identities,
  })  : _deviceId = deviceId,
        _versionFile = versionFile,
        _credentials = credentials,
        _localSettings = localSettings,
        _settings = settings,
        _history = history,
        _favorites = favorites,
        _passwords = passwords,
        _notes = notes,
        _paymentCards = paymentCards,
        _idCards = idCards,
        _identities = identities;

  factory JSONLoadedAccount.fromDirectory({
    required String path,
    required String deviceId,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    JsonFile<AccountSettings>? settings,
    JsonFile<History>? history,
    JsonFile<Favorites>? favorites,
    PassyEntriesJSONFile<Password>? passwords,
    PassyEntriesJSONFile<Note>? notes,
    PassyEntriesJSONFile<PaymentCard>? paymentCards,
    PassyEntriesJSONFile<IDCard>? idCards,
    PassyEntriesJSONFile<Identity>? identities,
  }) {
    versionFile ??= File(path + Platform.pathSeparator + 'version.txt');
    credentials ??= AccountCredentials.fromFile(
        File(path + Platform.pathSeparator + 'credentials.json'));
    localSettings ??= LocalSettings.fromFile(
        File(path + Platform.pathSeparator + 'local_settings.json'));
    settings ??= JsonFile<AccountSettings>.fromFile(
      File(path + Platform.pathSeparator + 'settings.enc'),
      constructor: () => AccountSettings(),
      fromJson: AccountSettings.fromJson,
    );
    history ??= JsonFile<History>.fromFile(
      File(path + Platform.pathSeparator + 'history.enc'),
      constructor: () => History(),
      fromJson: History.fromJson,
    );
    favorites ??= JsonFile<Favorites>.fromFile(
      File(path + Platform.pathSeparator + 'favorites.enc'),
      constructor: () => Favorites(),
      fromJson: Favorites.fromJson,
    );
    passwords ??= PassyEntriesJSONFile<Password>.fromFile(
      File(path + Platform.pathSeparator + 'passwords.enc'),
    );
    notes ??= PassyEntriesJSONFile<Note>.fromFile(
      File(path + Platform.pathSeparator + 'notes.enc'),
    );
    paymentCards ??= PassyEntriesJSONFile<PaymentCard>.fromFile(
      File(path + Platform.pathSeparator + 'payment_cards.enc'),
    );
    idCards ??= PassyEntriesJSONFile<IDCard>.fromFile(
      File(path + Platform.pathSeparator + 'id_cards.enc'),
    );
    identities ??= PassyEntriesJSONFile<Identity>.fromFile(
      File(path + Platform.pathSeparator + 'identities.enc'),
    );
    return JSONLoadedAccount(
        deviceId: deviceId,
        versionFile: versionFile,
        credentials: credentials,
        localSettings: localSettings,
        settings: settings,
        history: history,
        favorites: favorites,
        passwords: passwords,
        notes: notes,
        paymentCards: paymentCards,
        idCards: idCards,
        identities: identities);
  }

  factory JSONLoadedAccount.fromEncryptedCSVDirectory({
    required String path,
    required Encrypter encrypter,
    required String deviceId,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    JsonFile<AccountSettings>? settings,
    JsonFile<History>? history,
    JsonFile<Favorites>? favorites,
    PassyEntriesJSONFile<Password>? passwords,
    PassyEntriesJSONFile<Note>? notes,
    PassyEntriesJSONFile<PaymentCard>? paymentCards,
    PassyEntriesJSONFile<IDCard>? idCards,
    PassyEntriesJSONFile<Identity>? identities,
  }) {
    File _settingsFile = File(path + Platform.pathSeparator + 'settings.enc');
    File _historyFile = File(path + Platform.pathSeparator + 'history.enc');
    File _favoritesFile = File(path + Platform.pathSeparator + 'favorites.enc');
    File _passwordsFile = File(path + Platform.pathSeparator + 'passwords.enc');
    File _notesFile = File(path + Platform.pathSeparator + 'notes.enc');
    File _paymentCardsFile =
        File(path + Platform.pathSeparator + 'payment_cards.enc');
    File _idCardsFile = File(path + Platform.pathSeparator + 'id_cards.enc');
    File _identitiesFile =
        File(path + Platform.pathSeparator + 'identities.enc');
    versionFile ??= File(path + Platform.pathSeparator + 'version.txt');
    credentials ??= AccountCredentials.fromFile(
        File(path + Platform.pathSeparator + 'credentials.json'));
    localSettings ??= LocalSettings.fromFile(
        File(path + Platform.pathSeparator + 'local_settings.json'));
    settings ??= JsonFile(_settingsFile,
        fromJson: AccountSettings.fromJson,
        value: AccountSettings.fromFile(_settingsFile, encrypter: encrypter)
            .value);
    history ??= JsonFile<History>(_historyFile,
        fromJson: History.fromJson,
        value: History.fromFile(
                File(path + Platform.pathSeparator + 'history.enc'),
                encrypter: encrypter)
            .value);
    favorites ??= JsonFile<Favorites>(_favoritesFile,
        fromJson: Favorites.fromJson,
        value: Favorites.fromFile(
                File(path + Platform.pathSeparator + 'favorites.enc'),
                encrypter: encrypter)
            .value);
    passwords ??= PassyEntriesJSONFile<Password>(_passwordsFile,
        value: PassyEntries(
            entries: Passwords.fromFile<Password>(_passwordsFile,
                    encrypter: encrypter)
                .entries));
    notes ??= PassyEntriesJSONFile<Note>(_notesFile,
        value: PassyEntries(
            entries: Notes.fromFile<Note>(_notesFile, encrypter: encrypter)
                .entries));
    paymentCards ??= PassyEntriesJSONFile<PaymentCard>(_paymentCardsFile,
        value: PassyEntries(
            entries: PaymentCards.fromFile<PaymentCard>(_paymentCardsFile,
                    encrypter: encrypter)
                .entries));
    idCards ??= PassyEntriesJSONFile<IDCard>(_idCardsFile,
        value: PassyEntries(
            entries:
                IDCards.fromFile<IDCard>(_idCardsFile, encrypter: encrypter)
                    .entries));
    identities ??= PassyEntriesJSONFile<Identity>(_identitiesFile,
        value: PassyEntries(
            entries: Identities.fromFile<Identity>(_identitiesFile,
                    encrypter: encrypter)
                .entries));
    return JSONLoadedAccount(
      versionFile: versionFile,
      credentials: credentials,
      deviceId: deviceId,
      localSettings: localSettings,
      settings: settings,
      history: history,
      favorites: favorites,
      passwords: passwords,
      notes: notes,
      paymentCards: paymentCards,
      idCards: idCards,
      identities: identities,
    );
  }

  LoadedAccount toEncryptedCSVLoadedAccount(
      Encrypter encrypter, Encrypter syncEncrypter) {
    return LoadedAccount(
      encrypter: encrypter,
      syncEncrypter: syncEncrypter,
      versionFile: _versionFile,
      deviceId: _deviceId,
      credentials: _credentials,
      localSettings: _localSettings,
      settings: _settings.toEncryptedJSONFile(encrypter),
      history: _history.toEncryptedJSONFile(encrypter),
      favorites: _favorites.toEncryptedJSONFile(encrypter),
      passwords: _passwords.toPassyEntriesEncryptedCSVFile(encrypter),
      notes: _notes.toPassyEntriesEncryptedCSVFile(encrypter),
      paymentCards: _paymentCards.toPassyEntriesEncryptedCSVFile(encrypter),
      idCards: _idCards.toPassyEntriesEncryptedCSVFile(encrypter),
      identities: _identities.toPassyEntriesEncryptedCSVFile(encrypter),
    );
  }

  Future<void> save() => Future.wait([
        _versionFile.writeAsString(accountVersion),
        _credentials.save(),
        _localSettings.save(),
        _settings.save(),
        _history.save(),
        _favorites.save(),
        _passwords.save(),
        _notes.save(),
        _paymentCards.save(),
        _idCards.save(),
        _identities.save(),
      ]);

  void saveSync() {
    _versionFile.writeAsStringSync(accountVersion);
    _credentials.saveSync();
    _localSettings.saveSync();
    _settings.saveSync();
    _history.saveSync();
    _favorites.saveSync();
    _passwords.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }
}
