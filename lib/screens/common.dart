import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:image/image.dart' as imglib;
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/biometric_storage_data.dart';
import 'package:passy/passy_data/common.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zxing2/qrcode.dart';

import 'log_screen.dart';
import 'main_screen.dart';
import 'passwords_screen.dart';

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.notes: '',
  Screen.idCards: '',
  Screen.identities: '',
};

final bool _isMobile = Platform.isAndroid || Platform.isIOS;

Future<bool> bioAuth(String username) async {
  BiometricStorageData _bioData;
  try {
    _bioData = await BiometricStorageData.fromLocker(username);
  } catch (e) {
    return false;
  }
  if (getPassyHash(_bioData.password).toString() !=
      data.getPasswordHash(username)) return false;
  data.info.value.lastUsername = username;
  await data.info.save();
  data.loadAccount(username, getPassyEncrypter(_bioData.password));
  return true;
}

void openUrl(String url) {
  if (_isMobile) {
    FlutterWebBrowser.openWebPage(url: url);
    return;
  }
  launchUrlString(url);
}

Future<String?> backupAccount(
  BuildContext context, {
  required String username,
}) async {
  try {
    MainScreen.shouldLockScreen = false;
    String? _buDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Backup Passy',
      lockParentWindow: true,
    );
    MainScreen.shouldLockScreen = true;
    if (_buDir == null) return null;
    await data.backupAccount(
      username: username,
      outputDirectoryPath: _buDir,
    );
    showSnackBar(context,
        message: 'Backup saved',
        icon:
            const Icon(Icons.save_rounded, color: PassyTheme.darkContentColor));
    return _buDir;
  } catch (e, s) {
    if (e is FileSystemException) {
      showSnackBar(context,
          message: 'Access denied, try another folder',
          icon: const Icon(Icons.save_rounded,
              color: PassyTheme.darkContentColor));
    } else {
      showSnackBar(
        context,
        message: 'Could not backup',
        icon:
            const Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: 'Details',
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
    }
    rethrow;
  }
}

// CameraImage BGRA8888 -> PNG
// Color
imglib.Image imageFromBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
imglib.Image imageFromYUV420(CameraImage image) {
  var img = imglib.Image(image.width, image.height); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data[planeOffset + x] = newVal;
    }
  }

  return img;
}

imglib.Image? imageFromCameraImage(CameraImage image) {
  try {
    imglib.Image img;
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        img = imageFromYUV420(image);
        break;
      case ImageFormatGroup.bgra8888:
        img = imageFromBGRA8888(image);
        break;
      default:
        return null;
    }
    return img;
  } catch (e) {
    //print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

Result? qrResultFromImage(imglib.Image image) {
  try {
    LuminanceSource _src = RGBLuminanceSource(
        image.width, image.height, Int32List.fromList(image.data));
    BinaryBitmap _bitmap = BinaryBitmap(HybridBinarizer(_src));
    QRCodeReader _reader = QRCodeReader();
    Result _result = _reader.decode(_bitmap);
    return _result;
  } catch (e) {
    return null;
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
  BuildContext context, {
  required String message,
  required Widget icon,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      icon,
      const SizedBox(width: 20),
      Expanded(child: Text(message)),
    ]),
    action: action,
  ));
}

PopupMenuItem getIconedPopupMenuItem({
  required Widget content,
  required Widget icon,
  void Function()? onTap,
}) {
  return PopupMenuItem(
    child: Row(
      children: [icon, const SizedBox(width: 20), content],
    ),
    onTap: onTap,
  );
}

List<PopupMenuEntry> idCardPopupMenuBuilder(
    BuildContext context, IDCardMeta idCardMeta) {
  return [
    getIconedPopupMenuItem(
      content: const Text('ID number'),
      icon: const Icon(Icons.numbers_outlined),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getIDCard(idCardMeta.key)!.idNumber));
        showSnackBar(context,
            message: 'ID number copied',
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    if (idCardMeta.name != '')
      getIconedPopupMenuItem(
        content: const Text('Name'),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(text: idCardMeta.name));
          showSnackBar(context,
              message: 'Name copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
  ];
}

List<PopupMenuEntry> passwordPopupMenuBuilder(
    BuildContext context, PasswordMeta passwordMeta) {
  return [
    if (passwordMeta.username != '')
      getIconedPopupMenuItem(
        content: const Text('Username'),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(
              text:
                  data.loadedAccount!.getPassword(passwordMeta.key)!.username));
          showSnackBar(context,
              message: 'Username copied',
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: const Text('Email'),
      icon: const Icon(Icons.mail_outline_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getPassword(passwordMeta.key)!.email));
        showSnackBar(context,
            message: 'Email copied',
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    getIconedPopupMenuItem(
      content: const Text('Password'),
      icon: const Icon(Icons.lock_outline_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getPassword(passwordMeta.key)!.password));
        showSnackBar(context,
            message: 'Password copied',
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    if (passwordMeta.website != '')
      getIconedPopupMenuItem(
        content: const Text('Visit'),
        icon: const Icon(Icons.open_in_browser_outlined),
        onTap: () {
          String _url =
              data.loadedAccount!.getPassword(passwordMeta.key)!.website;
          if (!_url.contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
            _url = 'http://' + _url;
          }
          try {
            openUrl(_url);
          } catch (_) {}
        },
      ),
  ];
}
