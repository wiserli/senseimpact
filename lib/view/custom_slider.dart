import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visionx/camera_preview/visionx_yolo_camera_controller.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/object_detector.dart';

import '../../../../theme/cubit/theme_cubit.dart';
import '../../../../utils/indicators.dart';
import '../theme/theme_utils.dart';

enum SliderValueType {
  Integer,
  Double,
}

class CustomSlider extends StatefulWidget {
  final String title;
  double currentSliderValue;
  double maxSliderValue;
  double? minSliderValue;
  int numOfDivision;
  double? maxSliderValueLimits;
  SliderValueType sliderValueType;
  final void Function(double value) onSliderChanged;
  bool isDecoratedSlider;
  double unAuthUserMaxLimit;
  double freemiumUserMaxLimit;
  double premiumUserMaxLimit;

  CustomSlider({
    Key? key,
    required this.title,
    required this.currentSliderValue,
    required this.maxSliderValue,
    required this.numOfDivision,
    required this.onSliderChanged,
    this.minSliderValue,
    this.maxSliderValueLimits,
    this.sliderValueType = SliderValueType.Double,
    this.isDecoratedSlider = false,
    this.unAuthUserMaxLimit = 30,
    this.freemiumUserMaxLimit = 50,
    this.premiumUserMaxLimit = 200,
  }) : super(key: key);

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  bool _hasShownAuthSnackbar = false;
  bool _hasShownFreemiumSnackbar = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              widget.maxSliderValue == widget.numOfDivision
                  ? Text(
                      "${widget.sliderValueType == SliderValueType.Integer ? widget.currentSliderValue.ceil() : widget.currentSliderValue.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      "${widget.sliderValueType == SliderValueType.Integer ? widget.currentSliderValue.ceil() : widget.currentSliderValue.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
            ],
          ),
        ),
        widget.isDecoratedSlider
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: ThreeColorSliderTrackShape(
                        CustomColors.activeSliderColor,
                        CustomColors.unAuthUserColor,
                        CustomColors.freemiumColor,
                        CustomColors.premiumColor,
                        widget.unAuthUserMaxLimit!,
                        widget.freemiumUserMaxLimit!,
                        widget.premiumUserMaxLimit!), // limit3 = maxlimit,
                    trackHeight: 6,
                  ),
                  child: Slider(
                    thumbColor: CustomColors.activeSliderColor,
                    value: (widget.sliderValueType == SliderValueType.Double)
                        ? widget.currentSliderValue.toDouble()
                        : (widget.sliderValueType == SliderValueType.Integer)
                            ? widget.currentSliderValue.ceil().toDouble()
                            : widget.currentSliderValue.toDouble(),
                    min: widget.minSliderValue ?? 0,
                    max: widget.maxSliderValue,
                    divisions: widget.numOfDivision,
                    label: (widget.sliderValueType == SliderValueType.Double)
                        ? widget.currentSliderValue.toStringAsFixed(2)
                        : (widget.sliderValueType == SliderValueType.Integer)
                            ? widget.currentSliderValue.ceil().toString()
                            : widget.currentSliderValue.toString(),
                    onChanged: (value) {
                      // if (!prefs.authFlag && value > widget.unAuthUserMaxLimit) {
                      //   CustomSnackBar().SnackBarMessage("Authentication required");
                      //   value = widget.unAuthUserMaxLimit;
                      // } else if (prefs.authFlag && value > widget.freemiumUserMaxLimit) {
                      //   CustomSnackBar().SnackBarMessage(
                      //       "Upgrade to premium for maximum limits.");
                      //   value = widget.freemiumUserMaxLimit;
                      // } else {
                      //   setState(() {
                      //     widget.onSliderChanged(value);
                      //     widget.currentSliderValue = value;
                      //   });
                      // }
                      if (!prefs.authFlag &&
                          value > widget.unAuthUserMaxLimit) {
                        if (!_hasShownAuthSnackbar) {
                          // Duration of the snackbar can not be adjusted because the official package does not support it.
                          // Workaround is to repeat the snackbar message
                          CustomSnackBar().SnackBarMessage(
                              "Authentication required to use this feature.");
                          _hasShownAuthSnackbar = true;
                        }
                        value = widget.unAuthUserMaxLimit;
                      } else if (prefs.authFlag &&
                          prefs.userSubscription != "premium" &&
                          value > widget.freemiumUserMaxLimit) {
                        if (!_hasShownFreemiumSnackbar) {
                          CustomSnackBar().SnackBarMessage(
                              "Upgrade to premium for maximum limits.");
                          _hasShownFreemiumSnackbar = true;
                        }
                        value = widget.freemiumUserMaxLimit;
                      } else {
                        // Reset flags when user returns to valid range
                        _hasShownAuthSnackbar = false;
                        _hasShownFreemiumSnackbar = false;

                        setState(() {
                          widget.onSliderChanged(value);
                          widget.currentSliderValue = value;
                        });
                      }
                    },
                  ),
                ),
              )
            : Slider(
                thumbColor: CustomColors.activeSliderColor,
                value: (widget.sliderValueType == SliderValueType.Double)
                    ? widget.currentSliderValue.toDouble()
                    : (widget.sliderValueType == SliderValueType.Integer)
                        ? widget.currentSliderValue.ceil().toDouble()
                        : widget.currentSliderValue.toDouble(),
                min: widget.minSliderValue ?? 0,
                max: widget.maxSliderValue,
                divisions: widget.numOfDivision,
                label: (widget.sliderValueType == SliderValueType.Double)
                    ? widget.currentSliderValue.toStringAsFixed(2)
                    : (widget.sliderValueType == SliderValueType.Integer)
                        ? widget.currentSliderValue.floor().toString()
                        : widget.currentSliderValue.toString(),
                onChanged: (value) {

                },
              ),
      ],
    );
  }
}

class ThreeColorSliderTrackShape extends SliderTrackShape {
  final Color activeSliderColor;
  Color color1;
  Color color2;
  Color color3;
  final double limit1;
  final double limit2;
  final double limit3;
  ThreeColorSliderTrackShape(this.activeSliderColor, this.color1, this.color2,
      this.color3, this.limit1, this.limit2, this.limit3);
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4.0;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    final trackRect =
        Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
    final radius = Radius.circular(trackHeight / 2);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // 1. Draw background segments with rounded edges
    final double segmentWidth3 = trackRect.width;
    final double segmentWidth1 = (trackRect.width / limit3) * limit1;
    if (limit1 >= limit2 || limit2 >= limit3) {
      color1 = color2 =
          color3 = Colors.grey; // Default color if limits are not in order
    }
    final double segmentWidth2 = (trackRect.width / limit3) * limit2;

    final segment1 = RRect.fromRectAndCorners(
      Rect.fromLTWH(
          trackRect.left, trackRect.top, segmentWidth1, trackRect.height),
      topLeft: radius,
      bottomLeft: radius,
    );
    final segment2 = RRect.fromRectAndCorners(
      Rect.fromLTWH(trackRect.left + segmentWidth1, trackRect.top,
          segmentWidth2 - segmentWidth1, trackRect.height),
    );
    final segment3 = RRect.fromRectAndCorners(
      Rect.fromLTWH(trackRect.left + segmentWidth2, trackRect.top,
          segmentWidth3 - segmentWidth2, trackRect.height),
      topRight: radius,
      bottomRight: radius,
    );

    paint.color = color1;
    context.canvas.drawRRect(segment1, paint);

    paint.color = color2;
    context.canvas.drawRRect(segment2, paint);

    paint.color = color3;
    context.canvas.drawRRect(segment3, paint);

    // 2. Draw active track in pink (from start to thumb position)
    final double activeTrackWidth = thumbCenter.dx - trackLeft;
    if (activeTrackWidth > 0) {
      final RRect activeTrack = RRect.fromRectAndCorners(
        Rect.fromLTWH(trackLeft, trackTop, activeTrackWidth, trackHeight),
        topLeft: radius,
        bottomLeft: radius,
        topRight: activeTrackWidth >= trackWidth ? radius : Radius.zero,
        bottomRight: activeTrackWidth >= trackWidth ? radius : Radius.zero,
      );

      paint.color = activeSliderColor;

      context.canvas.drawRRect(activeTrack, paint);
    }
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

void showDetectionSettings({
  required BuildContext context,
  required ObjectDetector objectDetector,
  required double confidenceThreshold,
  required double iouThreshold,
  required double numItemsThreshold,
  required bool showConfidence,
}) {
  Scaffold.of(context).showBottomSheet((BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        height: 330.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Center(
                    child: Text(
                      "Detection Settings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 60.w),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, size: 26),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomSlider(
                title: 'Confidence Threshold',
                currentSliderValue: double.parse(prefs.confidenceThreshold),
                maxSliderValue: 1.0,
                numOfDivision: 100,
                onSliderChanged: (double value) {
                  confidenceThreshold = value;
                  prefs.confidenceThreshold = value.toStringAsFixed(2);
                  objectDetector.setConfidenceThreshold(value);
                },
              ),
              SizedBox(height: 5.h),
              CustomSlider(
                title: 'IOU Threshold',
                currentSliderValue: double.parse(prefs.iouThreshold),
                maxSliderValue: 1.0,
                numOfDivision: 100,
                onSliderChanged: (double value) {
                  iouThreshold = value;
                  prefs.iouThreshold = value.toStringAsFixed(2);
                  objectDetector.setIouThreshold(value);
                },
              ),
              SizedBox(height: 5.h),
              CustomSlider(
                title: 'Number of Items',
                currentSliderValue: double.parse(prefs.numItemsThreshold),
                sliderValueType: SliderValueType.Integer,
                maxSliderValue: 200,
                unAuthUserMaxLimit: 30,
                freemiumUserMaxLimit: 100,
                premiumUserMaxLimit: 200,
                minSliderValue: 1,
                numOfDivision: 200,
                isDecoratedSlider: true,
                onSliderChanged: (double value) {
                  numItemsThreshold = value;
                  prefs.numItemsThreshold = value.toStringAsFixed(0);
                  objectDetector.setNumItemsThreshold(value.ceil());
                },
              ),
              SizedBox(height: 5.h),
              SwitchListTile(
                title: const Text(
                  'Show Confidence Values',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
                value: showConfidence,
                onChanged: (bool value) {
                  if (prefs.authFlag == true) {
                    showConfidence = value;
                    setModalState(() {
                      showConfidence = value;
                    });
                    prefs.showConfidence = value;
                  } else {
                    CustomSnackBar().snackBarLoginReqFeature(context);
                  }
                },
              ),
            ],
          ),
        ),
      );
    });
  });
}
