import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visionx/visionx_prediction_dir/visionx_detection_dir/line_counter_data_model.dart';

import '../main.dart';
import '../theme/cubit/theme_cubit.dart';
import '../theme/theme_utils.dart';

class LineDrawerScreen extends StatefulWidget {
  final dynamic _cameraController;
  final String? orientation;

  const LineDrawerScreen(this._cameraController,
      {this.orientation = "portraitUp"});

  @override
  State<LineDrawerScreen> createState() => _LineDrawerScreenState();
}

class _LineDrawerScreenState extends State<LineDrawerScreen> {
  Offset? centerPoint; // point where line passes through
  double angle = pi / 2; // slope/rotation in radians
  bool rotating = false;

  @override
  void initState() {
    initHelper();
    super.initState();
  }

  initHelper() async {
    final coords = await widget._cameraController.getLineCoordinates();
    if (coords != null) {
      final x1 = coords[0].toInt();
      final y1 = coords[1].toInt();
      final x2 = coords[2].toInt();
      final y2 = coords[3].toInt();

      setState(() {
        centerPoint = Offset((x1 + x2) / 2, (y1 + y2) / 2);
        angle = atan2(y2 - y1, x2 - x1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    centerPoint ??= Offset(screenSize.width / 2, screenSize.height / 2);

    // Compute line intersections with edges
    final edges = _getLineEdgePoints(centerPoint!, angle, screenSize);

    // Normalize angle to degrees [0–360)
    double angleDeg = (angle * 180 / pi) % 360;
    if (angleDeg < 0) angleDeg += 360;

    // Check if line is straight (horizontal)
    bool isStraight = (angleDeg >= 350 || angleDeg <= 10) || // near 0°
        (angleDeg >= 170 && angleDeg <= 190); // near 180°

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
          onPanStart: (details) {
            if (_isNearLine(details.localPosition, edges.$1, edges.$2)) {
              rotating = true;
              setState(() {
                isLineDrawModeOn = true;
              });
              widget._cameraController.pauseLivePrediction();
            }
          },
          onPanUpdate: (details) {
            if (rotating) {
              setState(() {
                final dx = details.localPosition.dx - centerPoint!.dx;
                final dy = details.localPosition.dy - centerPoint!.dy;
                angle = atan2(dy, dx); // compute new angle
                isLineDrawModeOn = true;
              });
              widget._cameraController.pauseLivePrediction();
            }
          },
          onPanEnd: (_) {
            rotating = false;
          },
          child: Stack(
            children: [
              CustomPaint(
                size: screenSize,
                painter: LinePainter(edges.$1, edges.$2, rotating: rotating),
              ),

              // Glowing red point
              Positioned(
                left: centerPoint!.dx - (rotating ? 70 : 20) / 2,
                top: centerPoint!.dy - (rotating ? 70 : 20) / 2,
                child: GestureDetector(
                  onPanStart: (_) {
                    setState(() {
                      rotating = true;
                      isLineDrawModeOn = true;
                    });
                    widget._cameraController.pauseLivePrediction();
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      centerPoint = Offset(
                        centerPoint!.dx + details.delta.dx,
                        centerPoint!.dy + details.delta.dy,
                      );
                      isLineDrawModeOn = true;
                    });
                    widget._cameraController.pauseLivePrediction();
                  },
                  onPanEnd: (_) {
                    setState(() {
                      rotating = false;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Glowing point
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: rotating ? 70 : 20,
                        height: rotating ? 70 : 20,
                        decoration: BoxDecoration(
                          color:
                              rotating ? Colors.white : const Color(0xFF62bcb9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF62bcb9).withOpacity(0.6),
                              blurRadius: rotating ? 25 : 10,
                              spreadRadius: rotating ? 10 : 3,
                            ),
                          ],
                        ),
                        child: rotating
                            ? Image.asset("assets/icons/wiserli_logo.png")
                            : null,
                      ),

                      // Labels
                      if (isStraight) ...[
                        Positioned(
                          top: -30,
                          child: _buildLabel("B"),
                        ),
                        Positioned(
                          bottom: -30,
                          child: _buildLabel("A"),
                        ),
                      ] else ...[
                        Positioned(
                          left: -30,
                          child: _buildLabel("A"),
                        ),
                        Positioned(
                          right: -30,
                          child: _buildLabel("B"),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Coordinates text
              if (isLineDrawModeOn)
                Positioned(
                  top: (widget.orientation == 'portraitUp' ||
                          widget.orientation == 'portraitDown')
                      ? 150.h
                      : 240.h,
                  left: (widget.orientation == 'landscapeRight')
                      ? null
                      : (widget.orientation == 'landscapeLeft')
                          ? 0.w
                          : 20.w,
                  right: (widget.orientation == 'landscapeRight') ? 0.w : null,
                  child: Transform.rotate(
                    angle: (widget.orientation == 'landscapeRight')
                        ? pi / 2
                        : (widget.orientation == 'landscapeLeft')
                            ? -pi / 2
                            : 0,
                    child: Text(
                      "Point1: (${edges.$1.dx.toStringAsFixed(1)}, ${edges.$1.dy.toStringAsFixed(1)})\n"
                      "Point2: (${edges.$2.dx.toStringAsFixed(1)}, ${edges.$2.dy.toStringAsFixed(1)})\n"
                      "Angle: ${angleDeg.toStringAsFixed(1)}°",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (isCountingOn)
                StreamBuilder<LineCounterDataModel?>(
                  stream: lineCounterStreamResultsController.stream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<LineCounterDataModel?> snapshot,
                  ) {
                    return Positioned(
                      // top: (widget.orientation == "portraitUp") ? 220.h,
                      // left: 20.h,
                      top: (widget.orientation == 'portraitUp' ||
                              widget.orientation == 'portraitDown')
                          ? 220.h
                          : 50.h,
                      left: (widget.orientation == 'landscapeRight')
                          ? null
                          : (widget.orientation == 'landscapeLeft')
                              ? 150.w
                              : 20.w,
                      right: (widget.orientation == 'landscapeRight')
                          ? 150.w
                          : (widget.orientation == 'landscapeLeft')
                              ? null
                              : null,
                      child: snapshot.data != null
                          ? Transform.rotate(
                              angle: (widget.orientation == 'landscapeRight')
                                  ? pi / 2
                                  : (widget.orientation == 'landscapeLeft')
                                      ? -pi / 2
                                      : 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${snapshot.data!.lineCounterStatsLabel}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      'A: ${snapshot.data!.labelsOut}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      'B: ${snapshot.data!.labelsIn}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    );
                  },
                ),
            ],
          )),
      floatingActionButton: isLineDrawModeOn
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: (widget.orientation == 'landscapeRight')
                      ? pi / 2
                      : (widget.orientation == 'landscapeLeft')
                          ? -pi / 2
                          : 0,
                  child: FloatingActionButton(
                    child: const Text(
                      "Set",
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      widget._cameraController.setLineCounterCoordinates(
                        x1: edges.$1.dx.toInt(),
                        y1: edges.$1.dy.toInt(),
                        x2: edges.$2.dx.toInt(),
                        y2: edges.$2.dy.toInt(),
                      );
                      widget._cameraController.resumeLivePrediction();
                      setState(() {
                        isLineDrawModeOn = false;
                      });
                    },
                  ),
                ),
              ],
            )
          : null,
    );
  }

  /// Check if a point is near the line segment
  bool _isNearLine(Offset p, Offset a, Offset b, {double tolerance = 30}) {
    final cross = (p.dy - a.dy) * (b.dx - a.dx) - (p.dx - a.dx) * (b.dy - a.dy);
    final dist = cross.abs() / (a - b).distance;
    final dot = (p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy);
    if (dot < 0) return false;
    if (dot > (b - a).distanceSquared) return false;
    return dist <= tolerance;
  }

  /// Finds line edge intersections
  (Offset, Offset) _getLineEdgePoints(Offset point, double theta, Size size) {
    final width = size.width;
    final height = size.height;
    final m = tan(theta);

    List<Offset> intersections = [];

    // Left edge (x=0)
    double yAtLeft = point.dy - m * (point.dx - 0);
    if (yAtLeft >= 0 && yAtLeft <= height) {
      intersections.add(Offset(0, yAtLeft));
    }

    // Right edge (x=width)
    double yAtRight = point.dy - m * (point.dx - width);
    if (yAtRight >= 0 && yAtRight <= height) {
      intersections.add(Offset(width, yAtRight));
    }

    // Top edge (y=0)
    if (m.abs() > 1e-6) {
      double xAtTop = point.dx - (point.dy - 0) / m;
      if (xAtTop >= 0 && xAtTop <= width) {
        intersections.add(Offset(xAtTop, 0));
      }
    }

    // Bottom edge (y=height)
    if (m.abs() > 1e-6) {
      double xAtBottom = point.dx - (point.dy - height) / m;
      if (xAtBottom >= 0 && xAtBottom <= width) {
        intersections.add(Offset(xAtBottom, height));
      }
    }

    if (intersections.length >= 2) {
      return (intersections[0], intersections[1]);
    } else {
      return (point, point);
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 3,
            color: Colors.black.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset p1;
  final Offset p2;
  final bool rotating;

  LinePainter(this.p1, this.p2, {this.rotating = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (rotating) {
      // Glow layers (outer to inner)
      final glowPaint1 = Paint()
        ..color = CustomColors.darkPinkColor.withOpacity(0.2)
        ..strokeWidth = 30
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      final glowPaint2 = Paint()
        ..color = CustomColors.darkPinkColor.withOpacity(0.4)
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      final glowPaint3 = Paint()
        ..color = CustomColors.darkPinkColor.withOpacity(0.6)
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Core bright line
      final corePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      // Draw from outer glow → inner glow → core
      canvas.drawLine(p1, p2, glowPaint1);
      canvas.drawLine(p1, p2, glowPaint2);
      canvas.drawLine(p1, p2, glowPaint3);
      canvas.drawLine(p1, p2, corePaint);
    } else {
      final corePaint = Paint()
        ..color = CustomColors.darkPinkColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return p1 != oldDelegate.p1 ||
        p2 != oldDelegate.p2 ||
        rotating != oldDelegate.rotating;
  }
}
