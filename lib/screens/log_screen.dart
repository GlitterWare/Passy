import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/common.dart';

import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/screens/common.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({Key? key}) : super(key: key);

  static const routeName = '/log';

  @override
  Widget build(BuildContext context) {
    final String _log =
        ModalRoute.of(context)!.settings.arguments as String? ?? '';
    return Scaffold(
        appBar: AppBar(
            title: Text(localizations.log),
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
                tooltip: localizations.copy,
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: '```\n$_log\n```')),
              ),
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: SvgPicture.asset(
                  'assets/images/github_icon.svg',
                  colorFilter: const ColorFilter.mode(
                      PassyTheme.lightContentColor, BlendMode.srcIn),
                ),
                tooltip: localizations.submitAnIssue,
                onPressed: () =>
                    openUrl('https://github.com/GlitterWare/Passy/issues'),
              )
            ]),
        body: SelectableText(_log));
  }
}
