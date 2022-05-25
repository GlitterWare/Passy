import 'package:flutter/material.dart';
import 'package:passy/widgets/passy_back_button.dart';

class EditIdentityScreen extends StatefulWidget {
  const EditIdentityScreen({Key? key}) : super(key: key);

  static const routeName = '/main/identities/editIdentity';

  @override
  State<StatefulWidget> createState() => _EditIdentityScreen();
}

class _EditIdentityScreen extends State<EditIdentityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: PassyBackButton(
            onPressed: () => Navigator.pop(context),
          ),
          title: const Center(child: Text('Add Identity'))),
    );
  }
}
