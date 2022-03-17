import 'package:flutter/material.dart';

class AddPaymentCardScreen extends StatefulWidget {
  const AddPaymentCardScreen({Key? key}) : super(key: key);

  static const routeName = '/addPaymentCard';

  @override
  State<StatefulWidget> createState() => _AddPaymentCardScreen();
}

class _AddPaymentCardScreen extends State<AddPaymentCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}
