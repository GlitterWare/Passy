import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';

import '../passy_flutter.dart';

class IdentityButton extends StatelessWidget {
  final IdentityMeta identity;
  final void Function()? onPressed;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext context)?
      popupMenuItemBuilder;

  const IdentityButton({
    Key? key,
    required this.identity,
    this.onPressed,
    this.popupMenuItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: ThreeWidgetButton(
            left: const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Icon(Icons.people_outline_rounded),
            ),
            right: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: onPressed,
            center: Column(
              children: [
                Align(
                  child: Text(
                    identity.nickname,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Align(
                  child: Text(
                    identity.firstAddressLine,
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
          ),
      ],
    );
  }
}
