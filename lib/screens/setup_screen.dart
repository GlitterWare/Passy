import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/security_screen.dart';

class SetupScreen extends StatefulWidget {
  static const String routeName = '/setupScreen';

  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetupScreen();
}

class _SetupScreen extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account setup'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check_rounded),
        onPressed: () =>
            Navigator.pushReplacementNamed(context, MainScreen.routeName),
      ),
      body: ListView(
        children: [
          PassyPadding(ThreeWidgetButton(
              center: const Text('Security'),
              left: const Padding(
                padding: EdgeInsets.only(right: 30),
                child: Icon(Icons.lock_rounded),
              ),
              right: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () =>
                  Navigator.pushNamed(context, SecurityScreen.routeName))),
        ],
      ),
    );
  }
}
