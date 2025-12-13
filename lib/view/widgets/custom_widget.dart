import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataBrick extends StatelessWidget {
  final Widget icon;
  final String text;
  final int minWidth;
  const DataBrick({
    super.key,
    required this.icon,
    required this.text,
    this.minWidth = 118,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth.w),
      height: 38.h,
      decoration: BoxDecoration(
        color: Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            icon,
            SizedBox(width: 6.w),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
