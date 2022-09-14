import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class GlobalSettingsScreen extends StatefulWidget {
  static const String routeName = '/globalSettings';

  const GlobalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GlobalSettingsScreen();
}

class _GlobalSettingsScreen extends State<GlobalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          PassyPadding(
            ThreeWidgetButton(
              center: const Text('Enable autofill'),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.password_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                AutofillService().requestSetAutofillService();
              },
            ),
          )
        ],
      ),
    );
  }
}
