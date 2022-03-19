import 'package:flutter/material.dart';

Widget getBackButton(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => Navigator.pop(context),
    );
