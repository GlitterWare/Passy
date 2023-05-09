import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';
import 'package:intranet_ip/intranet_ip.dart';

import 'favorites.dart';
import 'synchronization_2d0d0_modules.dart';
import 'common.dart';
import 'entry_event.dart';
import 'entry_type.dart';
import 'history.dart';
import 'host_address.dart';
import 'json_convertable.dart';
import 'loaded_account.dart';
import 'passy_entry.dart';
import 'passy_stream_subscription.dart';
import 'glare/glare_client.dart';
import 'glare/glare_server.dart';
import 'synchronization_2d0d0_utils.dart' as util;

const String _hello = 'hello';
const String _sameHistoryHash = 'same';

class SynchronizationResults {
  Map<EntryType, List<util.ExchangeEntry>>? sharedEntries;

  SynchronizationResults({this.sharedEntries});
}

class SynchronizationSignalData with JsonConvertable {
  String name;

  SynchronizationSignalData({required this.name});

  @override
  toJson() {
    return {
      'name': name,
    };
  }
}

class SynchronizationSignal with JsonConvertable {
  String type = 'signal';
  SynchronizationSignalData data;

  SynchronizationSignal({required this.data});

  @override
  toJson() {
    return {'type': type, 'data': data.toJson()};
  }
}

class _EntryData with JsonConvertable {
  final String key;
  final EntryType type;
  final EntryEvent event;
  final List<dynamic>? value;

  _EntryData({
    required this.key,
    required this.type,
    required this.event,
    this.value,
  });

  _EntryData.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        type = entryTypeFromName(json['type'])!,
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

class _Request with JsonConvertable {
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

class _EntryInfo with JsonConvertable {
  final History history;
  final _Request request;

  _EntryInfo({
    History? history,
    _Request? request,
  })  : history = history ?? History(),
        request = request ?? _Request();

  _EntryInfo.fromJson(Map<String, dynamic> json)
      : history = History.fromJson((json['history'] as Map<String, dynamic>)),
        request = _Request.fromJson(json['request']);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'history': history.toJson(),
        'request': request.toJson(),
      };
}

class Synchronization {
  final LoadedAccount _loadedAccount;
  final HistoryFile _history;
  final Favorites _favorites;
  final Encrypter _encrypter;
  final SynchronizationResults _synchronizationResults =
      SynchronizationResults();
  final void Function(SynchronizationResults)? _onComplete;
  bool _isOnCompleteCalled = false;
  final void Function(String log)? _onError;
  static ServerSocket? _server;
  static Socket? _socket;
  String _syncLog = '';
  bool _isConnected = false;
  int _entriesAdded = 0;
  int _entriesRemoved = 0;
  final RSAKeypair _rsaKeypair;
  GlareClient? _sync2d0d0Client;
  GlareServer? _sync2d0d0Host;

  get entriesAdded => _entriesAdded;
  get entriesRemoved => _entriesRemoved;

  Synchronization(this._loadedAccount,
      {required HistoryFile history,
      required Favorites favorites,
      required Encrypter encrypter,
      required RSAKeypair rsaKeypair,
      void Function(SynchronizationResults)? onComplete,
      void Function(String log)? onError})
      : _history = history,
        _favorites = favorites,
        _encrypter = encrypter,
        _rsaKeypair = rsaKeypair,
        _onComplete = onComplete,
        _onError = onError;

  void _callOnComplete() {
    if (_isOnCompleteCalled) return;
    _isOnCompleteCalled = true;
    _onComplete?.call(_synchronizationResults);
  }

  void _handleException(String message) {
    _socket?.destroy();
    _socket = null;
    if (_server != null) {
      _server?.close();
      _server = null;
    }
    _sync2d0d0Client?.disconnect();
    _sync2d0d0Host?.stop();
    String _exception = '\nLocal exception has occurred: ' + message;
    _syncLog += _exception;
    _onError?.call(_syncLog);
    _callOnComplete();
  }

  List<List<int>> _encodeData(_Request request) {
    List<List<int>> _data = [];

    for (EntryType entryType in [
      EntryType.password,
      EntryType.paymentCard,
      EntryType.note,
      EntryType.idCard,
      EntryType.identity,
    ]) {
      for (String key in request.getKeys(entryType)) {
        _data.add(utf8.encode(encrypt(
                jsonEncode(_EntryData(
                    key: key,
                    type: entryType,
                    event: _history.value.getEvents(entryType)[key]!,
                    value: _loadedAccount.getEntry(entryType)(key)?.toCSV())),
                encrypter: _encrypter) +
            '\u0000'));
      }
    }

    return _data;
  }

  Future<void> _sendEntries(_Request request) async {
    List<List<int>> _data = _encodeData(request);
    for (List<int> element in _data) {
      _socket?.add(element);
      await _socket?.flush();
    }
  }

  Future<void> _decryptEntries(List<List<int>> entries) async {
    await _history.reload();
    for (List<int> entry in entries) {
      _EntryData _entryData;
      try {
        _entryData = _EntryData.fromJson(
            jsonDecode(decrypt(utf8.decode(entry), encrypter: _encrypter)));
      } catch (e, s) {
        _handleException(
            'Could not decode an entry.\n${e.toString()}\n${s.toString()}');
        return;
      }

      try {
        Map<String, EntryEvent> _events =
            _history.value.getEvents(_entryData.type);

        if (_entryData.event.status == EntryStatus.removed) {
          if (_events.containsKey(_entryData.key)) {
            if (_events[_entryData.key]!.status == EntryStatus.alive) {
              await _loadedAccount.removeEntry(_entryData.type)(_entryData.key);
            }
          }
          _events[_entryData.key] = _entryData.event;
          _entriesRemoved += 1;
          continue;
        }

        if (_entryData.value == null) {
          _entryData.event
            ..lastModified = DateTime.now().toUtc()
            ..status = EntryStatus.removed;
          _events[_entryData.key] = _entryData.event;
          continue;
        }
        await _loadedAccount.setEntry(_entryData.type)(
            PassyEntry.fromCSV(_entryData.type)(_entryData.value!));
        _events[_entryData.key] = _entryData.event;
        _entriesAdded += 1;
      } catch (e, s) {
        _handleException(
            'Could not save an entry\n${e.toString()}\n${s.toString()}');
        return;
      }
    }
    return _loadedAccount.save();
  }

  Future<List<List<int>>> _handleEntries(
    PassyStreamSubscription subscription, {
    required int entryCount,
    VoidCallback? onFirstReceive,
  }) {
    List<List<int>> _entries = [];
    Completer<List<List<int>>> _completer = Completer<List<List<int>>>();

    void _handleEntries(List<int> data) {
      _entries.add(data);
      entryCount--;
      if (entryCount == 0) _completer.complete(_entries);
    }

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

    if (onFirstReceive != null) {
      subscription.onData((data) {
        onFirstReceive!();
        onFirstReceive = null;
        subscription.onData(_handleEntries);
        _handleEntries(data);
      });
    } else {
      subscription.onData(_handleEntries);
    }

    return _completer.future;
  }

  Future<HostAddress?> host({
    void Function()? onConnected,
    Map<EntryType, List<String>>? sharedEntryKeys,
  }) async {
    _syncLog = 'Hosting... ';
    HostAddress? _address;
    String _ip = '';
    try {
      List<NetworkInterface> _interfaces =
          await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (NetworkInterface _interface in _interfaces) {
        for (InternetAddress _address in _interface.addresses) {
          String _strAddress = _address.address;
          if (_strAddress.startsWith('192.168.1.')) {
            _ip = _strAddress;
            break;
          }
        }
      }
      if (_ip == '') _ip = (await intranetIpv4()).address;
    } catch (_) {
      _ip = '127.0.0.1';
    }
    try {
      if (_server != null) await _server?.close();
      _syncLog += 'done. \nListening... ';

      await ServerSocket.bind(_ip, 0).then((server) {
        _server = server;
        _address = HostAddress(InternetAddress(_ip), server.port);
        server.listen(
          (socket) {
            if (_socket != null) {
              _socket?.destroy();
              return;
            }
            if (onConnected != null) onConnected();
            _socket = socket;
            _isConnected = true;

            PassyStreamSubscription _sub =
                PassyStreamSubscription(socket.listen(
              null,
              onError: (e, s) => _handleException(
                  'Connection error.\n${e.toString()}\n${s.toString()}'),
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
                  _callOnComplete();
                  return;
                }
                _remoteHistory = History.fromJson(
                    jsonDecode(decrypt(_data, encrypter: _encrypter)));
              } catch (e, s) {
                _handleException(
                    'Could not decode history.\n${e.toString()}\n${s.toString()}');
                return;
              }

              /// Create Info
              /// Iterate through local and remote events.
              /// - If an event does not exist or is older on either end, add it
              /// to an appropriate request.
              {
                _info = _EntryInfo();
                _remoteRequest = _Request();

                for (EntryType entryType in [
                  EntryType.password,
                  EntryType.paymentCard,
                  EntryType.note,
                  EntryType.idCard,
                  EntryType.identity,
                ]) {
                  Map<String, EntryEvent> _localEvents =
                      _history.value.getEvents(entryType);
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
                    EntryEvent _remoteEvent;

                    if (!_localEvents.containsKey(key)) {
                      _localRequestKeys.add(key);
                      continue;
                    }
                    _localEvent = _localEvents[key]!;
                    if (!_remoteEvents.containsKey(key)) {
                      _shortLocalEvents[key] = _localEvent;
                      _remoteRequestKeys.add(key);
                      continue;
                    }
                    _remoteEvent = _remoteEvents[key]!;

                    _localLastModified = _localEvent.lastModified;

                    if (_localLastModified
                        .isBefore(_remoteEvent.lastModified)) {
                      _localRequestKeys.add(key);
                      continue;
                    }
                    if (_localLastModified.isAfter(_remoteEvent.lastModified)) {
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
                Completer<void> _sendEntriesCompleter = Completer();
                Future<List<List<int>>> _handleEntriesFuture =
                    _handleEntries(_sub, entryCount: _info.request.length,
                        onFirstReceive: () {
                  _sendEntries(_remoteRequest)
                      .then((value) => _sendEntriesCompleter.complete());
                });
                Completer<void> _decryptEntriesCompleter = Completer();

                if (_info.request.length != 0) {
                  _handleEntriesFuture.then((value) {
                    _decryptEntries(value)
                        .then((value) => _decryptEntriesCompleter.complete());
                  });
                } else {
                  _decryptEntriesCompleter.complete();
                }

                _handleEntriesFuture.then((value) async {
                  await _sendEntriesCompleter.future;
                  // Disconnect
                  _socket?.destroy();
                  _socket = null;
                  server.close();
                  _server = null;
                  await _decryptEntriesCompleter.future;
                  // Cleanup
                  _syncLog += 'done.';
                  _isConnected = false;
                  _callOnComplete();
                });
                _sendInfo(_info);
                _syncLog += 'done.\nExchanging data... ';
              }
            }

            Future<void> _sendHistoryHash() {
              _syncLog += 'done.\nSending history hash... ';
              Map<String, dynamic> _localHistory = _history.value.toJson();
              socket.add(utf8.encode(
                  getPassyHash(jsonEncode(_localHistory)).toString() +
                      '\u0000'));
              return socket.flush();
            }

            void _handleSignal(List<int> data) {
              _syncLog += '\nReceived synchronization signal. Decoding... ';
              dynamic _signal;
              try {
                _signal = utf8.decode(data);
                _signal = jsonDecode(_signal);
              } catch (e, s) {
                _handleException(
                    'Could not decode synchronization signal.\n${e.toString()}\n${s.toString()}');
                return;
              }
              if (_signal is! Map<String, dynamic>) {
                _handleException('Synchronization signal is empty.');
                return;
              }
              dynamic _type = _signal['type'];
              if (_type is! String) {
                _handleException(
                    'Synchronization signal does not specify a type.\n${_signal.toString()}');
                return;
              }
              if (_type != 'signal') {
                _handleException('Unsupported signal type.\n$_type');
                return;
              }
              dynamic _data = _signal['data'];
              if (_data is! Map<String, dynamic>) {
                _handleException(
                    'Synchronization signal does not specify data.\n${_signal.toString()}');
                return;
              }
              dynamic name = _data['name'];
              if (name is! String) {
                _handleException(
                    'Synchronization signal does not specify a name.\n${_signal.toString()}');
                return;
              }
              switch (name) {
                case 'exit':
                  // Disconnect
                  _socket?.destroy();
                  _socket = null;
                  server.close();
                  _server = null;
                  // Cleanup
                  _syncLog += 'done.';
                  _isConnected = false;
                  _callOnComplete();
                  return;
              }
              _handleException(
                  'Unrecognized synchronization signal.\n${_signal.toString()}');
              return;
            }

            void _synchronization2d0d0() async {
              _sub.onData(_handleSignal);
              _syncLog +=
                  'done.\nClient supports 2.0.0+ synchronization. Starting 2.0.0+ synchronization server... ';
              GlareServer host = await GlareServer.bind(
                address: _ip,
                port: 0,
                keypair: _rsaKeypair,
                modules: buildSynchronization2d0d0Modules(
                  account: _loadedAccount,
                  encrypter: _encrypter,
                  history: _history,
                  favorites: _favorites,
                  sharedEntryKeys: sharedEntryKeys,
                  onSetEntry: () => _entriesAdded++,
                  onRemoveEntry: () => _entriesRemoved++,
                ),
                serviceInfo:
                    'Passy cross-platform password manager entry synchronization server v$syncVersion',
              );
              _sync2d0d0Host = host;
              _syncLog +=
                  'done.\nSending 2.0.0+ synchronization server address... ';
              socket.add(utf8.encode('$_ip:${host.port}\u0000'));
            }

            void _handleHello(List<int> data) {
              _syncLog += 'done.\nReceiving hello... ';
              String _data;
              try {
                _data = utf8.decode(data);
              } catch (e, s) {
                _handleException(
                    'Could not decode hello.\n${e.toString()}\n${s.toString()}');
                return;
              }
              List<String> _dataSplit = _data.split(' ');
              if (_dataSplit[0] == _hello) {
                // 2.0.0+ synchronization
                _synchronization2d0d0();
                return;
              }
              try {
                _data = decrypt(decrypt(_data, encrypter: _encrypter),
                    encrypter: getPassyEncrypter(_loadedAccount.username));
              } catch (e, s) {
                _handleException(
                    'Could not decrypt hello. Make sure that local and remote username and password are the same.\n${e.toString()}\n${s.toString()}');
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
              socket.add(utf8.encode('Passy 1.0.0 - $syncVersion\u0000'));
              return socket.flush();
            }

            _sub.onData(_handleHello);
            _sendServiceInfo();
          },
        );
      });
      return _address;
    } catch (e, s) {
      _handleException('Failed to host.\n${e.toString()}\n${s.toString()}');
    }
    return null;
  }

  Future<void> connect(HostAddress address) async {
    void _onConnected(Socket socket) {
      _isConnected = true;
      bool _serviceInfoHandled = false;
      _socket = socket;
      PassyStreamSubscription _sub = PassyStreamSubscription(socket.listen(
        null,
        onError: (e, s) => _handleException(
            'Connection error.\n${e.toString()}\n${s.toString()}'),
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
        } catch (e, s) {
          _handleException(
              'Could not decode info.\n${e.toString()}\n${s.toString()}');
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
          Completer<void> _decryptEntriesCompleter = Completer();
          Completer<void> _sendEntriesCompleter = Completer();

          // If there's no request, the decryption will never complete, so
          // complete its completer
          if (_requestLength != 0) {
            _handleEntriesFuture.then((value) {
              _decryptEntries(value)
                  .then((value) => _decryptEntriesCompleter.complete());
            });
          } else {
            _decryptEntriesCompleter.complete();
          }

          _syncLog += 'done.\nExchanging data... ';
          if (_info.request.length == 0) {
            socket.add(utf8.encode('ready\u0000'));
            await socket.flush();
            _sendEntriesCompleter.complete();
          } else {
            _sendEntries(_info.request)
                .then((value) => _sendEntriesCompleter.complete());
          }

          _handleEntriesFuture.then((value) async {
            await _sendEntriesCompleter.future;
            _socket?.destroy();
            _socket = null;
            await _decryptEntriesCompleter.future;
            _syncLog += 'done.';
            _callOnComplete();
          });
        }
      }

      Future<void> _sendHistory(String historyCSV) {
        _syncLog += 'done.\nSending history... ';
        socket.add(
            utf8.encode(encrypt(historyCSV, encrypter: _encrypter) + '\u0000'));
        return socket.flush();
      }

      void _handleHistoryHash(List<int> data) {
        _syncLog += 'done.\nDecoding history hash... ';
        String _historyJson = jsonEncode(_history.value.toJson());
        bool _same = true;
        try {
          _same = getPassyHash(_historyJson) == Digest(data);
        } catch (e, s) {
          _handleException(
              'Could not read history hash.\n${e.toString()}\n${s.toString()}');
          return;
        }
        if (_same) {
          _socket = null;
          Future.delayed(const Duration(seconds: 16), () => socket.destroy());
          socket.add(utf8.encode(_sameHistoryHash + '\u0000'));
          socket.flush();
          return;
        }
        _sub.onData(_handleInfo);
        _sendHistory(_historyJson);
      }

      void _synchronization2d0d0(String address) async {
        void _handleApiException(String message, Object exception) {
          if (exception is Map<String, dynamic>) {
            _handleException('$message: ${jsonEncode(exception)}');
            return;
          }
          _handleException('$message: $exception.');
        }

        Map<String, dynamic> _checkResponse(Map<String, dynamic>? response) {
          if (response is! Map<String, dynamic>) {
            return {
              'error':
                  'Malformed server response. Expected type `Map<String, dynamic>`, received type `${response.runtimeType.toString()}`.'
            };
          }
          if (response.containsKey('error')) return response['error'];
          dynamic data = response['data'];
          if (data is! Map<String, dynamic>) {
            return {
              'error':
                  'Malformed server response data. Expected type `Map<String, dynamic>`, received type `${response.runtimeType.toString()}`.'
            };
          }
          dynamic error = data['error'];
          if (error != null) return {'error': error};
          dynamic result = data['result'];
          if (result == null) {
            return {'error': 'Server module responded with null'};
          }
          return response['data']['result'];
        }

        List<String> _addressSplit = address.split(':');
        if (_addressSplit.length < 2) {
          _handleException(
              'Could not connect. Malformed server address: $address.');
          return;
        }
        int? port = int.tryParse(_addressSplit[1]);
        if (port == null) {
          _handleException(
              'Could not connect. Malformed server address: $address.');
          return;
        }
        GlareClient _safeSync2d0d0Client;
        try {
          _safeSync2d0d0Client = await GlareClient.connect(
            host: _addressSplit[0],
            port: port,
            keypair: _rsaKeypair,
          );
          _sync2d0d0Client = _safeSync2d0d0Client;
        } catch (e, s) {
          _handleException(
              'Could not connect.\n${e.toString()}\n${s.toString()}');
          return;
        }
        _syncLog += 'done.\nReceiving users list... ';
        Map<String, dynamic> response;
        dynamic users = [
          {'username': _loadedAccount.username}
        ];
        for (dynamic user in users) {
          _syncLog += 'done.\nProcessing next user... ';
          if (user is! Map<String, dynamic>) {
            _handleException(
                'Malformed user information. Expected type `Map<String, dynamic>`, received type `${users.runtimeType.toString()}`.');
            return;
          }
          dynamic username = user['username'];
          if (username is! String) {
            _handleException(
                'Malformed username. Expected type `String`, received type `${username.runtimeType.toString()}`.');
            return;
          }
          if (username != _loadedAccount.username) {
            _handleException(
                'No shared accounts found. Please make sure that your main and/or shared accounts are added on both ends and have the same usernames and passwords.');
            return;
          }
          Encrypter usernameEncrypter =
              getPassyEncrypter(_loadedAccount.username);
          String apiVersion = DateTime.now()
                  .toUtc()
                  .isBefore(synchronization2d0d0DeprecationDate)
              ? '2d0d0'
              : '2d0d1';
          bool useNewAuth = // true
              apiVersion == '2d0d1';

          Map<String, dynamic> auth() {
            return {
              'account': useNewAuth
                  ? null
                  : {
                      'username': username,
                      'passwordHash': _loadedAccount.passwordHash,
                    },
              'auth': util.generateAuth(
                  encrypter: _encrypter, usernameEncrypter: usernameEncrypter),
            };
          }

          _syncLog += 'done.\nAuthenticating... ';
          Map<String, dynamic> authResponse =
              _checkResponse(await _safeSync2d0d0Client.runModule([
            apiVersion,
            useNewAuth ? 'authenticate' : 'checkAccount',
            jsonEncode(auth()),
          ]));
          if (authResponse.containsKey('error')) {
            _syncLog +=
                'done.\nFailed to authenticate. Receiving shared entries... ';
            response = _checkResponse(await _safeSync2d0d0Client.runModule([
              apiVersion,
              'getSharedEntries',
            ]));
            if (response.containsKey('error')) {
              _handleException(
                  '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
              return;
            }
            Map<EntryType, List<util.ExchangeEntry>> sharedEntries;
            try {
              sharedEntries = util.getEntries(response['entries']);
            } catch (e) {
              _handleApiException('Malformed entries received', e);
              return;
            }
            if (sharedEntries.isEmpty) {
              _handleException(
                  '2.0.0+ synchronization host error:\n${jsonEncode(authResponse)}');
              return;
            } else {
              _syncLog += 'done.\nProcessing shared entries... ';
              String nowString = DateTime.now().toUtc().toIso8601String();
              int i = 0;
              for (List<util.ExchangeEntry> sharedEntriesEntry
                  in sharedEntries.values) {
                for (util.ExchangeEntry exchangeEntry in sharedEntriesEntry) {
                  exchangeEntry.key = '$nowString-shared-$i';
                  i++;
                  if (i == 15) break;
                }
                if (i == 15) break;
              }
              try {
                await util.processTypedExchangeEntries(
                  entries: sharedEntries,
                  account: _loadedAccount,
                  history: _history.value,
                  onSetEntry: () => _entriesAdded++,
                  onRemoveEntry: () => _entriesAdded++,
                );
              } catch (e) {
                _handleApiException('Failed to process shared entries', e);
                return;
              }
              _synchronizationResults.sharedEntries = sharedEntries;
              continue;
            }
          }
          if (useNewAuth) {
            try {
              util.verifyAuth(authResponse['auth'],
                  encrypter: _encrypter, usernameEncrypter: usernameEncrypter);
            } catch (e) {
              _handleApiException('Failed to verify host auth', e);
              return;
            }
          }
          // 1. Receive hashes
          _syncLog += 'done.\nReceiving hashes... ';
          response = _checkResponse(await _safeSync2d0d0Client.runModule([
            apiVersion,
            'getHashes',
            jsonEncode(auth()),
          ]));
          if (response.containsKey('error')) {
            _handleException(
                '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
            return;
          }
          dynamic remoteHistoryHash = response['historyHash'];
          dynamic remoteFavoritesHash = response['favoritesHash'];
          if (remoteHistoryHash is! String) {
            _handleException(
                'Received malformed history hash. Expected type `String`, received type `${remoteHistoryHash.runtimeType.toString()}`.');
            return;
          }
          if (remoteFavoritesHash is! String) {
            _handleException(
                'Received malformed favorites hash. Expected type `String`, received type `${remoteFavoritesHash.runtimeType.toString()}`.');
            return;
          }
          Map<EntryType, String> historyHashes;
          try {
            historyHashes = util.getEntriesHashes(response['historyHashes']);
          } catch (e) {
            _handleApiException('Received malformed history hashes', e);
            return;
          }
          Map<EntryType, String> favoritesHashes;
          try {
            favoritesHashes =
                util.getEntriesHashes(response['favoritesHashes']);
          } catch (e) {
            _handleApiException('Received malformed favorites hashes', e);
            return;
          }
          Map<String, dynamic> historyJson = _history.value.toJson();
          _syncLog += 'done.\nComparing history hashes... ';
          if (remoteHistoryHash !=
              getPassyHash(jsonEncode(historyJson)).toString()) {
            // 2. Compare history hashes and find entry types that require synchronization
            Map<EntryType, String> localHistoryHashes;
            try {
              localHistoryHashes = util.findEntriesHashes(json: historyJson);
            } catch (e) {
              _handleApiException('Failed to find local history hashes', e);
              return;
            }
            List<EntryType> entryTypes;
            try {
              entryTypes = util.findEntryTypesToSynchronize(
                  localHashes: localHistoryHashes, remoteHashes: historyHashes);
            } catch (e) {
              _handleApiException('Failed to compare history hashes', e);
              return;
            }
            // 3. Receive history for entry types that require synchronization
            _syncLog += 'done.\nReceiving history entries... ';
            response = _checkResponse(await _safeSync2d0d0Client.runModule([
              apiVersion,
              'getHistoryEntries',
              jsonEncode({
                ...auth(),
                'entryTypes': entryTypes.map<String>((e) => e.name).toList(),
              }),
            ]));
            if (response.containsKey('error')) {
              _handleException(
                  '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
              return;
            }
            Map<EntryType, Map<String, EntryEvent>> historyEntries;
            try {
              historyEntries =
                  util.getTypedEntryEvents(response['historyEntries']);
            } catch (e) {
              _handleApiException('Received malformed history entries', e);
              return;
            }
            Map<EntryType, Map<String, EntryEvent>> localHistoryEntries = {};
            for (EntryType type in entryTypes) {
              localHistoryEntries[type] = _history.value.getEvents(type);
            }
            _syncLog += 'done.\nComparing history entries... ';
            util.EntriesToSynchronize entriesToSynchronize;
            try {
              entriesToSynchronize = util.findEntriesToSynchronize(
                  localEntries: localHistoryEntries,
                  remoteEntries: historyEntries);
            } catch (e) {
              _handleApiException('Failed to compare history entries', e);
              return;
            }
            if (entriesToSynchronize.entriesToSend.isNotEmpty) {
              _syncLog += 'done.\nSending entries... ';
              response = _checkResponse(await _safeSync2d0d0Client.runModule([
                apiVersion,
                'setEntries',
                jsonEncode({
                  ...auth(),
                  'entries': entriesToSynchronize.entriesToSend
                      .map((entryType, entryKeys) {
                    Map<String, EntryEvent> historyEntries =
                        _history.value.getEvents(entryType);
                    PassyEntry? Function(String) getEntry =
                        _loadedAccount.getEntry(entryType);
                    return MapEntry(
                      entryType.name,
                      entryKeys.map<Map<String, dynamic>>((e) {
                        return {
                          'key': e,
                          'historyEntry': historyEntries[e],
                          'entry': getEntry(e),
                        };
                      }).toList(),
                    );
                  }),
                }),
              ]));
              if (response.containsKey('error')) {
                _handleException(
                    '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
                return;
              }
            }
            if (entriesToSynchronize.entriesToRetrieve.isNotEmpty) {
              _syncLog += 'done.\nReceiving entries... ';
              response = _checkResponse(await _safeSync2d0d0Client.runModule([
                apiVersion,
                'getEntries',
                jsonEncode({
                  ...auth(),
                  'entryKeys': entriesToSynchronize.entriesToRetrieve
                      .map((key, value) => MapEntry(key.name, value)),
                }),
              ]));
              if (response.containsKey('error')) {
                _handleException(
                    '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
                return;
              }
              Map<EntryType, List<util.ExchangeEntry>> entries;
              try {
                entries = util.getEntries(response['entries']);
              } catch (e) {
                _handleApiException('Malformed entries received', e);
                return;
              }
              _syncLog += 'done.\nProcessing entries... ';
              try {
                await _history.reload();
                await util.processTypedExchangeEntries(
                  entries: entries,
                  account: _loadedAccount,
                  history: _history.value,
                  onRemoveEntry: () => _entriesRemoved++,
                  onSetEntry: () => _entriesAdded++,
                );
              } catch (e) {
                _handleApiException('Failed to process entries', e);
                return;
              }
            }
          }
          Map<String, dynamic> favoritesJson = _favorites.toJson();
          _syncLog += 'done.\nComparing favorites hashes... ';
          if (remoteFavoritesHash !=
              getPassyHash(jsonEncode(favoritesJson)).toString()) {
            // Compare favorites hashes and find entry types that require synchronization
            Map<EntryType, String> localFavoritesHashes;
            try {
              localFavoritesHashes =
                  util.findEntriesHashes(json: favoritesJson);
            } catch (e) {
              _handleApiException('Failed to find local favorites hashes', e);
              return;
            }
            List<EntryType> entryTypes;
            try {
              entryTypes = util.findEntryTypesToSynchronize(
                  localHashes: localFavoritesHashes,
                  remoteHashes: favoritesHashes);
            } catch (e) {
              _handleApiException('Failed to compare favorites hashes', e);
              return;
            }
            // Receive favorites for entry types that require synchronization
            _syncLog += 'done.\nReceiving favorites entries... ';
            response = _checkResponse(await _safeSync2d0d0Client.runModule([
              apiVersion,
              'getFavoritesEntries',
              jsonEncode({
                ...auth(),
                'entryTypes': entryTypes.map<String>((e) => e.name).toList(),
              }),
            ]));
            if (response.containsKey('error')) {
              _handleException(
                  '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
              return;
            }
            Map<EntryType, Map<String, EntryEvent>> favoritesEntries;
            try {
              favoritesEntries =
                  util.getTypedEntryEvents(response['favoritesEntries']);
            } catch (e) {
              _handleApiException('Received malformed favorites entries', e);
              return;
            }
            Map<EntryType, Map<String, EntryEvent>> localFavoritesEntries = {};
            for (EntryType type in entryTypes) {
              localFavoritesEntries[type] = _favorites.getEvents(type);
            }
            _syncLog += 'done.\nComparing favorites entries... ';
            util.EntriesToSynchronize entriesToSynchronize;
            try {
              entriesToSynchronize = util.findEntriesToSynchronize(
                  localEntries: localFavoritesEntries,
                  remoteEntries: favoritesEntries);
            } catch (e) {
              _handleApiException('Failed to compare favorites entries', e);
              return;
            }
            if (entriesToSynchronize.entriesToSend.isNotEmpty) {
              _syncLog += 'done.\nSending favorites entries... ';
              response = _checkResponse(await _safeSync2d0d0Client.runModule([
                apiVersion,
                'setFavoritesEntries',
                jsonEncode({
                  ...auth(),
                  'favoritesEntries': entriesToSynchronize.entriesToSend
                      .map<String, dynamic>((entryType, keyList) {
                    Map<String, EntryEvent> localFavorites =
                        _favorites.getEvents(entryType);
                    List<dynamic> val = [];
                    for (String key in keyList) {
                      EntryEvent? entryEvent = localFavorites[key];
                      if (entryEvent == null) continue;
                      val.add(entryEvent);
                    }
                    return MapEntry(
                      entryType.name,
                      val,
                    );
                  }),
                }),
              ]));
              if (response.containsKey('error')) {
                _handleException(
                    '2.0.0+ synchronization host error:\n${jsonEncode(response)}');
                return;
              }
            }
            if (entriesToSynchronize.entriesToRetrieve.isNotEmpty) {
              _syncLog += 'done.\nSaving favorites entries... ';
              for (MapEntry<EntryType, List<String>> entriesToRetrieveEntry
                  in entriesToSynchronize.entriesToRetrieve.entries) {
                EntryType entryType = entriesToRetrieveEntry.key;
                Map<String, EntryEvent>? typeFavoritesEntries =
                    favoritesEntries[entryType];
                if (typeFavoritesEntries == null) continue;
                Map<String, EntryEvent> localFavoritesEntries =
                    _favorites.getEvents(entryType);
                for (String entryKey in entriesToRetrieveEntry.value) {
                  EntryEvent? favoritesEntry = typeFavoritesEntries[entryKey];
                  if (favoritesEntry == null) continue;
                  localFavoritesEntries[entryKey] = favoritesEntry;
                }
              }
              await _loadedAccount.saveFavorites();
            }
          }
        }
        _syncLog += '\nAll done.\nDisconnecting... ';
        _safeSync2d0d0Client.disconnect();
        _socket = null;
        socket.add(utf8.encode(jsonEncode(SynchronizationSignal(
                    data: SynchronizationSignalData(name: 'exit'))
                .toJson()) +
            '\u0000'));
        socket.flush();
        _callOnComplete();
        Future.delayed(const Duration(milliseconds: 500), () {
          socket.destroy();
          _syncLog += 'done.';
        });
      }

      _handle2p0p0ServerAddress(List<int> data) {
        String _address2d0d0;
        try {
          _address2d0d0 = utf8.decode(data);
        } catch (e, s) {
          _handleException(
              'Could not decode 2.0.0+ synchronization server address.\n${e.toString()}\n${s.toString()}');
          return;
        }
        _syncLog += 'done.\nConnecting... ';
        _synchronization2d0d0(_address2d0d0);
      }

      Future<void> _sendHello(String hello) {
        _syncLog += 'done.\nSending hello... ';
        socket.add(utf8.encode(hello + '\u0000'));
        return socket.flush();
      }

      void _handleServiceInfo(List<int> data) {
        if (_serviceInfoHandled) return;
        _serviceInfoHandled = true;
        _syncLog += 'done.\nReceiving service info... ';
        List<String> _info = [];
        try {
          _info = utf8.decode(data).split(' ');
        } catch (e, s) {
          _handleException(
              'Could not decode hello.\n${e.toString()}\n${s.toString()}');
          return;
        }
        if (_info.length < 2) {
          _handleException(
              'Service info is less than 2 parts long. Info length: ${_info.length}.');
          return;
        }
        if (_info[0] != 'Passy') {
          _handleException(
              'Remote service is not Passy. Service name: ${_hello[0]}.');
          return;
        }
        if ('1.0.0' != _info[1]) {
          _handleException(
              'Local and remote versions are different. Local version: 1.0.0. Remote version: ${_info[1]}.');
          return;
        }
        if (_info.length > 3) {
          // 2.0.0+ synchronization
          _syncLog +=
              'done.\nHost supports 2.0.0+ synchronization. Sending 2.0.0+ hello... ';
          socket.add(utf8.encode(_hello + '\u0000'));
          _syncLog += 'done.\nReceiving 2.0.0+ server address... ';
          _sub.onData(_handle2p0p0ServerAddress);
          return;
        }
        _syncLog += 'done.\nReceiving history hash... ';
        _sub.onData(_handleHistoryHash);
        _sendHello(encrypt(
            encrypt(_hello,
                encrypter: getPassyEncrypter(_loadedAccount.username)),
            encrypter: _encrypter));
      }

      _sub.onData(_handleServiceInfo);
    }

    _syncLog = 'Connecting... ';
    await Socket.connect(address.ip, address.port,
            timeout: const Duration(seconds: 8))
        .then((socket) => _onConnected(socket),
            onError: (e, s) => _handleException(
                'Failed to connect.\n${e.toString()}\n${s.toString()}'));
  }

  void close() {
    if (!_isConnected) {
      _server?.close();
      _socket?.destroy();
      _sync2d0d0Host?.stop();
      _sync2d0d0Client?.disconnect();
      _callOnComplete();
    } else {
      _handleException('Synchronization requested to close while connected.');
    }
  }
}
