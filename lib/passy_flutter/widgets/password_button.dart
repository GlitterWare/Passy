import 'package:flutter/material.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/common/assets.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:flutter_svg/svg.dart';

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
            child: password.websites.isEmpty || password.websites[0].isEmpty
                ? SvgPicture.asset(
                    logoCircleSvg,
                    colorFilter: ColorFilter.mode(
                        PassyTheme.of(context)
                            .highlightContentColor
                            .withAlpha(180),
                        BlendMode.srcIn),
                    width: 50,
                  )
                : FavIconImage(address: password.websites[0]),
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
