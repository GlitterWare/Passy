import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:image/image.dart' as imglib;
import 'package:passy/common/common.dart';
import 'package:passy/common/synchronization_wrapper.dart';
import 'package:passy/main.dart';
import 'package:passy/passy_data/entry_type.dart';
import 'package:passy/passy_data/id_card.dart';
import 'package:passy/passy_data/identity.dart';
import 'package:passy/passy_data/note.dart';
import 'package:passy/passy_data/password.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/id_cards_screen.dart';
import 'package:passy/screens/identities_screen.dart';
import 'package:passy/screens/notes_screen.dart';
import 'package:passy/screens/payment_cards_screen.dart';
import 'package:passy/screens/unlock_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zxing2/qrcode.dart';

import 'connect_screen.dart';
import 'id_card_screen.dart';
import 'identity_screen.dart';
import 'log_screen.dart';
import 'main_screen.dart';
import 'note_screen.dart';
import 'password_screen.dart';
import 'passwords_screen.dart';
import 'payment_card_screen.dart';
import 'splash_screen.dart';

bool isAutofill = false;
final bool recommendKeyDerivation = DateTime.now()
    .toUtc()
    .subtract(const Duration(days: 21))
    .isAfter(DateTime.parse('2023-11-23 17:09:30.339789Z'));

const screenToRouteName = {
  Screen.main: MainScreen.routeName,
  Screen.passwords: PasswordsScreen.routeName,
  Screen.paymentCards: PaymentCardsScreen.routeName,
  Screen.notes: NotesScreen.routeName,
  Screen.idCards: IDCardsScreen.routeName,
  Screen.identities: IdentitiesScreen.routeName,
};

String entryTypeToEntriesRouteName(EntryType entryType) {
  switch (entryType) {
    case EntryType.password:
      return PasswordsScreen.routeName;
    case EntryType.paymentCard:
      return PaymentCardsScreen.routeName;
    case EntryType.note:
      return NotesScreen.routeName;
    case EntryType.idCard:
      return IDCardsScreen.routeName;
    case EntryType.identity:
      return IdentitiesScreen.routeName;
  }
}

String entryTypeToEntryRouteName(EntryType entryType) {
  switch (entryType) {
    case EntryType.password:
      return PasswordScreen.routeName;
    case EntryType.paymentCard:
      return PaymentCardScreen.routeName;
    case EntryType.note:
      return NoteScreen.routeName;
    case EntryType.idCard:
      return IDCardScreen.routeName;
    case EntryType.identity:
      return IdentityScreen.routeName;
  }
}

final bool _isMobile = Platform.isAndroid || Platform.isIOS;

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
  bool autoFilename = true,
}) async {
  if (Platform.isAndroid) autoFilename = true;
  try {
    UnlockScreen.shouldLockScreen = false;
    String? _fileName;
    String? _buDir;
    if (autoFilename) {
      _buDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: localizations.backupPassy,
        lockParentWindow: true,
      );
    } else {
      _fileName =
          'passy-backup-$username-${DateTime.now().toUtc().toIso8601String().replaceAll(':', ';')}.zip';
      _buDir = await FilePicker.platform.saveFile(
        dialogTitle: localizations.backupPassy,
        lockParentWindow: true,
        fileName: _fileName,
      );
    }
    Future.delayed(const Duration(seconds: 2))
        .then((value) => UnlockScreen.shouldLockScreen = true);
    if (_buDir == null) return null;
    if (!autoFilename) _buDir = File(_buDir).parent.path;
    await data.backupAccount(
      username: username,
      outputDirectoryPath: _buDir,
      fileName: _fileName,
    );
    showSnackBar(
        message: localizations.backupSaved,
        icon:
            const Icon(Icons.save_rounded, color: PassyTheme.darkContentColor));
    return _buDir;
  } catch (e, s) {
    if (e is FileSystemException) {
      showSnackBar(
          message: localizations.accessDeniedTryAnotherFolder,
          icon: const Icon(Icons.save_rounded,
              color: PassyTheme.darkContentColor));
    } else {
      showSnackBar(
        message: localizations.couldNotBackup,
        icon:
            const Icon(Icons.save_rounded, color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
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

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar({
  required String message,
  TextStyle? textStyle,
  required Widget icon,
  SnackBarAction? action,
  Duration duration = const Duration(milliseconds: 4000),
  Color? backgroundColor,
}) {
  BuildContext? context = navigatorKey.currentContext;
  if (context == null) return null;
  ScaffoldMessenger.of(context).clearSnackBars();
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      icon,
      const SizedBox(width: 20),
      Expanded(
          child: Text(
        message,
        style: textStyle,
      )),
    ]),
    action: action,
    duration: duration,
    backgroundColor: backgroundColor,
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
      content: Text(localizations.idNumber),
      icon: const Icon(Icons.numbers_outlined),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getIDCard(idCardMeta.key)!.idNumber));
        showSnackBar(
            message: localizations.idNumber,
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    if (idCardMeta.name != '')
      getIconedPopupMenuItem(
        content: Text(localizations.name),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(text: idCardMeta.name));
          showSnackBar(
              message: localizations.name,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
  ];
}

List<PopupMenuEntry> identityPopupMenuBuilder(
    BuildContext context, IdentityMeta identityMeta) {
  return [
    getIconedPopupMenuItem(
      content: Text(localizations.name),
      icon: const Icon(Icons.person_outline_rounded),
      onTap: () {
        Identity? _identity = data.loadedAccount!.getIdentity(identityMeta.key);
        if (_identity == null) return;
        String _name = _identity.firstName;
        if (_name == '') {
          _name = _identity.middleName;
        } else {
          _name += ' ${_identity.middleName}';
        }
        if (_name == '') {
          _name = _identity.lastName;
        } else {
          _name += ' ${_identity.lastName}';
        }
        Clipboard.setData(ClipboardData(text: _name));
        showSnackBar(
            message: localizations.name,
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    getIconedPopupMenuItem(
      content: Text(localizations.email),
      icon: const Icon(Icons.mail_outline_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getIdentity(identityMeta.key)!.email));
        showSnackBar(
            message: localizations.email,
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    if (identityMeta.firstAddressLine != '')
      getIconedPopupMenuItem(
        content: Text(localizations.firstAddresssLine),
        icon: const Icon(Icons.house_outlined),
        onTap: () {
          Clipboard.setData(ClipboardData(text: identityMeta.firstAddressLine));
          showSnackBar(
              message: localizations.firstAddresssLine,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
  ];
}

List<PopupMenuEntry> notePopupMenuBuilder(
    BuildContext context, NoteMeta identityMeta) {
  return [
    getIconedPopupMenuItem(
      content: Text(localizations.copy),
      icon: const Icon(Icons.copy_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getNote(identityMeta.key)!.note));
        showSnackBar(
            message: localizations.copied,
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
        content: Text(localizations.username),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(ClipboardData(
              text:
                  data.loadedAccount!.getPassword(passwordMeta.key)!.username));
          showSnackBar(
              message: localizations.username,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: Text(localizations.email),
      icon: const Icon(Icons.mail_outline_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getPassword(passwordMeta.key)!.email));
        showSnackBar(
            message: localizations.email,
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    getIconedPopupMenuItem(
      content: Text(localizations.password),
      icon: const Icon(Icons.lock_outline_rounded),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: data.loadedAccount!.getPassword(passwordMeta.key)!.password));
        showSnackBar(
            message: localizations.password,
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
    if (passwordMeta.website != '')
      getIconedPopupMenuItem(
        content: Text(localizations.visit),
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

List<PopupMenuEntry> paymentCardPopupMenuBuilder(
    BuildContext context, PaymentCardMeta paymentCardMeta) {
  return [
    if (paymentCardMeta.cardNumber != '')
      getIconedPopupMenuItem(
        content: Text(localizations.cardNumber),
        icon: const Icon(Icons.numbers_outlined),
        onTap: () {
          Clipboard.setData(ClipboardData(
              text: data.loadedAccount!
                  .getPaymentCard(paymentCardMeta.key)!
                  .cardNumber));
          showSnackBar(
              message: localizations.cardNumber,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    if (paymentCardMeta.cardholderName != '')
      getIconedPopupMenuItem(
        content: Text(localizations.cardHolderName),
        icon: const Icon(Icons.person_outline_rounded),
        onTap: () {
          Clipboard.setData(
              ClipboardData(text: paymentCardMeta.cardholderName));
          showSnackBar(
              message: localizations.cardHolderName,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    if (paymentCardMeta.exp != '')
      getIconedPopupMenuItem(
        content: Text(localizations.expirationDate),
        icon: const Icon(Icons.date_range_outlined),
        onTap: () {
          Clipboard.setData(ClipboardData(text: paymentCardMeta.exp));
          showSnackBar(
              message: localizations.expirationDate,
              icon: const Icon(Icons.copy_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: const Text('CVV'),
      icon: const Icon(Icons.password_outlined),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text:
                data.loadedAccount!.getPaymentCard(paymentCardMeta.key)!.cvv));
        showSnackBar(
            message: 'CVV',
            icon: const Icon(Icons.copy_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
  ];
}

List<PopupMenuEntry> filePopupMenuBuilder(
    BuildContext context, FileEntry fileEntry,
    {Future<void> Function()? onChanged}) {
  return [
    if (fileEntry.type != FileEntryType.folder)
      getIconedPopupMenuItem(
        content: Text(localizations.rename),
        icon: const Icon(Icons.edit_outlined),
        onTap: () async {
          String? result = await showDialog(
              context: context,
              builder: (context) => RenameFileDialog(name: fileEntry.name));
          if (result == null) return;
          Navigator.pushNamed(context, SplashScreen.routeName);
          await Future.delayed(const Duration(milliseconds: 200));
          await data.loadedAccount!.renameFile(fileEntry.key, name: result);
          await (onChanged?.call());
          if (!context.mounted) return;
          Navigator.pop(context);
          showSnackBar(
              message: 'File renamed',
              icon: const Icon(Icons.edit_outlined,
                  color: PassyTheme.darkContentColor));
        },
      ),
    if (fileEntry.type != FileEntryType.folder)
      getIconedPopupMenuItem(
        content: Text(localizations.export),
        icon: const Icon(Icons.ios_share_rounded),
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 200));
          String? expFile;
          if (Platform.isAndroid) {
            String? expDir = await FilePicker.platform.getDirectoryPath(
              dialogTitle: localizations.exportPassy,
              lockParentWindow: true,
            );
            if (expDir != null) {
              expFile = expDir + Platform.pathSeparator + fileEntry.name;
            }
          } else {
            expFile = await FilePicker.platform.saveFile(
              dialogTitle: localizations.exportPassy,
              lockParentWindow: true,
              fileName: fileEntry.name,
            );
          }
          if (expFile == null) return;
          Navigator.pushNamed(context, SplashScreen.routeName);
          await Future.delayed(const Duration(milliseconds: 200));
          await data.loadedAccount!
              .exportFile(fileEntry.key, file: File(expFile));
          Navigator.pop(context);
          await (onChanged?.call());
          if (!context.mounted) return;
          Navigator.pop(context);
          showSnackBar(
              message: localizations.exportSaved,
              icon: const Icon(Icons.ios_share_rounded,
                  color: PassyTheme.darkContentColor));
        },
      ),
    getIconedPopupMenuItem(
      content: Text(localizations.remove),
      icon: const Icon(Icons.delete_outline_rounded),
      onTap: () async {
        bool? result = await showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: PassyTheme.dialogShape,
                title: Text(localizations.removeFile),
                content:
                    Text('${localizations.filesCanOnlyBeRestoredFromABackup}.'),
                actions: [
                  TextButton(
                    child: Text(
                      localizations.cancel,
                      style: const TextStyle(
                          color: PassyTheme.lightContentSecondaryColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(
                      localizations.remove,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                  )
                ],
              );
            });
        if (result != true) return;
        Navigator.pushNamed(context, SplashScreen.routeName);
        await Future.delayed(const Duration(milliseconds: 200));
        if (fileEntry.type == FileEntryType.folder) {
          await data.loadedAccount!.removeFolder(fileEntry.path);
          await (onChanged?.call());
          if (!context.mounted) return;
          Navigator.pop(context);
          showSnackBar(
              message: 'Folder removed',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: PassyTheme.darkContentColor));
          return;
        }
        await data.loadedAccount!.removeFile(fileEntry.key);
        await (onChanged?.call());
        if (!context.mounted) return;
        Navigator.pop(context);
        showSnackBar(
            message: 'File removed',
            icon: const Icon(Icons.delete_outline_rounded,
                color: PassyTheme.darkContentColor));
      },
    ),
  ];
}

List<PopupMenuEntry> passyEntryPopupMenuItemBuilder(
    BuildContext context, SearchEntryData entry) {
  switch (entry.type) {
    case EntryType.idCard:
      return idCardPopupMenuBuilder(context, entry.meta as IDCardMeta);
    case EntryType.identity:
      return identityPopupMenuBuilder(context, entry.meta as IdentityMeta);
    case EntryType.note:
      return notePopupMenuBuilder(context, entry.meta as NoteMeta);
    case EntryType.password:
      return passwordPopupMenuBuilder(context, entry.meta as PasswordMeta);
    case EntryType.paymentCard:
      return paymentCardPopupMenuBuilder(
          context, entry.meta as PaymentCardMeta);
  }
}

Future<void> showConnectDialog(BuildContext context,
    {String popUntilRouteName = MainScreen.routeName}) async {
  CameraController _controller = CameraController(
    (await availableCameras()).first,
    ResolutionPreset.low,
    enableAudio: false,
  );
  Future<void> _initializeControllerFuture = _controller.initialize();
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            shape: PassyTheme.dialogShape,
            title: Text(
              localizations.scanQRCode,
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 250,
              height: 250,
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context,
                      (route) => route.settings.name == popUntilRouteName);
                  Navigator.pushNamed(context, ConnectScreen.routeName,
                      arguments: data.loadedAccount!);
                },
                child: Text(
                  localizations.canNotScanQuestion,
                  style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  localizations.cancel,
                  style: const TextStyle(
                    color: PassyTheme.lightContentSecondaryColor,
                  ),
                ),
              )
            ],
          )).whenComplete(() {
    _controller.dispose();
  });
  Future(() async {
    await _initializeControllerFuture;
    _controller.startImageStream((image) {
      imglib.Image? _image = imageFromCameraImage(image);
      if (_image == null) return;
      Result? _result = qrResultFromImage(_image);
      if (_result == null) {
        _result = qrResultFromImage(imglib.invert(_image));
        if (_result == null) {
          return;
        }
      }
      Navigator.popUntil(
          context, (route) => route.settings.name == popUntilRouteName);
      SynchronizationWrapper(context: context).connect(data.loadedAccount!,
          address: _result.text, popUntilRouteName: popUntilRouteName);
    });
  });
}

void Function() onConnectPressed(BuildContext context,
    {String popUntilRouteName = MainScreen.routeName}) {
  return Platform.isAndroid || Platform.isIOS
      ? () => showConnectDialog(context, popUntilRouteName: popUntilRouteName)
      : () {
          Navigator.popUntil(
              context, (route) => route.settings.name == popUntilRouteName);
          Navigator.pushNamed(context, ConnectScreen.routeName,
              arguments: data.loadedAccount!);
        };
}

void showSynchronizationDialog(BuildContext context,
    {String popUntilRouteName = MainScreen.routeName}) {
  void Function() _onConnectPressed =
      onConnectPressed(context, popUntilRouteName: popUntilRouteName);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: PassyTheme.dialogShape,
      title: Center(
          child: Text(
        localizations.synchronize,
        style: const TextStyle(color: PassyTheme.lightContentColor),
      )),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
            child: Text(
              localizations.host,
              style:
                  const TextStyle(color: PassyTheme.lightContentSecondaryColor),
            ),
            onPressed: () => SynchronizationWrapper(context: context)
                .host(data.loadedAccount!)),
        TextButton(
          child: Text(
            localizations.connect,
            style:
                const TextStyle(color: PassyTheme.lightContentSecondaryColor),
          ),
          onPressed: _onConnectPressed,
        ),
      ],
    ),
  ).then((value) => null);
}

String genderToReadableName(Gender gender) {
  switch (gender) {
    case Gender.notSpecified:
      return localizations.notSpecified;
    case Gender.male:
      return localizations.male;
    case Gender.female:
      return localizations.female;
    case Gender.other:
      return localizations.other;
  }
}

setOnError(BuildContext context) {
  FlutterError.onError = (e) {
    FlutterError.presentError(e);
    try {
      showSnackBar(
        message: localizations.somethingWentWrong,
        icon: const Icon(Icons.error_outline_rounded,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(
              navigatorKey.currentContext!, LogScreen.routeName,
              arguments: e.exception.toString() + '\n' + e.stack.toString()),
        ),
      );
    } catch (_) {}
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      showSnackBar(
        message: localizations.somethingWentWrong,
        icon: const Icon(Icons.error_outline_rounded,
            color: PassyTheme.darkContentColor),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(
              navigatorKey.currentContext!, LogScreen.routeName,
              arguments: error.toString() + '\n' + stack.toString()),
        ),
      );
    } catch (_) {}
    return false;
  };
}
