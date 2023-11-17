import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart';

import 'common.dart';
import 'line_stream_subscription.dart';

class RSAClientSocket {
  static const version = rsaSocketVersion;
  final Socket _socket;
  final InternetAddress address;
  final int port;
  final RSAKeypair _keyPair;
  RSAPublicKey? _serverPublicKey;
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
    try {
      _serverPublicKey = RSAPublicKey.fromString(publicKey);
    } catch (_) {
      return false;
    }
    _socket.writeln('{"rsa":{"publicKey":"${_keyPair.publicKey.toString()}"}}');
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
    if (_serverPublicKey == null) return;
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

  void add(List<int> bytes) {
    _socket.add(bytes);
  }

  void writeJson(Map<String, dynamic> data) {
    if (_encrypter == null) return;
    String encoded = jsonEncode(data);
    IV _iv = IV.fromSecureRandom(16);
    encoded = _iv.base64 + ',' + _encrypter!.encrypt(encoded, iv: _iv).base64;
    _socket.writeln(encoded);
  }
}
