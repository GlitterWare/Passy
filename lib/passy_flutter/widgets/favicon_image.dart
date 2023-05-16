import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../../common/assets.dart';
import '../passy_flutter.dart';

bool _isFaviconManagerStarted = false;
Completer _faviconManagerCompleter = Completer();
Map<String, dynamic> _favicons = {};
Map<String, Future<Favicon?>> _faviconFutures = {};
bool _saveRequested = false;

class FavIconImage extends StatelessWidget {
  final String address;
  final double width;

  const FavIconImage({
    Key? key,
    required this.address,
    this.width = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FileInfo? fileInfo;
    if (!_isFaviconManagerStarted) {
      _isFaviconManagerStarted = true;
      Future(() async {
        fileInfo =
            await DefaultCacheManager().getFileFromCache('passyfavicons');
        File file;
        if (fileInfo == null) {
          file = await DefaultCacheManager().putFile(
              'passyfavicons',
              Uint8List.fromList(
                  utf8.encode(jsonEncode({'favicons': _favicons}))));
          file.writeAsStringSync(jsonEncode({'favicons': _favicons}));
        } else {
          file = fileInfo!.file;
          Map<String, dynamic> contents = jsonDecode(file.readAsStringSync());
          dynamic favicons = contents['favicons'];
          if (favicons is! Map<String, dynamic>) {
            favicons = {};
            contents['favicons'] = favicons;
            file.writeAsStringSync(jsonEncode(contents));
          }
          _favicons = favicons;
        }
        _faviconManagerCompleter.complete();
        Future<void> faviconManager() async {
          if (_saveRequested) {
            file.writeAsStringSync(jsonEncode({'favicons': _favicons}));
          }
          Future.delayed(const Duration(seconds: 5), faviconManager);
        }

        faviconManager();
      });
    }
    String url = address;
    Widget placeholder = WebsafeSvg.asset(
      logoCircleSvg,
      colorFilter:
          const ColorFilter.mode(PassyTheme.lightContentColor, BlendMode.srcIn),
      width: width,
    );
    url = 'http://${url.replaceFirst(RegExp('https://|http://'), '')}';
    return FutureBuilder(
      future: Future(() async {
        await _faviconManagerCompleter.future;
        dynamic imageURL = _favicons[url];
        if (imageURL is String) return Favicon(imageURL);
        Favicon? icon;
        try {
          Future<Favicon?>? faviconFuture = _faviconFutures[url];
          faviconFuture ??= compute<String, Favicon?>(
              (url) async => await FaviconFinder.getBest(url,
                  suffixes: ['png', 'jpg', 'jpeg', 'ico']),
              url);
          icon = await faviconFuture;
          _faviconFutures.remove(url);
        } catch (_) {
          _faviconFutures.remove(url);
          return null;
        }
        if (icon == null) return null;
        _favicons[url] = icon.url;
        _saveRequested = true;
        return icon;
      }),
      builder: (BuildContext context, AsyncSnapshot<Favicon?> snapshot) {
        Favicon? favicon = snapshot.data;
        if (favicon == null) return placeholder;
        return CachedNetworkImage(
          imageUrl: favicon.url,
          placeholder: (context, _) => placeholder,
          errorWidget: (ctx, obj, s) {
            _favicons.remove(url);
            _saveRequested = true;
            return placeholder;
          },
          width: width,
          fit: BoxFit.fill,
        );
      },
    );
  }
}
