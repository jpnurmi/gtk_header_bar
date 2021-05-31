import 'dart:ui';

import 'package:flutter/foundation.dart';

class GtkWidget {
  const GtkWidget({this.visible, this.sensitive});

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

class GtkButton extends GtkWidget {
  const GtkButton({
    this.label,
    this.onClicked,
    bool? visible,
    bool? sensitive,
  }) : super(visible: visible, sensitive: sensitive);

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
    String? label,
    this.active,
    this.onToggled,
    bool? visible,
    bool? sensitive,
  }) : super(label: label, visible: visible, sensitive: sensitive);

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
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
    bool? visible,
    bool? sensitive,
  }) : super(
          label: label,
          active: active,
          onToggled: onToggled,
          visible: visible,
          sensitive: sensitive,
        );
}
