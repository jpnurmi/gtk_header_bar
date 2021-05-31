import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@immutable
class GtkWidget {
  const GtkWidget();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
    };
  }
}

@immutable
class GtkButton extends GtkWidget {
  const GtkButton({this.label, this.onClicked});

  final String? label;
  final VoidCallback? onClicked;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'label': label,
    };
  }
}

@immutable
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
    switch (call.method) {
      case 'buttonClicked':
        switch (call.arguments.first as String) {
          case 'start':
            final button =
                headerBar.start?[call.arguments.last as int] as GtkButton?;
            button?.onClicked?.call();
            break;
          case 'end':
            final button =
                headerBar.end?[call.arguments.last as int] as GtkButton?;
            button?.onClicked?.call();
            break;
        }
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
