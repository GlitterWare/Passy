import 'package:flutter/material.dart';

import 'file_entry_type.dart';

class FileEntry {
  final String key;
  final String path;
  final String name;
  final FileEntryType type;
  final Widget? icon;

  FileEntry({
    required this.key,
    required this.path,
    required this.name,
    required this.type,
    this.icon,
  });
}
