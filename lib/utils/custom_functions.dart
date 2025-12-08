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
    // print('YAML Document: $yamlDoc');
    // print('Image size: $imageSize');
    // print('Description: $desc');
  });
  return imageSize;
}

Future<bool> checkFolderExists(String assetPath) async {
  final String path;
  if (Platform.isAndroid) {
    path = '${(await getApplicationCacheDirectory()).path}/$assetPath';
  } else {
    path = '${(await getApplicationDocumentsDirectory()).path}/$assetPath';
  }
  final directory = Directory(path);
  bool exists = await directory.exists();
  if (!exists) {
    return false;
  } else {
    return true;
  }
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

Future<String> exchangeFirebaseToken(String idToken) async {
  const supabaseUrl = "https://oiauibxmhhhctsnrlenb.supabase.co";
  const supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pYXVpYnhtaGhoY3RzbnJsZW5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNjE5MzksImV4cCI6MjA3NTgzNzkzOX0.K6DaB_uC80qhkBJwJPEmlvGXYSEg8BMcaT3eXSkptP0";

  final url = Uri.parse('$supabaseUrl/functions/v1/exchange-firebase-token');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'apikey': supabaseAnonKey,
      'Authorization': 'Bearer $supabaseAnonKey',
    },
    body: jsonEncode({'idToken': idToken}),
  );

  if (response.statusCode != 200) {
    throw Exception('Edge Function error: ${response.body}');
  }

  final rpcData = jsonDecode(response.body);
  if (rpcData['refresh_token'] == null) {
    throw Exception('No Supabase token returned');
  }

  debugPrint('Supabase token: ${rpcData['refresh_token']}');

  return rpcData['refresh_token'];
}
