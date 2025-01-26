import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/glare/common.dart';

class FilePageResult {
  HttpServer server;
  Uri uri;
  String? password;

  FilePageResult({
    required this.server,
    required this.uri,
    this.password,
  });
}

Future<FilePageResult> createPdfPage(
  List<int> data, {
  Duration? runDuration = const Duration(minutes: 15),
}) async {
  AsymmetricKeyPair pair = CryptoUtils.generateEcKeyPair();
  ECPrivateKey privKey = pair.privateKey as ECPrivateKey;
  ECPublicKey pubKey = pair.publicKey as ECPublicKey;
  String cert = generateSelfSignedCertificate(
      privateKey: privKey, publicKey: pubKey, days: 2);
  SecurityContext ctx = SecurityContext();
  ctx.useCertificateChainBytes(utf8.encode(cert));
  ctx.usePrivateKeyBytes(
      utf8.encode(CryptoUtils.encodeEcPrivateKeyToPem(privKey)));
  HttpServer server = await HttpServer.bindSecure('127.0.0.1', 0, ctx);
  String password = generatePassword();
  server.forEach((HttpRequest request) {
    String? remotePassword = request.uri.queryParameters['password'];
    if (remotePassword != password) {
      request.response.close();
      return;
    }
    String? closeParameter = request.uri.queryParameters['close'];
    if (closeParameter == 'true') {
      request.response.close();
      server.close();
      return;
    }
    request.response.headers.contentType = ContentType('application', 'pdf');
    request.response.add(data);
    request.response.close();
  });
  if (runDuration != null) {
    Future.delayed(runDuration, () => server.close());
  }
  return FilePageResult(
    server: server,
    uri: Uri.https(
        '127.0.0.1:${server.port}', '/document.pdf', {'password': password}),
  );
}

Future<FilePageResult> createOctetStreamPage(
  List<int> data, {
  Duration? runDuration = const Duration(minutes: 15),
}) async {
  AsymmetricKeyPair pair = CryptoUtils.generateEcKeyPair();
  ECPrivateKey privKey = pair.privateKey as ECPrivateKey;
  ECPublicKey pubKey = pair.publicKey as ECPublicKey;
  String cert = generateSelfSignedCertificate(
      privateKey: privKey, publicKey: pubKey, days: 2);
  SecurityContext ctx = SecurityContext();
  ctx.useCertificateChainBytes(utf8.encode(cert));
  ctx.usePrivateKeyBytes(
      utf8.encode(CryptoUtils.encodeEcPrivateKeyToPem(privKey)));
  HttpServer server = await HttpServer.bindSecure('127.0.0.1', 0, ctx);
  String password = generatePassword();
  server.forEach((HttpRequest request) {
    String? remotePassword = request.headers.value('password');
    if (remotePassword != password) {
      request.response.close();
      return;
    }
    request.response.headers.contentType =
        ContentType('application', 'octet-stream');
    request.response.add(data);
    request.response.close();
  });
  if (runDuration != null) {
    Future.delayed(runDuration, () => server.close());
  }
  return FilePageResult(
    server: server,
    uri: Uri.https('127.0.0.1:${server.port}'),
    password: password,
  );
}
