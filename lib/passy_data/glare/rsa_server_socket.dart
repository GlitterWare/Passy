import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'line_stream_subscription.dart';
import 'package:uuid/uuid.dart';

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
    if (_encrypter == null) return;
    Map<String, dynamic> decoded = {};
    try {
      String decrypted = '';
      for (String part in utf8.decode(data).split(' ')) {
        List<String> partSplit = part.split(',');
        if (partSplit.length < 2) return;
        decrypted += _encrypter!
            .decrypt64(partSplit[1], iv: IV.fromBase64(partSplit[0]));
      }
      decoded = jsonDecode(decrypted);
    } catch (_) {
      return;
    }
    _streamController.add(decoded);
  }

  RSAServerSocket(Socket socket, {RSAKeypair? keypair})
      : _socket = socket,
        _keyPair = keypair ?? RSAKeypair.fromRandom(keySize: 4096) {
    LineByteStreamSubscription subscription;
    subscription = LineByteStreamSubscription(_socket.listen(null,
        onError: (Object error, StackTrace? stackTrace) =>
            _streamController.addError(error, stackTrace),
        onDone: () {
          _streamController.close();
        }));
    subscription.onData((data) {
      if (_handshake(data)) {
        String _password = const Uuid().v4().substring(0, 32);
        _encrypter = Encrypter(AES(Key.fromUtf8(_password)));
        _socket.writeln(
            _clientPublicKey!.encrypt(jsonEncode({'password': _password})));
        subscription.onData(_onData);
      }
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

  void writeJson(Map<String, dynamic> data) {
    if (_encrypter == null) return;
    String encoded = jsonEncode(data);
    IV _iv = IV.fromSecureRandom(16);
    encoded = _iv.base64 + ',' + _encrypter!.encrypt(encoded, iv: _iv).base64;
    _socket.writeln(encoded);
  }
}
