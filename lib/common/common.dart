import 'package:flutter/material.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_data/passy_data.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:passy/screens/main_screen.dart';
import 'package:passy/screens/splash_screen.dart';
import 'package:passy/widgets/back_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

void _onConnected({required BuildContext context}) {
  Navigator.popUntil(context, (r) => r.settings.name == MainScreen.routeName);
  Navigator.pushNamed(context, SplashScreen.routeName);
}

void _onSyncComplete({required BuildContext context}) => Navigator.pop(context);

void _onSyncError(String log, {required BuildContext context}) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.sync_problem_rounded, color: darkContentColor),
          const SizedBox(width: 20),
          const Expanded(child: Text('Sync error')),
        ]),
        action: SnackBarAction(
            label: 'Details',
            onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
                arguments: log)),
      ));

void connect(LoadedAccount account,
    {required BuildContext context, required String address}) {
  HostAddress _hostAddress;
  try {
    _hostAddress = HostAddress.parse(address);
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.sync_problem_rounded, color: darkContentColor),
        const SizedBox(width: 20),
        const Text('Invalid address format'),
      ]),
    ));
    return;
  }

  account
      .connect(
    _hostAddress,
    onConnected: () => _onConnected(context: context),
    onComplete: () => _onSyncComplete(context: context),
    onError: (log) => _onSyncError(log, context: context),
  )
      .onError((error, stackTrace) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.sync_problem_rounded, color: darkContentColor),
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

void host(LoadedAccount account, {required BuildContext context}) {
  account
      .host(
    onConnected: () => _onConnected(context: context),
    onComplete: () => _onSyncComplete(context: context),
    onError: (log) => _onSyncError(log, context: context),
  )
      .then((value) {
    if (value == null) return;
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: dialogShape,
        children: [
          Center(
            child: SizedBox(
              width: 300,
              height: 350,
              child: Column(
                children: [
                  QrImage(
                    data: value.toString(),
                    foregroundColor: Colors.blue[50],
                  ),
                  Expanded(
                    child: Center(
                      child: Text(value.toString()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}
