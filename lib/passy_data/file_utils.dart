import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/glare/common.dart';

class FilePageResult {
  HttpServer server;
  Uri uri;
  String password;

  FilePageResult({
    required this.server,
    required this.uri,
    required this.password,
  });
}

Future<FilePageResult> createFilePage(
  List<int> data, {
  required ContentType contentType,
  bool includePasswordInUrl = false,
  Duration? runDuration = const Duration(minutes: 15),
  bool secure = true,
}) async {
  HttpServer server;
  if (secure) {
    AsymmetricKeyPair pair = CryptoUtils.generateEcKeyPair();
    ECPrivateKey privKey = pair.privateKey as ECPrivateKey;
    ECPublicKey pubKey = pair.publicKey as ECPublicKey;
    String cert = generateSelfSignedCertificate(
        privateKey: privKey, publicKey: pubKey, days: 2);
    SecurityContext ctx = SecurityContext();
    ctx.useCertificateChainBytes(utf8.encode(cert));
    ctx.usePrivateKeyBytes(
        utf8.encode(CryptoUtils.encodeEcPrivateKeyToPem(privKey)));
    server = await HttpServer.bindSecure('localhost', 0, ctx);
  } else {
    server = await HttpServer.bind('localhost', 0);
  }
  String password = generatePassword();
  server.forEach((HttpRequest request) {
    String? remotePassword = request.uri.queryParameters['password'];
    remotePassword ??= request.headers.value('password');
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
    request.response.headers.contentType = contentType;
    request.response.headers.contentLength = data.length;
    request.response.headers.set('Content-Disposition', 'inline');
    request.response.add(data);
    request.response.close();
  });
  if (runDuration != null) {
    Future.delayed(runDuration, () => server.close());
  }
  // Some Windows configurations do not allow Passy to connect to 127.0.0.1
  return FilePageResult(
    server: server,
    uri: (secure ? Uri.https : Uri.http)(
        '${Platform.isWindows ? 'localhost' : '127.0.0.1'}:${server.port}',
        '',
        includePasswordInUrl ? {'password': password} : null,
    ),
    password: password,
  );
}

Future<FilePageResult> createPdfPage(
  List<int> data, {
  bool includePasswordInUrl = true,
  Duration? runDuration = const Duration(minutes: 15),
}) =>
    createFilePage(
      data,
      contentType: ContentType('application', 'pdf'),
      includePasswordInUrl: includePasswordInUrl,
      runDuration: runDuration,
    );

Future<FilePageResult> createOctetStreamPage(
  List<int> data, {
  bool includePasswordInUrl = false,
  Duration? runDuration = const Duration(minutes: 15),
}) =>
    createFilePage(
      data,
      contentType: ContentType.binary,
      includePasswordInUrl: includePasswordInUrl,
      runDuration: runDuration,
    );
