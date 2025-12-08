import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/theme_utils.dart';

class CircularIconButton extends StatefulWidget {
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onPressed;

  const CircularIconButton({
    Key? key,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<CircularIconButton> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        widget.onPressed();
      },
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(
                // isActive
                // ? 'assets/icons/${widget.activeIcon}':
                'assets/icons/${widget.inActiveIcon}'),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final Color borderColor;
  final Color labelColor;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  int? minLines;
  final String? Function(String?)? validator;

  CustomTextField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.borderColor,
    required this.labelColor,
    required this.obscureText,
    required this.keyboardType,
    required this.validator,
    required this.controller,
    this.minLines,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool modelExist = false;

  void checkIfModelExists(String value) {
    if (modelExist == true) {
      setState(() {
        modelExist = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.labelColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        // Gap
        SizedBox(height: 5.h),
        SizedBox(
          width: 318.w,
          child: TextFormField(
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: null,
            controller: widget.controller,
            cursorHeight: 24,
            minLines: widget.minLines,
            // expands: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(fontSize: 14),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: CustomColors.permissionBackgroundColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.darkPinkColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.darkPinkColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.darkPinkColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CustomColors.darkPinkColor),
                borderRadius: BorderRadius.circular(8.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(8.r),
              ),
              isCollapsed: false,
              errorText: modelExist ? "Model name already exists" : null,
            ),
            onChanged: (value) {
              checkIfModelExists(value);
            },
          ),
        ),
      ],
    );
  }
}

Widget customGreyButton(String btntext, Color btncolor, VoidCallback onPress,
    Color textColor, double width, double height) {
  return InkWell(
    onTap: () {
      onPress();
    },
    child: Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: btncolor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(
          btntext,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}


class CustomChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const CustomChip({
    Key? key,
    required this.label,
    this.backgroundColor = CustomColors.chipColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8),
      label: Text(
        label,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

Widget customTextField2({
  String? hintText,
  Icon? icon,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  TextEditingController? controller,
  bool obscureText = false,
  Color borderColor = CustomColors.profileAppBarColor,
  String? Function(String?)? validator,
  String? Function(String?)? onChanged,
  bool allowedToChange = true,
  bool isPasswordVisible = false,
  VoidCallback? togglePasswordVisibility,
  bool? passshowhide = true,
}) {
  return TextFormField(
    initialValue: allowedToChange ? null : hintText,
    obscureText: obscureText,
    controller: allowedToChange ? controller : null,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    readOnly: !allowedToChange,
    cursorColor: CustomColors.darkPinkColor,
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 5.h),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: CustomColors.darkPinkColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      errorMaxLines: 3,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(4),
        child: icon,
      ),
      suffixIcon: passshowhide!
          ? isPasswordVisible
              ? IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: togglePasswordVisibility,
                )
              : IconButton(
                  icon: const Icon(Icons.visibility_off),
                  onPressed: togglePasswordVisibility,
                )
          : null,
    ),
  );
}
