import 'package:qr/qr.dart';

const _correctionLevel = QrErrorCorrectLevel.L;

/// Check whether it's possible to check row next to [row] based on [oddRow] and current [moduleCount]
bool _checkRow(oddRow, moduleCount, row) {
  return !oddRow || (row + 1) >= moduleCount;
}

/// Prints the QRCode of [input] in the console
String generate(String input, {int typeNumber = 10, bool small = false}) {
  final qrcode = QrCode(typeNumber, _correctionLevel);
  qrcode.addData(input);
  final qri = QrImage(qrcode);
  final moduleCount = qrcode.moduleCount;

  var output = "";
  if (small) {
    const whiteAll = "\u{2588}";
    const whiteBlack = "\u{2580}";
    const blackWhite = "\u{2584}";
    const blackAll = " ";

    final oddRow = moduleCount % 2 == 1;

    final borderTop =
        Iterable<int>.generate(moduleCount + 2).map((e) => blackWhite).join("");
    final borderBottom =
        Iterable<int>.generate(moduleCount + 2).map((e) => whiteBlack).join("");

    output += "$borderTop\n";

    for (var row = 0; row < moduleCount; row += 2) {
      output += whiteAll;

      for (var col = 0; col < moduleCount; col++) {
        if (!qri.isDark(row, col) &&
            (_checkRow(oddRow, moduleCount, row) ||
                !qri.isDark(row + 1, col))) {
          output += whiteAll;
        } else if (!qri.isDark(row, col) &&
            (_checkRow(oddRow, moduleCount, row) || qri.isDark(row + 1, col))) {
          output += whiteBlack;
        } else if (qri.isDark(row, col) &&
            (_checkRow(oddRow, moduleCount, row) ||
                !qri.isDark(row + 1, col))) {
          output += blackWhite;
        } else {
          output += blackAll;
        }
      }

      output += "$whiteAll\n";
    }

    if (!oddRow) output += borderBottom;
  } else {
    const black = "  ";
    const white = "\u{2588}\u{2588}";

    final border =
        Iterable<int>.generate(moduleCount + 2).map((e) => white).join("");

    output += "$border\n";

    for (var row = 0; row < moduleCount; row += 1) {
      output += white;
      for (var col = 0; col < moduleCount; col += 1) {
        output += qri.isDark(row, col) ? black : white;
      }
      output += "$white\n";
    }
    output += border;
  }

  return output;
}
