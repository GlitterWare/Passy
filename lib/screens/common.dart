import 'dart:io';
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
import 'package:passy/passy_data/passy_app_theme.dart';
import 'package:passy/passy_data/passy_file_type.dart';
import 'package:passy/passy_data/payment_card.dart';
import 'package:passy/passy_data/screen.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/files_screen.dart';
import 'package:passy/screens/id_cards_screen.dart';
import 'package:passy/screens/identities_screen.dart';
import 'package:passy/screens/notes_screen.dart';
import 'package:passy/screens/payment_cards_screen.dart';
import 'package:passy/screens/unlock_screen.dart';
import 'package:system_tray/system_tray.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
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

const double floatingActionButtonPadding = 72.0;

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
      icon: const Icon(Icons.save_rounded),
    );
    return _buDir;
  } catch (e, s) {
    if (e is FileSystemException) {
      showSnackBar(
        message: localizations.accessDeniedTryAnotherFolder,
        icon: const Icon(Icons.save_rounded),
      );
    } else {
      showSnackBar(
        message: localizations.couldNotBackup,
        icon: const Icon(Icons.save_rounded),
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
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
    order: imglib.ChannelOrder.bgra,
  );
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
imglib.Image imageFromYUV420(CameraImage image) {
  final uvRowStride = image.planes[1].bytesPerRow;
  final uvPixelStride = image.planes[1].bytesPerPixel ?? 0;
  final img = imglib.Image(width: image.width, height: image.height);
  for (final p in img) {
    final x = p.x;
    final y = p.y;
    final uvIndex =
        uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
    final index = y * uvRowStride +
        x; // Use the row stride instead of the image width as some devices pad the image data, and in those cases the image width != bytesPerRow. Using width will give you a distored image.
    final yp = image.planes[0].bytes[index];
    final up = image.planes[1].bytes[uvIndex];
    final vp = image.planes[2].bytes[uvIndex];
    p.r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255).toInt();
    p.g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
        .round()
        .clamp(0, 255)
        .toInt();
    p.b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255).toInt();
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
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: imglib.ChannelOrder.abgr)
            .buffer
            .asInt32List());
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
      IconTheme(
          data: IconThemeData(
              color: PassyTheme.of(context).highlightContentTextColor),
          child: icon),
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
          icon: const Icon(Icons.copy_rounded),
        );
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
            icon: const Icon(Icons.copy_rounded),
          );
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
          icon: const Icon(Icons.copy_rounded),
        );
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
          icon: const Icon(Icons.copy_rounded),
        );
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
            icon: const Icon(Icons.copy_rounded),
          );
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
          icon: const Icon(Icons.copy_rounded),
        );
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
            icon: const Icon(Icons.copy_rounded),
          );
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
          icon: const Icon(Icons.copy_rounded),
        );
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
          icon: const Icon(Icons.copy_rounded),
        );
      },
    ),
    if (passwordMeta.websites.firstOrNull != '')
      for (String website in passwordMeta.websites.sublist(0,
          passwordMeta.websites.length < 5 ? passwordMeta.websites.length : 5))
        getIconedPopupMenuItem(
          content: Text(website),
          icon: const Icon(Icons.open_in_browser_outlined),
          onTap: () {
            if (!website.contains(RegExp('http:\\/\\/|https:\\/\\/'))) {
              website = 'http://' + website;
            }
            try {
              openUrl(website);
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
            icon: const Icon(Icons.copy_rounded),
          );
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
            icon: const Icon(Icons.copy_rounded),
          );
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
            icon: const Icon(Icons.copy_rounded),
          );
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
          icon: const Icon(Icons.copy_rounded),
        );
      },
    ),
  ];
}

List<PopupMenuEntry> filePopupMenuBuilder(
    BuildContext context, FileEntry fileEntry,
    {Future<void> Function()? onChanged}) {
  List<String> originalPathSplit = fileEntry.path.split('/');
  originalPathSplit.removeLast();
  String originalPath = originalPathSplit.join('/') + '/';
  return [
    if (fileEntry.type != FileEntryType.folder)
      getIconedPopupMenuItem(
        content: Text(localizations.edit),
        icon: const Icon(Icons.edit_outlined),
        onTap: () async {
          EditFileDialogResponse? result = await showDialog(
              context: context,
              builder: (context) =>
                  EditFileDialog(name: fileEntry.name, type: fileEntry.type));
          if (result == null) return;
          PassyFileType? type = passyFileTypeFromFileEntryType(result.type);
          Navigator.pushNamed(context, SplashScreen.routeName);
          await Future.delayed(const Duration(milliseconds: 200));
          if (result.name != fileEntry.name) {
            try {
              await data.loadedAccount!
                  .renameFile(fileEntry.key, name: result.name);
            } catch (e, s) {
              showSnackBar(
                message: localizations.somethingWentWrong,
                icon: const Icon(Icons.error_outline_rounded),
                action: SnackBarAction(
                  label: localizations.details,
                  onPressed: () => Navigator.pushNamed(
                      navigatorKey.currentContext!, LogScreen.routeName,
                      arguments: e.toString() + '\n' + s.toString()),
                ),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              return;
            }
          }
          if (type != null) {
            if (result.type != fileEntry.type) {
              await data.loadedAccount!
                  .changeFileType(fileEntry.key, type: type);
            }
          }
          await (onChanged?.call());
          if (!context.mounted) return;
          Navigator.pop(context);
          showSnackBar(
            message: localizations.fileSaved,
            icon: const Icon(Icons.edit_outlined),
          );
        },
      ),
    if (fileEntry.type != FileEntryType.folder)
      getIconedPopupMenuItem(
        content: Text(localizations.move),
        icon: const Icon(Icons.move_down),
        onTap: () async {
          List<String> pathSplit = fileEntry.path.split('/');
          pathSplit.removeLast();
          String path;
          if (pathSplit.length == 1) {
            path = '/';
          } else {
            path = pathSplit.join('/');
          }
          dynamic result = await Navigator.pushNamed(
              context, FilesScreen.routeName,
              arguments: FilesScreenArgs(
                  path: path, select: FilesScreenSelectMode.folder));
          if (result is! FilesScreenResult) return;
          String newPath;
          if (result.key == '/') {
            newPath = result.key;
          } else {
            newPath = result.key + '/';
          }
          Navigator.pushNamed(context, SplashScreen.routeName);
          await Future.delayed(const Duration(milliseconds: 200));
          if (newPath != originalPath) {
            try {
              await data.loadedAccount!
                  .moveFile(fileEntry.key, path: newPath + fileEntry.name);
            } catch (e, s) {
              showSnackBar(
                message: localizations.somethingWentWrong,
                icon: const Icon(Icons.error_outline_rounded),
                action: SnackBarAction(
                  label: localizations.details,
                  onPressed: () => Navigator.pushNamed(
                      navigatorKey.currentContext!, LogScreen.routeName,
                      arguments: e.toString() + '\n' + s.toString()),
                ),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              return;
            }
          }
          await (onChanged?.call());
          if (!context.mounted) return;
          Navigator.pop(context);
          showSnackBar(
            message: localizations.fileSaved,
            icon: const Icon(Icons.edit_outlined),
          );
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
            icon: const Icon(Icons.ios_share_rounded),
          );
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
                      style: TextStyle(
                          color: PassyTheme.of(context)
                              .highlightContentSecondaryColor),
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
            icon: const Icon(Icons.delete_outline_rounded),
          );
          return;
        }
        await data.loadedAccount!.removeFile(fileEntry.key);
        await (onChanged?.call());
        if (!context.mounted) return;
        Navigator.pop(context);
        showSnackBar(
          message: 'File removed',
          icon: const Icon(Icons.delete_outline_rounded),
        );
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
                  style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  localizations.cancel,
                  style: TextStyle(
                    color:
                        PassyTheme.of(context).highlightContentSecondaryColor,
                  ),
                ),
              )
            ],
          )).whenComplete(() {
    _controller.dispose();
  });
  Future(() async {
    await _initializeControllerFuture;
    bool isBusy = false;
    _controller.startImageStream((image) {
      if (isBusy) return;
      isBusy = true;
      Future.delayed(const Duration(seconds: 1), () => isBusy = false);
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
        style: TextStyle(color: PassyTheme.of(context).contentTextColor),
      )),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
            child: Text(
              localizations.host,
              style: TextStyle(
                  color: PassyTheme.of(context).highlightContentSecondaryColor),
            ),
            onPressed: () => SynchronizationWrapper(context: context)
                .host(data.loadedAccount!)),
        TextButton(
          child: Text(
            localizations.connect,
            style: TextStyle(
                color: PassyTheme.of(context).highlightContentSecondaryColor),
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
        icon: const Icon(Icons.error_outline_rounded),
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
        icon: const Icon(Icons.error_outline_rounded),
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

class PassyTray extends SystemTray {
  static const String _kChannelName = "flutter/system_tray/tray";

  static const String _kInitSystemTray = "InitSystemTray";

  static const String _kTrayIdKey = "tray_id";
  static const String _kTitleKey = "title";
  static const String _kIconPathKey = "iconpath";
  static const String _kToolTipKey = "tooltip";
  static const String _kIsTemplateKey = "is_template";

  static const MethodChannel _platformChannel = MethodChannel(_kChannelName);

  PassyTray() : super();

  @override
  Future<bool> initSystemTray({
    required String iconPath,
    String? title,
    String? toolTip,
    bool isTemplate = false,
  }) async {
    if (!Platform.environment.containsKey('container')) {
      return await super.initSystemTray(
        iconPath: iconPath,
        title: title,
        toolTip: toolTip,
        isTemplate: isTemplate,
      );
    }
    // Flatpak
    return await _platformChannel.invokeMethod(
      _kInitSystemTray,
      <String, dynamic>{
        _kTrayIdKey: const Uuid().v1(),
        _kTitleKey: title,
        _kIconPathKey: iconPath,
        _kToolTipKey: toolTip,
        _kIsTemplateKey: isTemplate,
      },
    );
  }
}

bool _trayEnabled = false;
bool get trayEnabled => _trayEnabled;
SystemTray? _systemTray;

Future<void> toggleTray(BuildContext context) async {
  SystemTray systemTray;
  if (_systemTray == null) {
    try {
      systemTray = PassyTray();
      _systemTray = systemTray;
    } catch (e, s) {
      if (!context.mounted) return;
      showSnackBar(
        message: localizations.somethingWentWrong,
        icon: const Icon(Icons.error_outline_rounded),
        action: SnackBarAction(
          label: localizations.details,
          onPressed: () => Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString()),
        ),
      );
      return;
    }
  } else {
    systemTray = _systemTray!;
  }
  if (_trayEnabled) {
    await systemTray.destroy();
  } else {
    String path = Platform.isWindows
        ? 'assets/images/icon.ico'
        : Platform.environment.containsKey('container')
            ? 'io.github.glitterware.Passy'
            : 'assets/images/icon48.png';
    final menu = Menu();
    menu.buildFrom([
      MenuItemLabel(
        label: localizations.showWindow,
        onClicked: (_) async {
          while (!await windowManager.isVisible()) {
            await windowManager.show();
            await windowManager.focus();
            await Future.delayed(const Duration(milliseconds: 100));
          }
        },
      ),
      MenuItemLabel(
        label: localizations.hideWindow,
        onClicked: (_) {
          windowManager.hide();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: localizations.exitPassy,
        onClicked: (_) => SystemNavigator.pop(),
      ),
    ]);

    // We first init the systray menu and then add the menu entries
    await systemTray.initSystemTray(
      title: 'Passy',
      iconPath: path,
    );

    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows
            ? windowManager.show()
            : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows
            ? systemTray.popUpContextMenu()
            : windowManager.show();
      }
    });
  }
  _trayEnabled = !_trayEnabled;
}

void switchAppTheme(BuildContext context, PassyAppTheme? appTheme) {
  if (!context.mounted) return;
  ThemeData? data;
  if (appTheme == null) {
    data = null;
  } else {
    data = PassyTheme.themes[appTheme];
  }
  if (data == null) {
    PassyThemeNotification(PassyTheme.classicDark).dispatch(context);
  } else {
    PassyThemeNotification(data).dispatch(context);
  }
}
