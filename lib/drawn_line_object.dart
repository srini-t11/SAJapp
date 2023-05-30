import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class DrawnLine {
  final List path;
  final Color color;
  final double width;

  DrawnLine(this.path, this.color, this.width);
}