import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class NoAccountsScreen extends StatelessWidget {
  static const String routeName = '/noAccounts';

  const NoAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                const Spacer(),
                PassyPadding(Text(localizations.noAccounts)),
                PassyPadding(FloatingActionButton(
                  child: const Icon(Icons.close_rounded),
                  onPressed: () => SystemNavigator.pop(),
                )),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
