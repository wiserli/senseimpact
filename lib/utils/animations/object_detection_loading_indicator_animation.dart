import 'package:flutter/material.dart';
import 'package:pothole_detection_app/view/build_methods.dart';
import 'dart:math';

enum DetectionType{
  Realtime,
  IpCamera,
  Image
}

class ObjectDetectionLoadingIndicator extends StatefulWidget {
  DetectionType? detectionType = DetectionType.Realtime;
  String? orientation = "portraitUp";
  ObjectDetectionLoadingIndicator({super.key,this.detectionType,this.orientation});

  @override
  _ObjectDetectionLoadingIndicatorState createState() =>
      _ObjectDetectionLoadingIndicatorState();
}

class _ObjectDetectionLoadingIndicatorState
    extends State<ObjectDetectionLoadingIndicator>
    with TickerProviderStateMixin  {
  late AnimationController _controller;
  late AnimationController _loadingTextController;
  late Animation<double> _fadeAnimation;
  BuildMethods animationBuildMethods = BuildMethods();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.00000000000001,
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Controller for "Loading..." fade-in/out animation
    _loadingTextController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingTextController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          animationBuildMethods.buildLogo(orientation: widget.orientation!,isColored: true),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: VideoDetectionPainter(_controller,widget.detectionType),
                  size: Size(300, 200),
                ),
                // Fading "Loading..." text at the center
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingTextController.dispose();
    super.dispose();
  }
}

class VideoDetectionPainter extends CustomPainter {
  final Animation<double> animation;
  DetectionType? detectionType = DetectionType.Realtime;

  VideoDetectionPainter(this.animation,this.detectionType) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    // Paint for the outer frame
    final framePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Paint for the detection rectangles
    final rectPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Paint for the scanning bar
    final barPaint = Paint()..color = Colors.red.withOpacity(0.6);

    // Text style for object labels
    final textStyle = TextStyle(
      color: Colors.greenAccent,
      fontSize: 12,
    );

    // Draw the outer frame
    final frameRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(frameRect, framePaint);

    // Draw detection rectangles (moving objects)
    for (int i = 0; i < 4; i++) {
      final rectX = random.nextDouble() * (size.width - 50);
      final rectY = random.nextDouble() * (size.height - 50);
      final rectWidth = 50 + random.nextDouble() * 30;
      final rectHeight = 30 + random.nextDouble() * 20;

      // Slower movement: scale down the animation effect
      final offset = 5 * sin(animation.value * 2 * pi * 0.5); // Reduce frequency

      final rect = Rect.fromLTWH(
        rectX + offset, // Horizontal movement with slower speed
        rectY,
        rectWidth,
        rectHeight,
      );

      canvas.drawRect(rect, rectPaint);

      // Add a label to the rectangle
      final textSpan = TextSpan(
        text: 'Object ${i + 1}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, rect.topLeft + Offset(5, -15));
    }

    // Draw scanning bar
    final barHeight = 10.0;
    final barY = size.height * animation.value;
    canvas.drawRect(
      Rect.fromLTWH(0, barY, size.width, barHeight),
      barPaint,
    );
    if(detectionType == DetectionType.IpCamera) {
      // Draw "REC" sign with red dot
      final recDotPaint = Paint()
        ..color = Colors.red;
      final dotRadius = 6.0;

      // Position the "REC" sign at the top-right corner
      final recOffset = Offset(size.width - 75, 15);

      // Draw red dot
      canvas.drawCircle(recOffset, dotRadius, recDotPaint);

      // Draw "REC" text
      final recTextStyle = TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      final recTextSpan = TextSpan(
        text: 'OFFLINE',
        style: recTextStyle,
      );
      final recTextPainter = TextPainter(
        text: recTextSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )
        ..layout();
      recTextPainter.paint(canvas, recOffset + Offset(dotRadius + 5, -8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
