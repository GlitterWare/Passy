import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/common/common.dart';
import 'package:passy/screens/common.dart';

class CloudUserAgreementScreen extends StatefulWidget {
  static const routeName = '/main/cloudRegister/userAgreement';

  const CloudUserAgreementScreen({Key? key}) : super(key: key);

  @override
  State<CloudUserAgreementScreen> createState() =>
      _CloudUserAgreementScreenState();
}

class _CloudUserAgreementScreenState extends State<CloudUserAgreementScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            padding: PassyTheme.appBarButtonPadding,
            splashRadius: PassyTheme.appBarButtonSplashRadius,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(localizations.cloudUserAgreementSummaryTitle),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(children: [
          const Spacer(),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.red,
            child: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
            tooltip: localizations.decline,
          ),
          const Spacer(),
          FloatingActionButton.extended(
            heroTag: 'cloudButton',
            label: Text(localizations.openFullUserAgreement),
            onPressed: () => openUrl('https://glitterware.net/EULA'),
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.green,
            child: const Icon(Icons.check_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            tooltip: localizations.accept,
          ),
          const Spacer(),
        ]),
        body: ListView(
          children: [
            PassyPadding(
              Text.rich(
                style: const TextStyle(
                  height: 1.5,
                ),
                FormattedTextParser(context: context)
                    .parse(text: localizations.cloudUserAgreementSummary),
              ),
            ),
          ],
        ),
      );
}
