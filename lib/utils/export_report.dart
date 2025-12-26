import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pothole_detection_app/db/road_sensor_db.dart';
import 'package:pothole_detection_app/model/sensor_data.dart';
import 'package:pothole_detection_app/utils/indicators.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/pothole_data_model.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class ExportPassportHelper {
  // static Future<void> exportCSV() async {
  //   final potholes = await PotholeDatabase.getAllPotholes();
  //
  //   if (potholes.isEmpty) {
  //     CustomSnackBar().SnackBarMessage("No data to export");
  //     return;
  //   }
  //
  //   // Prepare CSV data
  //   List<List<dynamic>> csvData = [
  //     [
  //       'ID',
  //       'Latitude',
  //       'Longitude',
  //       'Speed (km/h)',
  //       'Severity',
  //       'Timestamp',
  //       'Image',
  //     ],
  //   ];
  //
  //   for (final p in potholes) {
  //     csvData.add([
  //       p.id ?? 0,
  //       p.latitude,
  //       p.longitude,
  //       p.speedKmh,
  //       p.severity,
  //       p.timestamp.toIso8601String(),
  //       p.imagePath ?? '',
  //     ]);
  //   }
  //
  //   String csv = const ListToCsvConverter().convert(csvData);
  //
  //   // ✅ Use FileSaver with explicit extension
  //   final bytes = utf8.encode(csv);
  //   final result = await FileSaver.instance.saveAs(
  //     name: "pothole_report",
  //     bytes: bytes,
  //     fileExtension: 'csv',
  //     mimeType: MimeType.csv,
  //   );
  //
  //   if (result != null) {
  //     CustomSnackBar().SnackBarMessage("CSV saved successfully to $result");
  //   }
  // }

  static Future<void> exportCSVWithImages() async {
    /// Export CSV for Pothole Metadata + Images
    final potholes = await PotholeDatabase.getAllPotholes();

    if (potholes.isEmpty) {
      CustomSnackBar().SnackBarMessage("No data to export");
      return;
    }

    // Prepare CSV data
    List<List<dynamic>> csvData = [
      [
        'ID',
        'Latitude',
        'Longitude',
        'Speed (km/h)',
        'Severity',
        'Timestamp',
        'Image',
      ],
    ];

    for (final p in potholes) {
      csvData.add([
        p.id ?? 0,
        p.latitude,
        p.longitude,
        p.speedKmh,
        p.severity,
        p.timestamp.toIso8601String(),
        path.basename(p.imagePath) ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    Uint8List csvBytes = Uint8List.fromList(utf8.encode(csv));

    /// Export CSV for Sensor Data
    final sensorData = await RoadSensorDB.getSensorData();

    List<List<dynamic>> csvDataForSensors = [
      [
        'ID',
        'Latitude',
        'Longitude',
        'Speed (km/h)',
        'Timestamp',
        'Accel X',
        'Accel Y',
        'Accel Z',
        'Gyro X',
        'Gyro Y',
        'Gyro Z',
      ],
    ];

    for (final p in sensorData) {
      csvDataForSensors.add([
        p.id ?? 0,
        p.latitude,
        p.longitude,
        p.speedKmh,
        p.timestampUs,
        p.accelX,
        p.accelY,
        p.accelZ,
        p.gyroX,
        p.gyroY,
        p.gyroZ,
      ]);
    }

    String csvFromSensors = const ListToCsvConverter().convert(
      csvDataForSensors,
    );
    Uint8List csvBytesFromSensors = Uint8List.fromList(
      utf8.encode(csvFromSensors),
    );

    // Create ZIP archive
    final encoder = ZipEncoder();
    final archive = Archive();

    // Add CSV to ZIP
    archive.addFile(
      ArchiveFile('pothole_report.csv', csvBytes.lengthInBytes, csvBytes),
    );
    archive.addFile(
      ArchiveFile(
        'sensor_data_report.csv',
        csvBytesFromSensors.lengthInBytes,
        csvBytesFromSensors,
      ),
    );

    // Add images to ZIP
    for (final p in potholes) {
      final imagePath = p.imagePath;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          await File(imagePath).exists()) {
        final imageBytes = await File(imagePath).readAsBytes();
        final fileName = path.basename(
          imagePath,
        ); // Extracts just filename like "pothole_1766148631633.jpg"
        archive.addFile(
          ArchiveFile('images/$fileName', imageBytes.lengthInBytes, imageBytes),
        );
      }
    }

    // Encode ZIP bytes
    final zipBytes = encoder.encode(archive)!;
    final bytes = Uint8List.fromList(zipBytes);

    // Save ZIP using FileSaver
    final result = await FileSaver.instance.saveAs(
      name: "pothole_report",
      bytes: bytes,
      fileExtension: 'zip',
      mimeType: MimeType.other,
    );

    if (result != null) {
      CustomSnackBar().SnackBarMessage(
        "ZIP saved successfully to $result (contains CSV + images)",
      );
    }
  }

  static Future<void> exportExcel() async {
    final potholes = await PotholeDatabase.getAllPotholes();

    if (potholes.isEmpty) {
      CustomSnackBar().SnackBarMessage("No data to export");
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Potholes'];

    // Header row
    sheet.appendRow([
      TextCellValue("ID"),
      TextCellValue("Latitude"),
      TextCellValue("Longitude"),
      TextCellValue("Speed (km/h)"),
      TextCellValue("Severity"),
      TextCellValue("Timestamp"),
      TextCellValue("Image"),
    ]);

    // Data rows
    for (final p in potholes) {
      sheet.appendRow([
        IntCellValue(p.id ?? 0),
        DoubleCellValue(p.latitude),
        DoubleCellValue(p.longitude),
        DoubleCellValue(p.speedKmh),
        IntCellValue(p.severity),
        TextCellValue(p.timestamp.toIso8601String()),
        TextCellValue(p.imagePath ?? ''),
      ]);
    }

    // ✅ FIXED: Convert List<int> to Uint8List
    final bytesList = excel.encode()!;
    final bytes = Uint8List.fromList(bytesList);

    final result = await FileSaver.instance.saveAs(
      name: "pothole_report",
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    if (result != null) {
      CustomSnackBar().SnackBarMessage("Excel saved successfully to $result");
    }
  }

  static Future<void> exportPDF() async {
    final potholes = await PotholeDatabase.getAllPotholes();

    if (potholes.isEmpty) {
      CustomSnackBar().SnackBarMessage("No data to export");
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Text(
                "Pothole Report",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Table.fromTextArray(
                headers: [
                  "ID",
                  "Latitude",
                  "Longitude",
                  "Speed",
                  "Severity",
                  "Time",
                ],
                data:
                    potholes.map((p) {
                      return [
                        p.id.toString(),
                        p.latitude.toStringAsFixed(5),
                        p.longitude.toStringAsFixed(5),
                        "${p.speedKmh} km/h",
                        p.severity.toString(),
                        p.timestamp,
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
                headerDecoration: const pw.BoxDecoration(),
              ),
            ],
      ),
    );

    // ✅ Use FileSaver with explicit extension
    final bytes = await pdf.save();
    final result = await FileSaver.instance.saveAs(
      name: "pothole_report",
      bytes: bytes,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );

    if (result != null) {
      CustomSnackBar().SnackBarMessage("PDF saved successfully to $result");
    }
  }

  static Future<void> exportExcelWithImageLink() async {
    final potholes = await PotholeDatabase.getAllPotholes();

    if (potholes.isEmpty) {
      CustomSnackBar().SnackBarMessage("No data to export");
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Potholes'];

    sheet.appendRow([
      TextCellValue("ID"),
      TextCellValue("Latitude"),
      TextCellValue("Longitude"),
      TextCellValue("Speed (km/h)"),
      TextCellValue("Severity"),
      TextCellValue("Timestamp"),
      TextCellValue("Image"),
    ]);

    for (final p in potholes) {
      final imagePath = p.imagePath ?? '';

      final cell = TextCellValue(
        imagePath.isNotEmpty ? 'View Image' : 'No Image',
      );

      sheet.appendRow([
        IntCellValue(p.id ?? 0),
        DoubleCellValue(p.latitude),
        DoubleCellValue(p.longitude),
        DoubleCellValue(p.speedKmh),
        IntCellValue(p.severity),
        TextCellValue(p.timestamp.toIso8601String()),
        cell,
      ]);

      // Add hyperlink if image exists
      if (imagePath.isNotEmpty) {
        final rowIndex = sheet.maxRows - 1;
        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
            )
            .value = FormulaCellValue('HYPERLINK("$imagePath","View Image")');
      }
    }

    final bytes = Uint8List.fromList(excel.encode()!);

    await FileSaver.instance.saveAs(
      name: "pothole_report",
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    CustomSnackBar().SnackBarMessage("Excel saved with image links");
  }
}
