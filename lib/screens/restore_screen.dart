import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/widgets/elevated_iconed_button.dart';
import 'package:passy/widgets/passy_back_button.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({Key? key}) : super(key: key);

  static const routeName = '/main/backupAndRestore/restore';

  @override
  State<StatefulWidget> createState() => _RestoreScreen();
}

class _RestoreScreen extends State<RestoreScreen> {
  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Restore'),
        centerTitle: true,
      ),
      body: ListView(children: [
        ElevatedIconedButton(
          body: const Text('Passy Restore'),
          leftIcon: SvgPicture.asset(
            logoCircleSvg,
            width: 25,
            color: lightContentColor,
          ),
          rightIcon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () {},
        ),
      ]),
    );
  }
}
