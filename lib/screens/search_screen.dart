import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

class SearchScreenArgs {
  String? title;
  Widget Function(
    String terms,
    List<String> tags,
    void Function() rebuild,
  ) builder;
  bool isAutofill;
  EntryType? entryType;
  List<String> selectedTags;

  SearchScreenArgs({
    this.title,
    required this.builder,
    this.isAutofill = false,
    required this.entryType,
    this.selectedTags = const [],
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static const routeName = '/search';

  @override
  State<StatefulWidget> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  final LoadedAccount _account = data.loadedAccount!;
  bool _initialized = false;
  bool _loaded = false;
  Widget _widget = const Text('');
  TextEditingController queryController = TextEditingController();
  FocusNode queryFocus = FocusNode()..requestFocus();
  List<String> selected = [];
  List<String> notSelected = [];
  Future<void>? entryBuilder;
  late Widget Function(String terms, List<String> tags, void Function() rebuild)
      _builder;

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
          _widget = _builder(queryController.text, selected, rebuild);
        });
      });
    });
  }

  Future<void> _load(SearchScreenArgs args) async {
    List<String> newTags;
    try {
      switch (args.entryType) {
        case EntryType.password:
          newTags = await _account.passwordTags;
          break;
        case EntryType.paymentCard:
          newTags = await _account.paymentCardTags;
          break;
        case EntryType.note:
          newTags = await _account.notesTags;
          break;
        case EntryType.idCard:
          newTags = await _account.idCardsTags;
          break;
        case EntryType.identity:
          newTags = await _account.identitiesTags;
          break;
        case null:
          newTags = await _account.tags;
          break;
      }
      newTags.sort();
    } catch (_) {
      return;
    }
    if (mounted) {
      setState(() {
        _loaded = true;
        if (newTags.isEmpty) {
          selected = [];
          return;
        }
        for (String tag in newTags) {
          if (selected.contains(tag)) continue;
          notSelected.add(tag);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SearchScreenArgs args =
        ModalRoute.of(context)!.settings.arguments as SearchScreenArgs;
    _builder = args.builder;
    if (!_initialized) {
      selected = args.selectedTags.toList();
      _widget = _builder(queryController.text, selected, rebuild);
      _load(args);
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
                  String lowerS = s.toLowerCase();
                  notSelected.sort(
                    (a, b) {
                      a = a.toLowerCase();
                      b = b.toLowerCase();
                      int aMatches = lowerS.allMatches(a).length;
                      int bMatches = lowerS.allMatches(b).length;
                      if (aMatches == bMatches) return a.compareTo(b);
                      return bMatches - aMatches;
                    },
                  );
                  int baseOffset = queryController.selection.baseOffset;
                  queryController.text = s;
                  queryController.selection = TextSelection(
                      baseOffset: baseOffset, extentOffset: baseOffset);
                  entryBuilder ??= Future<void>.delayed(
                      const Duration(milliseconds: 100), () {
                    entryBuilder = null;
                    setState(() {
                      _widget =
                          _builder(queryController.text, selected, rebuild);
                    });
                  });
                });
              })),
          if (_loaded && (selected.isNotEmpty || notSelected.isNotEmpty))
            Padding(
                padding: EdgeInsets.only(
                    top: PassyTheme.passyPadding.top / 2,
                    bottom: PassyTheme.passyPadding.bottom / 2),
                child: EntryTagList(
                  notSelected: notSelected,
                  selected: selected,
                  onAdded: (tag) => setState(() {
                    queryFocus.requestFocus();
                    if (queryController.text.isNotEmpty) {
                      queryController.text = '';
                    }
                    selected.add(tag);
                    selected.sort();
                    notSelected.remove(tag);
                    _widget = _builder(queryController.text, selected, rebuild);
                  }),
                  onRemoved: (tag) => setState(() {
                    queryFocus.requestFocus();
                    selected.remove(tag);
                    notSelected.add(tag);
                    notSelected.sort();
                    _widget = _builder(queryController.text, selected, rebuild);
                  }),
                )),
          Expanded(
            child: _widget,
          ),
        ],
      ),
    );
  }
}
