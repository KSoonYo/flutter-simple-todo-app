import 'package:flutter/material.dart';

Size getTextSize(String content, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: content, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
