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
      'type': widget.runtimeType.toString(),
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

  GtkWidget? _findChild(List<GtkWidget>? children, Map args) {
    final index = args['index'] as int;
    final type = args['type'] as String;
    final child = children?.getOrNull(index);
    assert(child?.runtimeType.toString() == type);
    return child;
  }

  GtkWidget? _findWidget(Iterable path) {
    List<GtkWidget>? children = <GtkWidget>[
      ...?widget.start,
      ...?widget.end,
    ];
    GtkWidget? child;
    for (final args in path) {
      child = _findChild(children, args);
      if (child is GtkContainer) {
        children = child.children;
      } else if (child is GtkMenuButton) {
        children = <GtkWidget>[if (child.popup != null) child.popup!];
      } else if (child is GtkMenuItem) {
        children = <GtkWidget>[if (child.submenu != null) child.submenu!];
      } else {
        throw UnimplementedError();
      }
    }
    return child;
  }

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      final child = _findWidget(call.arguments['path']);
      switch (call.method) {
        case 'buttonClicked':
          (child as GtkButton?)?.onClicked?.call();
          break;
        case 'buttonToggled':
          final active = call.arguments['active'] as bool;
          (child as GtkToggleButton?)?.onToggled?.call(active);
          break;
        case 'entryActivate':
          final text = call.arguments['text'] as String;
          (child as GtkEntry?)?.onActivate?.call(text);
          break;
        case 'menuItemActivate':
          (child as GtkMenuItem?)?.onActivate?.call();
          break;
        default:
          throw UnimplementedError(call.method);
      }
    });
    _channel.invokeMethod<void>('updateHeaderBar', toJson());
  }

  @override
  void didUpdateWidget(GtkHeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _channel.invokeMethod<void>('updateHeaderBar', toJson());
  }

  @override
  void dispose() {
    super.dispose();
    _channel.invokeMethod<void>('updateHeaderBar');
  }
}

extension _NullableList<T> on List<T> {
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
