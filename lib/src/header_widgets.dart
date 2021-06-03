import 'dart:ui';

import 'package:flutter/foundation.dart';

class GtkWidget {
  const GtkWidget({
    this.key,
    this.visible,
    this.sensitive,
  });

  final Key? key;
  final bool? visible;
  final bool? sensitive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
      'key': key?.toString(),
      'visible': visible,
      'sensitive': sensitive,
    };
  }
}

class GtkButton extends GtkWidget {
  const GtkButton({
    Key? key,
    bool? visible,
    bool? sensitive,
    this.label,
    this.onClicked,
  }) : super(
          key: key,
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
    Key? key,
    bool? visible,
    bool? sensitive,
    String? label,
    this.active,
    this.onToggled,
  }) : super(
          key: key,
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
    Key? key,
    bool? visible,
    bool? sensitive,
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
  }) : super(
          key: key,
          visible: visible,
          sensitive: sensitive,
          label: label,
          active: active,
          onToggled: onToggled,
        );
}

class GtkMenuButton extends GtkToggleButton {
  const GtkMenuButton({
    Key? key,
    bool? visible,
    bool? sensitive,
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
    this.popup,
  }) : super(
          key: key,
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
    Key? key,
    bool? visible = false,
    bool? sensitive,
    this.children,
  }) : super(
          key: key,
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

class GtkMenu extends GtkContainer {
  const GtkMenu({
    Key? key,
    bool? visible = false,
    bool? sensitive,
    List<GtkWidget>? children,
  }) : super(
          key: key,
          visible: visible,
          sensitive: sensitive,
          children: children,
        );
}

class GtkMenuItem extends GtkWidget {
  const GtkMenuItem({
    Key? key,
    bool? visible,
    bool? sensitive,
    this.label,
    this.onActivate,
  }) : super(
          key: key,
          visible: visible,
          sensitive: sensitive,
        );

  final String? label;
  final VoidCallback? onActivate;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'label': label,
    };
  }
}

class GtkEntry extends GtkWidget {
  const GtkEntry({
    Key? key,
    bool? visible,
    bool? sensitive,
    this.text,
    this.onActivate,
  }) : super(
          key: key,
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
