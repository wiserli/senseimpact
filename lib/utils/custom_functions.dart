import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import "package:yaml/yaml.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../res/constants.dart';

Future<String> copy({required String assetPath, String? folderName}) async {
  final String path;
  String folderPath;
  if (folderName == null || folderName == "" || folderName.isEmpty) {
    folderPath = "default";
  } else {
    folderPath = folderName;
  }
  if (Platform.isAndroid) {
    path =
        '${(await getApplicationCacheDirectory()).path}/$folderPath/$assetPath';
  } else {
    path =
        '${(await getApplicationDocumentsDirectory()).path}/$folderPath/$assetPath';
  }
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
  }
  print('file.path is ${file.path}');
  return file.path;
}

// This functions reads the yaml file from local storage and give the values
Future<int> readMetadataYamlImageSize(String filePath) async {
  int imageSize = initialInputSize;
  await readFile(filePath).then((contents) {
    var yamlDoc = loadYamlDocument(contents);
    String desc = yamlDoc.contents.value['description'];
    imageSize = yamlDoc.contents.value['imgsz'][0];
  });
  return imageSize;
}

Future<String> readFile(String filePath) async {
  try {
    File file = File(filePath);
    // Read the file
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    // Error reading the file
    print("Error reading file: $e");
    return 'NULL';
  }
}
