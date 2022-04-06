import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/entry_event.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_stream_subscription.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:universal_io/io.dart';

import 'history.dart';
import 'host_address.dart';
import 'id_card.dart';
import 'identity.dart';
import 'images.dart';
import 'json_convertable.dart';
import 'note.dart';
import 'password.dart';
import 'payment_card.dart';

const String _hello = 'hello';
const String _sameHistoryHash = 'same';

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
  final List<String> passwords;
  final List<String> passwordIcons;
  final List<String> notes;
  final List<String> paymentCards;
  final List<String> idCards;
  final List<String> identities;

  Map<String, List<String>> toMap() => {
        'passwords': passwords,
        'passwordIcons': passwordIcons,
        'notes': notes,
        'paymentCards': paymentCards,
        'idCards': idCards,
        'identities': identities,
      };

  @override
  Map<String, dynamic> toJson() => toMap();

  factory _Request.fromJson(Map<String, dynamic> json) => _Request(
        passwords: (json['passwords'] as List<dynamic>).cast<String>(),
        passwordIcons: (json['passwordIcons'] as List<dynamic>).cast<String>(),
        notes: (json['notes'] as List<dynamic>).cast<String>(),
        paymentCards: (json['paymentCards'] as List<dynamic>).cast<String>(),
        idCards: (json['idCards'] as List<dynamic>).cast<String>(),
        identities: (json['identities'] as List<dynamic>).cast<String>(),
      );

  _Request({
    List<String>? passwords,
    List<String>? passwordIcons,
    List<String>? notes,
    List<String>? paymentCards,
    List<String>? idCards,
    List<String>? identities,
  })  : passwords = passwords ?? [],
        passwordIcons = passwordIcons ?? [],
        notes = notes ?? [],
        paymentCards = paymentCards ?? [],
        idCards = idCards ?? [],
        identities = identities ?? [];
}

class _ServerInfo implements JsonConvertable {
  final History relevantHistory;
  final _Request request;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'history': relevantHistory.toJson(),
        'request': request.toJson(),
      };

  factory _ServerInfo.fromJson(Map<String, dynamic> json) => _ServerInfo(
        history: History.fromJson(json['history']),
        request: _Request.fromJson(json['request']),
      );

  _ServerInfo({
    History? history,
    _Request? request,
  })  : relevantHistory = history ?? History(),
        request = request ?? _Request();
}

class Synchronization {
  final LoadedAccount _loadedAccount;
  final History _history;
  final Passwords _passwords;
  final Images _passwordIcons;
  final Notes _notes;
  final PaymentCards _paymentCards;
  final IDCards _idCards;
  final Identities _identities;
  final Encrypter _encrypter;
  final BuildContext _context;
  static ServerSocket? _server;
  static Socket? _socket;
  String _syncLog = '';
  void Function(String data) _onReceived = (data) {};

  Synchronization(this._loadedAccount,
      {required History history,
      required Passwords passwords,
      required Images passwordIcons,
      required Notes notes,
      required PaymentCards paymentCards,
      required IDCards idCards,
      required Identities identities,
      required Encrypter encrypter,
      required BuildContext context})
      : _history = history,
        _passwords = passwords,
        _passwordIcons = passwordIcons,
        _notes = notes,
        _paymentCards = paymentCards,
        _idCards = idCards,
        _identities = identities,
        _encrypter = encrypter,
        _context = context;

  void _handleException(String message) {
    if (_socket != null) {
      _socket!.destroy();
      _socket = null;
    }
    if (_server != null) {
      _server!.close();
      _server = null;
    }
    String _exception = '\nLocal exception has occurred: ' + message;
    _syncLog += _exception;
    print(_syncLog);
    Navigator.pushNamedAndRemoveUntil(
        _context, MainScreen.routeName, (r) => false);
    ScaffoldMessenger.of(_context).clearSnackBars();
    ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
      content: Row(children: const [
        Icon(Icons.sync_rounded, color: Colors.white),
        SizedBox(width: 20),
        Expanded(child: Text('Sync error')),
      ]),
      action: SnackBarAction(
          label: 'Show',
          onPressed: () => {
                //TODO: show error log
              }),
    ));
  }

  List<List<int>> _encodeData(_Request request) {
    List<List<int>> _data = [];

    for (var element in request.passwords) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element, value: _passwords.getEntry(element)!.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.passwordIcons) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element, value: _passwordIcons.getEntry(element))),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.notes) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element, value: _notes.getEntry(element)!.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.paymentCards) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element,
                  value: _paymentCards.getEntry(element)!.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.idCards) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element, value: _idCards.getEntry(element)!.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.identities) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_DataEntry(
                  key: element,
                  value: _identities.getEntry(element)!.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    return _data;
  }

  Future<void> _sendData(_Request request) async {
    _syncLog += 'done\nSending data... ';
    List<List<int>> _data = _encodeData(request);
    if (_data.isEmpty) {
      _socket!.add(utf8.encode('ready\u0000'));
      return _socket!.flush();
    }
    for (List<int> element in _data) {
      _socket!.add(element);
      await _socket!.flush();
      if (_socket == null) return;
    }
  }

  void _receiveData(
    List<int> data, {
    required History remoteHistory,
    required Map<String, String> remoteEntryTypes,
  }) {
    _DataEntry _dataEntry;
    try {
      _dataEntry = _DataEntry.fromJson(
          jsonDecode(decrypt(utf8.decode(data), encrypter: _encrypter)));
      switch (remoteEntryTypes[_dataEntry.key]) {
        case 'passwords':
          _passwords.setEntry(Password.fromJson(_dataEntry.value));
          _history.passwords[_dataEntry.key] =
              remoteHistory.passwords[_dataEntry.key]!;
          return;
        case 'passwordIcons':
          _passwordIcons.setImage(
              _dataEntry.key, base64Decode(_dataEntry.value));
          _history.passwordIcons[_dataEntry.key] =
              remoteHistory.passwordIcons[_dataEntry.key]!;
          return;
        case 'paymentCards':
          _paymentCards.setEntry(PaymentCard.fromJson(_dataEntry.value));
          _history.paymentCards[_dataEntry.key] =
              remoteHistory.paymentCards[_dataEntry.key]!;
          return;
        case 'notes':
          _notes.setEntry(Note.fromJson(_dataEntry.value));
          _history.notes[_dataEntry.key] = remoteHistory.notes[_dataEntry.key]!;
          return;
        case 'idCards':
          _idCards.setEntry(IDCard.fromJson(_dataEntry.value));
          _history.idCards[_dataEntry.key] =
              remoteHistory.idCards[_dataEntry.key]!;
          return;
        case 'identities':
          _identities.setEntry(Identity.fromJson(_dataEntry.value));
          _history.identities[_dataEntry.key] =
              remoteHistory.identities[_dataEntry.key]!;
          return;
      }
    } catch (e) {
      _handleException('Could not decode an entry.\n${e.toString()}');
      return;
    }
  }

  Future<HostAddress?> host() async {
    _syncLog = 'Hosting... ';
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

    try {
      if (_server != null) await _server!.close();
      _server = await ServerSocket.bind(_ip, 0);
      _syncLog += 'done. \nListening... ';
      _address = HostAddress(InternetAddress(_ip), _server!.port);

      _server!.listen(
        (socket) {
          if (_socket != null) {
            _socket!.destroy();
            return;
          }
          _socket = socket;

          PassyStreamSubscription _sub = PassyStreamSubscription(socket.listen(
            null,
            onError: (e) =>
                _handleException('Connection error.\n${e.toString()}'),
            onDone: () {
              if (_socket != null) {
                _handleException('Remote disconnected unexpectedly.');
              }
            },
          ));

          void _sendData() {
            _syncLog += 'done.\nSending data...';
            socket.add([0]);
            _syncLog += 'done';
            _socket = null;
            Future.delayed(const Duration(seconds: 16), () {
              socket.destroy();
              _server!.close();
            });
            Navigator.pushNamedAndRemoveUntil(
                _context, MainScreen.routeName, (r) => false);
          }

          void _sendInfo(_ServerInfo info) {
            _syncLog += 'done.\nSending info... ';
            socket.add(utf8.encode(
                encrypt(jsonEncode(info), encrypter: _encrypter) + '\u0000'));
            socket.flush();
          }

          void _receiveHistory(List<int> data) {
            _syncLog += 'done.\nReceiving history... ';
            _ServerInfo _info = _ServerInfo();
            History _remoteHistory;
            Map<String, String> _remoteEntryTypes = {};
            Map<String, Map<String, EntryEvent>> _historyMap = _history.toMap();
            Map<String, Map<String, EntryEvent>> _relevantHistoryMap =
                _info.relevantHistory.toMap();
            Map<String, List<String>> _requestMap = _info.request.toMap();
            int _toReceive;

            try {
              String _data = utf8.decode(data);
              if (_data == _sameHistoryHash) {
                _socket = null;
                socket.destroy();
                _server!.close();
                Navigator.pushNamedAndRemoveUntil(
                    _context, MainScreen.routeName, (r) => false);
                return;
              }
              _remoteHistory = History.fromJson(
                  jsonDecode(decrypt(_data, encrypter: _encrypter)));
            } catch (e) {
              _handleException('Could not decode history.\n${e.toString()}');
              return;
            }

            _remoteHistory.toMap().forEach((entryType, value) {
              value.forEach((key, event) {
                DateTime _localLastModified;
                EntryEvent _localEvent;
                if (!_historyMap[entryType]!.containsKey(key)) {
                  _remoteEntryTypes[key] = entryType;
                  _requestMap[entryType]!.add(key);
                  return;
                }
                _localEvent = _historyMap[entryType]![key]!;
                _localLastModified = _localEvent.lastModified;
                if (event.lastModified.isAfter(_localLastModified)) {
                  _remoteEntryTypes[key] = entryType;
                  _requestMap[entryType]!.add(entryType);
                }
                if (event.lastModified.isBefore(_localLastModified)) {
                  _relevantHistoryMap[entryType]![key] = _localEvent;
                }
              });
            });

            _toReceive = _remoteEntryTypes.length;

            if (_toReceive != 0) {
              _sub.onData((data) {
                _receiveData(
                  data,
                  remoteHistory: _remoteHistory,
                  remoteEntryTypes: _remoteEntryTypes,
                );
                if (_socket == null) return;
                _toReceive--;
                if (_toReceive == 0) {
                  _loadedAccount.saveSync();
                  _sendData();
                  return;
                }
              });
            } else {
              _sub.onData((data) {
                if (utf8.decode(data) == 'ready') _sendData();
              });
            }
            _sendInfo(_info);
            _syncLog += 'done.\nReceiving data... ';
          }

          void _sendHistoryHash() {
            _syncLog += 'done.\nSending history hash... ';
            Map<String, dynamic> _localHistory = _history.toJson();
            socket.add(getHash(jsonEncode(_localHistory))
                .bytes
                .followedBy([0]).toList());
            socket.flush();
          }

          void _receiveHello(List<int> data) {
            _syncLog += 'done.\nReceiving hello... ';
            String _data;
            try {
              _data = utf8.decode(data);
            } catch (e) {
              _handleException('Could not decode hello.\n${e.toString()}');
              return;
            }
            try {
              _data = decrypt(decrypt(_data, encrypter: _encrypter),
                  encrypter: getEncrypter(_loadedAccount.username));
            } catch (e) {
              _handleException(
                  'Could not decrypt hello. Make sure that local and remote username and password are the same.\n${e.toString()}');
              return;
            }
            if (_data != _hello) {
              _handleException(
                  'Hello is incorrect. Expected "$_hello", received "$_data".');
              return;
            }
            _sub.onData((data) => _receiveHistory(data));
            _sendHistoryHash();
          }

          void _sendServiceInfo() {
            _syncLog += 'done.\nSending service info... ';
            socket.add(utf8.encode('Passy v$passyVersion\u0000'));
            socket.flush();
          }

          Navigator.pushNamedAndRemoveUntil(
              _context, SplashScreen.routeName, (r) => false);
          _sub.onData(_receiveHello);
          _sendServiceInfo();
        },
      );
      return _address;
    } catch (e) {
      _handleException('Failed to host.\n${e.toString()}');
    }
    return null;
  }

  Future<void> connect(HostAddress address) {
    _syncLog = 'Connecting... ';
    return Socket.connect(address.ip, address.port).then((socket) {
      _socket = socket;
      PassyStreamSubscription _sub = PassyStreamSubscription(socket.listen(
        null,
        onError: (e) => _handleException('Connection error.\n${e.toString()}'),
        onDone: () {
          if (_socket != null) {
            _handleException('Remote disconnected unexpectedly.');
          }
        },
      ));

      void _receiveData(List<int> data) {
        //TODO: receive data from server
        Navigator.pushNamedAndRemoveUntil(
            _context, MainScreen.routeName, (r) => false);
        _socket = null;
        socket.destroy();
      }

      void _receiveInfo(List<int> data) {
        _syncLog += 'done.\nReceiving info... ';
        _ServerInfo _info;
        try {
          _info = _ServerInfo.fromJson(
              jsonDecode(decrypt(utf8.decode(data), encrypter: _encrypter)));
        } catch (e) {
          _handleException('Could not decode info.\n${e.toString()}');
          return;
        }
        _sub.onData(_receiveData);
        _sendData(_info.request);
      }

      void _sendHistory(String historyJson) {
        _syncLog += 'done.\nSending history... ';
        socket.add(utf8
            .encode(encrypt(historyJson, encrypter: _encrypter) + '\u0000'));
        socket.flush();
      }

      void _receiveHistoryHash(List<int> data) {
        _syncLog += 'done.\nReceiving history hash... ';
        String _historyJson = jsonEncode(_history);
        bool _same = true;
        try {
          _same = getHash(_historyJson) == Digest(data);
        } catch (e) {
          _handleException('Could not read history hash.');
          return;
        }
        if (_same) {
          _socket = null;
          Future.delayed(const Duration(seconds: 16), () => socket.destroy());
          socket.add(utf8.encode(_sameHistoryHash + '\u0000'));
          socket.flush();
          Navigator.pushNamedAndRemoveUntil(
              _context, MainScreen.routeName, (r) => false);
          return;
        }
        _sub.onData(_receiveInfo);
        _sendHistory(_historyJson);
      }

      void _sendHello(String hello) {
        _syncLog += 'done.\nSending hello... ';
        socket.add(utf8.encode(hello + '\u0000'));
        socket.flush();
      }

      void _receiveServiceInfo(List<int> data) {
        _syncLog += 'done.\nReceiving service info... ';
        List<String> _info = [];
        try {
          _info = utf8.decode(data).split(' ');
        } catch (e) {
          _handleException('Could not decode hello.\n${e.toString()}');
          return;
        }
        if (_info.length < 2) {
          _handleException(
              'Service info is less than 2 parts long. Info length: ${_info.length}');
          return;
        }
        if (_info[0] != 'Passy') {
          _handleException(
              'Remote service is not Passy. Service name: ${_hello[0]}');
          return;
        }
        if (_info[1] != 'v$passyVersion') {
          _handleException(
              'Local and remote versions are different. Local version: v$passyVersion. Remote version: ${_info[1]}.');
          return;
        }
        _sub.onData(_receiveHistoryHash);
        _sendHello(encrypt(
            encrypt(_hello, encrypter: getEncrypter(_loadedAccount.username)),
            encrypter: _encrypter));
      }

      Navigator.pushNamedAndRemoveUntil(
          _context, SplashScreen.routeName, (r) => false);
      _sub.onData(_receiveServiceInfo);
    }, onError: (e) => _handleException('Failed to connect.\n${e.toString()}'));
    // Ask server for data hashes, if they are not the same, exchange data
  }
}
