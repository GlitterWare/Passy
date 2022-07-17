import 'package:encrypt/encrypt.dart';
import 'package:passy/passy_data/tfa.dart';
import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'account_settings.dart';
import 'common.dart';
import 'custom_field.dart';
import 'entry_event.dart';
import 'history.dart';
import 'id_card.dart';
import 'identity.dart';
import 'passy_images.dart';
import 'loaded_account.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

LoadedAccount convertLegacyAccount(
    {required String path, required Encrypter encrypter}) {
  String _version;
  File _versionFile = File(path + Platform.pathSeparator + 'version.txt');
  if (_versionFile.existsSync()) {
    _version = _versionFile.readAsStringSync();
  } else {
    _version = '0.0.0';
  }
  if (_version == accountVersion) {
    return LoadedAccount(path: path, encrypter: encrypter);
  }
  if (int.parse(_version[0]) <= int.parse(accountVersion[0])) {
    int _accV2 = int.parse(_version[2]);
    if (_accV2 <= int.parse(accountVersion[2])) {
      // 0.3.0 conversion
      if (_version[0] == '0') {
        if (_accV2 < 3) {
          LoadedAccount _account =
              convertPre0_3_0Account(path: path, encrypter: encrypter);
          _versionFile.writeAsStringSync(accountVersion);
          return _account;
        }
      }
      // No conversion
      if (int.parse(_version[4]) <= int.parse(accountVersion[4])) {
        _versionFile.writeAsStringSync(accountVersion);
        return LoadedAccount(path: path, encrypter: encrypter);
      }
    }
  }
  throw Exception(
      'Account version is higher than the manager version. Please make sure that you are using the latest release of Passy before loading this account');
}

LoadedAccount convertPre0_3_0Account({
  required String path,
  required Encrypter encrypter,
}) {
  void _fixCustomFields(List<dynamic> csv) {
    csv[1] = (csv[1] as List<dynamic>).isNotEmpty
        ? (csv[1] as List<dynamic>)
            .map((e) => CustomField.fromCSV(e[0]).toCSV())
            .toList()
        : [];
  }

  PasswordsFile _loadPasswords(File file) {
    String _encrypted = file.readAsStringSync();
    String _decrypted = decrypt(_encrypted, encrypter: encrypter);
    Map<String, Password> _entries = {};
    for (String line in _decrypted.split('\n')) {
      if (line == '') break;
      List _csv = csvDecode(line, recursive: true);
      // Custom Fields
      _fixCustomFields(_csv);
      // TFA
      _csv[9] = _csv[9].isNotEmpty ? TFA.fromCSV(_csv[9][0]).toCSV() : [];
      _entries[_csv[0]] = Password.fromCSV(_csv);
    }
    return PasswordsFile(file,
        encrypter: encrypter, value: Passwords(entries: _entries));
  }

  NotesFile _loadNotes(File file) {
    String _encrypted = file.readAsStringSync();
    String _decrypted = decrypt(_encrypted, encrypter: encrypter);
    Map<String, Note> _entries = {};
    for (String line in _decrypted.split('\n')) {
      if (line == '') break;
      List _csv = csvDecode(line, recursive: true);
      _fixCustomFields(_csv);
      _entries[_csv[0]] = Note.fromCSV(_csv);
    }
    return NotesFile(file,
        encrypter: encrypter, value: Notes(entries: _entries));
  }

  PaymentCardsFile _loadPaymentCards(File file) {
    String _encrypted = file.readAsStringSync();
    String _decrypted = decrypt(_encrypted, encrypter: encrypter);
    Map<String, PaymentCard> _entries = {};
    for (String line in _decrypted.split('\n')) {
      if (line == '') break;
      List _csv = csvDecode(line, recursive: true);
      _fixCustomFields(_csv);
      _entries[_csv[0]] = PaymentCard.fromCSV(_csv);
    }
    return PaymentCardsFile(file,
        encrypter: encrypter, value: PaymentCards(entries: _entries));
  }

  IDCardsFile _loadIDCards(File file) {
    String _encrypted = file.readAsStringSync();
    String _decrypted = decrypt(_encrypted, encrypter: encrypter);
    Map<String, IDCard> _entries = {};
    for (String line in _decrypted.split('\n')) {
      if (line == '') break;
      List _csv = csvDecode(line, recursive: true);
      _fixCustomFields(_csv);
      _entries[_csv[0]] = IDCard.fromCSV(_csv);
    }
    return IDCardsFile(file,
        encrypter: encrypter, value: IDCards(entries: _entries));
  }

  IdentitiesFile _loadIdentities(File file) {
    String _encrypted = file.readAsStringSync();
    String _decrypted = decrypt(_encrypted, encrypter: encrypter);
    Map<String, Identity> _entries = {};
    for (String line in _decrypted.split('\n')) {
      if (line == '') break;
      List _csv = csvDecode(line, recursive: true);
      _fixCustomFields(_csv);
      _entries[_csv[0]] = Identity.fromCSV(_csv);
    }
    return IdentitiesFile(file,
        encrypter: encrypter, value: Identities(entries: _entries));
  }

  Map<String, EntryEvent> _entriesFromCSV(List<List> csv) {
    Map<String, EntryEvent> _entries = {};
    for (List<dynamic> _entry in csv) {
      if (_entry.isEmpty) return _entries;
      _entries[_entry[0]] = EntryEvent.fromCSV(_entry);
    }
    return _entries;
  }

  HistoryFile _loadedHistory;
  LoadedAccount _account;

  {
    File _historyFile = File(path + Platform.pathSeparator + 'history.enc');
    String _history = decrypt(
      _historyFile.readAsStringSync(),
      encrypter: encrypter,
    );
    List<String> _historyLines = _history.split('\n');
    _loadedHistory = HistoryFile(_historyFile,
        encrypter: encrypter,
        value: History(
          //version:
          //int.parse(csvDecode(_historyLines[0], recursive: true)[0][0]),
          passwords: _entriesFromCSV(
              csvDecode(_historyLines[1], recursive: true)
                  .map((e) => e as List<dynamic>)
                  .toList()),
          passwordIcons: _entriesFromCSV(
              csvDecode(_historyLines[2], recursive: true)
                  .map((e) => e as List<dynamic>)
                  .toList()),
          paymentCards: _entriesFromCSV(
              csvDecode(_historyLines[3], recursive: true)
                  .map((e) => e as List<dynamic>)
                  .toList()),
          notes: _entriesFromCSV(csvDecode(_historyLines[4], recursive: true)
              .map((e) => e as List<dynamic>)
              .toList()),
          idCards: _entriesFromCSV(csvDecode(_historyLines[5], recursive: true)
              .map((e) => e as List<dynamic>)
              .toList()),
          identities: _entriesFromCSV(
              csvDecode(_historyLines[6], recursive: true)
                  .map((e) => e as List<dynamic>)
                  .toList()),
        ));
  }

  _account = LoadedAccount(
    path: path,
    encrypter: encrypter,
    history: _loadedHistory,
    credentials: AccountCredentials.fromFile(
        File(path + Platform.pathSeparator + 'credentials.json')),
    settings: AccountSettings.fromFile(
        File(path + Platform.pathSeparator + 'settings.enc'),
        encrypter: encrypter),
    passwords: _loadPasswords(
      File(path + Platform.pathSeparator + 'passwords.enc'),
    ),
    passwordIcons: PassyImages(path + Platform.pathSeparator + 'password_icons',
        encrypter: encrypter),
    notes: _loadNotes(File(path + Platform.pathSeparator + 'notes.enc')),
    paymentCards: _loadPaymentCards(
        File(path + Platform.pathSeparator + 'payment_cards.enc')),
    idCards: _loadIDCards(File(path + Platform.pathSeparator + 'id_cards.enc')),
    identities: _loadIdentities(
      File(path + Platform.pathSeparator + 'identities.enc'),
    ),
  );

  _account.saveSync();

  return _account;
}
