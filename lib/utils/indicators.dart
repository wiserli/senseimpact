import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pothole_detection_app/theme/theme_utils.dart';


class CustomSnackBar {
  bool _isToastShowing = false;

  snackBarDownloading(String modelName) {
    return Fluttertoast.showToast(
      msg: "Downloading $modelName",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarDownloaded(String modelName) {
    return Fluttertoast.showToast(
      msg: "Downloaded $modelName",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

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

  SnackBarUploading(String modelName) {
    return Fluttertoast.showToast(
      msg: "Uploading $modelName",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarDeploying(String modelName) {
    return Fluttertoast.showToast(
      msg: "Deploying $modelName.\nPlease wait...",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarDeployed(String modelName) {
    return Fluttertoast.showToast(
      msg: "Deployed $modelName",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarEncrypting(String modelName) {
    return Fluttertoast.showToast(
      msg: "Encrypting $modelName. Please wait...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarEncrypted(String modelName) {
    return Fluttertoast.showToast(
      msg: "Encrypted $modelName",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarError(String error) {
    return Fluttertoast.showToast(
      msg: "Error $error",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarOffline() {
    return Fluttertoast.showToast(
      msg: "You are offline",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarOnline() {
    return Fluttertoast.showToast(
      msg: "You are online",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarSWR() {
    return Fluttertoast.showToast(
      msg: "Something Went Wrong!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  // SnackBarModelUploadSuccess() {
  //   return SnackBar(
  //     content: const Text('Model uploaded successfully'),
  //     action: SnackBarAction(
  //       label: "Hide",
  //       onPressed: () {
  //         return;
  //       },
  //     ),
  //   );
  // }

  snackBarAccDetailsUpdate() {
    return Fluttertoast.showToast(
      msg: "Successfully updated your account details.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarUsing(BuildContext context, String chosenModelName) {
    return SnackBar(
      backgroundColor: CustomColors.scaffoldColor,
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 170,
          left: 10,
          right: 10),
      content: Text(
        "Using $chosenModelName",
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      action: SnackBarAction(
        label: "Hide",
        textColor: Colors.black,
        onPressed: () {
          return;
        },
      ),
    );
  }

  snackBarDeleted(String modelName) {
    return Fluttertoast.showToast(
      msg: "Deleted $modelName",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarSharing(List<String> emails) {
    return Fluttertoast.showToast(
      msg: 'Model Shared to ${emails.join(', ')}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarLoginReqIPCamera(BuildContext context) {
    return Fluttertoast.showToast(
      msg: 'Login Required: Please log in to access IP Camera',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarLoginReqDashboard(BuildContext context) {
    return Fluttertoast.showToast(
      msg: 'Login Required: Please log in to access the Dashboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarLoginRequired(BuildContext context) {
    return Fluttertoast.showToast(
      msg: 'Login Required: Please log in to access this model',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
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

  snackBarVerificationCodeSent(
      String email, BuildContext context, void Function() onPressed) {
    return SnackBar(
      action: SnackBarAction(
        label: "Verification",
        onPressed: () {
          onPressed();
        },
      ),
      content: Text(
          'Verification code already sent to $email.\nDidn\'t receive? Use Resend Passcode button on Verification screen.'),
    );
  }

  snackBarSuccess() {
    return Fluttertoast.showToast(
      msg: 'API Key copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarMAE() {
    return Fluttertoast.showToast(
      msg: "Model already exist!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: CustomColors.greyColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  snackBarServerDown() {
    return Fluttertoast.showToast(
      msg: "Server is down!, Please try again later.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
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

  void showAlertDialog(
      {String? title,
      String? message,
      String? rbtntxt,
      bool? dismissible,
      Function()? rbtnFunction,
      required BuildContext ctx}) {
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
                    const SizedBox(
                      width: 3,
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showError({String? errorMessage, String? inPage, BuildContext? ctx}) {
    showDialog(
      context: ctx!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Error $inPage!",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: Text(
            errorMessage!,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildExitDialog({
    required BuildContext dialogContext,
    required String imageUrl,
    required String title,
    bool isgoal = false,
    bool isSignAnon = false,
    // required VoidCallback? onPressed
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.only(
        top: 35,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSignAnon)
            Image.asset(
              imageUrl,
              width: 150,
              height: 120,
            ),
          const SizedBox(
            height: 18,
          ),
          SizedBox(
            width: 194,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text(
                  'YES',
                  style: TextStyle(
                    color: CustomColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(CustomColors.darkPinkColor)),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ],
      ),
    );
  }
}
