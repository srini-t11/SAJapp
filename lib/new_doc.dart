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
import 'dart:math';



class NewDocRoute extends StatefulWidget {

  User user;
  String docName;
  String relPath;
  List<DrawnLine> lines;

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
  List<DrawnLine> lines;



  String docName;
  bool savedOnce = false;
  String relPath;
  String penMode = "draw";

  List<double> selectBoxPoints = [0, 0, 0, 0];
  List<double> oldSelectBoxPoints = [0, 0, 0, 0];

  List highlightLines = [DrawnLine([], Colors.black, 5)];
  List<int> highlightLinesIndexList = [];

  double stretch = 1;
  double newStretch = 1;
  double oldStretch = 1;

  Offset fPoint = Offset(0,0);

  Offset shift = Offset(0,0);
  Offset newShift = Offset(0,0);
  Offset oldShift = Offset(0,0);

  List<DrawnLine> selectedLines = [];
  List<DrawnLine> oldSelectedLines = [];

  List<DrawnLine> copiedLines = [DrawnLine([], Colors.black, 1)];




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
                      child: DrawingSurface(context, Colors.blueGrey, selectedWidth, selectedColor),
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
          height: screen_h/7,
          color: Colors.green,
          child: MakeSelectBoxButton(context),
        ),
        Container(
          width: screen_w/5,
          color: Colors.orange,
          child: SaveButton(context),
        ),
      ],
    );
  }

  Widget MakeSelectBoxButton(BuildContext context) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Container(
        padding: EdgeInsets.all(16.0),
        //constraints: BoxConstraints.expand(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/predict_handwriting_icon.png"),
              //fit: BoxFit.contain,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                penMode = "select";
              },
              splashColor: Colors.lightGreen,
            ),
          ),
        )

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

  void showCustomMenu(BuildContext context, Offset position) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: createLongPressPopUpMenuItemList(),
    );

    // Handle the selected option
    if (result != null) {
      switch (result) {
        case 'Predict':
        // Handle Option 1
          break;
        case 'Cut':
          cutSelectedLines();
          break;
        case 'Copy':
          copySelectedLines();
          break;
        case "Paste":
          pasteCopiedLines(position);
          break;
        case 'Delete':
          deleteSelectedLines();
          break;
      }

      setState((){
        selectBoxPoints = [0,0,0,0];
        highlightLines = [DrawnLine([], Colors.black, 1)];
      });


    }
  }

  void deleteSelectedLines() {

    setState((){
      highlightLinesIndexList = createIndexOfSelectedLines(transformLines(lines, shift, stretch), selectBoxPoints);
      lines = createFilteredLinesListExcluded(lines, highlightLinesIndexList);
      highlightLines = [];
      selectedLines = [];
      selectBoxPoints = [0,0,0,0];
    });

    return;
  }

  void copySelectedLines() {
    copiedLines = [DrawnLine([], Colors.black, 1)];
    copiedLines.addAll(selectedLines);
    return;
  }

  void cutSelectedLines() {

    copySelectedLines();
    deleteSelectedLines();

    return;
  }

  void pasteCopiedLines(Offset point) {

    List<double> tightBoxForCopiedLines = createTightBoxForLines(copiedLines);
    Offset copiedLinesCenter = findCenterOfBox(tightBoxForCopiedLines);
    Offset shiftOfLinesDuringPaste = point - copiedLinesCenter;
    List<DrawnLine> linesToPaste = transformLines(copiedLines, shiftOfLinesDuringPaste/stretch, 1);

    setState((){
      lines.addAll(linesToPaste);
    });

    deleteSelectedLines();

    return;
  }



  PopupMenuItem LongPressPopUpMenuItem(String text) {
    return PopupMenuItem(
      child: Text(text),
      value: text,
    );
  }

  List<PopupMenuItem> createLongPressPopUpMenuItemList() {
    return [
      LongPressPopUpMenuItem("Predict"),
      LongPressPopUpMenuItem("Cut"),
      LongPressPopUpMenuItem("Copy"),
      LongPressPopUpMenuItem("Paste"),
      LongPressPopUpMenuItem("Delete"),
    ];
  }

  Widget DrawingSurface(BuildContext context, Color canvas_color, double selectedWidth, Color selectedColor) {




    return Container(
      color: canvas_color,
      constraints: BoxConstraints.expand(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: onScaleStart,
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: onScaleEnd,
        onTap: onTap,
        onLongPressStart: onLongPress,
        child: RepaintBoundary(
          child: Container(
            color: Colors.transparent,
            //width: MediaQuery.of(context).size.width,
            //height: MediaQuery.of(context).size.height,
            // CustomPaint widget will go here
            child: CustomPaint(
              painter: MySketcher(transformLines(lines, shift, stretch), transformLines(highlightLines, shift, stretch), selectBoxPoints),
            ),
          ),
        ),
      ), //returns a gesture detector
    );
  }

  void onScaleStart(ScaleStartDetails details) {

    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.localFocalPoint);

    highlightLinesIndexList = createIndexOfSelectedLines(transformLines(lines, shift, stretch), selectBoxPoints);
    selectedLines = createFilteredLinesListIncluded(lines, highlightLinesIndexList);

    lines = createFilteredLinesListExcluded(lines, highlightLinesIndexList);

    highlightLines = createListOfHighlightedLines(selectedLines);

    oldSelectedLines = [];
    for (int i = 0; i < selectedLines.length; i++) {
      oldSelectedLines.add(selectedLines[i]);
    }

    fPoint = point;

    oldSelectBoxPoints[0] = selectBoxPoints[0];
    oldSelectBoxPoints[1] = selectBoxPoints[1];
    oldSelectBoxPoints[2] = selectBoxPoints[2];
    oldSelectBoxPoints[3] = selectBoxPoints[3];





    bool isPointerInSelectBox = checkIfPointInBox(point, selectBoxPoints);

    if (penMode == "select") {

      setState((){
        selectBoxPoints[0] = point.dx;
        selectBoxPoints[1] = point.dx;
        selectBoxPoints[2] = point.dy;
        selectBoxPoints[3] = point.dy;
      });

      return;
    }

    if (details.pointerCount == 1 && isPointerInSelectBox == true) {
      penMode = "adjust pos";

    }


    if (details.pointerCount == 1 && isPointerInSelectBox == false) {


      setState((){
        highlightLines = [DrawnLine([], Colors.black, 5)];
        highlightLinesIndexList = [];
        selectBoxPoints = [0, 0, 0, 0];
      });


      setState((){
        if (lines.length == 1) {
          lines[lines.length - 1] = reverseTransformLine(DrawnLine([point], selectedColor, selectedWidth), shift, stretch);
        }
      });
    }

    if (details.pointerCount == 2) {

    }

  }

  void onScaleUpdate(ScaleUpdateDetails details) {



    final RenderBox box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.localFocalPoint);

    bool isPointerInSelectBox = checkIfPointInBox(point, selectBoxPoints);

    if (penMode == "select") {

      setState((){
        selectBoxPoints[1] = point.dx;
        selectBoxPoints[3] = point.dy;
      });

      return;
    }

    if (details.pointerCount == 1 && penMode == "adjust pos") {


      Offset selectedLineShift = point - fPoint;

      setState((){

        selectBoxPoints[0] = oldSelectBoxPoints[0] + selectedLineShift.dx;
        selectBoxPoints[1] = oldSelectBoxPoints[1] + selectedLineShift.dx;
        selectBoxPoints[2] = oldSelectBoxPoints[2] + selectedLineShift.dy;
        selectBoxPoints[3] = oldSelectBoxPoints[3] + selectedLineShift.dy;

        selectedLines = transformLines(oldSelectedLines, selectedLineShift/stretch, 1);
        highlightLines = createListOfHighlightedLines(selectedLines);

        highlightLinesIndexList = createIndexOfSelectedLines(transformLines(lines, shift, stretch), selectBoxPoints);

      });

      return;

    }

    if (details.scale != 1.0 && details.pointerCount > 2) {
      return;
    }

    if (details.pointerCount == 1  && isPointerInSelectBox == false && penMode == "draw") {

      final path = List.from(lines[lines.length - 1].path)..add(reverseTransformPoint(point, shift, stretch));

      setState((){
        lines[lines.length - 1] = DrawnLine(path, selectedColor, selectedWidth/1);

      });
    }

    if (details.pointerCount == 2 && isPointerInSelectBox == false) {

      setState((){

        newShift = point - fPoint;
        newStretch = details.scale;

        stretch = calcNewStretch(newStretch, oldStretch);
        shift = calcNewShift(newStretch, fPoint, newShift, oldShift);



      });

    }
  }

  void onScaleEnd(ScaleEndDetails details) {

    if (penMode == "select") {
      setState((){

        penMode = "draw";

        highlightLinesIndexList = createIndexOfSelectedLines(transformLines(lines, shift, stretch), selectBoxPoints);

        selectedLines = createFilteredLinesListIncluded(lines, highlightLinesIndexList);

        highlightLines = createFilteredLinesListIncluded(lines, highlightLinesIndexList);
        highlightLines = createListOfHighlightedLines(highlightLines);

        selectBoxPoints = createTightBoxForLines(transformLines(highlightLines, shift, stretch));
      });
      return;
    }

    if (penMode == "adjust pos") {

      lines.addAll(selectedLines);

      penMode = "draw";
      selectBoxPoints = [0,0,0,0];
      highlightLines = [DrawnLine([], Colors.black, 5)];
      highlightLinesIndexList = [];
    }

    setState((){
      if (lines[lines.length - 1].path.length >= 1) {
        lines.add(DrawnLine([], Colors.black, 5.0));
      }

      oldStretch = stretch;
      oldShift = shift;

      newShift = Offset(0,0);
      newStretch = 1;

      //prevStretch = stretch;
    });


  }

  void onTap() {
    setState((){
      highlightLines = [DrawnLine([], Colors.black, 5)];
      highlightLinesIndexList = [];
      selectBoxPoints = [0, 0, 0, 0];
    });
    return;
  }

  void onLongPress(LongPressStartDetails details) {

    final RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.localPosition);
    point = details.localPosition;

    if (highlightLinesIndexList.isNotEmpty) {



      showCustomMenu(context, point);
      return;
    } else {
      showCustomMenu(context, point);

      return;
    }


  }



}

Offset findCenterOfBox(List<double> boxAsLRTBNums) {
  double x_coord = (boxAsLRTBNums[0] + boxAsLRTBNums[1])/2;
  double y_coord = (boxAsLRTBNums[2] + boxAsLRTBNums[3])/2;
  return Offset(x_coord,y_coord);
}

double calcNewStretch(double stretchFromCurrRescale, double oldStretch) {
  double out = pow(stretchFromCurrRescale * oldStretch, 0.5).toDouble();
  return out;
}

Offset calcNewShift(double stretchFromCurrRescale, Offset focalPoint, Offset shiftFromCurrRescale, Offset oldShift) {
  double focalPoint_x = focalPoint.dx;
  double focalPoint_y = focalPoint.dy;

  double shiftFromCurrRescale_x = shiftFromCurrRescale.dx;
  double shiftFromCurrRescale_y = shiftFromCurrRescale.dy;

  double oldShift_x = oldShift.dx;
  double oldShift_y = oldShift.dy;

  double out_x = focalPoint_x + shiftFromCurrRescale_x + stretchFromCurrRescale * (oldShift_x - focalPoint_x);
  double out_y = focalPoint_y + shiftFromCurrRescale_y + stretchFromCurrRescale * (oldShift_y - focalPoint_y);

  return Offset(out_x, out_y);
}

Offset calcNewShift1(double stretchFromCurrRescale, Offset focalPoint, Offset shiftFromCurrRescale, Offset oldShift) {
  double focalPoint_x = focalPoint.dx;
  double focalPoint_y = focalPoint.dy;

  double shiftFromCurrRescale_x = shiftFromCurrRescale.dx;
  double shiftFromCurrRescale_y = shiftFromCurrRescale.dy;

  double oldShift_x = oldShift.dx;
  double oldShift_y = oldShift.dy;

  double out_x = focalPoint_x + shiftFromCurrRescale_x + stretchFromCurrRescale * (oldShift_x - focalPoint_x);
  double out_y = focalPoint_y + shiftFromCurrRescale_y + stretchFromCurrRescale * (oldShift_y - focalPoint_y);

  return Offset(out_x, out_y);
}

Offset transformPoint(Offset origPoint, Offset shift, double stretch) {
  Offset temp = Offset(stretch * origPoint.dx, stretch * origPoint.dy);
  Offset newPoint = temp + shift;

  return newPoint;
}

DrawnLine transformLine(DrawnLine line, Offset shift, double stretch) {
  List path = line.path;
  List newPath = [];
  Offset newPoint = Offset(0, 0);
  for (Offset point in path) {
    newPoint = transformPoint(point, shift, stretch);
    newPath.add(newPoint);
  }
  return DrawnLine(newPath, line.color, line.width*stretch);

}

List<DrawnLine> transformLines(List lines, Offset shift, double stretch) {
  List<DrawnLine> newLines = [];
  DrawnLine newLine = DrawnLine([], Colors.black, 5);
  for (DrawnLine line in lines) {
    newLine = transformLine(line, shift, stretch);
    newLines.add(newLine);
  }
  return newLines;

}

Offset reverseTransformPoint(Offset origPoint, Offset shift, double stretch) {
  Offset temp = origPoint - shift;
  Offset newPoint = Offset(temp.dx / stretch, temp.dy / stretch);
  return newPoint;
}

DrawnLine reverseTransformLine(DrawnLine line, Offset shift, double stretch) {
  List path = line.path;
  List newPath = [];
  Offset newPoint = Offset(0, 0);
  for (Offset point in path) {
    newPoint = reverseTransformPoint(point, shift, stretch);
    newPath.add(newPoint);
  }
  return DrawnLine(newPath, line.color, line.width/stretch);

}

List reverseTransformLines(List lines, Offset shift, double stretch) {
  List newLines = [];
  DrawnLine newLine = DrawnLine([], Colors.black, 5);
  for (DrawnLine line in lines) {
    newLine = reverseTransformLine(line, shift, stretch);
    newLines.add(newLine);
  }
  return newLines;

}

List<DrawnLine> createFilteredLinesListIncluded(List lines, List<int> includedIndices) {
  List<DrawnLine> filteredList = [];

  for (int i = 0; i < lines.length; i++) {
    if (includedIndices.contains(i)) {
      filteredList.add(lines[i]);
    }
  }

  return filteredList;
}

List<DrawnLine> createFilteredLinesListExcluded(List lines, List<int> excludedIndices) {
  List<DrawnLine> filteredList = [];

  for (int i = 0; i < lines.length; i++) {
    if (!excludedIndices.contains(i)) {
      filteredList.add(lines[i]);
    }
  }

  return filteredList;
}

List<double> createTightBoxForLines(List lines) {

  double left = double.infinity;
  double right = double.negativeInfinity;
  double top = double.infinity;
  double bottom = double.negativeInfinity;


  for (DrawnLine line in lines) {
    List<double> lineValues = createTightBoxForLine(line);

    if (lineValues.isNotEmpty) {
      double l = lineValues[0];
      double r = lineValues[1];
      double t = lineValues[2];
      double b = lineValues[3];

      left = l < left ? l : left;
      right = r > right ? r : right;
      top = t < top ? t : top;
      bottom = b > bottom ? b : bottom;
    }
  }

  if (left.isInfinite || right.isInfinite || top.isInfinite || bottom.isInfinite) {
    return [0,0,0,0];
  }

  List<double> out = [left, right, top, bottom];

  return out;
}

List<double> createTightBoxForLine(DrawnLine line) {

  List<double> out = [0, 0, 0, 0];
  List offsetList = line.path;

  if (offsetList.length == 0) {
    return [];
  }

  double left = offsetList[0].dx;
  double right = offsetList[0].dx;
  double top = offsetList[0].dy;
  double bottom = offsetList[0].dy;

  for (Offset point in offsetList) {
    if (point.dx < left) {
      left = point.dx;
    }
    if (point.dx > right) {
      right = point.dx;
    }
    if (point.dy < top) {
      top = point.dy;
    }
    if (point.dy > bottom) {
      bottom = point.dy;
    }
  }
  out[0] = left;
  out[1] = right;
  out[2] = top;
  out[3] = bottom;

  return out;
}

List<int> createIndexOfSelectedLines(List lines, List<double> boxPoints) {

  int curr_index = 0;
  List<int> out = [];



  for (DrawnLine line in lines) {

    if (checkIfAllPointsInBox(line, boxPoints) == true) {
      out.add(curr_index);
    }
    curr_index = curr_index + 1;
  }

  return out;
}

List<DrawnLine> createListOfSelectedLines(List lines, List<double> boxPoints) {

  List<DrawnLine> out = [];

  for (DrawnLine line in lines) {
    if (checkIfAllPointsInBox(line, boxPoints) == true) {
      out.add(line);
    }
  }

  return out;
}

List<DrawnLine> createListOfHighlightedLines(List lines) {

  List<DrawnLine> out = [];

  DrawnLine temp = DrawnLine([], Colors.black, 5);

  for (DrawnLine line in lines) {
    temp = DrawnLine(line.path, Color.fromRGBO(255, 255, 0, 0.5), line.width*1.3);
    out.add(temp);
  }

  if (out.length == 0) {
    return [DrawnLine([], Colors.black, 5)];
  }

  return out;
}

double proportionPointsInBox(DrawnLine line, List<double> boxPoints) {
  int pointsIn = 0;
  List offsetList = line.path;
  int totPoints = offsetList.length;

  for (Offset point in offsetList) {
    if (checkIfPointInBox(point, boxPoints) == true) {
      pointsIn = pointsIn + 1;
    }
  }

  return pointsIn/totPoints;
}

bool checkIfPropPointsInBox(DrawnLine line, List<double> boxPoints, double cutOffProp) {
  if (proportionPointsInBox(line, boxPoints) >= cutOffProp) {
    return true;
  }
  return false;
}

bool checkIfAllPointsInBox(DrawnLine line, List<double> boxPoints) {

  List offsetList = line.path;

  if (offsetList.length == 0) {
    return false;
  }

  for (Offset point in offsetList) {
    if (checkIfPointInBox(point, boxPoints) == false) {
      return false;
    }
  }
  return true;

}

bool checkIfEndPointsInBox(DrawnLine line, List<double> boxPoints) {

  List offsetList = line.path;
  int len = offsetList.length;

  if (len == 0) {
    return false;
  }

  if (checkIfPointInBox(offsetList[0], boxPoints) == true && checkIfPointInBox(offsetList[len - 1], boxPoints) == true) {
    return true;
  }

  return false;

}

bool checkIfAnyPointsInBox(DrawnLine line, List<double> boxPoints) {

  List offsetList = line.path;

  if (offsetList.length == 0) {
    return false;
  }

  for (Offset point in offsetList) {
    if (checkIfPointInBox(point, boxPoints) == true) {
      return true;
    }
  }
  return false;

}

bool checkIfPointInBox(Offset point, List<double> boxPoints) {
  double left;
  double right;
  double top;
  double bottom;

  //arrange the coordinates appropriately:

  if (boxPoints[0] <= boxPoints[1]) {
    left = boxPoints[0];
    right = boxPoints[1];
  } else {
    left = boxPoints[1];
    right = boxPoints[0];
  }

  if (boxPoints[2] <= boxPoints[3]) {
    top = boxPoints[2];
    bottom = boxPoints[3];
  } else {
    top = boxPoints[3];
    bottom = boxPoints[2];
  }

  double x = point.dx;
  double y = point.dy;

  if (x >= left && x <= right && y >= top && y <= bottom) {
    return true;
  } else {
    return false;
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

test_op(){
  print("in test op");
}






