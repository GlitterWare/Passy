import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:universal_io/io.dart';

import 'common.dart';
import 'entry_event.dart';
import 'history.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'password.dart';
import 'payment_card.dart';
import 'account_info.dart';
import 'dated_entries.dart';
import 'note.dart';

class LoadedAccount {
  final AccountInfo _accountInfo;
  final History _history;
  final DatedEntries<Password> _passwords;
  final Images _passwordIcons;
  final DatedEntries<Note> _notes;
  final DatedEntries<PaymentCard> _paymentCards;
  final DatedEntries<IDCard> _idCards;
  final DatedEntries<Identity> _identities;
  Encrypter _encrypter;

  void _setAccountPassword(String password) {
    _accountInfo.password = password;
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

          //TODO: receive and merge data + merge history
          void _receiveData(Uint8List d) {
            print('done.\nHOTS: Receiving data... ');
            s.close();
          }

          //TODO: send relevant history and data + request missing data
          void _sendData() {
            print('done.\nHOTS: Sending data... ');
            Map<String, dynamic> _json = {
              'passwords': {},
              'passwordIcons': {},
              'notes': {},
              'paymentCards': {},
              'idCards': {},
              'identities': {},
            };
            _sub.onData(_receiveData);
            c.add(utf8.encode(
                '{"history":"${encrypt(jsonEncode(_json), encrypter: _encrypter)}","data":"","request":""}'));
          }

          //TODO: receive and compare history
          void _receiveHistory(Uint8List d) {
            print('done.\nHOTS: Receiving history... ');
            Map<String, dynamic> _json =
                jsonDecode(decrypt(utf8.decode(d), encrypter: _encrypter));
            print(_json);
            s.close();
          }

          void _sendHistoryHash() {
            print('done.\nHOTS: Sending history hash... ');
            _sub.onData(_receiveHistory);
            c.add(getHash(jsonEncode(_history)).bytes);
          }

          void _receiveHello(Uint8List d) {
            print('done.\nHOST: Receiving hello... ');
            Map<String, dynamic> _json = {};
            String _remoteRandom = '';
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
                  'HOST: Local exception has occurred: There is no key named service');
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
            if (data.info.version != _json['version']) {
              String _err =
                  'Local and remote versions are different. Local version: ${data.info.version}. Remote version: ${_json['version']}.';
              print('HOST: Local exception has occurred: $_err');
              c.addError(_err);
              c.flush().whenComplete(() => s.close());
              return;
            }
            if (!_json.containsKey('random')) {
              String _err = 'There is no key named random.';
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
                '{"service":"passy","version":"${data.info.version}","random":"${encrypt(encrypt(_random, encrypter: getEncrypter(_accountInfo.username)), encrypter: _encrypter)}"}'));
            c.flush();
          }

          _sendHello();
        },
        onError: (e) {
          print(e.runtimeType);
          s.close();
        },
        onDone: () => s.close(),
      );
    });
    return _address;
  }

  Future<void> connect(HostAddress address) {
    print('SYNC: Synchronizing... ');
    //TODO: add onError to Socket.connect (could not connect to remote)
    return Socket.connect(address.ip, address.port).then(
      (s) {
        StreamSubscription<Uint8List> _sub = s.listen(
          null,
          onError: (e) {
            print(e.runtimeType);
            s.destroy();
          },
        );
        String _historyJson = '';

        //TODO: send requested data
        void _sendData() {
          print('done\nSYNC: Sending data... ');
          s.destroy();
        }

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
              '{"service":"passy","version":"${data.info.version}","random":"${encrypt(random, encrypter: _encrypter)}"}'));
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
                'SYNC: Local exception has occurred: There is no key named service');
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
            String _err = 'There is no key named version.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          if (data.info.version != _json['version']) {
            String _err =
                'Local and remote versions are different. Local version: ${data.info.version}. Remote version: ${_json['version']}.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          if (!_json.containsKey('random')) {
            String _err = 'There is no key named random.';
            print('SYNC: Local exception has occurred: $_err');
            s.addError(_err);
            s.flush().whenComplete(() => s.destroy());
            return;
          }
          try {
            _random = decrypt(
              decrypt(_json['random'], encrypter: _encrypter),
              encrypter: getEncrypter(_accountInfo.username),
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
  String get username => _accountInfo.username;
  set username(String value) => _accountInfo.username = value;
  String get icon => _accountInfo.icon;
  set icon(String value) => _accountInfo.icon = value;
  Color get color => _accountInfo.color;
  set color(Color value) => _accountInfo.color = color;
  String get passwordHash => _accountInfo.passwordHash;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.entries;
  void addPassword(Password password) {
    _history.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.add(password);
  }

  void setPassword(Password password) =>
      _history.passwords[password.creationDate]!.lastModified = DateTime.now();

  void removePassword(Password password) {
    _history.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _passwords.remove(password);
  }

  // Password Icons wrappers
  Uint8List? getPasswordIcon(String name) => _passwordIcons.getImage(name);

  void setPasswordIcon(String name, Uint8List image) {
    _history.passwordIcons[name] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwordIcons.setImage(name, image);
  }

  // Notes wrappers
  Iterable<Note> get notes => _notes.entries;
  void addNote(Note note) {
    _history.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _notes.add(note);
  }

  void setNote(Note note) =>
      _history.notes[note.creationDate]!.lastModified = DateTime.now();

  void removeNote(Note note) {
    _history.notes[note.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _notes.remove(note);
  }

  // Payment Cards wrappers
  Iterable<PaymentCard> get paymentCards => _paymentCards.entries;
  void addPaymentCard(PaymentCard paymentCard) {
    _history.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _paymentCards.add(paymentCard);
  }

  void setPaymentCard(PaymentCard paymentCard) =>
      _history.paymentCards[paymentCard.creationDate]!.lastModified =
          DateTime.now();

  void removePaymentCard(PaymentCard paymentCard) {
    _history.paymentCards[paymentCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _paymentCards.remove(paymentCard);
  }

  // ID Cards wrappers
  Iterable<IDCard> get idCards => _idCards.entries;
  void addIDCard(IDCard idCard) {
    _history.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _idCards.add(idCard);
  }

  void setIDCard(IDCard idCard) =>
      _history.idCards[idCard.creationDate]!.lastModified = DateTime.now();

  void removeIDCard(IDCard idCard) {
    _history.idCards[idCard.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _idCards.remove(idCard);
  }

  // Identities wrappers
  Iterable<Identity> get identities => _identities.entries;
  void addIdentity(Identity identity) {
    _history.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _identities.add(identity);
  }

  void setIdentity(Identity identity) =>
      _history.identities[identity.creationDate]!.lastModified = DateTime.now();

  void removeIdentity(Identity identity) {
    _history.identities[identity.creationDate] = EntryEvent(
        status: EntryStatus.removed, lastModified: DateTime.now().toUtc());
    _identities.remove(identity);
  }

  LoadedAccount(this._accountInfo, {required Encrypter encrypter})
      : _history = History(
            File(_accountInfo.path + Platform.pathSeparator + 'history.enc'),
            encrypter: encrypter),
        _passwords = DatedEntries<Password>(
            File(_accountInfo.path + Platform.pathSeparator + 'passwords.enc'),
            encrypter: encrypter),
        _passwordIcons = Images(
            _accountInfo.path + Platform.pathSeparator + 'password_icons',
            encrypter: encrypter),
        _notes = DatedEntries<Note>(
            File(_accountInfo.path + Platform.pathSeparator + 'notes.enc'),
            encrypter: encrypter),
        _paymentCards = DatedEntries<PaymentCard>(
            File(_accountInfo.path +
                Platform.pathSeparator +
                'payment_cards.enc'),
            encrypter: encrypter),
        _idCards = DatedEntries<IDCard>(
            File(_accountInfo.path + Platform.pathSeparator + 'id_cards.enc'),
            encrypter: encrypter),
        _identities = DatedEntries<Identity>(
            File(_accountInfo.path + Platform.pathSeparator + 'identities.enc'),
            encrypter: encrypter),
        _encrypter = encrypter;
}
