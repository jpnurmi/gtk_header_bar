#include "include/gtk_header_bar/gtk_header_bar_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

static const gchar* kUniqueKey = "_key";
static const gchar* kPackingKey = "_packing";
static const gchar* kIndexKey = "_index";

#define GTK_HEADER_BAR_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), gtk_header_bar_plugin_get_type(), \
                              GtkHeaderBarPlugin))

struct _GtkHeaderBarPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  GHashTable* widgets;
  gboolean rebuild;
};

G_DEFINE_TYPE(GtkHeaderBarPlugin, gtk_header_bar_plugin, g_object_get_type())

static gint* g_intdup(int i) {
  gint* value = (gint*)g_new(int, 1);
  *value = i;
  return value;
}

static bool fl_value_is_valid(FlValue* value, FlValueType type) {
  return value && fl_value_get_type(value) == type;
}

static void button_clicked_cb(GtkButton* button, GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  const gchar* packing =
      (const gchar*)g_object_get_data(G_OBJECT(button), kPackingKey);
  gint* index = (gint*)g_object_get_data(G_OBJECT(button), kIndexKey);

  FlValue* args = fl_value_new_list();
  fl_value_append_take(args, fl_value_new_string(packing));
  fl_value_append_take(args, fl_value_new_int(*index));

  fl_method_channel_invoke_method(plugin->channel, "buttonClicked", args,
                                  nullptr, nullptr, nullptr);
}

static void button_toggled_cb(GtkToggleButton* button,
                              GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  const gchar* packing =
      (const gchar*)g_object_get_data(G_OBJECT(button), kPackingKey);
  gint* index = (gint*)g_object_get_data(G_OBJECT(button), kIndexKey);
  gboolean active = gtk_toggle_button_get_active(button);

  FlValue* args = fl_value_new_list();
  fl_value_append_take(args, fl_value_new_string(packing));
  fl_value_append_take(args, fl_value_new_int(*index));
  fl_value_append_take(args, fl_value_new_bool(active));

  fl_method_channel_invoke_method(plugin->channel, "buttonToggled", args,
                                  nullptr, nullptr, nullptr);
}

static void entry_activate_cb(GtkEntry* entry, GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  const gchar* packing =
      (const gchar*)g_object_get_data(G_OBJECT(entry), kPackingKey);
  gint* index = (gint*)g_object_get_data(G_OBJECT(entry), kIndexKey);
  const gchar* text = gtk_entry_get_text(entry);

  FlValue* args = fl_value_new_list();
  fl_value_append_take(args, fl_value_new_string(packing));
  fl_value_append_take(args, fl_value_new_int(*index));
  fl_value_append_take(args, fl_value_new_string(text));

  fl_method_channel_invoke_method(plugin->channel, "entryActivate", args,
                                  nullptr, nullptr, nullptr);
}

static GtkWidget* header_bar_get(GtkHeaderBarPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));

  GtkWidget* header_bar = gtk_window_get_titlebar(GTK_WINDOW(window));
  if (!header_bar) {
    header_bar = gtk_header_bar_new();
    gtk_window_set_titlebar(GTK_WINDOW(window), header_bar);
  }

  return header_bar;
}

static GtkWidget* widget_create(GtkHeaderBarPlugin* self, const gchar* type,
                                FlValue* args) {
  GtkWidget* widget = nullptr;
  if (g_strcmp0(type, "GtkButton") == 0) {
    widget = gtk_button_new();
    g_signal_connect(widget, "clicked", G_CALLBACK(button_clicked_cb), self);
  } else if (g_strcmp0(type, "GtkToggleButton") == 0) {
    widget = gtk_toggle_button_new();
    g_signal_connect(widget, "toggled", G_CALLBACK(button_toggled_cb), self);
  } else if (g_strcmp0(type, "GtkCheckButton") == 0) {
    widget = gtk_check_button_new();
    g_signal_connect(widget, "toggled", G_CALLBACK(button_toggled_cb), self);
  } else if (g_strcmp0(type, "GtkMenuButton") == 0) {
    widget = gtk_menu_button_new();
    g_signal_connect(widget, "toggled", G_CALLBACK(button_toggled_cb), self);
  } else if (g_strcmp0(type, "GtkMenu") == 0) {
    widget = gtk_menu_new();
  } else if (g_strcmp0(type, "GtkMenuItem") == 0) {
    widget = gtk_menu_item_new();
  } else if (g_strcmp0(type, "GtkEntry") == 0) {
    widget = gtk_entry_new();
    g_signal_connect(widget, "activate", G_CALLBACK(entry_activate_cb), self);
  }
  return widget;
}

static void widget_update(GtkWidget* widget, const gchar* type, FlValue* args) {
  if (GTK_IS_BUTTON(widget)) {
    FlValue* label = fl_value_lookup_string(args, "label");
    if (fl_value_is_valid(label, FL_VALUE_TYPE_STRING)) {
      gtk_button_set_label(GTK_BUTTON(widget), fl_value_get_string(label));
    }
  }

  if (GTK_IS_TOGGLE_BUTTON(widget)) {
    FlValue* active = fl_value_lookup_string(args, "active");
    if (fl_value_is_valid(active, FL_VALUE_TYPE_BOOL)) {
      gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(widget),
                                   fl_value_get_bool(active));
    }
  }

  if (GTK_IS_MENU_BUTTON(widget)) {
    // FlValue* popup = fl_value_lookup_string(args, "popup");
    // if (fl_value_is_valid(label, FL_VALUE_TYPE_MAP)) {
    //   ...
    // }
  }

  if (GTK_IS_MENU(widget)) {
    FlValue* title = fl_value_lookup_string(args, "title");
    if (fl_value_is_valid(title, FL_VALUE_TYPE_STRING)) {
      gtk_menu_set_title(GTK_MENU(widget), fl_value_get_string(title));
    }
  }

  if (GTK_IS_MENU_ITEM(widget)) {
    FlValue* label = fl_value_lookup_string(args, "label");
    if (fl_value_is_valid(label, FL_VALUE_TYPE_STRING)) {
      gtk_menu_item_set_label(GTK_MENU_ITEM(widget),
                              fl_value_get_string(label));
    }
  }

  if (GTK_IS_ENTRY(widget)) {
    FlValue* text = fl_value_lookup_string(args, "text");
    if (fl_value_is_valid(text, FL_VALUE_TYPE_STRING)) {
      gtk_entry_set_text(GTK_ENTRY(widget), fl_value_get_string(text));
    }
  }

  if (GTK_IS_WIDGET(widget)) {
    FlValue* sensitive = fl_value_lookup_string(args, "sensitive");
    if (fl_value_is_valid(sensitive, FL_VALUE_TYPE_BOOL)) {
      gtk_widget_set_sensitive(widget, fl_value_get_bool(sensitive));
    }

    FlValue* visible = fl_value_lookup_string(args, "visible");
    if (fl_value_is_valid(visible, FL_VALUE_TYPE_BOOL)) {
      gtk_widget_set_visible(widget, fl_value_get_bool(visible));
    } else {
      gtk_widget_show(widget);
    }
  }
}

static void header_bar_pack(GtkHeaderBarPlugin* self, const gchar* packing,
                            gint index, FlValue* args,
                            void (*pack)(GtkHeaderBar*, GtkWidget*)) {
  FlValue* type = fl_value_lookup_string(args, "type");
  if (!fl_value_is_valid(type, FL_VALUE_TYPE_STRING)) {
    return;
  }

  GtkWidget* child = nullptr;
  GtkWidget* header_bar = header_bar_get(self);

  FlValue* key = fl_value_lookup_string(args, kUniqueKey);
  gpointer value = nullptr;
  if (fl_value_is_valid(key, FL_VALUE_TYPE_STRING)) {
    value = g_hash_table_lookup(self->widgets, fl_value_get_string(key));
    if (GTK_IS_WIDGET(value)) {
      child = GTK_WIDGET(value);
    }
  }

  if (!child) {
    child = widget_create(self, fl_value_get_string(type), args);
  }

  if (child) {
    if (!value && fl_value_is_valid(key, FL_VALUE_TYPE_STRING)) {
      gchar* data = g_strdup(fl_value_get_string(key));
      g_object_set_data(G_OBJECT(child), kUniqueKey, data);
      g_hash_table_insert(self->widgets, data, child);
    }

    g_object_set_data_full(G_OBJECT(child), kPackingKey, g_strdup(packing),
                           (GDestroyNotify)g_free);
    g_object_set_data_full(G_OBJECT(child), kIndexKey, g_intdup(index),
                           (GDestroyNotify)g_free);

    if (!gtk_widget_get_parent(child)) {
      pack(GTK_HEADER_BAR(header_bar), child);
    }

    widget_update(child, fl_value_get_string(type), args);
  }
}

static void header_bar_pack_all(GtkHeaderBarPlugin* self, FlValue* args,
                                const gchar* packing,
                                void (*pack)(GtkHeaderBar*, GtkWidget*)) {
  FlValue* children = fl_value_lookup_string(args, packing);
  if (fl_value_is_valid(children, FL_VALUE_TYPE_LIST)) {
    self->rebuild = TRUE;
    size_t length = fl_value_get_length(children);
    for (size_t i = 0; i < length; ++i) {
      FlValue* child = fl_value_get_list_value(children, i);
      header_bar_pack(self, packing, i, child, pack);
    }
    self->rebuild = FALSE;
  }
}

static void header_bar_set_args(GtkHeaderBarPlugin* self, FlValue* args) {
  GtkWidget* header_bar = header_bar_get(self);

  GList* children = gtk_container_get_children(GTK_CONTAINER(header_bar));
  GList* child = children;
  while (child) {
    if (!g_object_get_data(G_OBJECT(child->data), kUniqueKey)) {
      gtk_widget_destroy(GTK_WIDGET(child->data));
    } else {
      gtk_widget_hide(GTK_WIDGET(child->data));
    }
    child = child->next;
  }
  g_list_free(children);

  FlValue* title = fl_value_lookup_string(args, "title");
  if (fl_value_is_valid(title, FL_VALUE_TYPE_STRING)) {
    gtk_header_bar_set_title(GTK_HEADER_BAR(header_bar),
                             fl_value_get_string(title));
  }

  FlValue* subtitle = fl_value_lookup_string(args, "subtitle");
  if (fl_value_is_valid(subtitle, FL_VALUE_TYPE_STRING)) {
    gtk_header_bar_set_subtitle(GTK_HEADER_BAR(header_bar),
                                fl_value_get_string(subtitle));
  }

  FlValue* show_close_button = fl_value_lookup_string(args, "showCloseButton");
  if (fl_value_is_valid(show_close_button, FL_VALUE_TYPE_BOOL)) {
    gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(header_bar),
                                         fl_value_get_bool(show_close_button));
  }

  FlValue* decoration_layout = fl_value_lookup_string(args, "decorationLayout");
  if (fl_value_is_valid(decoration_layout, FL_VALUE_TYPE_STRING)) {
    gtk_header_bar_set_decoration_layout(
        GTK_HEADER_BAR(header_bar), fl_value_get_string(decoration_layout));
  }

  header_bar_pack_all(self, args, "start", gtk_header_bar_pack_start);
  header_bar_pack_all(self, args, "end", gtk_header_bar_pack_end);
}

static void gtk_header_bar_plugin_handle_method_call(
    GtkHeaderBarPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "setHeaderBar") == 0) {
    header_bar_set_args(self, args);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void gtk_header_bar_plugin_dispose(GObject* object) {
  GtkHeaderBarPlugin* self = GTK_HEADER_BAR_PLUGIN(object);
  g_object_unref(self->registrar);
  g_object_unref(self->channel);
  g_hash_table_unref(self->widgets);

  G_OBJECT_CLASS(gtk_header_bar_plugin_parent_class)->dispose(object);
}

static void gtk_header_bar_plugin_class_init(GtkHeaderBarPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = gtk_header_bar_plugin_dispose;
}

static void gtk_header_bar_plugin_init(GtkHeaderBarPlugin* self) {
  self->widgets = g_hash_table_new(g_str_hash, g_str_equal);
  self->rebuild = FALSE;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  GtkHeaderBarPlugin* plugin = GTK_HEADER_BAR_PLUGIN(user_data);
  gtk_header_bar_plugin_handle_method_call(plugin, method_call);
}

void gtk_header_bar_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  GtkHeaderBarPlugin* plugin = GTK_HEADER_BAR_PLUGIN(
      g_object_new(gtk_header_bar_plugin_get_type(), nullptr));
  plugin->registrar = g_object_ref(registrar);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "gtk_header_bar", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
