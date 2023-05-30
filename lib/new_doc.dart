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
import 'pdf_object.dart';
import 'user_object.dart';



class NewDocRoute extends StatefulWidget {

  User user;
  String docName;
  String relPath;
  List lines;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NewDocRouteState(this.user, this.relPath, this.docName, this.lines);
  }

  NewDocRoute(this.user, this.relPath, this.docName, this.lines);


}

class NewDocRouteState extends State<NewDocRoute> {

  User user;
  Color selectedColor = Colors.black;
  double selectedWidth = 5;
  List lines;
  double scale = 1.0;
  double currScale = 1.0;
  Offset f1 = Offset(0.0, 0.0);
  Offset f2 = Offset (0.0, 0.0);
  String docName;
  bool savedOnce = false;
  String relPath;



  NewDocRouteState(this.user, this.relPath, this.docName, this.lines);


  @override
  Widget build(BuildContext context) {


    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              width: screen_w,
              color: Colors.black,
              child: FileNameField(context)
            ),

            Container(
              color: Colors.green,
              alignment: Alignment.topCenter,
              height: screen_h/7,
              child: DocTopBar(context),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    color: Colors.red,
                    alignment: Alignment.topCenter,
                    width: screen_w/7,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.yellow,
                      padding: EdgeInsets.all(10),
                      //alignment: Alignment.topCenter,
                      //height: screen_h/7,
                      child: DrawingSurface(context, lines, Colors.blueGrey, selectedWidth, selectedColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DocTopBar(BuildContext context) {
    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          //constraints: BoxConstraints,
          height: screen_h/7,
          width: screen_w/5,
          color: Colors.orangeAccent,
          child: ColorPickerWidget(context),
        ),
        Container(
          width: screen_w/5,
          color: Colors.greenAccent,
          child: SizeSLider(context),
        ),
        Container(
          width: screen_w/5,
          height: screen_h/7,
          color: Colors.orange,
          child: EraseAll(context),
        ),
        Container(

          width: screen_w/5,
          color: Colors.orange,
          child: SaveButton(context),
        ),
      ],
    );
  }

  Widget SaveButton(BuildContext context) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(16.0),
      //constraints: BoxConstraints.expand(),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/save_icon.png"),
            //fit: BoxFit.contain,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              saveDoc(relPath, docName, DocObject(lines));
            },
            splashColor: Colors.orange,
          ),
        ),
      )

    );

  }

  Widget FileNameField(BuildContext context) {
    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        width: screen_w/4,
        height: screen_h/15,
        color: Colors.grey,
        child: Text(docName),
      ),
    );
  }

  Widget ColorPickerWidget(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed))
              return selectedColor;//Colors.purple;
            return selectedColor;//Colors.purpleAccent; // Use the component's default.
          },
        ),
      ),
      onPressed: (){
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text('Pick a color!'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: selectedColor, //default color
                    onColorChanged: (Color color){ //on color picked
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('DONE'),
                    onPressed: () {
                      Navigator.of(context).pop(); //dismiss the color picker
                    },
                  ),
                ],
              );
            }
        );

      },
      child: Text("Pen Color", style: TextStyle(color: getContrastingTextColor(selectedColor)),),
    );
  }

  Widget SizeSLider(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text("Pen Size:"),
        ),
        Container(
            child: SliderTheme(
              data: SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: selectedWidth/2),
              ),
              child: Slider(
                value: selectedWidth,
                onChanged: (newWidth) {
                  setState(() => selectedWidth = newWidth);
                },
                divisions: 99,
                min: 1,
                max: 100,
                label: selectedWidth.toInt().toString(),
              ),
            )
        ),
      ],
    );
  }

  Widget EraseAll(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          lines = [DrawnLine([], Colors.black, 5)];
        });
      },
      child: Text('Clear All'),
    );
  }

  Widget DrawingSurface(BuildContext context, List lines, Color canvas_color, double selectedWidth, Color selectedColor) {

    List transformedLines(List lines) {
      List tranf_lines = [];

      for (int i = 0; i < lines.length; ++i) {
        List temp_path = lines[i].path.map((p) => f2 + (p - f1)*currScale).toList();
        Color temp_color = lines[i].color;
        double temp_width = lines[i].width*currScale;
        tranf_lines.add(DrawnLine(temp_path, temp_color, temp_width));
      }

      return tranf_lines;

    }

    Offset reverseTransformedPoint(Offset point) {
      Offset point_out = f1 + (point - f2) / currScale;
      return point_out;
    }

    List reverseTransformedPath(List path) {
      List path_out = path.map((p) => f1 + (p - f2) / currScale).toList();
      return path_out;
    }

    DrawnLine reverseTransformedLine(DrawnLine line){
      List path_out = line.path.map((p) => f1 + (p - f2) / currScale).toList();
      Color color_out = line.color;
      double width_out = line.width/currScale;

      DrawnLine line_out = DrawnLine(path_out, color_out, width_out);

      return line_out;
    }

    void onScaleStart(ScaleStartDetails details) {

      if (details.pointerCount == 1) {

        final RenderBox box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.localFocalPoint);

        setState((){
          if (lines.length == 1) {
            lines[lines.length - 1] = reverseTransformedLine(DrawnLine([point], selectedColor, selectedWidth));
          }
        });
      }

      if (details.pointerCount == 2) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final f_point = box.globalToLocal(details.localFocalPoint);

        setState((){
          f1 = f_point;
          f2 = f_point;
        });

      }

    }

    void onScaleUpdate(ScaleUpdateDetails details) {


      if (details.scale != 1.0 && details.pointerCount > 2) {
        return;
      }

      if (details.pointerCount == 1) {
        final box = context.findRenderObject() as RenderBox;
        final point = box.globalToLocal(details.localFocalPoint);

        final path = List.from(lines[lines.length - 1].path)..add(reverseTransformedPoint(point));

        setState((){
          lines[lines.length - 1] = DrawnLine(path, selectedColor, selectedWidth/currScale);

        });
      }

      if (details.pointerCount == 2) {

        final box = context.findRenderObject() as RenderBox;
        final f_point = box.globalToLocal(details.localFocalPoint);

        setState((){
          currScale = scale*details.scale;
          f2 = f_point;
        });

      }
    }

    void onScaleEnd(ScaleEndDetails details) {

      setState((){
        if (lines[lines.length - 1].path.length >= 1) {
          lines.add(DrawnLine([], Colors.black, 5.0));
        }
        scale = currScale;
      });


    }


    return Container(
      color: canvas_color,
      constraints: BoxConstraints.expand(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: onScaleStart,
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: onScaleEnd,
        child: RepaintBoundary(
          child: Container(
            color: Colors.transparent,
            //width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height,
            // CustomPaint widget will go here
            child: CustomPaint(
              painter: MySketcher(transformedLines(lines)),
            ),
          ),
        ),
      ), //returns a gesture detector
    );
  }

}



Future<void> saveDoc(String relPath, String file_name, DocObject doc_obj) async {


  String f_content = doc_obj.convertToText();

  writeData(relPath, file_name, f_content);

  //readData(f_name);

}

Future<String> _getDirPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> createDirectory(String folderName, String path) async {

  final Directory _folderToCreate = Directory('${path}/${folderName}/');

  if(await _folderToCreate.exists()){ //if folder already exists return path
    return _folderToCreate.path;
  }else{//if folder not exists create folder and then return its path
    final Directory _folderToCreateNew=await _folderToCreate.create(recursive: true);
    return _folderToCreateNew.path;
  }

}

Future<void> writeData(String relPath, String file_name, String text) async {
  final String dirPath = await _getDirPath();

  String absPath = "$dirPath/$relPath";

  final myFile = File('$absPath/$file_name');
  // If data.txt doesn't exist, it will be created automatically



  await myFile.writeAsString(text);

}

Future<String> readData(String relPath, String file_name) async {

  final dirPath = await _getDirPath();
  final myFile = File('$dirPath/$relPath/$file_name');
  final String data = await myFile.readAsString(encoding: utf8);

  return data;
}

Color getContrastingTextColor(Color backgroundColor) {
  // Calculate the luminance of the background color
  double bgLuminance = backgroundColor.computeLuminance();

  // Choose white or black as the contrasting text color
  return bgLuminance > 0.5 ? Colors.black : Colors.white;
}




