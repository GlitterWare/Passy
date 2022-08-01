import 'package:flutter/material.dart';
import 'package:passy/common/theme.dart';
import 'package:passy/widgets/passy_back_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  State<StatefulWidget> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  bool _initialized = false;
  List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> Function(String terms) _builder = ModalRoute.of(context)!
        .settings
        .arguments as List<Widget> Function(String);
    if (!_initialized) {
      _widgets = _builder('');
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: PassyBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: entryPadding,
            child: TextFormField(
                decoration: const InputDecoration(
                  label: Text('Search'),
                  hintText: 'github human@example.com',
                ),
                onChanged: (s) {
                  setState(() {
                    _widgets = _builder(s);
                  });
                }),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _widgets.length,
              itemBuilder: (BuildContext context, int index) => _widgets[index],
            ),
          ),
        ],
      ),
    );
  }
}
