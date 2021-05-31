//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <gtk_header_bar/gtk_header_bar_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) gtk_header_bar_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "GtkHeaderBarPlugin");
  gtk_header_bar_plugin_register_with_registrar(gtk_header_bar_registrar);
}
