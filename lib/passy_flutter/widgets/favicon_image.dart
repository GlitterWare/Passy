import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

bool _isFaviconManagerStarted = false;
Completer _faviconManagerCompleter = Completer();
Map<String, dynamic> _favicons = {};
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
        Future<void> _faviconManager() async {
          if (_saveRequested) {
            file.writeAsStringSync(jsonEncode({'favicons': _favicons}));
          }
          Future.delayed(const Duration(seconds: 5), _faviconManager);
        }

        _faviconManager();
      });
    }
    String _url = address;
    SvgPicture _placeholder = SvgPicture.asset(
      logoCircleSvg,
      color: Colors.white,
      width: width,
    );
    _url = 'http://' + _url.replaceFirst(RegExp('https://|http://'), '');
    return FutureBuilder(
      future: Future(() async {
        await _faviconManagerCompleter.future;
        dynamic _imageURL = _favicons[_url];
        if (_imageURL is String) return Favicon(_imageURL);
        Favicon? icon;
        try {
          icon = await FaviconFinder.getBest(_url,
              suffixes: ['png', 'jpg', 'jpeg', 'ico']);
        } catch (_) {
          return null;
        }
        if (icon == null) return null;
        _favicons[_url] = icon.url;
        _saveRequested = true;
        return icon;
      }),
      builder: (BuildContext context, AsyncSnapshot<Favicon?> snapshot) {
        Favicon? favicon = snapshot.data;
        if (favicon == null) return _placeholder;
        return CachedNetworkImage(
          imageUrl: favicon.url,
          placeholder: (context, _url) => _placeholder,
          errorWidget: (ctx, obj, s) {
            _favicons.remove(_url);
            _saveRequested = true;
            return _placeholder;
          },
          width: width,
          fit: BoxFit.fill,
        );
      },
    );
  }
}
