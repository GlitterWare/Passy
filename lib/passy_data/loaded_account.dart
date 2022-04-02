import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/widgets.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:universal_io/io.dart';

import 'account_credentials.dart';
import 'account_info.dart';
import 'common.dart';
import 'entry_event.dart';
import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

class _Hello implements JsonConvertable {
  final String service;
  final String version;
  final String random;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'service': service,
        'version': version,
        'random': random,
      };

  factory _Hello.fromJson(Map<String, dynamic> json) => _Hello(
        service: json['service'],
        version: json['version'],
        random: json['random'],
      );

  _Hello({
    required this.service,
    required this.version,
    required this.random,
  });
}

class _DataEntry implements JsonConvertable {
  final String key;

  /// Value can be Map<String, dynamic> if DatedEntry or String if image
  final dynamic value;

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'entry': value,
      };

  factory _DataEntry.fromJson(Map<String, dynamic> json) =>
      _DataEntry(key: json['key'], value: json['entry']);

  _DataEntry({
    required this.key,
    required this.value,
  });
}

class _Request implements JsonConvertable {
  final List<DateTime> passwords;
  final List<String> passwordIcons;
  final List<DateTime> notes;
  final List<DateTime> paymentCards;
  final List<DateTime> idCards;
  final List<DateTime> identities;

  @override
  Map<String, dynamic> toJson() => {
        'passwords': passwords.map<String>((e) => e.toIso8601String()).toList(),
        'passwordIcons': passwordIcons,
        'notes': notes.map<String>((e) => e.toIso8601String()).toList(),
        'paymentCards':
            paymentCards.map<String>((e) => e.toIso8601String()).toList(),
        'idCards': idCards.map<String>((e) => e.toIso8601String()).toList(),
        'identities':
            identities.map<String>((e) => e.toIso8601String()).toList(),
      };

  factory _Request.fromJson(Map<String, dynamic> json) => _Request(
        passwords: (json['passwords'] as List<dynamic>)
            .map((e) => DateTime.parse(e))
            .toList(),
        passwordIcons: (json['passwordIcons'] as List<dynamic>).cast<String>(),
        notes: (json['notes'] as List<dynamic>)
            .map((e) => DateTime.parse(e))
            .toList(),
        paymentCards: (json['paymentCards'] as List<dynamic>)
            .map((e) => DateTime.parse(e))
            .toList(),
        idCards: (json['idCards'] as List<dynamic>)
            .map((e) => DateTime.parse(e))
            .toList(),
        identities: (json['identities'] as List<dynamic>)
            .map((e) => DateTime.parse(e))
            .toList(),
      );

  _Request({
    List<DateTime>? passwords,
    List<String>? passwordIcons,
    List<DateTime>? notes,
    List<DateTime>? paymentCards,
    List<DateTime>? idCards,
    List<DateTime>? identities,
  })  : passwords = passwords ?? [],
        passwordIcons = passwordIcons ?? [],
        notes = notes ?? [],
        paymentCards = paymentCards ?? [],
        idCards = idCards ?? [],
        identities = identities ?? [];
}

class _ServerInfo implements JsonConvertable {
  final History history;
  final _Request request;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'history': history.toJson(),
        'request': request.toJson(),
      };

  factory _ServerInfo.fromJson(Map<String, dynamic> json) => _ServerInfo(
        history: History.fromJson(json['history']),
        request: _Request.fromJson(json['request']),
      );

  _ServerInfo({
    History? history,
    _Request? request,
  })  : history = history ?? History(),
        request = request ?? _Request();
}

class LoadedAccount {
  final AccountCredentialsFile _credentials;
  final AccountSettingsFile _settings;
  final HistoryFile _history;
  final PasswordsFile _passwords;
  final Images _passwordIcons;
  final NotesFile _notes;
  final PaymentCardsFile _paymentCards;
  final IDCardsFile _idCards;
  final IdentitiesFile _identities;
  Encrypter _encrypter;
  ServerSocket? _server;

  void _setAccountPassword(String password) {
    _credentials.value.password = password;
    _encrypter = getEncrypter(password);
    _settings.encrypter = _encrypter;
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
    await _settings.save();
    await _history.save();
    await _passwords.save();
    await _passwordIcons.save();
    await _notes.save();
    await _paymentCards.save();
    await _idCards.save();
    await _identities.save();
  }

  void saveSync() {
    _settings.saveSync();
    _history.saveSync();
    _passwords.saveSync();
    _passwordIcons.saveSync();
    _notes.saveSync();
    _paymentCards.saveSync();
    _idCards.saveSync();
    _identities.saveSync();
  }

  List<List<int>> _encodeData(_Request request) {
    List<List<int>> _data = [];

    for (var element in request.passwords) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element.toIso8601String(),
              value: _passwords.value.getEntry(element)!.toJson())),
          encrypter: _encrypter)));
    }
    for (var element in request.passwordIcons) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element, value: _passwordIcons.getImage(element))),
          encrypter: _encrypter)));
    }
    for (var element in request.notes) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element.toIso8601String(),
              value: _notes.value.getEntry(element)!.toJson())),
          encrypter: _encrypter)));
    }
    for (var element in request.paymentCards) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element.toIso8601String(),
              value: _paymentCards.value.getEntry(element)!.toJson())),
          encrypter: _encrypter)));
    }
    for (var element in request.idCards) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element.toIso8601String(),
              value: _idCards.value.getEntry(element)!.toJson())),
          encrypter: _encrypter)));
    }
    for (var element in request.identities) {
      _data.add(utf8.encode(encrypt(
          jsonEncode(_DataEntry(
              key: element.toIso8601String(),
              value: _identities.value.getEntry(element)!.toJson())),
          encrypter: _encrypter)));
    }
    return _data;
  }

  Future<HostAddress?> host(BuildContext context) async {
    String _log = 'Hosting... ';
    HostAddress? _address;
    String _ip = '127.0.0.1';
    List<NetworkInterface> _interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (NetworkInterface element in _interfaces) {
      for (InternetAddress ip in element.addresses) {
        List<String> _ipList = ip.address.split('.');
        if (_ipList[2] == '1') _ip = ip.address;
      }
    }

    void _logException(String message,
        {String prefix = 'Local exception has occurred: '}) {
      String _exception = '\n' + prefix + message;
      _log += _exception;
      print(_log);
    }

    try {
      if (_server != null) await _server!.close();
      _server = await ServerSocket.bind(_ip, 0);
      _log += 'done. \nListening...';
      _address = HostAddress(InternetAddress(_ip), _server!.port);

      bool _connected = false;

      void _logExceptionAndDisconnect(String message,
          {String prefix = 'Local exception has occurred: '}) {
        _logException(message, prefix: prefix);
        _server!.close();
      }

      _server!.listen(
        (socket) {
          if (_connected) {
            socket.close();
            return;
          }

          _connected = true;
          StreamSubscription<Uint8List> _sub = socket.listen(null);

          void _sendData() {
            _log += 'done.\nSending data...';
            _server!.close();
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.routeName, (r) => false);
          }

          void _receiveData(
            Uint8List data, {
            required Map<String, EntryType> entryTypes,
            required History remoteHistory,
          }) {
            _DataEntry _entry;
            try {
              _entry = _DataEntry.fromJson(jsonDecode(
                  decrypt(utf8.decode(data), encrypter: _encrypter)));
            } catch (e) {
              _logExceptionAndDisconnect(
                  'Could not decode an entry.\n${e.toString()}');
              return;
            }

            try {
              switch (entryTypes[_entry.key]!) {
                case EntryType.password:
                  Password _decoded = Password.fromJson(_entry.value);
                  _passwords.value.addOrSetEntry(_decoded);
                  _history.value.passwords[_decoded.creationDate] =
                      remoteHistory.passwords[_decoded.creationDate]!;
                  break;
                case EntryType.passwordIcon:
                  _passwordIcons.setImage(
                      _entry.key, base64.decode(_entry.value as String));
                  _history.value.passwordIcons[_entry.key] =
                      remoteHistory.passwordIcons[_entry.key]!;
                  break;
                case EntryType.paymentCard:
                  PaymentCard _decoded = PaymentCard.fromJson(_entry.value);
                  _paymentCards.value
                      .addOrSetEntry(PaymentCard.fromJson(_entry.value));
                  _history.value.paymentCards[_decoded.creationDate] =
                      remoteHistory.paymentCards[_decoded.creationDate]!;
                  break;
                case EntryType.note:
                  Note _decoded = Note.fromJson(_entry.value);
                  _notes.value.addOrSetEntry(Note.fromJson(_entry.value));
                  _history.value.notes[_decoded.creationDate] =
                      remoteHistory.notes[_decoded.creationDate]!;
                  break;
                case EntryType.idCard:
                  IDCard _decoded = IDCard.fromJson(_entry.value);
                  _idCards.value.addOrSetEntry(IDCard.fromJson(_entry.value));
                  _history.value.idCards[_decoded.creationDate] =
                      remoteHistory.idCards[_decoded.creationDate]!;
                  break;
                case EntryType.identity:
                  Identity _decoded = Identity.fromJson(_entry.value);
                  _identities.value
                      .addOrSetEntry(Identity.fromJson(_entry.value));
                  _history.value.identities[_decoded.creationDate] =
                      remoteHistory.identities[_decoded.creationDate]!;
                  break;
              }
            } catch (e) {
              _logExceptionAndDisconnect(
                  'Could not add an entry.\n${e.toString()}');
            }
          }

          void _sendInfo(_ServerInfo info) {
            _log += 'done.\nHOST: Sending info... ';
            socket.add(
                utf8.encode(encrypt(jsonEncode(info), encrypter: _encrypter)));
            socket.flush();
          }

          void _receiveHistory(Uint8List data) {
            _log += 'done.\nReceiving history... ';
            Map<String, EntryType> _entryTypes = {};
            _ServerInfo _info = _ServerInfo();
            History _remoteHistory;
            int _toReceive;

            try {
              _remoteHistory = History.fromJson(jsonDecode(
                  decrypt(utf8.decode(data), encrypter: _encrypter)));
            } catch (e) {
              _logExceptionAndDisconnect(
                  'Could not decode history.\n${e.toString()}');
              return;
            }

            _remoteHistory.passwords.forEach((key, value) {
              if (!_history.value.passwords.containsKey(key)) {
                _info.request.passwords.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.password;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.passwords[key]!.lastModified)) {
                _info.request.passwords.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.password;
              }
            });
            _remoteHistory.passwordIcons.forEach((key, value) {
              if (!_history.value.passwordIcons.containsKey(key)) {
                _info.request.passwordIcons.add(key);
                _entryTypes[key] = EntryType.passwordIcon;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.passwordIcons[key]!.lastModified)) {
                _info.request.passwordIcons.add(key);
                _entryTypes[key] = EntryType.passwordIcon;
              }
            });
            _remoteHistory.notes.forEach((key, value) {
              if (!_history.value.notes.containsKey(key)) {
                _info.request.notes.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.note;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.notes[key]!.lastModified)) {
                _info.request.notes.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.note;
              }
            });
            _remoteHistory.paymentCards.forEach((key, value) {
              if (!_history.value.paymentCards.containsKey(key)) {
                _info.request.paymentCards.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.paymentCard;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.paymentCards[key]!.lastModified)) {
                _info.request.paymentCards.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.paymentCard;
              }
            });
            _remoteHistory.idCards.forEach((key, value) {
              if (!_history.value.idCards.containsKey(key)) {
                _info.request.idCards.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.idCard;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.idCards[key]!.lastModified)) {
                _info.request.idCards.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.idCard;
              }
            });
            _remoteHistory.identities.forEach((key, value) {
              if (!_history.value.identities.containsKey(key)) {
                _info.request.identities.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.identity;
                return;
              }
              if (value.lastModified
                  .isAfter(_history.value.identities[key]!.lastModified)) {
                _info.request.identities.add(key);
                _entryTypes[key.toIso8601String()] = EntryType.identity;
              }
            });

            _toReceive = _entryTypes.length;

            _log += 'done.\nReceiving data... ';
            _sub.onData((data) {
              _toReceive--;
              _receiveData(data,
                  entryTypes: _entryTypes, remoteHistory: _remoteHistory);
              if (_toReceive == 0) {
                saveSync();
                _sendData();
                return;
              }
            });
            _sendInfo(_info);
          }

          void _sendHistoryHash() {
            _log += 'done.\nSending history hash... ';
            _sub.onData(_receiveHistory);
            socket.add(getHash(jsonEncode(_history.value)).bytes);
            socket.flush();
          }

          void _receiveHello(Uint8List data, String random) {
            _log += 'done.\nReceiving hello... ';
            _Hello _hello;
            String _random;
            try {
              _hello = _Hello.fromJson(jsonDecode(utf8.decode(data)));
            } catch (e) {
              _logExceptionAndDisconnect(
                  'Could not decode hello.\n${e.toString()}');
              return;
            }
            if (_hello.service != 'passy') {
              _logExceptionAndDisconnect('Remote service is not Passy.');
              return;
            }
            if (passyVersion != _hello.version) {
              _logExceptionAndDisconnect(
                  'Local and remote versions are different. Local version: $passyVersion. Remote version: ${_hello.version}.');
              return;
            }
            try {
              _random = decrypt(_hello.random, encrypter: _encrypter);
            } catch (e) {
              _logExceptionAndDisconnect(
                  'Could not decrypt random. Make sure that local and remote username and password are the same.\n${e.toString()}');
              return;
            }
            if (random != _random) {
              _logExceptionAndDisconnect(
                  'Local and remote randoms are different. Make sure that local and remote username and password are the same.');
              return;
            }
            _sendHistoryHash();
          }

          void _sendHello() {
            _log += 'done.\nSending hello... ';
            String _random = random.nextInt(1000).toRadixString(36);
            _sub.onData((data) => _receiveHello(data, _random));
            socket.add(utf8.encode(jsonEncode(_Hello(
                service: 'passy',
                version: passyVersion,
                random: encrypt(
                    encrypt(_random,
                        encrypter: getEncrypter(_credentials.value.username)),
                    encrypter: _encrypter)))));
            socket.flush();
          }

          Navigator.pushNamedAndRemoveUntil(
              context, SplashScreen.routeName, (r) => false);
          _sendHello();
        },
        onError: (e) => _logExceptionAndDisconnect(utf8.decode(e),
            prefix: 'Remote exception has occurred: '),
        onDone: () => _server!.close(),
      );
      return _address;
    } catch (e) {
      _logException('Failed to host.\n${e.toString()}');
    }
    return null;
  }

  Future<void> connect(HostAddress address, BuildContext context) {
    String _log = 'Connecting... ';
    void _logException(String message,
        {String prefix = 'Local exception has occurred: '}) {
      String _exception = '\n' + prefix + message;
      _log += _exception;
      print(_log);
    }

    return Socket.connect(address.ip, address.port).then((socket) {
      void _logExceptionAndDisconnect(String message,
          {String prefix = 'Local exception has occurred: '}) {
        _logException(message, prefix: prefix);
        socket.destroy();
      }

      StreamSubscription<Uint8List> _sub = socket.listen(
        null,
        onError: (e) => _logExceptionAndDisconnect(utf8.decode(e),
            prefix: 'SYNC: Local exception has occurred: '),
      );

      void _receiveData(Uint8List data) {
        //TODO: receive data from server
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.routeName, (r) => false);
        socket.destroy();
      }

      Future<void> _sendData(_Request request) async {
        _log += 'done\nSending data... ';
        List<List<int>> _data = _encodeData(request);
        if (_data.isEmpty) {
          socket.add(utf8.encode('ready'));
          return;
        }
        for (List<int> element in _data) {
          socket.add(element);
          await socket.flush();
        }
      }

      void _receiveInfo(Uint8List data) {
        _log += 'done.\nReceiving info... ';
        _ServerInfo _info;
        try {
          _info = _ServerInfo.fromJson(
              jsonDecode(decrypt(utf8.decode(data), encrypter: _encrypter)));
        } catch (e) {
          _logExceptionAndDisconnect('Could not decode info.\n${e.toString()}');
          return;
        }
        _sub.onData(_receiveData);
        _sendData(_info.request);
      }

      void _sendHistory(String historyJson) {
        _log += 'done.\nSending history... ';
        socket.add(utf8.encode(encrypt(historyJson, encrypter: _encrypter)));
        socket.flush();
      }

      void _receiveHistoryHash(Uint8List data) {
        _log += 'done.\nReceiving history hash... ';
        String _historyJson = jsonEncode(_history.value);
        bool _same = true;
        try {
          _same = getHash(_historyJson) == Digest(data);
        } catch (e) {
          _logExceptionAndDisconnect('Could not read history hash.');
          return;
        }
        if (_same) {
          _logExceptionAndDisconnect(
              'Local and remote histories are the same.');
          return;
        }
        _sub.onData(_receiveInfo);
        _sendHistory(_historyJson);
      }

      void _sendHello(_Hello hello) {
        _log += 'done.\nSending hello... ';

        socket.add(utf8.encode(jsonEncode(hello)));
        socket.flush();
      }

      void _receiveHello(Uint8List data) {
        _log += 'done.\nReceiving hello... ';
        _Hello _hello;
        String _random = '';
        try {
          _hello = _Hello.fromJson(jsonDecode(utf8.decode(data)));
        } catch (e) {
          _logExceptionAndDisconnect(
              'Could not decode hello.\n${e.toString()}');
          return;
        }
        if (_hello.service != 'passy') {
          _logExceptionAndDisconnect('Remote service is not Passy.');
          return;
        }
        if (passyVersion != _hello.version) {
          _logExceptionAndDisconnect(
              'Local and remote versions are different. Local version: $passyVersion. Remote version: ${_hello.version}.');
          return;
        }
        try {
          _random = decrypt(
            decrypt(_hello.random, encrypter: _encrypter),
            encrypter: getEncrypter(_credentials.value.username),
          );
        } catch (e) {
          _logExceptionAndDisconnect(
              'Could not decrypt random. Make sure that username and password are the same for both local and remote.\n${e.toString()}');
          return;
        }
        _sub.onData(_receiveHistoryHash);
        _sendHello(_Hello(
            service: 'passy',
            version: passyVersion,
            random: encrypt(_random, encrypter: _encrypter)));
      }

      _sub.onData(_receiveHello);
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.routeName, (r) => false);
    }, onError: (e) => _logException('Failed to connect. ${e.toString()}'));
    // Ask server for data hashes, if they are not the same, exchange data
  }

  // Account Credentials wrappers
  String get username => _credentials.value.username;
  set username(String value) => _credentials.value.username = value;
  String get passwordHash => _credentials.value.passwordHash;

  // Account Info wrappers
  String get icon => _settings.value.icon;
  set icon(String value) => _settings.value.icon = value;
  Color get color => _settings.value.color;
  set color(Color value) => _settings.value.color = color;

  // Passwords wrappers
  Iterable<Password> get passwords => _passwords.value.entries;
  void addPassword(Password password) {
    _history.value.passwords[password.creationDate] = EntryEvent(
        status: EntryStatus.alive, lastModified: DateTime.now().toUtc());
    _passwords.value.addEntry(password);
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
    _notes.value.addEntry(note);
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
    _paymentCards.value.addEntry(paymentCard);
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
    _idCards.value.addEntry(idCard);
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
    _identities.value.addEntry(identity);
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
    AccountCredentialsFile credentials, {
    required String path,
    required Encrypter encrypter,
  })  : _encrypter = encrypter,
        _credentials = credentials,
        _settings = AccountSettingsFile(
            File(path + Platform.pathSeparator + 'settings.enc'), encrypter),
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
