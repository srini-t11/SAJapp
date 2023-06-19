import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MySketcher extends CustomPainter {

  final List lines;
  final List selectBoxPoints;
  final List highlightLines;

  MySketcher(this.lines, this.highlightLines, this.selectBoxPoints);

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

    // draw highlighted lines
    for (int i = 0; i < highlightLines.length; ++i) {
      for (int j = 0; j < highlightLines[i].path.length - 1; ++j) {
        if (highlightLines[i].path[j] != null && highlightLines[i].path[j + 1] != null) {
          paint.color = highlightLines[i].color;
          paint.strokeWidth = highlightLines[i].width;
          canvas.drawLine(highlightLines[i].path[j], highlightLines[i].path[j + 1], paint);
        }
      }
    }

    paintBox(canvas, selectBoxPoints[0], selectBoxPoints[1], selectBoxPoints[2], selectBoxPoints[3]);

  }

  @override
  bool shouldRepaint(MySketcher delegate) {
    return true;
  }

  void paintBox(Canvas canvas, double Lx, double Rx, double Ty,double By) {

    //paints a dotted box based on left, right, top, and bottom edge coordinates
    //the left and right coordinates can be switched. Same for top and bottom.

    double left;
    double right;
    double top;
    double bottom;

    //arrange the coordinates appropriately:

    if (Lx <= Rx) {
      left = Lx;
      right = Rx;
    } else {
      left = Rx;
      right = Lx;
    }

    if (Ty <= By) {
      top = Ty;
      bottom = By;
    } else {
      top = By;
      bottom = Ty;
    }

    final path = Path();
    double dotSpacing = 5;
    double dotSize = 2;

    final paint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.round;

    // Draw top line
    for (double i = left; i < right; i += dotSpacing) {
      path.moveTo(i, top);
      path.lineTo(i + dotSize, top);
    }

    // Draw right line
    for (double i = top; i < bottom; i += dotSpacing) {
      path.moveTo(right, i);
      path.lineTo(right, i + dotSize);
    }

    // Draw bottom line
    for (double i = right; i > left; i -= dotSpacing) {
      path.moveTo(i, bottom);
      path.lineTo(i - dotSize, bottom);
    }

    // Draw left line
    for (double i = bottom; i > top; i -= dotSpacing) {
      path.moveTo(left, i);
      path.lineTo(left, i - dotSize);
    }

    canvas.drawPath(path, paint);

  }

}

