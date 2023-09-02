import 'dart:io';

import 'package:crypton/crypton.dart';

import 'common.dart';
import 'glare_server_socket.dart';
import 'glare_module.dart';

class GlareServer {
  static const String version = glareProtocolVersion;
  static const int maxIdleMs = 300000; // 5 minutes
  final InternetAddress address;
  final int port;
  final ServerSocket _serverSocket;
  final Map<String, GlareServerSocket> _sockets;
  final Function(String)? _log;

  GlareServer._({
    required this.address,
    required this.port,
    required ServerSocket serverSocket,
    required Map<String, GlareServerSocket> sockets,
    Function(String)? log,
  })  : _serverSocket = serverSocket,
        _sockets = sockets,
        _log = log;

  static Future<GlareServer> bind({
    required dynamic address,
    required int port,
    RSAKeypair? keypair,
    required Map<String, GlareModule> modules,
    Function(dynamic object)? log,
    String serviceInfo = 'Glare server protocol v$version',
    int maxBindTries = 1,
    Duration bindTryInterval = const Duration(seconds: 10),
  }) async {
    GlareServer _result;
    Map<String, GlareServerSocket> _sockets = {};
    ServerSocket serverSocket;
    int bindTryCount = maxBindTries == 0 ? 1 : 0;
    while (true) {
      if (maxBindTries != 0) bindTryCount++;
      try {
        serverSocket = await ServerSocket.bind(address, port);
        break;
      } catch (_) {
        if (bindTryCount == maxBindTries) rethrow;
        await Future.delayed(bindTryInterval);
      }
    }
    serverSocket.listen((Socket socket) {
      String address = '${socket.remoteAddress.address}:${socket.remotePort}';
      log?.call('I:Client $address connected.');
      socket.done.catchError((Object error) {});
      socket.writeln(serviceInfo);
      _sockets[address] = GlareServerSocket(socket,
          keypair: keypair,
          maxIdleMs: maxIdleMs,
          onDone: () {
            _sockets.remove(address);
            log?.call('I:Client $address disconnected.');
          },
          onError: (Object error) => {},
          modules: modules);
    }, onError: (Object error) => {});
    log?.call(
        'I:Glare server started at ${serverSocket.address.address}:${serverSocket.port}.');
    _result = GlareServer._(
      address: serverSocket.address,
      port: serverSocket.port,
      serverSocket: serverSocket,
      sockets: _sockets,
      log: log,
    );
    return _result;
  }

  Future<void> stop() async {
    await _serverSocket.close();
    _log?.call('I:Glare server stopped.');
    _sockets.clear();
  }
}
