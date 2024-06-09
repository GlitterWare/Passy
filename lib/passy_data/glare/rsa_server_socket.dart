import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'line_stream_subscription.dart';
import 'rsa_socket_helpers.dart';

class RSAServerSocket {
  static const version = rsaSocketVersion;
  final Socket _socket;
  final RSAKeypair _keyPair;
  RSAPublicKey? _clientPublicKey;
  Encrypter? _encrypter;
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();
  final Completer<void> _handshakeCompleter = Completer();

  Future<void> get handshakeComplete => _handshakeCompleter.future;

  bool _handshake(List<int> data) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(utf8.decode(data));
    } catch (_) {
      return false;
    }
    if (decoded['rsa'] == null) return false;
    dynamic rsa = decoded['rsa'];
    if (rsa is! Map) return false;
    dynamic publicKey = rsa['publicKey'];
    if (publicKey == null) return false;
    try {
      _clientPublicKey = RSAPublicKey.fromString(publicKey);
    } catch (_) {
      return false;
    }
    return true;
  }

  void _onData(List<int> data) {
    Map<String, dynamic> decoded = {};
    try {
      decoded = RSASocketHelpers.decodeData(data, encrypter: _encrypter)!;
    } catch (_) {
      return;
    }
    _streamController.add(decoded);
  }

  RSAServerSocket(Socket socket, {RSAKeypair? keypair})
      : _socket = socket,
        _keyPair = keypair ?? RSAKeypair.fromRandom(keySize: 4096) {
    LineByteStreamSubscription subscription;
    subscription = LineByteStreamSubscription(_socket.listen(null, onDone: () {
      _streamController.close();
    }));
    subscription.onData((data) {
      if (_handshake(data)) {
        String _password = generatePassword();
        _encrypter = Encrypter(AES(Key.fromUtf8(_password)));
        subscription.onData(_onData);
        _socket.writeln(
            _clientPublicKey!.encrypt(jsonEncode({'password': _password})));
      }
    });
    subscription.onError((Object error, StackTrace? stackTrace) {
      _streamController.addError(error, stackTrace);
    });
    _socket.writeln(jsonEncode({
      'socketVersion': version,
      'rsa': {'publicKey': _keyPair.publicKey.toString()},
    }));
  }

  void destroy() => _socket.destroy();

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
