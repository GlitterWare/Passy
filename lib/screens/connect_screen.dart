import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/host_address.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/widgets/back_button.dart';

import 'log_screen.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoadedAccount _account =
        ModalRoute.of(context)!.settings.arguments as LoadedAccount;
    String _address = '';

    void _connect() {
      HostAddress _hostAddress;
      try {
        _hostAddress = HostAddress.parse(_address);
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

      _account
          .connect(_hostAddress, context: context)
          .onError((error, stackTrace) {
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

    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Connect'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(children: [
              const Spacer(),
              const Text('Enter host address as shown below the QR code'),
              Row(children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: entryPadding.right,
                        top: entryPadding.top,
                        bottom: entryPadding.bottom),
                    child: TextFormField(
                      controller: TextEditingController(),
                      decoration: const InputDecoration(
                        labelText: 'Host address',
                      ),
                      onChanged: (s) => _address = s,
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(right: entryPadding.right),
                    child: FloatingActionButton(
                      onPressed: _connect,
                      child: const Icon(Icons.sync_rounded),
                    ),
                  ),
                )
              ]),
              const Spacer(),
            ]),
          ),
        ],
      ),
    );
  }
}
