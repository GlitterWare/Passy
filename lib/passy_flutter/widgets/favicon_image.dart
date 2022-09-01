import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/screens/assets.dart';

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
    String _url = address;
    SvgPicture _placeholder = SvgPicture.asset(
      logoCircleSvg,
      color: Colors.white,
      width: 50,
      alignment: Alignment.topCenter,
    );
    if (!_url.contains(RegExp(r'https://|http://'))) {
      _url = 'http://$_url';
    }
    String _request =
        'https://s2.googleusercontent.com/s2/favicons?sz=32&domain=$_url';

    return CachedNetworkImage(
      imageUrl: _request,
      placeholder: (context, _url) => _placeholder,
      errorWidget: (ctx, obj, s) => _placeholder,
      width: width,
      fit: BoxFit.fill,
    );
  }
}
