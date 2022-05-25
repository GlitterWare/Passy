import 'package:flutter/material.dart';
import 'package:passy/widgets/passy_back_button.dart';

class EditIdCardScreen extends StatefulWidget {
  const EditIdCardScreen({Key? key}) : super(key: key);

  static const routeName = '/main/idCards/editIdCard';

  @override
  State<StatefulWidget> createState() => _EditIdCardScreen();
}

class _EditIdCardScreen extends State<EditIdCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Add ID Card')),
      ),
    );
  }
}
