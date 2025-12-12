import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pothole_detection_app/theme/theme_utils.dart';

class CustomSnackBar {
  SnackBarMessage(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarLoginReqFeature(BuildContext context) {
    return Fluttertoast.showToast(
      msg: 'Login Required: Please log in to access this feature',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarEnableTrackingFirst() async {
    await Fluttertoast.showToast(
      msg: "Turn on Object Tracking to use Object Counter.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarTrackerReset() async {
    await Fluttertoast.showToast(
      msg: "Object Tracker Reset Successfully.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarCounterReset() async {
    await Fluttertoast.showToast(
      msg: "Object Counter Reset Successfully.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  void showAlertDialog({
    String? title,
    String? message,
    String? rbtntxt,
    bool? dismissible,
    Function()? rbtnFunction,
    required BuildContext ctx,
  }) {
    showDialog(
      context: ctx,
      barrierDismissible: dismissible ?? true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return dismissible ?? true;
          },
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            content: Text(
              message!,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: rbtnFunction,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rbtntxt!),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
