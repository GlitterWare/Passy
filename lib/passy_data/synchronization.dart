import 'dart:async';
import 'dart:convert';

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

class _EntryData implements JsonConvertable {
  final String key;
  final String type;
  final EntryEvent event;

  /// Value can be Map<String, dynamic> if DatedEntry, String if image or null if deleted
  final dynamic value;

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type,
        'event': event.toJson(),
        'entry': value,
      };

  factory _EntryData.fromJson(Map<String, dynamic> json) => _EntryData(
      key: json['key'],
      type: json['type'],
      event: EntryEvent.fromJson(json['event']),
      value: json['entry']);

  _EntryData({
    required this.key,
    required this.type,
    required this.event,
    this.value,
  });
}

class _Request implements JsonConvertable {
  final List<String> passwords;
  final List<String> passwordIcons;
  final List<String> notes;
  final List<String> paymentCards;
  final List<String> idCards;
  final List<String> identities;
  int get length =>
      passwords.length +
      passwordIcons.length +
      notes.length +
      paymentCards.length +
      idCards.length +
      identities.length;

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

class _EntryInfo implements JsonConvertable {
  final History history;
  final _Request request;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'history': history.toJson(),
        'request': request.toJson(),
      };

  factory _EntryInfo.fromJson(Map<String, dynamic> json) => _EntryInfo(
        history: History.fromJson(json['history']),
        request: _Request.fromJson(json['request']),
      );

  _EntryInfo({
    History? history,
    _Request? request,
  })  : history = history ?? History(),
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
    _socket!.destroy();
    _socket = null;
    if (_server != null) {
      _server!.close();
      _server = null;
    }
    String _exception = '\nLocal exception has occurred: ' + message;
    _syncLog += _exception;
    print(_syncLog);
    Navigator.pop(_context);
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

    for (String element in request.passwords) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'passwords',
                  event: _history.passwords[element]!,
                  value: _passwords.getEntry(element)?.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.passwordIcons) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'passwordIcons',
                  event: _history.passwordIcons[element]!,
                  value: _passwordIcons.getEntry(element))),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.notes) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'notes',
                  event: _history.notes[element]!,
                  value: _notes.getEntry(element)?.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.paymentCards) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'paymentCards',
                  event: _history.paymentCards[element]!,
                  value: _paymentCards.getEntry(element)?.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.idCards) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'idCards',
                  event: _history.idCards[element]!,
                  value: _idCards.getEntry(element)?.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    for (var element in request.identities) {
      _data.add(utf8.encode(encrypt(
              jsonEncode(_EntryData(
                  key: element,
                  type: 'identities',
                  event: _history.identities[element]!,
                  value: _identities.getEntry(element)?.toJson())),
              encrypter: _encrypter) +
          '\u0000'));
    }
    return _data;
  }

  Future<void> _sendEntries(_Request request) async {
    List<List<int>> _data = _encodeData(request);
    for (List<int> element in _data) {
      _socket!.add(element);
      await _socket!.flush();
    }
  }

  Future<void> _decryptEntries(List<List<int>> entries) async {
    for (List<int> entry in entries) {
      _EntryData _entryData;
      try {
        _entryData = _EntryData.fromJson(
            jsonDecode(decrypt(utf8.decode(entry), encrypter: _encrypter)));
        if (_entryData.event.status == EntryStatus.deleted) {
          switch (_entryData.type) {
            case 'passwords':
              if (_history.passwords.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.passwords[_entryData.key] = _entryData.event;
              break;
            case 'passwordIcons':
              if (_history.passwordIcons.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.passwordIcons[_entryData.key] = _entryData.event;
              break;
            case 'paymentCards':
              if (_history.paymentCards.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.paymentCards[_entryData.key] = _entryData.event;
              break;
            case 'notes':
              if (_history.notes.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.notes[_entryData.key] = _entryData.event;
              break;
            case 'idCards':
              if (_history.idCards.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.idCards[_entryData.key] = _entryData.event;
              break;
            case 'identities':
              if (_history.identities.containsKey(_entryData.key)) {
                if (_history.passwords[_entryData.key]!.status ==
                    EntryStatus.alive) _passwords.remove(_entryData.key);
              }
              _history.identities[_entryData.key] = _entryData.event;
              break;
          }
          continue;
        }
        switch (_entryData.type) {
          case 'passwords':
            _passwords.setEntry(Password.fromJson(_entryData.value));
            _history.passwords[_entryData.key] = _entryData.event;
            break;
          case 'passwordIcons':
            _passwordIcons.setImage(
                _entryData.key, base64Decode(_entryData.value));
            _history.passwordIcons[_entryData.key] = _entryData.event;
            break;
          case 'paymentCards':
            _paymentCards.setEntry(PaymentCard.fromJson(_entryData.value));
            _history.paymentCards[_entryData.key] = _entryData.event;
            break;
          case 'notes':
            _notes.setEntry(Note.fromJson(_entryData.value));
            _history.notes[_entryData.key] = _entryData.event;
            break;
          case 'idCards':
            _idCards.setEntry(IDCard.fromJson(_entryData.value));
            _history.idCards[_entryData.key] = _entryData.event;
            break;
          case 'identities':
            _identities.setEntry(Identity.fromJson(_entryData.value));
            _history.identities[_entryData.key] = _entryData.event;
            break;
        }
      } catch (e) {
        _handleException('Could not decode an entry.\n${e.toString()}');
        return;
      }
    }
    return _loadedAccount.save();
  }

//TODO: remove entrycount
  Future<List<List<int>>> _handleEntries(
    PassyStreamSubscription subscription, {
    required int entryCount,
    VoidCallback? onFirstReceive,
  }) {
    List<List<int>> _entries = [];
    Completer<List<List<int>>> _completer = Completer<List<List<int>>>();
    subscription.onDone(() {
      if (!_completer.isCompleted) _completer.complete(_entries);
    });
    if (entryCount == 0) {
      subscription.onData((data) {
        if (onFirstReceive != null) onFirstReceive!();
      });
      _completer.complete(_entries);
      return _completer.future;
    }
    subscription.onData((data) {
      void _handleEntries() {
        _entries.add(data);
        entryCount--;
        if (entryCount == 0) {
          _completer.complete(_entries);
        }
      }

      if (onFirstReceive != null) {
        onFirstReceive!();
        onFirstReceive = null;
      }
      _handleEntries();
    });
    return _completer.future;
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
      _syncLog += 'done. \nListening... ';

      await ServerSocket.bind(_ip, 0).then((server) {
        _server = server;
        _address = HostAddress(InternetAddress(_ip), server.port);
        server.listen(
          (socket) {
            if (_socket != null) {
              _socket!.destroy();
              return;
            }
            _socket = socket;

            PassyStreamSubscription _sub =
                PassyStreamSubscription(socket.listen(
              null,
              onError: (e) =>
                  _handleException('Connection error.\n${e.toString()}'),
              onDone: () {
                if (_socket != null) {
                  _handleException('Remote disconnected unexpectedly.');
                }
              },
            ));

            Future<void> _sendInfo(_EntryInfo info) {
              _syncLog += 'done.\nSending info... ';
              socket.add(utf8.encode(
                  encrypt(jsonEncode(info), encrypter: _encrypter) + '\u0000'));
              return socket.flush();
            }

            void _handleHistory(List<int> data) {
              _syncLog += 'done.\nReceiving history... ';
              _EntryInfo _info;
              _Request _remoteRequest;
              History _remoteHistory;

              try {
                String _data = utf8.decode(data);
                if (_data == _sameHistoryHash) {
                  _socket = null;
                  socket.destroy();
                  server.close();
                  Navigator.pop(_context);
                  return;
                }
                _remoteHistory = History.fromJson(
                    jsonDecode(decrypt(_data, encrypter: _encrypter)));
              } catch (e) {
                _handleException('Could not decode history.\n${e.toString()}');
                return;
              }

              /// Create Info
              {
                _info = _EntryInfo();
                _remoteRequest = _Request();
                Map<String, Map<String, EntryEvent>> _localHistoryMap =
                    _history.toMap();
                Map<String, Map<String, EntryEvent>> _remoteHistoryMap =
                    _remoteHistory.toMap();
                Map<String, Map<String, EntryEvent>> _localShortHistoryMap =
                    _info.history.toMap();
                Map<String, List<String>> _localRequestMap =
                    _info.request.toMap();
                Map<String, List<String>> _remoteRequestMap =
                    _remoteRequest.toMap();

                //TODO: merge local/remote history iteration
                _remoteHistoryMap.forEach((entryType, value) {
                  value.forEach((key, event) {
                    DateTime _localLastModified;
                    EntryEvent _localEvent;
                    if (!_localHistoryMap[entryType]!.containsKey(key)) {
                      _localRequestMap[entryType]!.add(key);
                      return;
                    }
                    _localEvent = _localHistoryMap[entryType]![key]!;
                    _localLastModified = _localEvent.lastModified;
                    if (_localLastModified.isBefore(event.lastModified)) {
                      _localRequestMap[entryType]!.add(key);
                      return;
                    }
                    if (_localLastModified.isAfter(event.lastModified)) {
                      _localShortHistoryMap[entryType]![key] = _localEvent;
                      _remoteRequestMap[entryType]!.add(key);
                    }
                  });
                });

                _localHistoryMap.forEach((entryType, value) {
                  value.forEach((key, event) {
                    if (_remoteHistoryMap[entryType]!.containsKey(key)) return;
                    _localShortHistoryMap[entryType]![key] = event;
                    _remoteRequestMap[entryType]!.add(key);
                  });
                });
              }

              {
                int _requestLength = _info.request.length;
                Completer<void> _onFirstReceive = Completer();
                Future<void> _decryptEntriesFuture = Future.value();
                Future<void> _sendEntriesFuture = Future.value();
                Future<void> _handleEntriesFuture = _handleEntries(_sub,
                    entryCount: _info.request.length, onFirstReceive: () {
                  _onFirstReceive.complete();
                  _sendEntriesFuture = _sendEntries(_remoteRequest);
                }).then((value) {
                  _decryptEntriesFuture = _decryptEntries(value);
                });
                _sendInfo(_info);
                _syncLog += 'done.\nExchanging data... ';
                _handleEntriesFuture.whenComplete(() async {
                  await _onFirstReceive.future;
                  try {
                    await _sendEntriesFuture;
                  } catch (e) {
                    _handleException(
                        'Could not send an entry.\n${e.toString()}');
                    return;
                  }
                  if (_socket == null) return;
                  _socket!.destroy();
                  _socket = null;
                  server.close();
                  _server = null;
                  await _decryptEntriesFuture;
                  Navigator.pop(_context);
                });
              }
            }

            Future<void> _sendHistoryHash() {
              _syncLog += 'done.\nSending history hash... ';
              Map<String, dynamic> _localHistory = _history.toJson();
              socket.add(utf8.encode(
                  getHash(jsonEncode(_localHistory)).toString() + '\u0000'));
              return socket.flush();
            }

            void _handleHello(List<int> data) {
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
              _sub.onData((data) => _handleHistory(data));
              _sendHistoryHash();
            }

            Future<void> _sendServiceInfo() {
              _syncLog += 'done.\nSending service info... ';
              socket.add(utf8.encode('Passy v$passyVersion\u0000'));
              return socket.flush();
            }

            Navigator.popUntil(
                _context, (r) => r.settings.name == MainScreen.routeName);
            Navigator.pushNamed(_context, SplashScreen.routeName);
            _sub.onData(_handleHello);
            _sendServiceInfo();
          },
        );
      });
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

      Future<void> _handleInfo(List<int> data) async {
        _syncLog += 'done.\nReceiving info... ';
        int _requestLength;
        _EntryInfo _info;
        Future<void> _decryptEntriesFuture;
        Future<void> _handleEntriesFuture;
        Future<void> _sendEntriesFuture;

        try {
          _info = _EntryInfo.fromJson(
              jsonDecode(decrypt(utf8.decode(data), encrypter: _encrypter)));
        } catch (e) {
          _handleException('Could not decode info.\n${e.toString()}');
          return;
        }

        //TODO: go through info history and check alive/removed entries

        _requestLength = _info.history.length;
        _decryptEntriesFuture = Future.value();
        _handleEntriesFuture = _handleEntries(
          _sub,
          entryCount: _requestLength,
        ).then((value) {
          _decryptEntriesFuture = _decryptEntries(value);
        });
        _syncLog += 'done.\nExchanging data... ';
        if (_info.request.length == 0) {
          socket.add(utf8.encode('ready\u0000'));
          await socket.flush();
        }
        _sendEntriesFuture = _sendEntries(_info.request);
        _handleEntriesFuture.whenComplete(() async {
          try {
            await _sendEntriesFuture;
          } catch (e) {
            _handleException('Could not send an entry.\n${e.toString()}');
            return;
          }
          _syncLog += 'done.';
          _socket!.destroy();
          _socket = null;
          await _decryptEntriesFuture;
          Navigator.pop(_context);
        });
      }

      Future<void> _sendHistory(String historyJson) {
        _syncLog += 'done.\nSending history... ';
        socket.add(utf8
            .encode(encrypt(historyJson, encrypter: _encrypter) + '\u0000'));
        return socket.flush();
      }

      void _handleHistoryHash(List<int> data) {
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
          Navigator.pop(_context);
          return;
        }
        _sub.onData(_handleInfo);
        _sendHistory(_historyJson);
      }

      Future<void> _sendHello(String hello) {
        _syncLog += 'done.\nSending hello... ';
        socket.add(utf8.encode(hello + '\u0000'));
        return socket.flush();
      }

      void _handleServiceInfo(List<int> data) {
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
        if (_info[1].replaceFirst('v', '').split('.')[0] !=
            passyVersion.split('.')[0]) {
          _handleException(
              'Local and remote versions are different. Local version: v$passyVersion. Remote version: ${_info[1]}.');
          return;
        }
        _sub.onData(_handleHistoryHash);
        _sendHello(encrypt(
            encrypt(_hello, encrypter: getEncrypter(_loadedAccount.username)),
            encrypter: _encrypter));
      }

      Navigator.popUntil(
          _context, (r) => r.settings.name == MainScreen.routeName);
      Navigator.pushNamed(_context, SplashScreen.routeName);
      _sub.onData(_handleServiceInfo);
    }, onError: (e) => _handleException('Failed to connect.\n${e.toString()}'));
    // Ask server for data hashes, if they are not the same, exchange data
  }
}
