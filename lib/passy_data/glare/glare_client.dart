import 'dart:async';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:event/event.dart';

import 'common.dart';
import 'rsa_client_socket.dart';

class GlareClient {
  static const String version = glareProtocolVersion;
  bool _connected = true;
  final InternetAddress address;
  final int port;
  final RSAClientSocket _socket;
  late StreamSubscription<Map<String, dynamic>> _socketSubscription;
  final Function(dynamic)? _log;
  final Map<String, Completer<Map<String, dynamic>?>> _commandEvents = {};
  final Map<String, List<int> Function(int length)> _readBytesEvents = {};
  final Event _onDisconnect = Event();

  GlareClient._({
    required RSAClientSocket socket,
    required this.address,
    required this.port,
    Function(dynamic)? log,
  })  : _socket = socket,
        _log = log {
    _socketSubscription = _socket.listenJson(_onData, onDone: () {
      _cleanup();
    });
  }

  void onDisconnectSubscribe(Function(EventArgs? args) handler) {
    _onDisconnect + handler;
  }

  void onDisconnectUnsubscribe(Function(EventArgs? args) handler) {
    _onDisconnect - handler;
  }

  static Future<GlareClient> connect({
    required dynamic host,
    required int port,
    RSAKeypair? keypair,
    Function(dynamic object)? log,
    Duration? timeout,
  }) async {
    RSAClientSocket socket = await RSAClientSocket.connect(host, port,
        keypair: keypair, timeout: timeout);
    return GlareClient._(
      socket: socket,
      address: socket.address,
      port: socket.port,
      log: log,
    );
  }

  Future<void> _cleanup() async {
    await _socketSubscription.cancel();
    await _socket.close();
    for (Completer<Map<String, dynamic>?> completer in _commandEvents.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _commandEvents.clear();
    if (_connected) {
      _connected = false;
      _onDisconnect.broadcast();
    }
  }

  void _handleCommandResponse(Map<String, dynamic> data) {
    dynamic dataDecoded = data['data'];
    if (dataDecoded is! Map<String, dynamic>) return;
    dynamic arguments = data['arguments'];
    if (arguments is! List) return;
    if (arguments.isEmpty) return;
    String argumentsJoined = arguments.join('\n');
    Completer<Map<String, dynamic>?>? commandEvent =
        _commandEvents[argumentsJoined];
    if (commandEvent == null) {
      _log?.call('W:Unhandled command response:\n$data');
      return;
    }
    dynamic action = data['action'];
    if (action is Map<String, dynamic>) {
      if (action['name'] == 'readBytes') {
        if (action.containsKey('error')) {
          return;
        }
        dynamic lengthStr = action['length'];
        if (lengthStr is! String) return;
        int length;
        try {
          length = int.parse(lengthStr);
        } catch (_) {
          return;
        }
        List<int>? bytes = _readBytesEvents[argumentsJoined]?.call(length);
        if (bytes == null) return;
        _socket.add(bytes);
        return;
      }
    }
    if (!commandEvent.isCompleted) commandEvent.complete(data);
    _commandEvents.remove(argumentsJoined);
  }

  Future<void> _onData(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'hello':
        _log?.call(
            'I:Connected to ${_socket.remoteAddress.address}:${_socket.remotePort}.');
        break;
      case 'commandResponse':
        _handleCommandResponse(data);
        break;
    }
  }

  void writeJson(Map<String, dynamic> data) {
    _socket.writeJson(data);
  }

  Future<Map<String, dynamic>> ping() async {
    if (!_connected) {
      return {
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      };
    }
    Completer<Map<String, dynamic>?>? pingCompleter = _commandEvents['ping'];
    await pingCompleter?.future;
    pingCompleter = Completer<Map<String, dynamic>?>();
    _commandEvents['ping'] = pingCompleter;
    DateTime before = DateTime.now().toUtc();
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['ping']
      }
    });
    Map<String, dynamic>? response = await pingCompleter.future;
    if (response == null) {
      return {
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      };
    }
    DateTime now = DateTime.now().toUtc();
    int latency = now.millisecondsSinceEpoch - before.millisecondsSinceEpoch;
    return {
      'type': 'localResponse',
      'latency': latency,
    };
  }

  Future<Map<String, dynamic>> requestVersion() async {
    if (!_connected) {
      return {
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      };
    }
    Completer<Map<String, dynamic>?>? versionCompleter =
        _commandEvents['version'];
    await versionCompleter?.future;
    versionCompleter = Completer<Map<String, dynamic>?>();
    _commandEvents['version'] = versionCompleter;
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['version']
      }
    });
    Map<String, dynamic>? response = await versionCompleter.future;
    if (response == null) {
      return {
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      };
    }
    return response;
  }

  Future<Map<String, dynamic>> listModules() async {
    if (!_connected) {
      return {
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      };
    }
    Completer<Map<String, dynamic>?>? listModulesCompleter =
        _commandEvents['list\nmodules'];
    await listModulesCompleter?.future;
    listModulesCompleter = Completer<Map<String, dynamic>?>();
    _commandEvents['list\nmodules'] = listModulesCompleter;
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['list', 'modules']
      }
    });
    Map<String, dynamic>? response = await listModulesCompleter.future;
    if (response == null) {
      return {
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      };
    }
    dynamic data = response['data'];
    if (data is! Map<String, dynamic>) {
      return {
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid data received',
        },
      };
    }
    dynamic modules = data['modules'];
    if (modules is! Map<String, dynamic>) {
      return {
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid modules received',
        },
      };
    }
    if (modules.isEmpty) return {};
    Map<String, dynamic> result = {};
    for (MapEntry<String, dynamic> module in modules.entries) {
      dynamic val = module.value;
      if (val is! Map<String, dynamic>) continue;
      dynamic name = val['name'];
      result[module.key] = {
        'name': name is String ? name : null,
      };
    }
    return {
      'modules': result,
    };
  }

  Future<Map<String, dynamic>> runModule(List<String> args,
      {List<int> Function(int length)? onReadBytes}) async {
    if (args.isEmpty) {
      return {
        'type': 'localError',
        'arguments': args,
        'error': {
          'type': 'No arguments provided',
        },
      };
    }
    String id = 'modules\nrun\n${args.join('\n')}';
    Completer<Map<String, dynamic>?>? onModulesRun = _commandEvents[id];
    await onModulesRun?.future;
    onModulesRun = Completer<Map<String, dynamic>?>();
    _commandEvents[id] = onModulesRun;
    if (onReadBytes != null) _readBytesEvents[id] = onReadBytes;
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['modules', 'run', ...args],
      }
    });
    Map<String, dynamic>? response = await onModulesRun.future;
    if (response == null) {
      return {
        'type': 'localError',
        'arguments': args,
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      };
    }
    return response;
  }

  Future<void> disconnect() async {
    _cleanup();
  }
}
