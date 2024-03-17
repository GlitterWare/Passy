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
                  colorScheme: const ColorScheme.dark(
                    //primary: Color.fromRGBO(74, 20, 140, 1),
                    primary: PassyTheme.lightContentColor,
                    onPrimary: PassyTheme.darkContentColor,
                    secondary: PassyTheme.lightContentColor,
                    onSecondary: PassyTheme.lightContentColor,
                    onSurface: PassyTheme.lightContentColor,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    floatingLabelStyle: const TextStyle(
                        color: PassyTheme.lightContentSecondaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                        color: PassyTheme.darkContentSecondaryColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(
                            color: PassyTheme.lightContentColor)),
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
                      backgroundColor: PassyTheme.darkContentColor,
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 28 *
                          (defaultTargetPlatform == TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                    ),
                    swapCategoryAndBottomBar: false,
                    skinToneConfig: const ep.SkinToneConfig(),
                    categoryViewConfig: const ep.CategoryViewConfig(
                        backgroundColor: PassyTheme.darkContentColor),
                    bottomActionBarConfig: const ep.BottomActionBarConfig(
                        backgroundColor: PassyTheme.darkContentColor),
                    searchViewConfig: const ep.SearchViewConfig(
                        buttonIconColor: PassyTheme.lightContentColor,
                        backgroundColor: PassyTheme.darkContentColor),
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
                        style: const TextStyle(
                            color: PassyTheme.lightContentSecondaryColor)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _tag);
                    },
                    child: Text(localizations.rename,
                        style: const TextStyle(
                            color: PassyTheme.lightContentSecondaryColor)),
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
