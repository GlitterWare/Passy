import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'line_stream_subscription.dart';
import 'rsa_socket_helpers.dart';

class RSAClientSocket {
  static const version = rsaSocketVersion;
  final Socket _socket;
  final InternetAddress address;
  final int port;
  final RSAKeypair _keyPair;
  //RSAPublicKey? _serverPublicKey;
  Encrypter? _encrypter;
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();
  final Completer<void> _onConnected = Completer<void>();

  get remoteAddress => _socket.remoteAddress;
  get remotePort => _socket.remotePort;

  bool _handshake(List<int> data) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(utf8.decode(data));
    } catch (_) {
      return false;
    }
    dynamic serviceVersion = decoded['socketVersion'];
    if (serviceVersion is! String) return false;
    dynamic rsa = decoded['rsa'];
    if (rsa is! Map) return false;
    dynamic publicKey = rsa['publicKey'];
    if (publicKey == null) return false;
    /*
    try {
      _serverPublicKey = RSAPublicKey.fromString(publicKey);
    } catch (_) {
      return false;
    }
    */
    return true;
  }

  void _onData(List<int> data) {
    if (_encrypter == null) return;
    Map<String, dynamic> decoded = {};
    try {
      decoded = RSASocketHelpers.decodeData(data, encrypter: _encrypter)!;
    } catch (_) {
      return;
    }
    _streamController.add(decoded);
  }

  RSAClientSocket._(Socket socket, {RSAKeypair? keypair})
      : _socket = socket,
        address = socket.address,
        port = socket.port,
        _keyPair = keypair ?? RSAKeypair.fromRandom(keySize: 4096) {
    LineByteStreamSubscription subscription =
        LineByteStreamSubscription(_socket.listen(
      null,
      onError: (Object error, StackTrace? stackTrace) =>
          _streamController.addError(error, stackTrace),
      onDone: () => _streamController.close(),
    ));
    subscription.onData((List<int> data) {
      if (_handshake(data)) {
        subscription.onData((data) {
          Map<String, dynamic> decoded;
          try {
            decoded =
                jsonDecode(_keyPair.privateKey.decrypt(utf8.decode(data)));
          } catch (_) {
            return;
          }
          dynamic password = decoded['password'];
          if (password is! String) return;
          try {
            _encrypter = Encrypter(AES(Key.fromUtf8(password)));
          } catch (_) {
            return;
          }
          subscription.onData(_onData);
          _onConnected.complete();
        });
        _socket.writeln(
            '{"rsa":{"publicKey":"${_keyPair.publicKey.toString()}"}}');
      }
    });
  }

  static Future<RSAClientSocket> connect(
    dynamic host,
    int port, {
    RSAKeypair? keypair,
    dynamic sourceAddress,
    int sourcePort = 0,
    Duration? timeout,
  }) async {
    Socket socket = await Socket.connect(host, port, timeout: timeout);
    socket.done.catchError((Object error) {});
    RSAClientSocket rsaSock = RSAClientSocket._(socket, keypair: keypair);
    await rsaSock._onConnected.future;
    return rsaSock;
  }

  Future<dynamic> close() => _socket.close();

  StreamSubscription<Map<String, dynamic>> listenJson(
    void Function(Map<String, dynamic> event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _streamController.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void writeJson(
    Map<String, dynamic> data, {
    Map<String, List<int>>? binaryObjects,
  }) {
    RSASocketHelpers.writeJson(data,
        socket: _socket, binaryObjects: binaryObjects, encrypter: _encrypter);
  }
}
