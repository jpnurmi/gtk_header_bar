#include "include/gtk_header_bar/gtk_header_bar_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define GTK_HEADER_BAR_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), gtk_header_bar_plugin_get_type(), \
                              GtkHeaderBarPlugin))

struct _GtkHeaderBarPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  gboolean rebuild;
};

G_DEFINE_TYPE(GtkHeaderBarPlugin, gtk_header_bar_plugin, g_object_get_type())

static bool fl_value_is_valid(FlValue* value, FlValueType type) {
  return value && fl_value_get_type(value) == type;
}

static GtkWidget* window_get(GtkHeaderBarPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  return gtk_widget_get_toplevel(GTK_WIDGET(view));
}

static GtkWidget* header_bar_get(GtkHeaderBarPlugin* self) {
  GtkWidget* window = window_get(self);
  g_return_val_if_fail(window, nullptr);

  GtkWidget* header_bar = gtk_window_get_titlebar(GTK_WINDOW(window));
  if (!GTK_IS_HEADER_BAR(header_bar)) {
    header_bar = gtk_header_bar_new();
    gtk_window_set_titlebar(GTK_WINDOW(window), header_bar);
  }
  return header_bar;
}

static gint container_child_get_index(GtkContainer* container,
                                      GtkWidget* child) {
  // ### TODO: g_object_get/set_data()?
  GList* children = gtk_container_get_children(container);
  gint index = g_list_index(children, child);
  g_list_free(children);
  return index;
}

static void widget_fill_path(GtkHeaderBarPlugin* self, GtkWidget* widget,
                             FlValue* path) {
  GtkWidget* header_bar = header_bar_get(self);
  if (!widget || widget == header_bar) return;

  GtkWidget* parent = gtk_widget_get_parent(widget);
  if (GTK_IS_MENU(widget)) {
    GtkWidget* attach_widget = gtk_menu_get_attach_widget(GTK_MENU(widget));
    if (attach_widget) {
      widget_fill_path(self, attach_widget, path);
    }
  } else if (parent) {
    widget_fill_path(self, parent, path);
  }

  FlValue* args = fl_value_new_map();
  fl_value_set_string_take(args, "type",
                           fl_value_new_string(G_OBJECT_TYPE_NAME(widget)));
  if (GTK_IS_CONTAINER(parent)) {
    gint index = container_child_get_index(GTK_CONTAINER(parent), widget);
    fl_value_set_string_take(args, "index", fl_value_new_int(index));
  }
  fl_value_append_take(path, args);
}

static FlValue* widget_get_path(GtkHeaderBarPlugin* self, GtkWidget* widget) {
  FlValue* path = fl_value_new_list();
  widget_fill_path(self, widget, path);
  return path;
}

static void button_clicked_cb(GtkButton* button, GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  FlValue* args = fl_value_new_map();
  fl_value_set_string_take(args, "path",
                           widget_get_path(plugin, GTK_WIDGET(button)));

  fl_method_channel_invoke_method(plugin->channel, "buttonClicked", args,
                                  nullptr, nullptr, nullptr);
}

static void button_toggled_cb(GtkToggleButton* button,
                              GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  gboolean active = gtk_toggle_button_get_active(button);

  FlValue* args = fl_value_new_map();
  fl_value_set_string_take(args, "active", fl_value_new_bool(active));
  fl_value_set_string_take(args, "path",
                           widget_get_path(plugin, GTK_WIDGET(button)));

  fl_method_channel_invoke_method(plugin->channel, "buttonToggled", args,
                                  nullptr, nullptr, nullptr);
}

static void entry_activate_cb(GtkEntry* entry, GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  const gchar* text = gtk_entry_get_text(entry);

  FlValue* args = fl_value_new_map();
  fl_value_set_string_take(args, "text", fl_value_new_string(text));
  fl_value_set_string_take(args, "path",
                           widget_get_path(plugin, GTK_WIDGET(entry)));

  fl_method_channel_invoke_method(plugin->channel, "entryActivate", args,
                                  nullptr, nullptr, nullptr);
}

static void menu_item_activate_cb(GtkMenuItem* menu_item,
                                  GtkHeaderBarPlugin* plugin) {
  if (plugin->rebuild) return;

  FlValue* args = fl_value_new_map();
  fl_value_set_string_take(args, "path",
                           widget_get_path(plugin, GTK_WIDGET(menu_item)));

  fl_method_channel_invoke_method(plugin->channel, "menuItemActivate", args,
                                  nullptr, nullptr, nullptr);
}

static GtkWidget* widget_create(GtkHeaderBarPlugin* self, FlValue* args);
static void widget_init(GtkHeaderBarPlugin* self, GtkWidget* widget,
                        FlValue* args);
static void widget_update(GtkHeaderBarPlugin* self, GtkWidget* widget,
                          FlValue* args);

static GtkWidget* widget_create(GtkHeaderBarPlugin* self, FlValue* args) {
  FlValue* value = fl_value_lookup_string(args, "type");
  g_return_val_if_fail(fl_value_is_valid(value, FL_VALUE_TYPE_STRING), nullptr);

  const gchar* name = fl_value_get_string(value);
  GType type = g_type_from_name(name);
  g_return_val_if_fail(g_type_is_a(type, GTK_TYPE_WIDGET), nullptr);

  GtkWidget* widget = gtk_widget_new(type, nullptr);
  widget_init(self, widget, args);
  return widget;
}

static void widget_init(GtkHeaderBarPlugin* self, GtkWidget* widget,
                        FlValue* args) {
  if (GTK_IS_BUTTON(widget)) {
    g_signal_connect(widget, "clicked", G_CALLBACK(button_clicked_cb), self);
  }

  if (GTK_IS_TOGGLE_BUTTON(widget)) {
    g_signal_connect(widget, "toggled", G_CALLBACK(button_toggled_cb), self);
  }

  if (GTK_IS_ENTRY(widget)) {
    g_signal_connect(widget, "activate", G_CALLBACK(entry_activate_cb), self);
  }

  if (GTK_IS_MENU_BUTTON(widget)) {
    FlValue* popup_args = fl_value_lookup_string(args, "popup");
    if (fl_value_is_valid(popup_args, FL_VALUE_TYPE_MAP)) {
      GtkMenu* popup = gtk_menu_button_get_popup(GTK_MENU_BUTTON(widget));
      if (!popup) {
        popup = GTK_MENU(widget_create(self, popup_args));
        gtk_menu_button_set_popup(GTK_MENU_BUTTON(widget), GTK_WIDGET(popup));
      }
    }
  }

  if (GTK_IS_HEADER_BAR(widget)) {
    FlValue* start = fl_value_lookup_string(args, "start");
    if (fl_value_is_valid(start, FL_VALUE_TYPE_LIST)) {
      size_t length = fl_value_get_length(start);
      for (size_t i = 0; i < length; ++i) {
        FlValue* child_args = fl_value_get_list_value(start, i);
        GtkWidget* child = widget_create(self, child_args);
        gtk_header_bar_pack_start(GTK_HEADER_BAR(widget), child);
      }
    }

    FlValue* end = fl_value_lookup_string(args, "end");
    if (fl_value_is_valid(end, FL_VALUE_TYPE_LIST)) {
      size_t length = fl_value_get_length(end);
      for (size_t i = 0; i < length; ++i) {
        FlValue* child_args = fl_value_get_list_value(end, i);
        GtkWidget* child = widget_create(self, child_args);
        gtk_header_bar_pack_end(GTK_HEADER_BAR(widget), child);
      }
    }
  }

  if (GTK_IS_CONTAINER(widget) && !GTK_IS_HEADER_BAR(widget)) {
    FlValue* children = fl_value_lookup_string(args, "children");
    if (fl_value_is_valid(children, FL_VALUE_TYPE_LIST)) {
      size_t length = fl_value_get_length(children);
      for (size_t i = 0; i < length; ++i) {
        FlValue* child_args = fl_value_get_list_value(children, i);
        GtkWidget* child = widget_create(self, child_args);
        gtk_container_add(GTK_CONTAINER(widget), child);
      }
    }
  }

  if (GTK_IS_MENU_ITEM(widget)) {
    FlValue* submenu_args = fl_value_lookup_string(args, "submenu");
    if (fl_value_is_valid(submenu_args, FL_VALUE_TYPE_MAP)) {
      GtkWidget* submenu = gtk_menu_item_get_submenu(GTK_MENU_ITEM(widget));
      if (!submenu) {
        submenu = widget_create(self, submenu_args);
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(widget), submenu);
      }
    }

    g_signal_connect(widget, "activate", G_CALLBACK(menu_item_activate_cb),
                     self);
  }
}

static GtkPackType container_child_get_pack_type(GtkContainer* container,
                                                 GtkWidget* child) {
  GtkPackType pack_type = GTK_PACK_START;
  gtk_container_child_get(GTK_CONTAINER(container), child, "pack-type",
                          &pack_type, nullptr);
  return pack_type;
}

static void container_update_all(GtkHeaderBarPlugin* self,
                                 GtkContainer* container, FlValue* args,
                                 GtkPackType pack_type) {
  GList* children = gtk_container_get_children(container);
  size_t i = 0;
  size_t length = fl_value_get_length(args);
  GList* it = children;
  while (it != nullptr && i < length) {
    GtkWidget* child = GTK_WIDGET(it->data);
    if (pack_type == GtkPackType(-1) ||
        container_child_get_pack_type(container, child) == pack_type) {
      FlValue* child_args = fl_value_get_list_value(args, i++);
      widget_update(self, child, child_args);
    }
    it = g_list_next(it);
  }
  g_list_free(children);
}

static void widget_update(GtkHeaderBarPlugin* self, GtkWidget* widget,
                          FlValue* args) {
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
    FlValue* popup_args = fl_value_lookup_string(args, "popup");
    if (fl_value_is_valid(popup_args, FL_VALUE_TYPE_MAP)) {
      GtkMenu* popup = gtk_menu_button_get_popup(GTK_MENU_BUTTON(widget));
      widget_update(self, GTK_WIDGET(popup), popup_args);
    }
  }

  if (GTK_IS_CONTAINER(widget)) {
    FlValue* children = fl_value_lookup_string(args, "children");
    if (fl_value_is_valid(children, FL_VALUE_TYPE_LIST)) {
      container_update_all(self, GTK_CONTAINER(widget), children,
                           GtkPackType(-1));
    }
  }

  if (GTK_IS_MENU_ITEM(widget)) {
    FlValue* label = fl_value_lookup_string(args, "label");
    if (fl_value_is_valid(label, FL_VALUE_TYPE_STRING)) {
      gtk_menu_item_set_label(GTK_MENU_ITEM(widget),
                              fl_value_get_string(label));
    }

    FlValue* submenu_args = fl_value_lookup_string(args, "submenu");
    if (fl_value_is_valid(submenu_args, FL_VALUE_TYPE_MAP)) {
      GtkWidget* submenu = gtk_menu_item_get_submenu(GTK_MENU_ITEM(widget));
      widget_update(self, submenu, submenu_args);
    }
  }

  if (GTK_IS_ENTRY(widget)) {
    FlValue* text = fl_value_lookup_string(args, "text");
    if (fl_value_is_valid(text, FL_VALUE_TYPE_STRING)) {
      gtk_entry_set_text(GTK_ENTRY(widget), fl_value_get_string(text));
    }
  }

  if (GTK_IS_HEADER_BAR(widget)) {
    FlValue* title = fl_value_lookup_string(args, "title");
    if (fl_value_is_valid(title, FL_VALUE_TYPE_STRING)) {
      gtk_header_bar_set_title(GTK_HEADER_BAR(widget),
                               fl_value_get_string(title));
    }

    FlValue* subtitle = fl_value_lookup_string(args, "subtitle");
    if (fl_value_is_valid(subtitle, FL_VALUE_TYPE_STRING)) {
      gtk_header_bar_set_subtitle(GTK_HEADER_BAR(widget),
                                  fl_value_get_string(subtitle));
    }

    FlValue* show_close_button =
        fl_value_lookup_string(args, "showCloseButton");
    if (fl_value_is_valid(show_close_button, FL_VALUE_TYPE_BOOL)) {
      gtk_header_bar_set_show_close_button(
          GTK_HEADER_BAR(widget), fl_value_get_bool(show_close_button));
    }

    FlValue* decoration_layout =
        fl_value_lookup_string(args, "decorationLayout");
    if (fl_value_is_valid(decoration_layout, FL_VALUE_TYPE_STRING)) {
      gtk_header_bar_set_decoration_layout(
          GTK_HEADER_BAR(widget), fl_value_get_string(decoration_layout));
    }

    FlValue* start = fl_value_lookup_string(args, "start");
    if (fl_value_is_valid(start, FL_VALUE_TYPE_LIST)) {
      container_update_all(self, GTK_CONTAINER(widget), start, GTK_PACK_START);
    }

    FlValue* end = fl_value_lookup_string(args, "end");
    if (fl_value_is_valid(end, FL_VALUE_TYPE_LIST)) {
      container_update_all(self, GTK_CONTAINER(widget), end, GTK_PACK_END);
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

static gboolean header_bar_is_initialized(GtkWidget* header_bar) {
  gpointer initialized =
      g_object_get_data(G_OBJECT(header_bar), "gtk_header_bar_plugin");
  return GPOINTER_TO_INT(initialized) == TRUE;
}

static void header_bar_set_initialized(GtkWidget* header_bar, gboolean init) {
  g_object_set_data(G_OBJECT(header_bar), "gtk_header_bar_plugin",
                    GINT_TO_POINTER(init));
}

static void header_bar_update(GtkHeaderBarPlugin* self, FlValue* args) {
  GtkWidget* window = window_get(self);
  g_return_if_fail(window);

  GtkWidget* header_bar = gtk_window_get_titlebar(GTK_WINDOW(window));
  self->rebuild = TRUE;
  if (!header_bar_is_initialized(header_bar)) {
    widget_init(self, header_bar, args);
    header_bar_set_initialized(header_bar, TRUE);
  }
  widget_update(self, header_bar, args);
  self->rebuild = FALSE;
}

static void gtk_header_bar_plugin_handle_method_call(
    GtkHeaderBarPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "updateHeaderBar") == 0) {
    header_bar_update(self, args);
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

  G_OBJECT_CLASS(gtk_header_bar_plugin_parent_class)->dispose(object);
}

static void init_gtk_types() {
  g_type_ensure(GTK_TYPE_BUTTON);
  g_type_ensure(GTK_TYPE_CHECK_BUTTON);
  g_type_ensure(GTK_TYPE_CONTAINER);
  g_type_ensure(GTK_TYPE_ENTRY);
  g_type_ensure(GTK_TYPE_HEADER_BAR);
  g_type_ensure(GTK_TYPE_MENU);
  g_type_ensure(GTK_TYPE_MENU_BUTTON);
  g_type_ensure(GTK_TYPE_MENU_ITEM);
  g_type_ensure(GTK_TYPE_TOGGLE_BUTTON);
}

static void gtk_header_bar_plugin_class_init(GtkHeaderBarPluginClass* klass) {
  init_gtk_types();
  G_OBJECT_CLASS(klass)->dispose = gtk_header_bar_plugin_dispose;
}

static void gtk_header_bar_plugin_init(GtkHeaderBarPlugin* self) {
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
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "gtk_header_bar", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
