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
