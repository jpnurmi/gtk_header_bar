import 'dart:ui';

import 'package:flutter/foundation.dart';

class GtkWidget {
  const GtkWidget({
    this.visible,
    this.sensitive,
  });

  final bool? visible;
  final bool? sensitive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
      'visible': visible,
      'sensitive': sensitive,
    };
  }
}

class GtkButton extends GtkBin {
  const GtkButton({
    bool? visible,
    bool? sensitive,
    this.label,
    this.onClicked,
  }) : super(
          visible: visible,
          sensitive: sensitive,
        );

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

class GtkToggleButton extends GtkButton {
  const GtkToggleButton({
    bool? visible,
    bool? sensitive,
    String? label,
    this.active,
    this.onToggled,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          label: label,
        );

  final bool? active;
  final ValueChanged<bool>? onToggled;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'active': active,
    };
  }
}

class GtkCheckButton extends GtkToggleButton {
  const GtkCheckButton({
    bool? visible,
    bool? sensitive,
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          label: label,
          active: active,
          onToggled: onToggled,
        );
}

class GtkMenuButton extends GtkToggleButton {
  const GtkMenuButton({
    bool? visible,
    bool? sensitive,
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
    this.popup,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          label: label,
          active: active,
          onToggled: onToggled,
        );

  final GtkWidget? popup;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'popup': popup?.toJson(),
    };
  }
}

abstract class GtkContainer extends GtkWidget {
  const GtkContainer({
    bool? visible = false,
    bool? sensitive,
    this.children,
  }) : super(
          visible: visible,
          sensitive: sensitive,
        );

  final List<GtkWidget>? children;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'children': children?.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class GtkBin extends GtkContainer {
  const GtkBin({
    bool? visible = false,
    bool? sensitive,
    this.child,
  }) : super(
          visible: visible,
          sensitive: sensitive,
        );

  final GtkWidget? child;
}

class GtkMenu extends GtkContainer {
  const GtkMenu({
    bool? visible = false,
    bool? sensitive,
    List<GtkWidget>? children,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          children: children,
        );
}

class GtkMenuItem extends GtkWidget {
  const GtkMenuItem({
    bool? visible,
    bool? sensitive,
    this.label,
    this.submenu,
    this.onActivate,
  }) : super(
          visible: visible,
          sensitive: sensitive,
        );

  final String? label;
  final GtkWidget? submenu;
  final VoidCallback? onActivate;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'label': label,
      'submenu': submenu?.toJson(),
    };
  }
}

class GtkEntry extends GtkWidget {
  const GtkEntry({
    bool? visible,
    bool? sensitive,
    this.text,
    this.onActivate,
  }) : super(
          visible: visible,
          sensitive: sensitive,
        );

  final String? text;
  final ValueChanged<String>? onActivate;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'text': text,
    };
  }
}

class GtkToolItem extends GtkBin {
  const GtkToolItem({
    bool? visible,
    bool? sensitive,
    GtkWidget? child,
    this.homogenous,
    this.expand,
    this.tooltipText,
    this.tooltipMarkup,
    this.useDragWindow,
    this.visibleHorizontal,
    this.visibleVertical,
    this.isImportant,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          child: child,
        );

  final bool? homogenous;
  final bool? expand;
  final String? tooltipText;
  final String? tooltipMarkup;
  final bool? useDragWindow;
  final bool? visibleHorizontal;
  final bool? visibleVertical;
  final bool? isImportant;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'homogenous': homogenous,
      'expand': expand,
      'tooltipText': tooltipText,
      'tooltipMarkup': tooltipMarkup,
      'useDragWindow': useDragWindow,
      'visibleHorizontal': visibleHorizontal,
      'visibleVertical': visibleVertical,
      'isImportant': isImportant,
    };
  }
}

class GtkSeparatorToolItem extends GtkToolItem {
  const GtkSeparatorToolItem({
    bool? visible,
    bool? sensitive,
    GtkWidget? child,
    bool? homogenous,
    bool? expand,
    String? tooltipText,
    String? tooltipMarkup,
    bool? useDragWindow,
    bool? visibleHorizontal,
    bool? visibleVertical,
    bool? isImportant,
    this.draw,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          child: child,
          homogenous: homogenous,
          expand: expand,
          tooltipText: tooltipText,
          tooltipMarkup: tooltipMarkup,
          useDragWindow: useDragWindow,
          visibleHorizontal: visibleHorizontal,
          visibleVertical: visibleVertical,
          isImportant: isImportant,
        );

  final bool? draw;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'draw': draw,
    };
  }
}

class GtkToolButton extends GtkToolItem {
  const GtkToolButton({
    bool? visible,
    bool? sensitive,
    GtkWidget? child,
    bool? homogenous,
    bool? expand,
    String? tooltipText,
    String? tooltipMarkup,
    bool? useDragWindow,
    bool? visibleHorizontal,
    bool? visibleVertical,
    bool? isImportant,
    this.label,
    this.useUnderline,
    this.stockId,
    this.iconName,
    this.iconWidget,
    this.labelWidget,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          child: child,
          homogenous: homogenous,
          expand: expand,
          tooltipText: tooltipText,
          tooltipMarkup: tooltipMarkup,
          useDragWindow: useDragWindow,
          visibleHorizontal: visibleHorizontal,
          visibleVertical: visibleVertical,
          isImportant: isImportant,
        );

  final String? label;
  final bool? useUnderline;
  final String? stockId;
  final String? iconName;
  final GtkWidget? iconWidget;
  final GtkWidget? labelWidget;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'label': label,
      'useUnderline': useUnderline,
      'stockId': stockId,
      'iconName': iconName,
      'iconWidget': iconWidget?.toJson(),
      'labelWidget': labelWidget?.toJson(),
    };
  }
}

class GtkToggleToolButton extends GtkToolButton {
  const GtkToggleToolButton({
    bool? visible,
    bool? sensitive,
    GtkWidget? child,
    bool? homogenous,
    bool? expand,
    String? tooltipText,
    String? tooltipMarkup,
    bool? useDragWindow,
    bool? visibleHorizontal,
    bool? visibleVertical,
    bool? isImportant,
    String? label,
    bool? useUnderline,
    String? stockId,
    String? iconName,
    GtkWidget? iconWidget,
    GtkWidget? labelWidget,
    this.active,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          child: child,
          homogenous: homogenous,
          expand: expand,
          tooltipText: tooltipText,
          tooltipMarkup: tooltipMarkup,
          useDragWindow: useDragWindow,
          visibleHorizontal: visibleHorizontal,
          visibleVertical: visibleVertical,
          isImportant: isImportant,
          label: label,
          useUnderline: useUnderline,
          stockId: stockId,
          iconName: iconName,
          iconWidget: iconWidget,
          labelWidget: labelWidget,
        );

  final bool? active;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'active': active,
    };
  }
}
