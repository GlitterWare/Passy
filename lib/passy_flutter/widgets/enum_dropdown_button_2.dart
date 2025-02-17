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

class EnumDropdownButton2<T extends Enum> extends StatefulWidget {
  final EnumDropdownButton2Item<T>? hint;
  final T? value;
  final List<EnumDropdownButton2Item<T>> items;
  final void Function(T? value)? onChanged;
  final TextStyle? style;
  final bool isExpanded;
  final AlignmentGeometry alignment;
  final DropdownStyleData dropdownStyleData;

  const EnumDropdownButton2({
    Key? key,
    required this.items,
    this.hint,
    this.value,
    this.onChanged,
    this.style,
    this.isExpanded = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.dropdownStyleData = const DropdownStyleData(),
  }) : super(key: key);

  @override
  State<EnumDropdownButton2<T>> createState() => _EnumDropdownButton2<T>();
}

class _EnumDropdownButton2<T extends Enum>
    extends State<EnumDropdownButton2<T>> {
  final GlobalKey _dropdownButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
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
    for (EnumDropdownButton2Item<T> item in widget.items) {
      _menuItems.add(DropdownMenuItem(
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                child: item.icon,
                padding: EdgeInsets.fromLTRB(
                    PassyTheme.of(context).passyPadding.left + 6,
                    0,
                    PassyTheme.of(context).passyPadding.right,
                    0)),
            Expanded(child: item.text),
          ],
        )),
        value: item.value,
      ));
    }
    EnumDropdownButton2Item<T> selected;
    if (widget.value == null) {
      if (widget.hint == null) {
        selected = widget.items[0];
      } else {
        selected = widget.hint!;
      }
    } else {
      selected =
          widget.items.firstWhere((element) => element.value == widget.value);
    }
    return DropdownButton2(
      dropdownStyleData: widget.dropdownStyleData,
      buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStatePropertyAll(Colors.transparent)),
      key: _dropdownButtonKey,
      items: _menuItems,
      value: widget.value,
      onChanged: widget.onChanged,
      style: widget.style,
      isExpanded: widget.isExpanded,
      alignment: widget.alignment,
      underline: const SizedBox.shrink(),
      customButton: PassyPadding(Material(
          color: PassyTheme.of(context).accentContentColor,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            splashFactory: Theme.of(context).splashFactory,
            splashColor: Theme.of(context).splashColor,
            hoverColor: Theme.of(context).hoverColor,
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
                          PassyTheme.of(context).passyPadding.left + 6,
                          0,
                          PassyTheme.of(context).passyPadding.right,
                          0)),
                  Expanded(
                      child: DefaultTextStyle(
                    style: TextStyle(
                        color: PassyTheme.of(context).highlightContentColor,
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
                          PassyTheme.of(context).passyPadding.left + 6,
                          0,
                          PassyTheme.of(context).passyPadding.right,
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
