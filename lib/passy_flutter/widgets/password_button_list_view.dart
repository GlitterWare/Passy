import 'package:flutter/material.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';

class PasswordButtonListView extends StatelessWidget {
  final List<PasswordMeta> passwords;
  final bool shouldSort;
  final void Function(PasswordMeta password)? onPressed;

  const PasswordButtonListView({
    Key? key,
    required this.passwords,
    this.shouldSort = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shouldSort) PassySort.sortPasswords(passwords);
    return ListView(
      children: [
        for (PasswordMeta password in passwords)
          PassyPadding(PasswordButton(
            password: password,
            onPressed: () => onPressed?.call(password),
          )),
      ],
    );
  }
}
