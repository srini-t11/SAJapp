import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'drawn_line_object.dart';
import 'my_sketcher.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class DocObject extends StatelessWidget {
  final Color selectedColor = Colors.black;
  final double selectedWidth = 5;
  final List lines;
  final double scale = 1.0;
  final double currScale = 1.0;
  final Offset f1 = Offset(0.0, 0.0);
  final Offset f2 = Offset (0.0, 0.0);

  DocObject(this.lines);

  //convert DocObject to a String
  String convertToText() {

    String out = "";

    for (int i = 0; i < lines.length; ++i) {
      DrawnLine temp_line = lines[i];


      if (temp_line.path.length > 0) {

        if (i == 0) {
          out = out + "{Lin: ${i},";
        } else {
          out = out + "\n{Lin: ${i},";
        }

        out = out + "Col: ${temp_line.color.value.toRadixString(16)},";
        out = out + "Wid: ${temp_line.width},";

        String path_str = "[";

        List temp_path = temp_line.path;

        for (int j = 0; j < temp_path.length - 1; ++j) {

          path_str = path_str + "(" + temp_path[j].dx.toString() + "," + temp_path[j].dy.toString() + "),";
          //path_str = path_str + temp_path[j].toString() + ",";
        }

        path_str = path_str + "(" + temp_path[temp_path.length - 1].dx.toString() + "," + temp_path[temp_path.length - 1].dy.toString() + ")" + "]";

        out = out + "pat: ${path_str}}";

      }

    }

    return out;
  }

  //convert String to a list of DocObject lines
  List convertTextToDocLines(String? text) {
    List lines_out = [];

    if (text == null) {
      return [DrawnLine([], Colors.black, 5)];
    }

    //remove empty lines from start of string
    RegExp regex = RegExp(r'^\n+');
    String text_temp = text.replaceAll(regex, '');


    List<String> raw_lines = text_temp.split('\n');

    int start_line = 0;

    if (raw_lines[0] == "") {
      start_line = 1;
    }


    for (int i = start_line; i < raw_lines.length; ++i) {

      String temp_raw_line = raw_lines[i];

      final col_regex = RegExp(r'(?<=Col: ).*(?=\,Wid)');

      final col_match_temp = col_regex.firstMatch(temp_raw_line)?.group(0) as String;

      String col_match_str = col_match_temp;
      var col_match_int = int.parse(col_match_str, radix: 16);
      Color col_out = Color(col_match_int);


      final wid_regex = RegExp(r'(?<=Wid: ).*(?=\,pat)');
      final wid_match = wid_regex.firstMatch(temp_raw_line)?.group(0) as String;
      double wid_double = double.parse(wid_match);


      final isolate_path_regex = RegExp(r'(?<=\[).*(?=\])');
      final isolate_path_match = isolate_path_regex.firstMatch(temp_raw_line)?.group(0) as String;
      List path_list = createPathFromText(isolate_path_match);

      DrawnLine temp_drawn_line = DrawnLine(path_list, col_out, wid_double);

      lines_out.add(temp_drawn_line);


    }

    return lines_out;

  }

  List createPathFromText(String path_txt)  {

    List path_out = [];

    final isolate_points_regex = RegExp(r'(?<=\().*?(?=\))');
    final get_x_regex = RegExp(r'.*(?=\,)');
    final get_y_regex = RegExp(r'[^,]*$');

    final point_matches = isolate_points_regex.allMatches(path_txt);

    for (final point in point_matches) {

      String point_temp = point.group(0) as String;
      final x = get_x_regex.firstMatch(point_temp)?.group(0) as String;
      final y = get_y_regex.firstMatch(point_temp)?.group(0) as String;

      var x_double = double.parse(x);
      var y_double = double.parse(y);

      Offset point_offset = Offset(x_double, y_double);

      path_out.add(point_offset);



    }


    return path_out;

  }

  build(BuildContext context) {
    return Scaffold();
  }


}