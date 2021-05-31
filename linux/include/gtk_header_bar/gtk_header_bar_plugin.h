#ifndef FLUTTER_PLUGIN_GTK_HEADER_BAR_PLUGIN_H_
#define FLUTTER_PLUGIN_GTK_HEADER_BAR_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _GtkHeaderBarPlugin GtkHeaderBarPlugin;
typedef struct {
  GObjectClass parent_class;
} GtkHeaderBarPluginClass;

FLUTTER_PLUGIN_EXPORT GType gtk_header_bar_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void gtk_header_bar_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_GTK_HEADER_BAR_PLUGIN_H_
