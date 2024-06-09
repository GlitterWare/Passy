import 'dart:async';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:event/event.dart';
import 'package:passy/passy_data/glare/glare_message.dart';

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
  final Map<String, Completer<GlareMessage?>> _commandEvents = {};
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
    for (Completer<GlareMessage?> completer in _commandEvents.values) {
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
    Completer<GlareMessage?>? commandEvent = _commandEvents[argumentsJoined];
    if (commandEvent == null) {
      _log?.call('W:Unhandled command response:\n$data');
      return;
    }
    if (!commandEvent.isCompleted) {
      commandEvent.complete(GlareMessage.fromSocketData(data));
    }
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

  void writeJson(
    Map<String, dynamic> data, {
    Map<String, List<int>>? binaryObjects,
  }) {
    _socket.writeJson(
      data,
      binaryObjects: binaryObjects,
    );
  }

  Future<GlareMessage> ping() async {
    if (!_connected) {
      return GlareMessage({
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      });
    }
    Completer<GlareMessage?>? pingCompleter = _commandEvents['ping'];
    await pingCompleter?.future;
    pingCompleter = Completer<GlareMessage?>();
    _commandEvents['ping'] = pingCompleter;
    DateTime before = DateTime.now().toUtc();
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['ping']
      }
    });
    GlareMessage? response = await pingCompleter.future;
    if (response == null) {
      return GlareMessage({
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      });
    }
    DateTime now = DateTime.now().toUtc();
    int latency = now.millisecondsSinceEpoch - before.millisecondsSinceEpoch;
    return GlareMessage({
      'type': 'localResponse',
      'latency': latency,
    });
  }

  Future<GlareMessage> requestVersion() async {
    if (!_connected) {
      return GlareMessage({
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      });
    }
    Completer<GlareMessage?>? versionCompleter = _commandEvents['version'];
    await versionCompleter?.future;
    versionCompleter = Completer<GlareMessage?>();
    _commandEvents['version'] = versionCompleter;
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['version']
      }
    });
    GlareMessage? response = await versionCompleter.future;
    if (response == null) {
      return GlareMessage({
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      });
    }
    return response;
  }

  Future<GlareMessage> listModules() async {
    if (!_connected) {
      return GlareMessage({
        'type': 'localError',
        'error': {
          'type': 'Not connected',
        },
      });
    }
    Completer<GlareMessage?>? listModulesCompleter =
        _commandEvents['list\nmodules'];
    await listModulesCompleter?.future;
    listModulesCompleter = Completer<GlareMessage?>();
    _commandEvents['list\nmodules'] = listModulesCompleter;
    writeJson({
      'type': 'command',
      'data': {
        'arguments': ['list', 'modules']
      }
    });
    GlareMessage? response = await listModulesCompleter.future;
    if (response == null) {
      return GlareMessage({
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      });
    }
    dynamic data = response.data['data'];
    if (data is! Map<String, dynamic>) {
      return GlareMessage({
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid data received',
        },
      });
    }
    dynamic modules = data['modules'];
    if (modules is! Map<String, dynamic>) {
      return GlareMessage({
        'type': 'localError',
        'response': response,
        'error': {
          'type': 'Invalid modules received',
        },
      });
    }
    if (modules.isEmpty) return GlareMessage({'modules': {}});
    Map<String, dynamic> result = {};
    for (MapEntry<String, dynamic> module in modules.entries) {
      dynamic val = module.value;
      if (val is! Map<String, dynamic>) continue;
      dynamic name = val['name'];
      result[module.key] = {
        'name': name is String ? name : null,
      };
    }
    return GlareMessage({
      'modules': result,
    });
  }

  Future<GlareMessage> runModule(
    List<String> args, {
    List<int> Function(int length)? onReadBytes,
    Map<String, List<int>>? binaryObjects,
  }) async {
    if (args.isEmpty) {
      return GlareMessage({
        'type': 'localError',
        'arguments': args,
        'error': {
          'type': 'No arguments provided',
        },
      });
    }
    String id = 'modules\nrun\n${args.join('\n')}';
    Completer<GlareMessage?>? onModulesRun = _commandEvents[id];
    await onModulesRun?.future;
    onModulesRun = Completer<GlareMessage?>();
    _commandEvents[id] = onModulesRun;
    writeJson(
      {
        'type': 'command',
        'data': {
          'arguments': ['modules', 'run', ...args],
        },
      },
      binaryObjects: binaryObjects,
    );
    GlareMessage? response = await onModulesRun.future;
    if (response == null) {
      return GlareMessage({
        'type': 'localError',
        'arguments': args,
        'response': response,
        'error': {
          'type': 'Invalid response received',
        },
      });
    }
    return response;
  }

  Future<void> disconnect() async {
    _cleanup();
  }
}
