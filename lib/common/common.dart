import 'package:flutter/material.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/widgets/back_button.dart';
import 'package:universal_io/io.dart';

import 'theme.dart';

late PassyData data;

final bool cameraSupported = Platform.isAndroid || Platform.isIOS;

AppBar getEditScreenAppBar(
  BuildContext context, {
  required String title,
  required void Function()? onSave,
  bool isNew = false,
}) =>
    AppBar(
      leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
      title: isNew
          ? Center(child: Text('Add $title'))
          : Center(child: Text('Edit $title')),
      actions: [
        IconButton(
          padding: appBarButtonPadding,
          splashRadius: appBarButtonSplashRadius,
          onPressed: onSave,
          icon: isNew
              ? const Icon(Icons.add_rounded)
              : const Icon(Icons.check_rounded),
        ),
      ],
    );

void connect(LoadedAccount account,
    {required BuildContext context, required String address}) {
  HostAddress _hostAddress;
  try {
    _hostAddress = HostAddress.parse(address);
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.sync_problem_rounded, color: lightContentColor),
        const SizedBox(width: 20),
        const Text('Invalid address format'),
      ]),
    ));
    return;
  }

  account.connect(_hostAddress, context: context).onError((error, stackTrace) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.sync_problem_rounded, color: lightContentColor),
        const SizedBox(width: 20),
        const Text('Connection failed'),
      ]),
      action: SnackBarAction(
        label: 'Details',
        onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
            arguments: error.toString() + '\n' + stackTrace.toString()),
      ),
    ));
  });
}

void host(LoadedAccount account, {required BuildContext context}) {}
