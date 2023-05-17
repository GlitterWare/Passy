String getBoxMessage(String message) {
  List<String> msgSplit = message.split('\n');
  int maxLength = 0;
  for (String line in msgSplit) {
    if (line.length > maxLength) maxLength = line.length;
  }
  String result = ' ${'_' * (maxLength + 2)}\n';
  for (String line in msgSplit) {
    result += '| $line${' ' * (maxLength - line.length)} |\n';
  }
  result += '|${'_' * (maxLength + 2)}|';
  return result;
}

List<String> parseCommand(String command) {
  bool isEscaped = false;
  String curStr = '';
  List<String> result = [];
  bool isSingleQuoted = false;
  bool isDoubleQuoted = false;
  for (int i = 0; i != command.length; i++) {
    String c = command[i];
    if (isEscaped) {
      curStr += c;
      isEscaped = false;
      continue;
    } else if (c == '\\') {
      isEscaped = true;
      continue;
    }
    if (!isDoubleQuoted) {
      if (c == '\'') {
        isSingleQuoted = !isSingleQuoted;
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    if (!isSingleQuoted) {
      if (c == '"') {
        isDoubleQuoted = !isDoubleQuoted;
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    if (!isDoubleQuoted && !isSingleQuoted) {
      if (c == ' ') {
        if (curStr != '') {
          result.add(curStr);
          curStr = '';
        }
        continue;
      }
    }
    curStr += c;
  }
  if (curStr != '') result.add(curStr);
  return result;
}
