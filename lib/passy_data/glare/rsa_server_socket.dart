import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'line_stream_subscription.dart';

class RSAServerSocket {
  static const version = rsaSocketVersion;
  late final LineByteStreamSubscription _subscription;
  final Socket _socket;
  final RSAKeypair _keyPair;
  RSAPublicKey? _clientPublicKey;
  Encrypter? _encrypter;
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();
  final Completer<void> _handshakeCompleter = Completer();
  Uint8List? _binaryData;

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
    Map<String, List<int>> binaryObjects = {};
    Map<String, dynamic> decoded = {};
    try {
      String decrypted = '';
      for (String part in utf8.decode(data).split(' ')) {
        List<String> partSplit = part.split(',');
        if (partSplit.length < 2) return;
        String? type;
        String? name;
        IV iv = IV.fromBase64(partSplit[0]);
        if (partSplit.length > 3) {
          type = partSplit[2];
          name = _encrypter!.decrypt64(partSplit[3], iv: iv);
        }
        String data = _encrypter!.decrypt64(partSplit[1], iv: iv);
        if (type == 'bin') {
          binaryObjects[name!] = data.codeUnits;
        } else {
          decrypted += data;
        }
      }
      decoded = jsonDecode(decrypted);
      decoded.remove('binaryObjects');
      if (binaryObjects.isNotEmpty) decoded['binaryObjects'] = binaryObjects;
    } catch (_) {
      return;
    }
    _streamController.add(decoded);
  }

  bool readBytes(int length) {
    if (_binaryData != null) return false;
    _subscription.receiveBinary(length);
    _binaryData = Uint8List(length);
    return true;
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
    _subscription = subscription;
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
    if (_encrypter == null) return;
    String encoded = jsonEncode(data);
    IV _iv = IV.fromSecureRandom(16);
    encoded = _iv.base64 + ',' + _encrypter!.encrypt(encoded, iv: _iv).base64;
    if (binaryObjects != null) {
      for (String key in binaryObjects.keys) {
        List<int> val = binaryObjects[key]!;
        IV _iv = IV.fromSecureRandom(16);
        encoded += ' ' +
            _iv.base64 +
            ',' +
            _encrypter!.encryptBytes(val, iv: _iv).base64 +
            ',bin,' +
            _encrypter!.encrypt(key, iv: _iv).base64;
      }
      print(encoded);
    }
    _socket.writeln(encoded);
  }
}
