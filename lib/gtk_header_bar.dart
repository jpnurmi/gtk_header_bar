
import 'dart:async';

import 'package:flutter/services.dart';

class GtkHeaderBar {
  static const MethodChannel _channel = MethodChannel('gtk_header_bar');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
