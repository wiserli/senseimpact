import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pothole_detection_app/db/pothole_data_model.dart';
import 'package:pothole_detection_app/model/potholes.dart';
import 'package:pothole_detection_app/utils/export_report.dart';

class ReportPreviewView extends StatefulWidget {
  const ReportPreviewView({super.key});

  @override
  State<ReportPreviewView> createState() => _ReportPreviewViewState();
}

class _ReportPreviewViewState extends State<ReportPreviewView> {
  final Set<int?> _selectedRows = {}; // stores selected row indexes
  bool showCheckboxes = false;
  @override
  void initState() {
    showCheckboxes = _selectedRows.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        centerTitle: true,
        actions: [
          if (_selectedRows.isEmpty)
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _showExportOptions(context);
                  },
                  icon: Icon(Icons.download),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showCheckboxes = !showCheckboxes;
                    });
                  },
                  icon: Icon(Icons.edit_document),
                ),
              ],
            )
          else
            IconButton(
              onPressed: () async {
                // Delete selected rows from database
                await PotholeDatabase.instance.deletePotholesByIds(
                  _selectedRows.whereType<int>().toList(),
                );
                setState(() {
                  _selectedRows.clear();
                });
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            tableHeader(),
            Expanded(
              child: FutureBuilder<List<PotholeEvent>>(
                future: PotholeDatabase.getAllPotholes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final row = data[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                "${index + 1}.",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${row.latitude.toStringAsFixed(5)},${row.longitude.toStringAsFixed(5)}",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(child: Image.file(File(row.imagePath))),
                            Expanded(
                              child: Text(
                                "${row.severity}",
                                textAlign: TextAlign.center,
                              ),
                            ),

                            /// ✅ Checkbox column
                            if (showCheckboxes)
                              SizedBox(
                                width: 40,
                                child: Checkbox(
                                  value: _selectedRows.contains(row.id),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedRows.add(row.id);
                                      } else {
                                        _selectedRows.remove(row.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Sr. No.",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Expanded(
          //   child: Text(
          //     "Time",
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // Expanded(
          //   child: Text(
          //     "Speed",
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          const Expanded(
            child: Text(
              "Lat & Lng",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            child: Text(
              "Potholes Images",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            child: Text(
              "Severity",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (showCheckboxes)
            const SizedBox(
              width: 40,
              child: Center(
                child: Text("✓", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              "Export Report",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text("Export as CSV"),
              onTap: () async {
                Navigator.pop(context);
                await ExportPassportHelper.exportCSV();
              },
            ),

            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text("Export as Excel"),
              onTap: () async {
                Navigator.pop(context);
                await ExportPassportHelper.exportExcel(); // stub
              },
            ),

            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Export as PDF"),
              onTap: () async {
                Navigator.pop(context);
                await ExportPassportHelper.exportPDF(); // stub
              },
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
