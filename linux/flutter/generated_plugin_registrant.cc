//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <dargon2_flutter_desktop/dargon2_flutter_desktop_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) dargon2_flutter_desktop_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "Dargon2FlutterDesktopPlugin");
  dargon2_flutter_desktop_plugin_register_with_registrar(dargon2_flutter_desktop_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
