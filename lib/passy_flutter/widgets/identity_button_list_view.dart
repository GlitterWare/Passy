import 'package:flutter/material.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class IdentityButtonListView extends StatelessWidget {
  final List<Identity> identities;
  final bool shouldSort;
  final void Function(Identity identity)? onPressed;

  const IdentityButtonListView({
    Key? key,
    required this.identities,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortIdentities(identities);
    return ListView(
      children: [
        for (Identity identity in identities)
          PassyPadding(IdentityButton(
            identity: identity,
            onPressed: () => onPressed?.call(identity),
          )),
      ],
    );
  }
}
