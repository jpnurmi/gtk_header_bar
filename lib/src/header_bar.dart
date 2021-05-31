import 'dart:async';

import 'package:flutter/services.dart';

import 'header_widgets.dart';

class GtkHeaderBar {
  const GtkHeaderBar({
    this.title,
    this.subtitle,
    this.showCloseButton,
    this.decorationLayout,
    this.start,
    this.end,
  });

  final String? title;
  final String? subtitle;
  final bool? showCloseButton;
  final String? decorationLayout;
  final List<GtkWidget>? start;
  final List<GtkWidget>? end;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'showCloseButton': showCloseButton,
      'decorationLayout': decorationLayout,
      'start': start?.map((widget) => widget.toJson()).toList(),
      'end': end?.map((widget) => widget.toJson()).toList(),
    };
  }
}

const MethodChannel _channel = MethodChannel('gtk_header_bar');

Future<void> setGtkHeaderBar(GtkHeaderBar headerBar) async {
  _channel.setMethodCallHandler((call) async {
    final packing = call.arguments.first as String;
    final index = call.arguments[1] as int;
    final widget = packing == 'start'
        ? headerBar.start?.getOrNull(index)
        : headerBar.end?.getOrNull(index);

    switch (call.method) {
      case 'buttonClicked':
        (widget as GtkButton).onClicked?.call();
        break;
      case 'buttonToggled':
        final value = call.arguments.last as bool;
        (widget as GtkToggleButton).onToggled?.call(value);
        break;
      case 'entryActivate':
        final value = call.arguments.last as String;
        (widget as GtkEntry).onActivate?.call(value);
        break;
      default:
        throw UnimplementedError(call.method);
    }
  });

  return _channel.invokeMethod<void>(
    'setHeaderBar',
    headerBar.toJson(),
  );
}

extension _NullableList<T> on List<T> {
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
