import 'package:flutter/material.dart';

import 'passy_theme.dart';

FormattedTextParser formattedTextParser = FormattedTextParser();

class FormattedTextParser {
  InlineSpan parse({
    required String text,
    Map<String, InlineSpan>? placeholders,
  }) {
    List<InlineSpan> spans = [];
    String curMsg = '';
    bool isBold = false;
    bool isTag = false;
    bool isPlaceholder = false;
    bool isEscaped = false;

    void addSpan() {
      spans.add(
        TextSpan(
            text: curMsg,
            style: isBold
                ? const TextStyle(color: PassyTheme.lightContentSecondaryColor)
                : null),
      );
      curMsg = '';
    }

    for (int i = 0; i != text.length; i++) {
      String char = text[i];
      if (isTag) {
        if (char == '>') {
          switch (curMsg) {
            case 'b':
              isBold = true;
              break;
            case '/b':
              isBold = false;
              break;
          }
          curMsg = '';
          isTag = false;
          continue;
        }
        curMsg += char;
        continue;
      }
      if (isEscaped) {
        curMsg += char;
        isEscaped = false;
        continue;
      }
      if (isPlaceholder) {
        addSpan();
        spans.add(placeholders?[char] ?? TextSpan(text: char));
        isPlaceholder = false;
        continue;
      }
      switch (char) {
        case '\\':
          isEscaped = true;
          continue;
        case '<':
          addSpan();
          isTag = true;
          continue;
        case '%':
          addSpan();
          isPlaceholder = true;
          continue;
        default:
          curMsg += char;
          continue;
      }
    }
    if (curMsg.isNotEmpty) addSpan();
    return TextSpan(children: spans);
  }
}
