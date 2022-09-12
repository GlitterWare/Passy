import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:passy/passy_flutter/passy_theme.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  static const routeName = '/log';

  @override
  Widget build(BuildContext context) {
    final String _log =
        ModalRoute.of(context)!.settings.arguments as String? ?? '';
    return Scaffold(
        appBar: AppBar(
            title: const Text('Log'),
            centerTitle: true,
            leading: IconButton(
              padding: PassyTheme.appBarButtonPadding,
              splashRadius: PassyTheme.appBarButtonSplashRadius,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => Clipboard.setData(ClipboardData(text: _log)),
              ),
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: SvgPicture.asset(
                  'assets/images/github_icon.svg',
                  color: PassyTheme.lightContentColor,
                ),
                onPressed: () => launchUrl(
                    Uri.https('github.com', '/GlitterWare/Passy/issues')),
              )
            ]),
        body: SelectableText(_log));
  }
}
