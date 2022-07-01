import 'package:flutter/material.dart';
import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/widgets/passy_back_button.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoadedAccount _account =
        ModalRoute.of(context)!.settings.arguments as LoadedAccount;
    String _address = '';

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
                      onPressed: () => SynchronizationWrapper(context: context)
                          .connect(_account, address: _address),
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
