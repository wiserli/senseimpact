import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../components/bottom_bar.dart';
import '../theme/theme_utils.dart';
import '../utils/permission_controller.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({
    super.key,
  });

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  void initState() {
    super.initState();
    checkPermissions(); // Load model only after checking permissions
  }

  Future<void> checkPermissions() async {
    final permissionsController = PermissionsController();
    final hasPermissions = await permissionsController.build();
    if (hasPermissions) {
      // Navigate to home screen if permission is granted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } else {
      _requestPermissions(context);
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    final statusList = <Permission>[Permission.camera,Permission.notification];
    if (Platform.isIOS) {
      statusList.add(Permission.photos);
    } else if (Platform.isAndroid) {
      final android = await DeviceInfoPlugin().androidInfo;
      final sdkInt = android.version.sdkInt;

      if (sdkInt > 32) {
        statusList.add(Permission.photos);
      } else {
        statusList.add(Permission.storage);
      }
    }

    final statusMap = await statusList.request();
    if (statusMap.values.every((status) => status.isGranted)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      ); // Permissions granted successfully
    } else {
      // If permissions are not granted, open app settings
      _openAppSettings();
      // Permissions not granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.permissionBackgroundColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Allow YOLOvX access to camera & storage ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Test your computer vision models in realtime using your camera',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              onPressed: () async {
                print("Button pressed");
                await _requestPermissions(context);
              },
              child: const Text(
                'ENABLE CAMERA ACCESS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CustomColors.profileAppBarColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () async {
                await _requestPermissions(context);
              },
              child: const Text(
                'ENABLE STORAGE ACCESS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CustomColors.profileAppBarColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
