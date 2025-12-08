// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class FileDownload {
//   final supabase = Supabase.instance.client;
//   bool isSuccess = false;
//   num myReceivedBytes = 0;
//   num myTotalBytes = 0;
//
//   Future startDownloading({
//     required BuildContext context,
//     required Function okCallback, // (completedFiles, totalFiles)
//     String? folderName,
//     String? modelFileName,
//     String? modelDownloadLink,
//     String? metadataFileName,
//     String? metadataDownloadLink,
//     String? mlModelFileName,
//     String? mlModelDownloadLink,
//   }) async {
//     try {
//       final List<Future<void>> tasks = [];
//
//       final List<_DownloadItem> files = [
//         if (modelFileName != null && modelDownloadLink != null)
//           _DownloadItem(modelFileName, modelDownloadLink),
//         if (metadataFileName != null && metadataDownloadLink != null)
//           _DownloadItem(metadataFileName, metadataDownloadLink),
//         if (mlModelFileName != null && mlModelDownloadLink != null)
//           _DownloadItem(mlModelFileName, mlModelDownloadLink),
//       ];
//
//       if (files.isEmpty) {
//         throw Exception("No files to download.");
//       }
//
//       int completedFiles = 0;
//       int totalFiles = files.length;
//
//       for (final item in files) {
//         tasks.add(
//           _downloadFileFromSupabase(
//             supabaseUrl: item.path,
//             localFileName: item.name,
//             folderName: folderName,
//             onComplete: (filePath, size) {
//               completedFiles++;
//               okCallback(completedFiles, totalFiles);
//               debugPrint("✅ Downloaded $filePath ($size bytes)");
//             },
//           ),
//         );
//       }
//
//       await Future.wait(tasks);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ All files downloaded successfully.")),
//       );
//     } catch (e) {
//       debugPrint("❌ Download failed: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading files: $e")),
//       );
//       rethrow;
//     }
//   }
//
//   /// Download a single asset file
//   Future startDownloadingAsset({
//     required BuildContext context,
//     required String assetFileName,
//     required String assetDownloadLink,
//     String? folderName,
//     Function(String filePath, int size)? onComplete,
//   }) async {
//     try {
//       final filePath = await _downloadFileFromSupabase(
//         supabaseUrl: assetDownloadLink,
//         localFileName: assetFileName,
//         folderName: folderName,
//         onComplete: onComplete ??
//             (path, size) {
//               debugPrint("✅ Asset downloaded: $path ($size bytes)");
//             },
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Asset downloaded: filePath}")),
//       );
//     } catch (e) {
//       debugPrint("⚠️ Error downloading asset: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error downloading asset: $e")),
//       );
//       rethrow;
//     }
//   }
//
//   Future<void> _downloadFileFromSupabase({
//     required String supabaseUrl,
//     required String localFileName,
//     required String? folderName,
//     required Function(String filePath, int size) onComplete,
//   }) async {
//     try {
//       // ✅ Extract bucket name and relative file path from full URL
//       final regex = RegExp(r'/storage/v1/object/public/([^/]+)/(.+)$');
//       final match = regex.firstMatch(supabaseUrl);
//       if (match == null) {
//         throw Exception("Invalid Supabase storage URL: $supabaseUrl");
//       }
//
//       final bucketName = match.group(1)!;
//       final filePathInBucket = match.group(2)!;
//
//       debugPrint("📦 Bucket: $bucketName");
//       debugPrint("📄 File path: $filePathInBucket");
//
//       // Download the file using Supabase
//       final Uint8List fileData =
//           await supabase.storage.from(bucketName).download(filePathInBucket);
//
//       // Create folder & save file locally
//       final filePath =
//           await _getFilePath(filename: localFileName, folderName: folderName);
//       final file = File(filePath);
//       await file.create(recursive: true);
//       await file.writeAsBytes(fileData);
//
//       onComplete(filePath, fileData.length);
//     } catch (e) {
//       debugPrint("⚠️ Error downloading $localFileName: $e");
//       rethrow;
//     }
//   }
//
//   Future<String> _getFilePath({
//     required String filename,
//     String? folderName,
//   }) async {
//     Directory dir;
//     if (Platform.isIOS) {
//       dir = await getApplicationDocumentsDirectory();
//     } else {
//       dir = await getApplicationCacheDirectory();
//     }
//
//     final folderPath =
//         folderName == null || folderName.isEmpty ? "default" : folderName;
//
//     return "${dir.path}/$folderPath/$filename";
//   }
// }
//
// class _DownloadItem {
//   final String name;
//   final String path;
//   _DownloadItem(this.name, this.path);
// }

import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileDownload {
  final supabase = Supabase.instance.client;
  final Dio dio = Dio();

  /// Download multiple files in parallel
  // Future<void> startDownloading({
  //   required BuildContext context,
  //   required Function(int receivedBytes, int totalBytes) okCallback,
  //   String? folderName,
  //   String? modelFileName,
  //   String? modelDownloadLink,
  //   String? metadataFileName,
  //   String? metadataDownloadLink,
  //   String? mlModelFileName,
  //   String? mlModelDownloadLink,
  // }) async {
  //   try {
  //     final List<_DownloadItem> files = [
  //       if (modelFileName != null && modelDownloadLink != null)
  //         _DownloadItem(modelFileName, modelDownloadLink),
  //       if (metadataFileName != null && metadataDownloadLink != null)
  //         _DownloadItem(metadataFileName, metadataDownloadLink),
  //       if (mlModelFileName != null && mlModelDownloadLink != null)
  //         _DownloadItem(mlModelFileName, mlModelDownloadLink),
  //     ];
  //
  //     if (files.isEmpty) throw Exception("No files to download.");
  //
  //     // Start parallel downloads
  //     final tasks = files.map((item) async {
  //       await _downloadFileWithSignedUrl(
  //         supabaseUrl: item.path,
  //         localFileName: item.name,
  //         folderName: folderName,
  //         okCallback: okCallback,
  //       );
  //     }).toList();
  //
  //     await Future.wait(tasks);
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("✅ All files downloaded successfully.")),
  //     );
  //   } catch (e) {
  //     debugPrint("❌ Download failed: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error downloading files: $e")),
  //     );
  //     rethrow;
  //   }
  // }
  Future<void> startDownloading({
    required BuildContext context,
    required Function(int receivedBytes, int totalBytes)
        okCallback, // per-file progress
    String? folderName,
    String? modelFileName,
    String? modelDownloadLink,
    String? metadataFileName,
    String? metadataDownloadLink,
    String? mlModelFileName,
    String? mlModelDownloadLink,
  }) async {
    try {
      final List<_DownloadItem> files = [
        if (modelFileName != null && modelDownloadLink != null)
          _DownloadItem(modelFileName, modelDownloadLink),
        if (metadataFileName != null && metadataDownloadLink != null)
          _DownloadItem(metadataFileName, metadataDownloadLink),
        if (mlModelFileName != null && mlModelDownloadLink != null)
          _DownloadItem(mlModelFileName, mlModelDownloadLink),
      ];

      if (files.isEmpty) throw Exception("No files to download.");

      // Start parallel downloads
      final tasks = files.map((item) async {
        await _downloadFileWithSignedUrl(
          supabaseUrl: item.path,
          localFileName: item.name,
          folderName: folderName,
          okCallback: okCallback,
        );
      }).toList();

      await Future.wait(tasks);

      debugPrint("✅ All files downloaded successfully.");
    } catch (e) {
      debugPrint("❌ Download failed: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error downloading files: $e")),
      // );
      rethrow;
    }
  }

  /// Download a single asset file
  Future<void> startDownloadingAsset({
    required BuildContext context,
    required String assetFileName,
    required String assetDownloadLink,
    String? folderName,
  }) async {
    try {
      String? fileName1 = assetFileName;
      String? baseUrl1 = assetDownloadLink;
      String? path1;
      if (fileName1 != null) {
        path1 = await _getFilePath(fileName1, folderName);
        await dio.download(
          "${const String.fromEnvironment('supabase_url')}$baseUrl1",
          path1,
          onReceiveProgress: (receivedBytes, totalBytes) {
            // receivedBytes = okCallback(receivedBytes, totalBytes);
          },
          deleteOnError: true,
        );
      }
    } catch (e) {
      // print("Exception $e");
      rethrow;
    }
  }

  /// Download a file using signed URL with Dio
  Future<void> _downloadFileWithSignedUrl({
    required String supabaseUrl,
    required String localFileName,
    String? folderName,
    required Function(int receivedBytes, int totalBytes) okCallback,
  }) async {
    try {
      final bucketName = _extractBucketName(supabaseUrl);
      final filePathInBucket = _extractFilePathInBucket(supabaseUrl);

      // Generate signed URL valid for 5 minutes
      final signedUrl = await supabase.storage
          .from(bucketName)
          .createSignedUrl(filePathInBucket, 300);
      log('🔗 Signed URL: $signedUrl');
      if (signedUrl == null) throw Exception("Failed to create signed URL");

      // Local path
      final localPath = await _getFilePath(localFileName, folderName);

      // Download with byte-level progress
      await dio.download(
        signedUrl,
        localPath,
        onReceiveProgress: okCallback,
        deleteOnError: true,
      );
    } catch (e) {
      debugPrint("⚠️ Error downloading $localFileName: $e");
      rethrow;
    }
  }

  /// Extract bucket name from Supabase storage URL
  String _extractBucketName(String url) {
    // Optional leading slash, then storage/v1/object/public/<bucket>/
    final regex = RegExp(r'^/?storage/v1/object/public/([^/]+)/');
    final match = regex.firstMatch(url);
    if (match == null) throw Exception("Invalid Supabase storage URL: $url");
    return match.group(1)!; // bucket name
  }

  /// Extract file path inside bucket from Supabase storage URL
  String _extractFilePathInBucket(String url) {
    final regex = RegExp(r'^/?storage/v1/object/public/[^/]+/(.+)$');
    final match = regex.firstMatch(url);
    if (match == null) throw Exception("Invalid Supabase storage URL: $url");
    return match.group(1)!; // file path inside bucket
  }

  /// Local path for saving downloaded file
  Future<String> _getFilePath(String filename, String? folderName) async {
    Directory dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationCacheDirectory();
    }

    final folderPath =
        folderName == null || folderName.isEmpty ? "default" : folderName;

    return "${dir.path}/$folderPath/$filename";
  }
}

class _DownloadItem {
  final String name;
  final String path;
  _DownloadItem(this.name, this.path);
}
