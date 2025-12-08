import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/theme_utils.dart';

Widget errorWidget({
  required String errorMessage,
  required BuildContext context,
  required void Function() onPressed,
}) {
  return Center(
    child: Column(
      children: [
        const Spacer(),
        // Image.asset(
        //   'assets/images/error.avif',
        // ),
        // Error Text
        Text(
          errorMessage,
          style: TextStyle(color: CustomColors.errorColor, fontSize: 18.sp),
        ),
        SizedBox(height: 50.h),
        const Spacer(),
      ],
    ),
  );
}
