//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dargon2_flutter_desktop/dargon2_flutter_desktop_plugin.h>
#include <emoji_picker_flutter/emoji_picker_flutter_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  Dargon2FlutterDesktopPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("Dargon2FlutterDesktopPlugin"));
  EmojiPickerFlutterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("EmojiPickerFlutterPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
