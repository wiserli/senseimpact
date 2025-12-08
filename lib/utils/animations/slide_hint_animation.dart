import 'package:flutter/material.dart';

class SlidableHintAnimation extends StatefulWidget {
  final Widget child;

  const SlidableHintAnimation({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SlidableHintAnimation> createState() => _SlidableHintAnimationState();
}

class _SlidableHintAnimationState extends State<SlidableHintAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create a curved animation that slides slightly right then back
    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.08, 0.0),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.08, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);

    // Run the animation when the widget is built, with periodic repetition
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _controller.forward().then((_) {
          // Reset and repeat animation periodically
          if (mounted) {
            _controller.reset();
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _playAnimationPeriodically();
              }
            });
          }
        });
      }
    });
  }

  void _playAnimationPeriodically() {
    if (!mounted) return;

    _controller.forward().then((_) {
      if (mounted) {
        _controller.reset();
        Future.delayed(const Duration(seconds: 5), () {
          _playAnimationPeriodically();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
