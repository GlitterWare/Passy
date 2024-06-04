import 'package:flutter/material.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PasswordButton extends StatelessWidget {
  final Widget? leftWidget;
  final PasswordMeta password;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const PasswordButton({
    Key? key,
    this.leftWidget,
    required this.password,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (leftWidget != null) leftWidget!,
      Flexible(
        child: ThreeWidgetButton(
          left: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: password.website == ''
                ? logoCircle50White
                : FavIconImage(address: password.website),
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: onPressed,
          center: Column(
            children: [
              Align(
                child: Text(
                  password.nickname,
                ),
                alignment: Alignment.centerLeft,
              ),
              Align(
                child: Text(
                  password.username,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                alignment: Alignment.centerLeft,
              ),
            ],
          ),
        ),
      ),
      if (popupMenuItemBuilder != null)
        FittedBox(
          child: PopupMenuButton(
            shape: PassyTheme.dialogShape,
            icon: const Icon(Icons.more_vert_rounded),
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 22),
            splashRadius: 24,
            itemBuilder: popupMenuItemBuilder!,
          ),
        )
    ]);
  }
}
