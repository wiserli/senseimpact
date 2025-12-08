import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../res/constants.dart';
import '../theme/theme_utils.dart';
import '../utils/file_download.dart';

class InitialModelDownloadView extends StatefulWidget {
  const InitialModelDownloadView({super.key});

  @override
  State<InitialModelDownloadView> createState() =>
      _InitialModelDownloadViewState();
}

class _InitialModelDownloadViewState extends State<InitialModelDownloadView> {
  double downloadProgress = 0;
  bool downloadCompleted = false;
  bool fileExists = false;
  bool errorOccurred = false;
  String? errorMessage;
  String? modelImage;

  @override
  void initState() {
    Platform.isIOS
        ? initHelper(
          mlModelFileName: initialMLModelModelFileName,
          mlModelFileLink: initialMLModelFileLink,
        )
        : initHelper(
          modelFileName: initialTfliteModelFileName,
          modelFileLink: initialTfliteModelFileLink,
          metadataFileName: initialMetadataFileName,
          metadataFileLink: initialMetadataFileLink,
        );
    super.initState();
  }

  initHelper({
    String? modelFileName,
    String? modelFileLink,
    String? metadataFileName,
    String? metadataFileLink,
    String? mlModelFileName,
    String? mlModelFileLink,
  }) async {
    final currentContext = context;
    if (!mounted) return;

    if (Platform.isIOS) {
      await FileDownload()
          .startDownloading(
            context: currentContext,
            okCallback: (receivedBytes, totalBytes) {
              if (mounted) {
                setState(() {
                  downloadProgress = receivedBytes / totalBytes;
                  downloadProgress == 1.0
                      ? (downloadCompleted = true, errorOccurred = false)
                      : downloadCompleted = false;
                });
              }
            },
            folderName: initialModelName,
            mlModelFileName: mlModelFileName,
            mlModelDownloadLink: mlModelFileLink,
          )
          .catchError((error) {
            if (mounted) {
              setState(() {
                errorOccurred = true;
              });
            }
            errorMessage = error.toString();
            debugPrint(errorMessage);
          })
          .then((value) async {})
          .then((value) {
            if (mounted) {
              setState(() {
                fileExists;
              });
            }
          });
    } else {
      await FileDownload()
          .startDownloading(
            context: currentContext,
            okCallback: (receivedBytes, totalBytes) {
              if (mounted) {
                setState(() {
                  downloadProgress = receivedBytes / totalBytes;
                  downloadProgress == 1.0
                      ? (downloadCompleted = true, errorOccurred = false)
                      : downloadCompleted = false;
                });
              }
            },
            folderName: initialModelName,
            modelFileName: modelFileName,
            modelDownloadLink: modelFileLink,
            metadataFileName: metadataFileName,
            metadataDownloadLink: metadataFileLink,
          )
          .catchError((error) {
            if (mounted) {
              setState(() {
                errorOccurred = true;
              });
            }
            errorMessage = error.toString();
          })
          .then((value) async {})
          .then((value) {
            if (mounted) {
              setState(() {
                fileExists;
              });
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/icons/yolovx_logo.png',
                  width: 115.w * 1.5,
                  height: 38.h * 1.5,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/initModelDownload.gif',
                  width: 300.w,
                  height: 300.h,
                ),
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Column(
                    children: [
                      Text(
                        '${(downloadProgress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CustomColors.darkPinkColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: downloadProgress,
                    semanticsLabel: 'Linear progress indicator',
                  ),
                ],
              ),
              SizedBox(height: 25.h),
              !errorOccurred
                  ? Center(
                    child: Text(
                      downloadCompleted
                          ? "Preparing app...\nModel downloaded\nApp is ready"
                          : "Preparing app...\nDownloading default model....",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                  : Center(
                    child: Text(
                      "Error occurred while downloading!\nCheck your internet connection",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              SizedBox(height: 100.h),
              errorOccurred
                  ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(344.w, 42.h),
                      foregroundColor: Colors.white,
                      backgroundColor: CustomColors.errorColor,
                    ),
                    onPressed: () async {
                      // var connectivityResult =
                      //     await Connectivity().checkConnectivity();
                      if (connectivityResult == ConnectivityResult.mobile ||
                          connectivityResult == ConnectivityResult.wifi) {
                        setState(() {
                          errorOccurred = false;
                        });
                        Platform.isIOS
                            ? initHelper(
                              mlModelFileName: initialMLModelModelFileName,
                              mlModelFileLink: initialMLModelFileLink,
                            )
                            : initHelper(
                              modelFileName: initialTfliteModelFileName,
                              modelFileLink: initialTfliteModelFileLink,
                              metadataFileName: initialMetadataFileName,
                              metadataFileLink: initialMetadataFileLink,
                            );
                      } else {
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('No internet'),
                              content: const Text(
                                'Please turn on the internet connection and Try Again!',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(
                      'Retry',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                  : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(344.w, 42.h),
                        foregroundColor: Colors.white,
                        backgroundColor: CustomColors.darkPinkColor,
                      ),
                      onPressed:
                          downloadCompleted && fileExists
                              ? () async {
                                List modelsClasses =
                                    initialClasses
                                        .substring(1, initialClasses.length - 1)
                                        .split(',')
                                        .map((e) => e.trim())
                                        .toList();
                                List<String> stringList = List<String>.from(
                                  modelsClasses,
                                );
                                List<String> classesLowercaseList =
                                    stringList
                                        .map(
                                          (String item) => item.toLowerCase(),
                                        )
                                        .toList();
                              }
                              : null,
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
