import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class EnumDropdownButton2Item<T> {
  final T value;
  final Widget text;
  Widget? icon;

  EnumDropdownButton2Item({
    required this.value,
    required this.text,
    this.icon,
  });
}

class EnumDropdownButton2<T extends Enum> extends StatelessWidget {
  final T value;
  final List<EnumDropdownButton2Item<T>> items;
  final void Function(T? value)? onChanged;
  final TextStyle? style;
  final bool isExpanded;
  final AlignmentGeometry alignment;

  const EnumDropdownButton2({
    Key? key,
    required this.value,
    required this.items,
    this.onChanged,
    this.style,
    this.isExpanded = false,
    this.alignment = AlignmentDirectional.centerStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey _dropdownButtonKey = GlobalKey();
    void openDropdown() {
      _dropdownButtonKey.currentContext?.visitChildElements((element) {
        if (element.widget is Semantics) {
          element.visitChildElements((element) {
            if (element.widget is Actions) {
              element.visitChildElements((element) {
                Actions.invoke(element, const ActivateIntent());
              });
            }
          });
        }
      });
    }

    List<DropdownMenuItem<T>> _menuItems = [];
    for (EnumDropdownButton2Item<T> item in items) {
      _menuItems.add(DropdownMenuItem(
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                child: item.icon,
                padding: EdgeInsets.fromLTRB(PassyTheme.passyPadding.left + 6,
                    0, PassyTheme.passyPadding.right, 0)),
            Expanded(child: item.text),
          ],
        )),
        value: item.value,
      ));
    }
    EnumDropdownButton2Item<T> selected =
        items.firstWhere((element) => element.value == value);
    return DropdownButton2(
      key: _dropdownButtonKey,
      items: _menuItems,
      value: value,
      onChanged: onChanged,
      style: style,
      isExpanded: isExpanded,
      alignment: alignment,
      underline: const SizedBox.shrink(),
      customButton: PassyPadding(Material(
          color: PassyTheme.darkPassyPurple,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white24,
            hoverColor: Colors.white12,
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              height: 44,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      child: selected.icon,
                      padding: EdgeInsets.fromLTRB(
                          PassyTheme.passyPadding.left + 6,
                          0,
                          PassyTheme.passyPadding.right,
                          0)),
                  Expanded(
                      child: DefaultTextStyle(
                    style: const TextStyle(
                        color: PassyTheme.lightContentColor,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500),
                    child: selected.text,
                  )),
                  Padding(
                      child: const Icon(
                        Icons.arrow_drop_down_circle_rounded,
                        size: 35,
                      ),
                      padding: EdgeInsets.fromLTRB(
                          PassyTheme.passyPadding.left + 6,
                          0,
                          PassyTheme.passyPadding.right,
                          0)),
                ],
              )),
            ),
            customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(100))),
            onTap: openDropdown,
          ))),
    );
  }
}
