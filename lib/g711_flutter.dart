
import 'dart:async';

import 'package:flutter/services.dart';

class G711Flutter {
  static const MethodChannel _channel = MethodChannel('g711_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
