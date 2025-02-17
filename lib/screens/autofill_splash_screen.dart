import 'package:flutter/material.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/common.dart';
import 'package:passy/screens/login_screen.dart';
import 'package:passy/screens/no_accounts_screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

import 'common.dart';

class AutofillSplashScreen extends StatefulWidget {
  final Widget? underLogo;

  static const routeName = '/';

  const AutofillSplashScreen({Key? key, this.underLogo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AutofillSplashScreen();
}

class _AutofillSplashScreen extends State<AutofillSplashScreen> {
  static bool initialized = false;

  @override
  void initState() {
    if (initialized) return;
    initialized = true;
    super.initState();
    loadPassyData().then((value) async {
      data = value;
      loadLocalizations(context);
      if (value.noAccounts) {
        Navigator.pushReplacementNamed(context, NoAccountsScreen.routeName);
        return;
      }
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    setOnError(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(flex: 5),
                Center(
                  child: logo60Purple,
                ),
                widget.underLogo ??
                    const PassyPadding(Row(
                      children: [
                        Spacer(),
                        Expanded(
                            child: PassyPadding(LinearProgressIndicator(
                                backgroundColor: Colors.black,
                                color: Colors.purple))),
                        Spacer(),
                      ],
                    )),
                const Spacer(flex: 5),
              ],
            ),
          )
        ],
      ),
    );
  }
}
