import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/add_account_screen.dart';
import 'package:passy/common/common.dart';
import 'package:passy/common/assets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = '/';
  static bool loaded = false;

  @override
  Widget build(BuildContext context) {
    Future<void> showUpdateDialog() {
      return showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New version available'),
          content: ThreeWidgetButton(
            left: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SvgPicture.asset(
                'assets/images/github_icon.svg',
                width: 26,
                color: PassyTheme.lightContentColor,
              ),
            ),
            center: const Text('Download'),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () => launchUrl(
              Uri.https('github.com', '/GlitterWare/Passy/releases/latest'),
            ),
          ),
        ),
      );
    }

    Future<void> _load() async {
      data = await loadPassyData();
      loaded = true;
      String _version = await getLatestVersion();
      if (data.noAccounts) {
        Navigator.pushReplacementNamed(context, AddAccountScreen.routeName);
        return;
      }
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      if (_version != passyVersion) showUpdateDialog();
    }

    if (!loaded) {
      _load();
    }
    return Scaffold(
      body: Center(
        child: logo60Purple,
      ),
    );
  }
}
