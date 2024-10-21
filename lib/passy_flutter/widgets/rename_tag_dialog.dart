import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as ep;

class RenameTagDialog extends StatefulWidget {
  final String tag;

  const RenameTagDialog({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RenameTagDialog();
}

class _RenameTagDialog extends State<RenameTagDialog> {
  String _tag = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tag = widget.tag;
    _controller.text = widget.tag;
    _controller.addListener(
      () => setState(() => _tag = _controller.text),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: PassyTheme.dialogShape,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 450),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  localizations.renameTag,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )),
            PassyPadding(
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(labelText: localizations.tag),
                onFieldSubmitted: (tag) {
                  Navigator.pop(context, tag);
                },
              ),
            ),
            SizedBox(
              height: 200,
              child: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.dark(
                    //primary: Color.fromRGBO(74, 20, 140, 1),
                    primary: PassyTheme.of(context).highlightContentColor,
                    onPrimary: PassyTheme.of(context).contentColor,
                    secondary: PassyTheme.of(context).highlightContentColor,
                    onSecondary: PassyTheme.of(context).highlightContentColor,
                    onSurface: PassyTheme.of(context).highlightContentColor,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    floatingLabelStyle: TextStyle(
                        color: PassyTheme.of(context)
                            .highlightContentSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        color: PassyTheme.of(context).contentSecondaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(
                            color:
                                PassyTheme.of(context).highlightContentColor)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                child: ep.EmojiPicker(
                  textEditingController: _controller,
                  onEmojiSelected: (ep.Category? category, ep.Emoji emoji) {},
                  config: ep.Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: ep.EmojiViewConfig(
                      backgroundColor: PassyTheme.of(context).contentColor,
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 28 *
                          (defaultTargetPlatform == TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                    ),
                    swapCategoryAndBottomBar: false,
                    skinToneConfig: const ep.SkinToneConfig(),
                    categoryViewConfig: ep.CategoryViewConfig(
                        backgroundColor: PassyTheme.of(context).contentColor),
                    bottomActionBarConfig: ep.BottomActionBarConfig(
                        backgroundColor: PassyTheme.of(context).contentColor),
                    searchViewConfig: ep.SearchViewConfig(
                        buttonIconColor:
                            PassyTheme.of(context).highlightContentColor,
                        backgroundColor: PassyTheme.of(context).contentColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localizations.cancel,
                        style: TextStyle(
                            color: PassyTheme.of(context)
                                .highlightContentSecondaryColor)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _tag);
                    },
                    child: Text(localizations.rename,
                        style: TextStyle(
                            color: PassyTheme.of(context)
                                .highlightContentSecondaryColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
