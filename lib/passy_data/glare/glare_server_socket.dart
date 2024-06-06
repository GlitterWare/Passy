import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';

import 'common.dart';
import 'glare_module.dart';
import 'rsa_server_socket.dart';

class GlareServerSocket {
  static const String version = glareProtocolVersion;
  final RSAServerSocket _socket;
  final int _maxIdleMs;
  DateTime _lastEvent;
  final Map<String, GlareModule> _modules;
  Map<String, dynamic>? _error;

  GlareServerSocket(
    Socket socket, {
    RSAKeypair? keypair,
    required int maxIdleMs,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    required Map<String, GlareModule> modules,
  })  : _socket = RSAServerSocket(socket, keypair: keypair),
        _maxIdleMs = maxIdleMs,
        _lastEvent = DateTime.now().toUtc(),
        _modules = modules {
    _socket.listenJson(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void sendError(Object e) {
    if (e is! Map<String, dynamic>) e = e.toString();
    _error = {
      'type': 'commandResponse',
      'arguments': ['err'],
      'data': {
        'error': e,
      },
    };
  }

  void destroy() {
    _socket.destroy();
  }

  Map<String, dynamic> _executeListModules() {
    return {
      'type': 'commandResponse',
      'arguments': ['list', 'modules'],
      'data': {
        'modules':
            _modules.map<String, dynamic>((k, v) => MapEntry(k, v.toJson())),
      }
    };
  }

  Map<String, dynamic> _executeList(List<String> args) {
    if (args.length < 2) {
      return {
        'type': 'commandResponse',
        'arguments': args,
        'data': {
          'error': {
            'type': 'Missing arguments',
            'description': 'Expected 2, received ${args.length}',
          }
        },
      };
    }
    switch (args[1]) {
      case 'modules':
        return _executeListModules();
      default:
        return {
          'type': 'commandResponse',
          'arguments': args,
          'data': {
            'error': {'type': 'List subcommand not found'}
          },
        };
    }
  }

  Future<Map<String, dynamic>> _runModule(
    List<String> args, {
    Map<String, List<int>>? binaryObjects,
  }) async {
    GlareModule? module = _modules[args[2]];
    if (module == null) {
      return {
        'type': 'commandResponse',
        'arguments': args,
        'data': {
          'error': {'type': 'Module not found'},
        },
      };
    }
    _lastEvent = DateTime.now().toUtc();
    try {
      Map<String, dynamic>? result = await module.run(
        args,
        addModule: (key, module) => _modules[key] = module,
        binaryObjects: binaryObjects,
      );
      Map<String, dynamic> jsonResult = {
        'type': 'commandResponse',
        'arguments': args,
        'data': {
          'result': result,
        },
      };
      if (result != null) {
        if (result.containsKey('binaryObjects')) {
          jsonResult['binaryObjects'] = result['binaryObjects'];
          result.remove('binaryObjects');
        }
      }
      return jsonResult;
    } catch (e, s) {
      dynamic errorEncoded;
      try {
        errorEncoded = jsonEncode(e);
      } catch (_) {}
      return {
        'type': 'commandResponse',
        'arguments': args,
        'data': {
          'error': {
            'type': 'Module exception',
            'exception': errorEncoded == null ? e.toString() : e,
            'stack': s.toString(),
          },
        },
      };
    }
  }

  Future<Map<String, dynamic>> _executeModules(
    List<String> args, {
    Map<String, List<int>>? binaryObjects,
  }) async {
    switch (args[1]) {
      case 'run':
        if (args.length < 3) {
          return {
            'type': 'commandResponse',
            'arguments': args,
            'data': {
              'error': {
                'type': 'Missing arguments',
                'description': 'Expected 3, received ${args.length}',
              }
            },
          };
        }
        return _runModule(
          args,
          binaryObjects: binaryObjects,
        );
      default:
        return {
          'type': 'commandResponse',
          'arguments': args,
          'data': {
            'error': {'type': 'Modules subcommand not found'}
          },
        };
    }
  }

  Future<void> onData(Map<String, dynamic> data) async {
    DateTime now = DateTime.now().toUtc();
    if ((now.millisecondsSinceEpoch - _lastEvent.millisecondsSinceEpoch) >
        _maxIdleMs) {
      _socket.destroy();
      return;
    }
    Map<String, dynamic>? err = _error;
    if (err != null) {
      _socket.writeJson(err);
      _error = null;
      return;
    }
    dynamic dataDecoded = data['data'];
    if (dataDecoded is! Map<String, dynamic>) return;
    dynamic arguments = dataDecoded['arguments'];
    if (arguments is! List) return;
    if (arguments.isEmpty) return;
    List<String> argumentsDecoded =
        arguments.map<String>((e) => e.toString()).toList();
    Map<String, List<int>>? binaryObjects;
    if (data.containsKey('binaryObjects')) {
      try {
        binaryObjects = Map.castFrom(data['binaryObjects']);
      } catch (_) {}
      data.remove('binaryObjects');
    }
    _lastEvent = now;
    switch (arguments[0]) {
      case 'ping':
        _socket.writeJson({
          'type': 'commandResponse',
          'arguments': arguments,
          'data': {
            'message': 'Pong!',
          },
        });
        break;
      case 'version':
        _socket.writeJson({
          'type': 'commandResponse',
          'arguments': arguments,
          'data': {
            'protocolVersion': version,
          },
        });
        break;
      case 'list':
        _socket.writeJson(_executeList(argumentsDecoded));
        break;
      case 'modules':
        Map<String, dynamic> moduleData = await _executeModules(
            argumentsDecoded,
            binaryObjects: binaryObjects);
        Map<String, List<int>>? moduleBinaryObjects;
        if (moduleData.containsKey('binaryObjects')) {
          try {
            moduleBinaryObjects = Map.castFrom(moduleData['binaryObjects']);
          } catch (_) {}
          moduleData.remove('binaryObjects');
        }
        _socket.writeJson(moduleData, binaryObjects: moduleBinaryObjects);
        break;
      default:
        _socket.writeJson({
          'type': 'commandResponse',
          'arguments': arguments,
          'data': {
            'error': {'type': 'Command not found'},
          },
        });
        break;
    }
  }
}
