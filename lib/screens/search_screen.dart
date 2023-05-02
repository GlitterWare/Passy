import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

class SearchScreenArgs {
  String? title;
  Widget Function(String) builder;

  SearchScreenArgs({
    this.title,
    required this.builder,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SearchScreenArgs _args =
        ModalRoute.of(context)!.settings.arguments as SearchScreenArgs;
    Widget Function(String terms) _builder = _args.builder;
    if (!_initialized) {
      _widget = _builder('');
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_args.title ?? localizations.search),
        centerTitle: true,
      ),
      body: Column(
        children: [
          PassyPadding(TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                label: Text(localizations.search),
                hintText: 'github human@example.com',
              ),
              onChanged: (s) {
                setState(() {
                  _widget = _builder(s);
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
