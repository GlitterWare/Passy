import 'dart:async';

import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/json_file.dart';
import 'package:passy/passy_data/local_settings.dart';
import 'package:passy/passy_data/passy_entires_json_file.dart';
import 'dart:io';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'auto_backup_settings.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'note.dart';
import 'password.dart';
import 'passy_entry.dart';
import 'payment_card.dart';
import 'screen.dart';
import 'synchronization.dart';

class LoadedAccount {
  Encrypter _encrypter;
  final File _versionFile;
  final AccountCredentialsFile _credentials;
  final LocalSettingsFile _localSettings;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final PasswordsFile _passwords;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;

  LoadedAccount({
    required Encrypter encrypter,
    required File versionFile,
    required AccountCredentialsFile credentials,
    required LocalSettingsFile localSettings,
    required AccountSettingsFile settings,
    required HistoryFile history,
    required PasswordsFile passwords,
    required NotesFile notes,
    required PaymentCardsFile paymentCards,
    required IDCardsFile idCards,
    required IdentitiesFile identities,
  })  : _encrypter = encrypter,
        _versionFile = versionFile,
        _credentials = credentials,
        _localSettings = localSettings,
        _settings = settings,
        _history = history,
        _passwords = passwords,
        _notes = notes,
        _paymentCards = paymentCards,
        _idCards = idCards,
        _identities = identities;

  factory LoadedAccount.fromDirectory({
    required String path,
    required Encrypter encrypter,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    AccountSettingsFile? settings,
    HistoryFile? history,
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
        versionFile: versionFile,
        credentials: credentials,
        localSettings: localSettings,
        settings: settings,
        history: history,
        passwords: passwords,
        notes: notes,
        paymentCards: paymentCards,
        idCards: idCards,
        identities: identities);
  }

  void setAccountPassword(String password) {
    _credentials.value.password = password;
    _encrypter = getPassyEncrypter(password);
    _settings.encrypter = _encrypter;
    _history.encrypter = _encrypter;
    _passwords.encrypter = _encrypter;
    _notes.encrypter = _encrypter;
    _paymentCards.encrypter = _encrypter;
    _idCards.encrypter = _encrypter;
    _identities.encrypter = _encrypter;
  }

  Future<void> save() => Future.wait([
        _versionFile.writeAsString(accountVersion),
        _credentials.save(),
        _localSettings.save(),
        _settings.save(),
        _history.save(),
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
    _passwords.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  Synchronization getSynchronization({
    void Function()? onConnected,
    void Function()? onComplete,
    void Function(String log)? onError,
  }) =>
      Synchronization(this,
          history: _history.value,
          encrypter: _encrypter,
          onComplete: onComplete,
          onError: onError);

  Future<HostAddress?> host({
    void Function()? onConnected,
    void Function()? onComplete,
    void Function(String log)? onError,
  }) =>
      getSynchronization(
              onConnected: onConnected,
              onComplete: onComplete,
              onError: onError)
          .host(onConnected: onConnected);

  Future<void> connect(
    HostAddress address, {
    void Function()? onConnected,
    void Function()? onComplete,
    void Function(String log)? onError,
  }) {
    onConnected?.call();
    return getSynchronization(
            onConnected: onConnected, onComplete: onComplete, onError: onError)
        .connect(address);
  }

  void Function(PassyEntry value) setEntry(EntryType type) {
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

  void Function(String key) removeEntry(EntryType type) {
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
  Future<void> saveSettings() => _settings.save();
  void saveSettingsSync() => _settings.saveSync();

  Future<BiometricStorageData> get biometricStorageData =>
      BiometricStorageData.fromLocker(_credentials.value.username);

  // History wrappers
  void clearRemovedHistory() => _history.value.clearRemoved();
  void renewHistory() => _history.value.renew();
  Future<void> saveHistory() => _history.save();
  void saveHistorySync() => _history.saveSync();

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.value.entries;

  Password? getPassword(String key) => _passwords.value.getEntry(key);

  void setPassword(Password password) {
    _history.value.passwords[password.key] = EntryEvent(password.key,
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.value.setEntry(password);
  }

  void removePassword(String key) {
    _history.value.passwords[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _passwords.value.removeEntry(key);
  }

  Future<void> savePasswords() async {
    await _passwords.save();
    await _history.save();
  }

  void savePasswordsSync() {
    _passwords.saveSync();
    _history.saveSync();
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.value.entries;

  Note? getNote(String key) => _notes.value.getEntry(key);

  void setNote(Note note) {
    _history.value.notes[note.key] = EntryEvent(
      note.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _notes.value.setEntry(note);
  }

  void removeNote(String key) {
    _history.value.notes[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _notes.value.removeEntry(key);
  }

  Future<void> saveNotes() async {
    await _notes.save();
    await _history.save();
  }

  void saveNotesSync() {
    _notes.saveSync();
    _history.saveSync();
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.value.entries;

  PaymentCard? getPaymentCard(String key) => _paymentCards.value.getEntry(key);

  void setPaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.key] = EntryEvent(
      paymentCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _paymentCards.value.setEntry(paymentCard);
  }

  void removePaymentCard(String key) {
    _history.value.paymentCards[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _paymentCards.value.removeEntry(key);
  }

  Future<void> savePaymentCards() async {
    await _paymentCards.save();
    await _history.save();
  }

  void savePaymentCardsSync() {
    _paymentCards.saveSync();
    _history.saveSync();
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.value.entries;

  IDCard? getIDCard(String key) => _idCards.value.getEntry(key);

  void setIDCard(IDCard idCard) {
    _history.value.idCards[idCard.key] = EntryEvent(
      idCard.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _idCards.value.setEntry(idCard);
  }

  void removeIDCard(String key) {
    _history.value.idCards[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _idCards.value.removeEntry(key);
  }

  Future<void> saveIDCards() async {
    await _idCards.save();
    await _history.save();
  }

  void saveIDCardsSync() {
    _idCards.saveSync();
    _history.saveSync();
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.value.entries;

  Identity? getIdentity(String key) => _identities.value.getEntry(key);

  void setIdentity(Identity identity) {
    _history.value.identities[identity.key] = EntryEvent(
      identity.key,
      status: EntryStatus.alive,
      lastModified: DateTime.now().toUtc(),
    );
    _identities.value.setEntry(identity);
  }

  void removeIdentity(String key) {
    _history.value.identities[key]!
      ..status = EntryStatus.removed
      ..lastModified = DateTime.now().toUtc();
    _identities.value.removeEntry(key);
  }

  Future<void> saveIdentities() async {
    await _identities.save();
    await _history.save();
  }

  void saveIdentitiesSync() {
    _identities.saveSync();
    _history.saveSync();
  }
}

class JSONLoadedAccount {
  final File _versionFile;
  final AccountCredentialsFile _credentials;
  final LocalSettingsFile _localSettings;
  final JsonFile<AccountSettings> _settings;
  final JsonFile<History> _history;
  final PassyEntriesJSONFile<Password> _passwords;
  final PassyEntriesJSONFile<Note> _notes;
  final PassyEntriesJSONFile<PaymentCard> _paymentCards;
  final PassyEntriesJSONFile<IDCard> _idCards;
  final PassyEntriesJSONFile<Identity> _identities;

  JSONLoadedAccount({
    required File versionFile,
    required AccountCredentialsFile credentials,
    required LocalSettingsFile localSettings,
    required JsonFile<AccountSettings> settings,
    required JsonFile<History> history,
    required PassyEntriesJSONFile<Password> passwords,
    required PassyEntriesJSONFile<Note> notes,
    required PassyEntriesJSONFile<PaymentCard> paymentCards,
    required PassyEntriesJSONFile<IDCard> idCards,
    required PassyEntriesJSONFile<Identity> identities,
  })  : _versionFile = versionFile,
        _credentials = credentials,
        _localSettings = localSettings,
        _settings = settings,
        _history = history,
        _passwords = passwords,
        _notes = notes,
        _paymentCards = paymentCards,
        _idCards = idCards,
        _identities = identities;

  factory JSONLoadedAccount.fromDirectory({
    required String path,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    JsonFile<AccountSettings>? settings,
    JsonFile<History>? history,
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
        versionFile: versionFile,
        credentials: credentials,
        localSettings: localSettings,
        settings: settings,
        history: history,
        passwords: passwords,
        notes: notes,
        paymentCards: paymentCards,
        idCards: idCards,
        identities: identities);
  }

  factory JSONLoadedAccount.fromEncryptedCSVDirectory({
    required String path,
    required Encrypter encrypter,
    File? versionFile,
    AccountCredentialsFile? credentials,
    LocalSettingsFile? localSettings,
    JsonFile<AccountSettings>? settings,
    JsonFile<History>? history,
    PassyEntriesJSONFile<Password>? passwords,
    PassyEntriesJSONFile<Note>? notes,
    PassyEntriesJSONFile<PaymentCard>? paymentCards,
    PassyEntriesJSONFile<IDCard>? idCards,
    PassyEntriesJSONFile<Identity>? identities,
  }) {
    File _settingsFile = File(path + Platform.pathSeparator + 'settings.enc');
    File _historyFile = File(path + Platform.pathSeparator + 'history.enc');
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
        value: AccountSettings.fromFile(_settingsFile, encrypter: encrypter)
            .value);
    history ??= JsonFile<History>(_historyFile,
        value: History.fromFile(
                File(path + Platform.pathSeparator + 'history.enc'),
                encrypter: encrypter)
            .value);
    passwords ??= PassyEntriesJSONFile<Password>(_passwordsFile,
        value:
            Passwords.fromFile<Password>(_passwordsFile, encrypter: encrypter)
                .value);
    notes ??= PassyEntriesJSONFile<Note>(_notesFile,
        value: Notes.fromFile<Note>(_notesFile, encrypter: encrypter).value);
    paymentCards ??= PassyEntriesJSONFile<PaymentCard>(_paymentCardsFile,
        value: PaymentCards.fromFile<PaymentCard>(_paymentCardsFile,
                encrypter: encrypter)
            .value);
    idCards ??= PassyEntriesJSONFile<IDCard>(_idCardsFile,
        value:
            IDCards.fromFile<IDCard>(_idCardsFile, encrypter: encrypter).value);
    identities ??= PassyEntriesJSONFile<Identity>(_identitiesFile,
        value:
            Identities.fromFile<Identity>(_identitiesFile, encrypter: encrypter)
                .value);
    return JSONLoadedAccount(
      versionFile: versionFile,
      credentials: credentials,
      localSettings: localSettings,
      settings: settings,
      history: history,
      passwords: passwords,
      notes: notes,
      paymentCards: paymentCards,
      idCards: idCards,
      identities: identities,
    );
  }

  LoadedAccount toEncryptedCSVLoadedAccount(Encrypter encrypter) {
    return LoadedAccount(
      encrypter: encrypter,
      versionFile: _versionFile,
      credentials: _credentials,
      localSettings: _localSettings,
      settings: _settings.toEncryptedJSONFile(encrypter),
      history: _history.toEncryptedJSONFile(encrypter),
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
    _passwords.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }
}
