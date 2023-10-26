import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PassyFileWidget extends StatefulWidget {
  final String path;
  final String name;
  final bool isEncrypted;
  final FileEntryType type;

  const PassyFileWidget({
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
      case FileEntryType.file:
        throw 'Unknown entry type.';
      case FileEntryType.plainText:
        String text = await compute<Uint8List, String>(
            (data) => utf8.decode(data, allowMalformed: true), data);
        return SelectableText(text);
      case FileEntryType.markdown:
        String text =
            await compute<Uint8List, String>((data) => utf8.decode(data), data);
        return SingleChildScrollView(child: PassyMarkdownBody(data: text));
      case FileEntryType.photo:
        if (widget.name.endsWith('.svg')) {
          return InkWell(
            onTap: () => showSnackBar(context,
                message: localizations.scrollOrPinchToZoom,
                icon: const Icon(
                  Icons.zoom_in,
                  color: PassyTheme.darkContentColor,
                )),
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white24,
            hoverColor: Colors.transparent,
            mouseCursor: SystemMouseCursors.zoomIn,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 100,
              child: SvgPicture.memory(
                data,
                height: 10000000000000,
                width: 10000000000000,
              ),
            ),
          );
        }
        return InkWell(
          onTap: () => showSnackBar(context,
              message: localizations.scrollOrPinchToZoom,
              icon: const Icon(
                Icons.zoom_in,
                color: PassyTheme.darkContentColor,
              )),
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.white24,
          hoverColor: Colors.transparent,
          mouseCursor: SystemMouseCursors.zoomIn,
          child: InteractiveViewer(
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
          ),
        );
      case FileEntryType.folder:
        throw 'Unknown entry type.';
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
