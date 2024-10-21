import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';

import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class ConnectScreen extends StatefulWidget {
  static const routeName = '/connect';

  const ConnectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConnectScreen();
}

class _ConnectScreen extends State<ConnectScreen> {
  String _address = '';
  late FormattedTextParser formattedTextParser;

  _ConnectScreen();

  @override
  void initState() {
    super.initState();
    formattedTextParser = FormattedTextParser(context: context);
  }

  @override
  Widget build(BuildContext context) {
    LoadedAccount _account =
        ModalRoute.of(context)!.settings.arguments as LoadedAccount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.connect),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(children: [
              const Spacer(),
              Text.rich(
                formattedTextParser.parse(
                  text:
                      '${localizations.connectMsg1}\n\n${localizations.connectMsg2}',
                ),
                textAlign: TextAlign.center,
              ),
              Row(children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: PassyTheme.of(context).passyPadding.right,
                        top: PassyTheme.of(context).passyPadding.top,
                        bottom: PassyTheme.of(context).passyPadding.bottom),
                    child: TextFormField(
                      initialValue: _address,
                      decoration: InputDecoration(
                        labelText: localizations.hostAddress,
                      ),
                      onChanged: (s) => setState(() => _address = s),
                    ),
                  ),
                ),
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: PassyTheme.of(context).passyPadding.right),
                    child: FloatingActionButton(
                      tooltip: localizations.connect,
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
