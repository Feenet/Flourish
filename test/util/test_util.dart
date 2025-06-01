import 'dart:convert';

import 'package:flutter/services.dart';

class TestUtil {
  static Future<Map<String, dynamic>> loadJsonFromAssets(
      String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return json.decode(jsonString);
  }
}
