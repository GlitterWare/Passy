import 'package:flutter/material.dart';

import 'package:passy/common/state.dart';

class Empty extends StatelessWidget {
  const Empty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future(() async {
      await loaded.future;
      loadApp(context);
    });
    return const Scaffold();
  }
}
