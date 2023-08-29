// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:io';

import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_linux.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_macos.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_noop.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_windows.dart'
    if (dart.library.html) 'app_auto_launcher_impl_windows_noop.dart';

class Autostart {
  Autostart();

  AppAutoLauncher _appAutoLauncher = AppAutoLauncherImplNoop();

  void setup({
    required String appName,
    required String appPath,
    List<String> args = const [],
  }) {
    if (Platform.isLinux) {
      _appAutoLauncher = AppAutoLauncherImplLinux(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    } else if (Platform.isMacOS) {
      _appAutoLauncher = AppAutoLauncherImplMacOS(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    } else if (Platform.isWindows) {
      _appAutoLauncher = AppAutoLauncherImplWindows(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    }
  }

  /// Sets your app to auto-launch at startup
  Future<bool> enable() => _appAutoLauncher.enable();

  /// Disables your app from auto-launching at startup.
  Future<bool> disable() => _appAutoLauncher.disable();

  Future<bool> isEnabled() => _appAutoLauncher.isEnabled();
}
