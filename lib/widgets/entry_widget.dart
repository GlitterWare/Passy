import 'package:flutter/cupertino.dart';

class EntryWidget extends StatelessWidget {
  final Widget _body;

  const EntryWidget({Key? key, required Widget body})
      : _body = body,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
        child: Padding(
          child: _body,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        ),
      );
}
