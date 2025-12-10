import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Public entry to get current location.
  /// This will block (show dialogs) until GPS + permission are available,
  /// or until the user never enables them (timeout stops waiting for resume).
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    return await getLocationWithDialogs(context);
  }
}

/// Waits until the app lifecycle becomes resumed or until [timeout].
/// Returns true if resumed, false if timed out.
Future<bool> _waitForAppResume({
  Duration timeout = const Duration(seconds: 30),
}) async {
  final completer = Completer<void>();

  // Local observer
  final observer = _LifecycleObserver((AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !completer.isCompleted) {
      completer.complete();
    }
  });

  WidgetsBinding.instance.addObserver(observer);

  try {
    // Wait for resume or timeout
    await completer.future.timeout(timeout);
    return true;
  } on TimeoutException {
    return false;
  } finally {
    WidgetsBinding.instance.removeObserver(observer);
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  final void Function(AppLifecycleState) onChange;
  _LifecycleObserver(this.onChange);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }
}

Future<Position?> getLocationWithDialogs(BuildContext context) async {
  // -------------------------------
  // STEP 1: Ensure GPS is enabled
  // -------------------------------
  while (true) {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) break;

    // Show force dialog to open settings
    await showForceDialog(
      context: context,
      title: "Enable Location",
      message:
          "Location services are turned off.\n\nWithout location, the app cannot proceed.",
      buttonText: "Open Settings",
    );

    // Open OS location settings
    await Geolocator.openLocationSettings();

    // Wait for the user to return to the app (or timeout)
    // If user returns, allow a short delay for the OS to apply changes.
    final resumed = await _waitForAppResume(
      timeout: const Duration(seconds: 30),
    );
    if (resumed) {
      // give the OS a moment to actually toggle the provider
      await Future.delayed(const Duration(milliseconds: 800));
    } else {
      // timed out waiting for resume - allow loop to re-show dialog
      // (this avoids permanently blocking if user never returns)
    }

    // Next loop iteration will re-check `isLocationServiceEnabled()`
    // If user enabled it, loop will break. Otherwise user sees dialog again.
  }

  // -------------------------------
  // STEP 2 & 3: Ensure Permission
  // -------------------------------
  while (true) {
    LocationPermission permission = await Geolocator.checkPermission();

    // CASE 1: DENIED -> try to request permission (system popup may show)
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // If still denied, show a forced dialog that lets the user retry.
      if (permission == LocationPermission.denied) {
        await showForceDialog(
          context: context,
          title: "Location Permission Required",
          message:
              "The app needs location permission to work.\n\nPlease allow location access.",
          buttonText: "Try Again",
        );

        // Loop continues and will call requestPermission() again.
        continue;
      }
    }

    // CASE 2: DENIED FOREVER -> require opening app settings
    if (permission == LocationPermission.deniedForever) {
      await showForceDialog(
        context: context,
        title: "Permission Blocked",
        message:
            "Location permission is permanently denied.\n\nPlease enable it from App Settings to continue.",
        buttonText: "Open App Settings",
      );

      await Geolocator.openAppSettings();

      // Wait for the user to return (or timeout)
      final resumed = await _waitForAppResume(
        timeout: const Duration(seconds: 30),
      );
      if (resumed) {
        // short delay to let OS apply changes
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Re-loop and re-check permission state.
      continue;
    }

    // CASE 3: PERMISSION GRANTED
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      break;
    }
  }

  // -------------------------------
  // STEP 4: Finally get location
  // -------------------------------
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

/// Dialog with ONLY one button (user cannot cancel)
Future<bool> showForceDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonText,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  child: Text(buttonText),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
      ) ??
      false;
}
