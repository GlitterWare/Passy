import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:universal_io/io.dart';

import 'account_info.dart';
import 'common.dart';
import 'entry_event.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

class LoadedAccount {
  final AccountInfoFile _accountInfo;
  final HistoryFile _history;
  final PasswordsFile _passwords;
  final Images _passwordIcons;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;
  Encrypter _encrypter;

  void _setAccountPassword(String password) {
    _accountInfo.value.password = password;
    _encrypter = getEncrypter(password);
    _history.encrypter = _encrypter;
    _passwords.encrypter = _encrypter;
    _passwordIcons.encrypter = _encrypter;
    _notes.encrypter = _encrypter;
    _paymentCards.encrypter = _encrypter;
    _idCards.encrypter = _encrypter;
    _identities.encrypter = _encrypter;
  }

  Future<void> setAccountPassword(String password) {
    _setAccountPassword(password);
    return save();
  }

  void setAccountPasswordSync(String password) {
    _setAccountPassword(password);
    saveSync();
  }

  Future<void> save() async {
    await _accountInfo.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _accountInfo.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  //TODO: catch exceptions
  Future<HostAddress?> host() async {
    print('HOST: Hosting... ');
    HostAddress? _address;
    //TODO: add error handling to bind (Could not listen on {ip}:{port}.)
    await ServerSocket.bind('127.0.0.1', 0).then((s) {
      _address = HostAddress(s.address, s.port);
      bool _connected = false;
      s.listen(
        (c) {
          if (_connected) c.close();
          _connected = true;
          StreamSubscription<Uint8List> _sub = c.listen(null);
          String _random = '';
          String _dataJson = '';

          //TODO: receive and merge data + merge history
          void _receiveData(Uint8List d) {
            print('done.\nHOST: Receiving data... ');
            s.close();
          }

          //TODO: send relevant history and data + request missing data
          void _sendData() {
            print('done.\nHOST: Sending data... ');
            s.close();
          }

          //TODO: receive and compare history
          void _receiveHistory(Uint8List d) {
            print('done.\nHOST: Receiving history... ');
            s.close();
          }

          void _sendHistoryHash() {
            print('done.\nHOST: Sending history hash... ');
            _sub.onData(_receiveHistory);
            c.add(getHash(jsonEncode(_history)).bytes);
            c.flush();
          }

          void _receiveHello(Uint8List d) {
            print('done.\nHOST: Receiving hello... ');
            Map<String, dynamic> _json;
            String _remoteRandom;
            try {
              _json = jsonDecode(utf8.decode(d));
            } catch (e) {
              print(
                  'HOST: Local exception has occurred: Could not decode hello json. ${e.toString()}');
              s.close();
              return;
            }
            if (!_json.containsKey('service')) {
              print(
                  'HOST: Local exception has occurred: There is no key named "service"');
              s.close();
              return;
            }
            if (_json['service'] != 'passy') {
              print(
                  'HOST: Local error has occurred: Remote service is not Passy');
              s.close();
              return;
            }
            if (!_json.containsKey('version')) {
              String _err = 'There is no key named version.';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            if (passyVersion != _json['version']) {
              String _err =
                  'Local and remote versions are different. Local version: $passyVersion. Remote version: ${_json['version']}.';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            if (!_json.containsKey('random')) {
              String _err = 'There is no key named "random".';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            try {
              _remoteRandom = decrypt(_json['random'], encrypter: _encrypter);
            } catch (e) {
              String _err =
                  'Could not decrypt random. Make sure that local and remote username and password are the same. ${e.toString()}.';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            if (_random != _remoteRandom) {
              String _err =
                  'Local and remote random are different. Make sure that local and remote username and password are the same.';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            _sendHistoryHash();
          }

          void _sendHello() {
            print('done.\nHOST: Sending hello... ');
            _sub.onData(_receiveHello);
            _random = random.nextInt(1000).toRadixString(36);
            c.add(utf8.encode(
                '{"service":"passy","version":"$passyVersion","random":"${encrypt(encrypt(_random, encrypter: getEncrypter(_accountInfo.value.username)), encrypter: _encrypter)}"}'));
            c.flush();
          }

          _sendHello();
        },
        onError: (e) {
          print('HOST: Remote exception has occurred: $e');
          s.close();
        },
        onDone: () => s.close(),
      );
    });
    return _address;
  }

  Future<void> connect(HostAddress address) {
    print('SYNC: Connecting... ');
    //TODO: add onError to Socket.connect (could not connect to remote)
    return Socket.connect(address.ip, address.port).then(
      (s) {
        StreamSubscription<Uint8List> _sub = s.listen(
          null,
          onError: (e) {
            print('SYNC: Remote exception has occurred: $e');
            s.destroy();
          },
        );
        String _historyJson = '';

        //TODO: send requested data
        void _sendData() {
          print('done\nSYNC: Sending data... ');
          s.destroy();
        }

        //TODO: split receive data into multiple parts (Password, PasswordIcon, Note, PaymentCard, IDCard, Identity)
        //TODO: receive and merge data and history
        void _receiveData(Uint8List d) {
          print('done\nSYNC: Receiving data... ');
          s.destroy();
        }

        void _sendHistory() {
          print('done\nSYNC: Sending history... ');
          _sub.onData(_receiveData);
          s.add(utf8.encode(encrypt(_historyJson, encrypter: _encrypter)));
          s.flush();
        }

        void _receiveHistoryHash(Uint8List d) {
          print('done\nSYNC: Receiving history hash... ');
          _historyJson = jsonEncode(_history);
          bool _same = true;
          try {
            _same = getHash(_historyJson) == Digest(d);
          } catch (e) {
            String _err = 'Could not read history hash.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          if (_same) {
            String _err = 'Local and remote histories are the same.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          _sendHistory();
        }

        void _sendHello(String random) {
          print('done.\nSYNC: Sending hello... ');
          _sub.onData(_receiveHistoryHash);
          s.add(utf8.encode(
              '{"service":"passy","version":"$passyVersion","random":"${encrypt(random, encrypter: _encrypter)}"}'));
          s.flush();
        }

        void _receiveHello(Uint8List d) {
          print('done.\nSYNC: Receiving hello... ');
          Map<String, dynamic> _json = {};
          String _random = '';
          try {
            _json = jsonDecode(utf8.decode(d));
          } catch (e) {
            print(
                'SYNC: Local exception has occurred: Could not decode hello json. ${e.toString()}');
            s.destroy();
            return;
          }
          if (!_json.containsKey('service')) {
            print(
                'SYNC: Local exception has occurred: There is no key named "service"');
            s.destroy();
            return;
          }
          if (_json['service'] != 'passy') {
            print(
                'SYNC: Local error has occurred: Remote service is not Passy');
            s.destroy();
            return;
          }
          if (!_json.containsKey('version')) {
            String _err = 'There is no key named "version".';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          if (passyVersion != _json['version']) {
            String _err =
                'Local and remote versions are different. Local version: $passyVersion. Remote version: ${_json['version']}.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          if (!_json.containsKey('random')) {
            String _err = 'There is no key named "random".';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          try {
            _random = decrypt(
              decrypt(_json['random'], encrypter: _encrypter),
              encrypter: getEncrypter(_accountInfo.value.username),
            );
          } catch (e) {
            String _err =
                'Could not decrypt random. Make sure that username and password are the same for both local and remote. ${e.toString()}.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          _sendHello(_random);
        }

        _sub.onData(_receiveHello);
      },
    );
    // Ask server for data hashes, if they are not the same, exchange data
  }

  // Account Info wrappers
  String get username => _accountInfo.value.username;
  set username(String value) => _accountInfo.value.username = value;
  String get icon => _accountInfo.value.icon;
  set icon(String value) => _accountInfo.value.icon = value;
  Color get color => _accountInfo.value.color;
  set color(Color value) => _accountInfo.value.color = color;
  String get passwordHash => _accountInfo.value.passwordHash;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.value.entries;
  void addPassword(Password password) {
    _history.value.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.value.add(password);
  }

  void setPassword(Password password) {
    _history.value.passwords[password.creationDate]!.lastModified =
        DateTime.now();
    _passwords.value.sort();
  }

  void removePassword(Password password) {
    _history.value.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _passwords.value.remove(password);
  }

  // Password Icons wrappers
  Uint8List? getPasswordIcon(String name) => _passwordIcons.getImage(name);

  void setPasswordIcon(String name, Uint8List image) {
    _history.value.passwordIcons[name] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwordIcons.setImage(name, image);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.value.entries;
  void addNote(Note note) {
    _history.value.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _notes.value.add(note);
  }

  void setNote(Note note) {
    _history.value.notes[note.creationDate]!.lastModified = DateTime.now();
    _notes.value.sort();
  }

  void removeNote(Note note) {
    _history.value.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _notes.value.remove(note);
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.value.entries;
  void addPaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _paymentCards.value.add(paymentCard);
  }

  void setPaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.creationDate]!.lastModified =
        DateTime.now();
    _paymentCards.value.sort();
  }

  void removePaymentCard(PaymentCard paymentCard) {
    _history.value.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _paymentCards.value.remove(paymentCard);
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.value.entries;
  void addIDCard(IDCard idCard) {
    _history.value.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _idCards.value.add(idCard);
  }

  void setIDCard(IDCard idCard) {
    _history.value.idCards[idCard.creationDate]!.lastModified = DateTime.now();
    _idCards.value.sort();
  }

  void removeIDCard(IDCard idCard) {
    _history.value.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _idCards.value.remove(idCard);
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.value.entries;
  void addIdentity(Identity identity) {
    _history.value.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _identities.value.add(identity);
  }

  void setIdentity(Identity identity) {
    _history.value.identities[identity.creationDate]!.lastModified =
        DateTime.now();
    _identities.value.sort();
  }

  void removeIdentity(Identity identity) {
    _history.value.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _identities.value.remove(identity);
  }

  LoadedAccount(
    AccountInfo accountInfo, {
    required String path,
    required Encrypter encrypter,
  })  : _encrypter = encrypter,
        _accountInfo = AccountInfoFile(
            File(path + Platform.pathSeparator + 'info.json'),
            value: accountInfo),
        _history = HistoryFile(
            File(path + Platform.pathSeparator + 'history.enc'), encrypter),
        _passwords = PasswordsFile(
            File(path + Platform.pathSeparator + 'passwords.enc'), encrypter),
        _passwordIcons = Images(
            path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = NotesFile(
            File(path + Platform.pathSeparator + 'notes.enc'), encrypter),
        _paymentCards = PaymentCardsFile(
            File(path + Platform.pathSeparator + 'payment_cards.enc'),
            encrypter),
        _idCards = IDCardsFile(
            File(path + Platform.pathSeparator + 'id_cards.enc'), encrypter),
        _identities = IdentitiesFile(
            File(path + Platform.pathSeparator + 'identities.enc'), encrypter);
}
