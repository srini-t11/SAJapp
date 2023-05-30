import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MySketcher extends CustomPainter {

  final List lines;

  MySketcher(this.lines);

  @override
  void paint(Canvas canvas, Size size) {

    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    double h = size.height;
    double w = size.width;

    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0;

    for (int i = 0; i < lines.length; ++i) {
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }

  }

  @override
  bool shouldRepaint(MySketcher delegate) {
    return true;
  }

}

