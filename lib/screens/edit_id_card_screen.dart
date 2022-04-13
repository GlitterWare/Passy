import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

class EditIdCardScreen extends StatefulWidget {
  const EditIdCardScreen({Key? key}) : super(key: key);

  static const routeName = '/main/idCards/editIdCard';

  @override
  State<StatefulWidget> createState() => _EditIdCardScreen();
}

class _EditIdCardScreen extends State<EditIdCardScreen> {
  late Widget _backButton;

  @override
  void initState() {
    super.initState();
    _backButton = getBackButton(
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton,
        title: const Center(child: Text('Add ID Card')),
      ),
    );
  }
}
