import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';

import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'host_address.dart';
import 'json_convertable.dart';
import 'loaded_account.dart';
import 'password.dart';
import 'passy_stream_subscription.dart';

const String _hello = 'hello';
const String _sameHistoryHash = 'same';

class _EntryData implements JsonConvertable {
  final String key;
  final EntryType type;
  final EntryEvent event;

  /// Value can be Map<String, dynamic> if exists or null if deleted
  final dynamic value;

  _EntryData({
    required this.key,
    required this.type,
    required this.event,
    this.value,
  });

  _EntryData.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        type = entryTypeFromName(json['type']),
        event = EntryEvent.fromJson(json['event']),
        value = json['entry'];

  @override
  Map<String, dynamic> toJson() => {
        'key': key,
        'type': type.name,
        'event': event.toJson(),
        'entry': value,
      };
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

  _Request.fromJson(Map<String, dynamic> json)
      : passwords = (json['passwords'] as List<dynamic>).cast<String>(),
        passwordIcons = (json['passwordIcons'] as List<dynamic>).cast<String>(),
        notes = (json['notes'] as List<dynamic>).cast<String>(),
        paymentCards = (json['paymentCards'] as List<dynamic>).cast<String>(),
        idCards = (json['idCards'] as List<dynamic>).cast<String>(),
        identities = (json['identities'] as List<dynamic>).cast<String>();

  List<String> getKeys(EntryType type) {
    switch (type) {
      case EntryType.password:
        return passwords;
      case EntryType.passwordIcon:
        return passwordIcons;
      case EntryType.paymentCard:
        return paymentCards;
      case EntryType.note:
        return notes;
      case EntryType.idCard:
        return idCards;
      case EntryType.identity:
        return identities;
      default:
        return [];
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'passwords': passwords,
        'passwordIcons': passwordIcons,
        'notes': notes,
        'paymentCards': paymentCards,
        'idCards': idCards,
        'identities': identities,
      };
}

class _EntryInfo implements JsonConvertable {
  final History history;
  final _Request request;

  _EntryInfo({
    History? history,
    _Request? request,
  })  : history = history ?? History(),
        request = request ?? _Request();

  _EntryInfo.fromJson(Map<String, dynamic> json)
      : history = History.fromJson(json['history']),
        request = _Request.fromJson(json['request']);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'history': history.toJson(),
        'request': request.toJson(),
      };
}

class Synchronization {
  final LoadedAccount _loadedAccount;
  final History _history;
  final Encrypter _encrypter;
  final BuildContext _context;
  static ServerSocket? _server;
  static Socket? _socket;
  String _syncLog = '';

  Synchronization(this._loadedAccount,
      {required History history,
      required Encrypter encrypter,
      required BuildContext context})
      : _history = history,
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
    ScaffoldMessenger.of(_context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
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

    for (EntryType entryType in EntryType.values) {
      for (String key in request.getKeys(entryType)) {
        _data.add(utf8.encode(encrypt(
                jsonEncode(_EntryData(
                    key: key,
                    type: entryType,
                    event: _history.getEvents(entryType)[key]!,
                    value: _loadedAccount.getEntry(entryType, key)?.toJson())),
                encrypter: _encrypter) +
            '\u0000'));
      }
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
      } catch (e) {
        _handleException('Could not decode an entry.\n${e.toString()}');
        return;
      }

      try {
        Map<String, EntryEvent> _events = _history.getEvents(_entryData.type);

        if (_entryData.event.status == EntryStatus.deleted) {
          if (_events.containsKey(_entryData.key)) {
            if (_events[_entryData.key]!.status == EntryStatus.alive) {
              _loadedAccount.removeEntry(_entryData.type, _entryData.key);
            }
          }
          _events[_entryData.key] = _entryData.event;
          continue;
        }

        _loadedAccount.setEntry(
            _entryData.type, Password.fromJson(_entryData.value));
        _events[_entryData.key] = _entryData.event;
      } catch (e) {
        _handleException('Could not save an entry\n${e.toString()}');
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
      void _handleEntries(List<int> data) {
        _entries.add(data);
        entryCount--;
        if (entryCount == 0) _completer.complete(_entries);
      }

      if (onFirstReceive != null) {
        onFirstReceive!();
        onFirstReceive = null;
        subscription.onData(_handleEntries);
      }
      _handleEntries(data);
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
              /// Iterate through local and remote events.
              /// - If an event does not exist or is older on either end, add it
              /// to an appropriate request.
              {
                _info = _EntryInfo();
                _remoteRequest = _Request();

                //TODO: merge local/remote history iteration
                for (EntryType entryType in EntryType.values) {
                  Map<String, EntryEvent> _localEvents =
                      _history.getEvents(entryType);
                  Map<String, EntryEvent> _shortLocalEvents =
                      _info.history.getEvents(entryType);
                  List<String> _localRequestKeys =
                      _info.request.getKeys(entryType);
                  Map<String, EntryEvent> _remoteEvents =
                      _remoteHistory.getEvents(entryType);
                  List<String> _remoteRequestKeys =
                      _remoteRequest.getKeys(entryType);

                  for (String key in _localEvents.keys
                      .followedBy(_remoteEvents.keys)
                      .toSet()) {
                    DateTime _localLastModified;
                    EntryEvent _localEvent;

                    if (!_localEvents.containsKey(key)) {
                      _localRequestKeys.add(key);
                      return;
                    }
                    _localEvent = _localEvents[key]!;
                    if (!_remoteEvents.containsKey(key)) {
                      _shortLocalEvents[key] = _localEvent;
                      _remoteRequestKeys.add(key);
                      return;
                    }

                    _localLastModified = _localEvent.lastModified;

                    if (_localLastModified.isBefore(_localEvent.lastModified)) {
                      _localRequestKeys.add(key);
                      return;
                    }
                    if (_localLastModified.isAfter(_localEvent.lastModified)) {
                      _shortLocalEvents[key] = _localEvent;
                      _remoteRequestKeys.add(key);
                    }
                  }
                }
              }

              /// Exchange data
              /// 1. Handle entries, if entry count is not 0, then decrypt them
              /// when completed.
              /// 2. When all entries are handled, wait for entries to be sent,
              /// then close sockets.
              /// 3. Wait for decryption to complete, then pop back to main
              /// screen.
              /// 4. Send info.
              {
                Future<void> _sendEntriesFuture = Future.value();
                Future<List<List<int>>> _handleEntriesFuture =
                    _handleEntries(_sub, entryCount: _info.request.length,
                        onFirstReceive: () {
                  _sendEntriesFuture = _sendEntries(_remoteRequest);
                });
                Future<void> _decryptEntriesFuture = Future.value();
                if (_info.request.length != 0) {
                  _handleEntriesFuture.then((value) {
                    _decryptEntriesFuture = _decryptEntries(value);
                  });
                }
                _handleEntriesFuture.whenComplete(() async {
                  await _sendEntriesFuture;
                  if (_socket == null) return;
                  _socket!.destroy();
                  _socket = null;
                  server.close();
                  _server = null;
                  await _decryptEntriesFuture;
                  _syncLog += 'done.';
                  Navigator.pop(_context);
                });
                _sendInfo(_info);
                _syncLog += 'done.\nExchanging data... ';
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
                    'Hello is incorrect. Expected \'$_hello\', received \'$_data\'.');
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
        _EntryInfo _info;

        try {
          _info = _EntryInfo.fromJson(
              jsonDecode(decrypt(utf8.decode(data), encrypter: _encrypter)));
        } catch (e) {
          _handleException('Could not decode info.\n${e.toString()}');
          return;
        }

        /// Exchange data
        /// 1. Handle entries, if entry count is not 0, then decrypt them
        /// when completed.
        /// 2. When all entries are handled, wait for entries to be sent,
        /// then close sockets.
        /// 3. Wait for decryption to complete, then pop back to main
        /// screen.
        /// 4. If request length is 0, send ready, otherwise send entries.
        {
          int _requestLength = _info.history.length;
          Future<List<List<int>>> _handleEntriesFuture = _handleEntries(
            _sub,
            entryCount: _requestLength,
          );
          Future<void> _decryptEntriesFuture = Future.value();
          Future<void> _sendEntriesFuture = Future.value();
          if (_requestLength != 0) {
            _handleEntriesFuture.then((value) {
              _decryptEntriesFuture = _decryptEntries(value);
            });
          }
          _handleEntriesFuture.whenComplete(() async {
            await _sendEntriesFuture;
            _socket!.destroy();
            _socket = null;
            await _decryptEntriesFuture;
            _syncLog += 'done.';
            Navigator.pop(_context);
          });
          _syncLog += 'done.\nExchanging data... ';
          if (_info.request.length == 0) {
            socket.add(utf8.encode('ready\u0000'));
            await socket.flush();
            return;
          }
          _sendEntriesFuture = _sendEntries(_info.request);
        }
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
