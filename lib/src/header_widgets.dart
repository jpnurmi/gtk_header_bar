import 'dart:ui';

import 'package:flutter/foundation.dart';

class GtkStyleContext {
  const GtkStyleContext({
    this.foregroundColor,
    this.backgroundColor,
  });

  final Color? foregroundColor;
  final Color? backgroundColor;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'foregroundColor': foregroundColor?.value,
      'backgroundColor': backgroundColor?.value,
    };
  }
}

class GtkWidget {
  const GtkWidget({
    this.visible,
    this.sensitive,
    this.styleContext,
  });

  final bool? visible;
  final bool? sensitive;
  final GtkStyleContext? styleContext;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': runtimeType.toString(),
      'visible': visible,
      'sensitive': sensitive,
      'styleContext': styleContext?.toJson(),
    };
  }
}

class GtkButton extends GtkWidget {
  const GtkButton({
    this.label,
    this.onClicked,
    bool? visible,
    bool? sensitive,
    GtkStyleContext? styleContext,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          styleContext: styleContext,
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
    String? label,
    this.active,
    this.onToggled,
    bool? visible,
    bool? sensitive,
    GtkStyleContext? styleContext,
  }) : super(
          label: label,
          visible: visible,
          sensitive: sensitive,
          styleContext: styleContext,
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
    String? label,
    bool? active,
    ValueChanged<bool>? onToggled,
    bool? visible,
    bool? sensitive,
    GtkStyleContext? styleContext,
  }) : super(
          label: label,
          active: active,
          onToggled: onToggled,
          visible: visible,
          sensitive: sensitive,
          styleContext: styleContext,
        );
}

class GtkEntry extends GtkWidget {
  const GtkEntry({
    this.text,
    this.onActivate,
    bool? visible,
    bool? sensitive,
    GtkStyleContext? styleContext,
  }) : super(
          visible: visible,
          sensitive: sensitive,
          styleContext: styleContext,
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
