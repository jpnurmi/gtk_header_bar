import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'header_widgets.dart';

const MethodChannel _channel = MethodChannel('gtk_header_bar');

class GtkHeaderBar extends StatefulWidget {
  const GtkHeaderBar({
    Key? key,
    this.title,
    this.subtitle,
    this.showCloseButton,
    this.decorationLayout,
    this.start,
    this.end,
    this.child,
  }) : super(key: key);

  final String? title;
  final String? subtitle;
  final bool? showCloseButton;
  final String? decorationLayout;
  final List<GtkWidget>? start;
  final List<GtkWidget>? end;
  final Widget? child;

  @override
  State<GtkHeaderBar> createState() => _GtkHeaderBarState();
}

class _GtkHeaderBarState extends State<GtkHeaderBar> {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': widget.title,
      'subtitle': widget.subtitle,
      'showCloseButton': widget.showCloseButton,
      'decorationLayout': widget.decorationLayout,
      'start': widget.start?.map((widget) => widget.toJson()).toList(),
      'end': widget.end?.map((widget) => widget.toJson()).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      final packing = call.arguments.first as String;
      final index = call.arguments[1] as int;
      final child = packing == 'start'
          ? widget.start?.getOrNull(index)
          : widget.end?.getOrNull(index);

      switch (call.method) {
        case 'buttonClicked':
          (child as GtkButton).onClicked?.call();
          break;
        case 'buttonToggled':
          final value = call.arguments.last as bool;
          (child as GtkToggleButton).onToggled?.call(value);
          break;
        case 'entryActivate':
          final value = call.arguments.last as String;
          (child as GtkEntry).onActivate?.call(value);
          break;
        case 'menuItemActivate':
          (child as GtkMenuItem).onActivate?.call();
          break;
        default:
          throw UnimplementedError(call.method);
      }
    });
    _channel.invokeMethod<void>('setHeaderBar', toJson());
  }

  @override
  void didUpdateWidget(GtkHeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel.invokeMethod<void>('setHeaderBar', toJson());
  }
}

extension _NullableList<T> on List<T> {
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
