import 'package:flutter/material.dart';

class CasamoTitle extends StatelessWidget {
  final double fontSize;
  final Color color;
  final TextAlign textAlign;

  const CasamoTitle({
    super.key,
    this.fontSize = 32,
    this.color = Colors.blueAccent,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "CASAMO",
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 3,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          )
        ],
      ),
    );
  }
}
