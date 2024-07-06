import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:chewie_media_kit/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/glare/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PassyFileWidget extends StatefulWidget {
  final String path;
  final String name;
  final bool isEncrypted;
  final FileEntryType type;
  final StreamController<String> _errorStreamController =
      StreamController<String>();
  Stream<String> get errorStream => _errorStreamController.stream;

  PassyFileWidget({
    super.key,
    required this.path,
    required this.name,
    required this.isEncrypted,
    required this.type,
  });

  @override
  State<StatefulWidget> createState() => _PassyFileWidget();
}

class _PassyFileWidget extends State<PassyFileWidget> {
  final LoadedAccount _account = data.loadedAccount!;
  Widget? _widget;
  bool _isLoaded = false;
  HttpServer? _server;
  Player? _player;

  @override
  void dispose() {
    widget._errorStreamController;
    super.dispose();
    _player?.dispose();
    _server?.close();
  }

  Widget _buildErrorWidget(e, s) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      PassyPadding(Text(localizations.failedToDisplayFile)),
      PassyPadding(ThreeWidgetButton(
        left: const Icon(Icons.error_outline),
        center: Text(
          localizations.details,
          textAlign: TextAlign.center,
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: () {
          Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString());
        },
      )),
    ]);
  }

  Future<Widget?> _loadWidget() async {
    if (widget.type == FileEntryType.unknown ||
        widget.type == FileEntryType.file) {
      throw 'Unknown entry type.';
    }
    Uint8List data;
    if (widget.isEncrypted) {
      data = await _account.readFileAsBytes(widget.path, useIsolate: true);
    } else {
      data = await File(widget.path).readAsBytes();
    }
    switch (widget.type) {
      case FileEntryType.unknown:
        throw 'Unknown entry type.';
      case FileEntryType.folder:
        throw 'Unknown entry type.';
      case FileEntryType.file:
        throw 'Unknown entry type.';
      case FileEntryType.plainText:
        String text = await compute<Uint8List, String>(
            (data) => utf8.decode(data, allowMalformed: true), data);
        return SingleChildScrollView(
            child: Center(child: SelectableText(text)));
      case FileEntryType.markdown:
        String text =
            await compute<Uint8List, String>((data) => utf8.decode(data), data);
        return SingleChildScrollView(
            child: Center(child: PassyMarkdownBody(data: text)));
      case FileEntryType.photo:
        Widget imageViewer;
        if (widget.name.endsWith('.svg')) {
          imageViewer = InteractiveViewer(
            minScale: 1,
            maxScale: 100,
            child: SvgPicture.memory(
              data,
              height: 10000000000000,
              width: 10000000000000,
            ),
          );
        } else {
          imageViewer = InteractiveViewer(
            minScale: 1,
            maxScale: 100,
            child: Image.memory(
              data,
              errorBuilder: (context, error, stackTrace) =>
                  _buildErrorWidget(error, stackTrace),
              scale: 0.0000000000001,
              height: 10000000000000,
              width: 10000000000000,
            ),
          );
        }
        return InkWell(
            onTap: () => showSnackBar(
                message: localizations.scrollOrPinchToZoom,
                icon: const Icon(
                  Icons.zoom_in,
                  color: PassyTheme.darkContentColor,
                )),
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white24,
            hoverColor: Colors.transparent,
            mouseCursor: SystemMouseCursors.zoomIn,
            child: imageViewer);
      case FileEntryType.audio:
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
        _server = server;
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
        Player player = Player(
            configuration: const PlayerConfiguration(
                bufferSize: 128 * 1024 * 1024 * 1024));
        _player = player;
        player.stream.error.listen((e) => widget._errorStreamController.add(e));
        VideoController controller = VideoController(player);
        player
            .open(
                Media('https://127.0.0.1:${server.port}',
                    httpHeaders: {'password': password}),
                play: false)
            .then((_) => player.play().then((_) => Future.delayed(
                const Duration(seconds: 1),
                () => player.seek(const Duration(milliseconds: 1)))));
        return PassyAudioProgressBar(
          controller: controller,
          colors: ChewieProgressColors(
            playedColor: PassyTheme.darkPassyPurple,
            handleColor: PassyTheme.lightContentColor,
          ),
          iconColor: PassyTheme.lightContentColor,
        );
      case FileEntryType.video:
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
        _server = server;
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
        Player player = Player(
            configuration: const PlayerConfiguration(
                bufferSize: 128 * 1024 * 1024 * 1024));
        _player = player;
        player.stream.error.listen((e) => widget._errorStreamController.add(e));
        VideoController controller = VideoController(player);
        player
            .open(
                Media('https://127.0.0.1:${server.port}',
                    httpHeaders: {'password': password}),
                play: false)
            .then((_) => player.play().then((_) => Future.delayed(
                const Duration(seconds: 1),
                () => player.seek(const Duration(milliseconds: 1)))));
        return Chewie(
          controller: ChewieController(
            videoPlayerController: controller,
            hideControlsTimer: const Duration(seconds: 2),
            showControlsFade: false,
            customControls: const CupertinoControls(
              backgroundColor: Colors.black,
              iconColor: PassyTheme.lightContentColor,
              showPlayButtonWhilePlaying: true,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      _isLoaded = true;
      _loadWidget().then((value) {
        if (!mounted) return;
        setState(() => _widget = value);
      }, onError: (e, s) {
        if (!mounted) return;
        setState(() => _widget = _buildErrorWidget(e, s));
      });
    }
    return _widget ??
        const CircularProgressIndicator(
          color: PassyTheme.lightContentColor,
        );
  }
}
