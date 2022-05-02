import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class FileHelper {
  static Future<dynamic> readDataFrom<T>(String filePath) async {
    var str = await rootBundle.loadString('assets/' + filePath);
    final data = json.decode(str);
    return data;
  }

  static Future<String> readFromAssetsAsString(String filePath) {
    return rootBundle.loadString('assets/' + filePath);
  }

  static Stream<List<int>> readFromAssetsAsBytes(String filePath) {
    File file = File('assets' + filePath);
    Stream<List<int>> futureContent = file.openRead();
    return futureContent;
  }
}