import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingBar extends StatefulWidget {
  final int maxRating;
  final double currentRating;
  final void Function(double) onRatingChanged;
  final double iconSize;

  const RatingBar({
    Key? key,
    this.maxRating = 5,
    required this.currentRating,
    required this.onRatingChanged,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.currentRating;
  }

  Widget buildStar(int index) {
    IconData iconData;
    Color color;
    if (index >= _currentRating) {
      iconData = Icons.star_border;
      color = Colors.grey;
    } else if (index > _currentRating - 1 && index < _currentRating) {
      iconData = Icons.star;
      color = Colors.amber;
    } else {
      iconData = Icons.star;
      color = Colors.amber;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRating = index + 1.0;
        });
        widget.onRatingChanged(_currentRating);
      },
      onHorizontalDragUpdate: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localPosition = box.globalToLocal(details.globalPosition);
        int newRating = (localPosition.dx / widget.iconSize)
            .clamp(0.0, widget.maxRating.toDouble())
            .round();
        setState(() {
          _currentRating = newRating.toDouble();
        });
        widget.onRatingChanged(_currentRating);
      },
      child: Icon(
        iconData,
        color: color,
        size: widget.iconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.maxRating, (index) => buildStar(index)),
    );
  }
}
