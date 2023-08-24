import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

class SearchScreenArgs {
  String? title;
  Widget Function(String terms, void Function() rebuild) builder;
  bool isAutofill;

  SearchScreenArgs({
    this.title,
    required this.builder,
    this.isAutofill = false,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  State<StatefulWidget> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  bool _initialized = false;
  Widget _widget = const Text('');
  TextEditingController queryController = TextEditingController();
  FocusNode queryFocus = FocusNode()..requestFocus();
  Future<void>? entryBuilder;
  late Widget Function(String terms, void Function() rebuild) _builder;

  @override
  void initState() {
    super.initState();
  }

  void rebuild() {
    setState(() {
      int baseOffset = queryController.selection.baseOffset;
      queryController.selection =
          TextSelection(baseOffset: baseOffset, extentOffset: baseOffset);
      entryBuilder ??=
          Future<void>.delayed(const Duration(milliseconds: 100), () {
        entryBuilder = null;
        setState(() {
          _widget = _builder(queryController.text, rebuild);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SearchScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as SearchScreenArgs;
    _builder = args.builder;
    if (!_initialized) {
      _widget = _builder(queryController.text, rebuild);
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: args.isAutofill
              ? SystemNavigator.pop
              : () => Navigator.pop(context),
        ),
        title: Text(args.title ?? localizations.search),
        centerTitle: true,
      ),
      body: Column(
        children: [
          PassyPadding(TextFormField(
              controller: queryController,
              focusNode: queryFocus,
              decoration: InputDecoration(
                label: Text(localizations.search),
                hintText: 'github human@example.com',
              ),
              onTap: () {
                if (!queryFocus.hasFocus) {
                  queryFocus.requestFocus();
                  queryController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: queryController.value.text.length);
                }
              },
              onChanged: (s) {
                setState(() {
                  int baseOffset = queryController.selection.baseOffset;
                  queryController.text = s;
                  queryController.selection = TextSelection(
                      baseOffset: baseOffset, extentOffset: baseOffset);
                  entryBuilder ??= Future<void>.delayed(
                      const Duration(milliseconds: 100), () {
                    entryBuilder = null;
                    setState(() {
                      _widget = _builder(queryController.text, rebuild);
                    });
                  });
                });
              })),
          Expanded(
            child: _widget,
          ),
        ],
      ),
    );
  }
}
