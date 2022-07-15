import 'package:flutter/material.dart';
import 'package:passy/widgets/passy_back_button.dart';
import 'package:passy/widgets/text_form_field_buttoned.dart';

class ConfirmStringScreenArguments {
  final Widget title;
  final Widget message;
  final String? labelText;
  final bool obscureText;
  final Widget confirmIcon;
  final void Function(BuildContext context)? onBackPressed;
  final void Function(BuildContext context, String value)? onConfirmPressed;

  ConfirmStringScreenArguments({
    this.title = const Text('Confirm string'),
    this.message = const Text('Enter string to confirm'),
    this.labelText,
    this.obscureText = false,
    this.confirmIcon = const Icon(Icons.arrow_forward_ios_rounded),
    this.onBackPressed,
    this.onConfirmPressed,
  });
}

class ConfirmStringScreen extends StatefulWidget {
  const ConfirmStringScreen({Key? key}) : super(key: key);

  static const routeName = '/confirmStringScreen';

  @override
  State<StatefulWidget> createState() => _ConfirmStringScreen();
}

class _ConfirmStringScreen extends State<ConfirmStringScreen> {
  @override
  Widget build(BuildContext context) {
    String _input = '';
    final ConfirmStringScreenArguments _args = ModalRoute.of(context)!
            .settings
            .arguments as ConfirmStringScreenArguments? ??
        ConfirmStringScreenArguments();

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
            onPressed: _args.onBackPressed == null
                ? null
                : () => _args.onBackPressed!(context)),
        title: _args.title,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(children: [
              const Spacer(),
              _args.message,
              TextFormFieldButtoned(
                labelText: _args.labelText,
                obscureText: _args.obscureText,
                onChanged: (s) => _input = s,
                onPressed: _args.onConfirmPressed == null
                    ? null
                    : () => _args.onConfirmPressed!(context, _input),
                buttonIcon: _args.confirmIcon,
              ),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
