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
import 'new_doc.dart';
import 'user_object.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:math';

class TrainingScreenRoute extends StatefulWidget {

  User user;

  String currRelativePathLeft;
  String currRelativePathMain;

  TrainingScreenRoute(this.user, this.currRelativePathLeft, this.currRelativePathMain){}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TrainingScreenRouteState(user, this.currRelativePathLeft, this.currRelativePathMain);
  }

}

class TrainingScreenRouteState extends State<TrainingScreenRoute> {

  User user;
  String currRelPathLeft;
  String currRelPathMain;
  Color selectedColor = Colors.black;
  Color penColorTextColor = Colors.white;
  double selectedWidth = 5;
  List lines = [DrawnLine([], Colors.black, 5)];
  double scale = 1.0;
  double currScale = 1.0;
  Offset f1 = Offset(0.0, 0.0);
  Offset f2 = Offset (0.0, 0.0);
  //String docName;
  bool savedOnce = false;
  //String relPath;
  late String trainDir;
  late String currDir;

  List<String?> selectedOptions =  [null];
  List<List<dynamic>> dropBoxVariablesList = [];
  String chosenCharacter = "";
  String outCharacter = "";

  List<List<String>> randomCharsAndPathsList = [];

  String textBelowCharacter = "";
  int numSamples = 0;

  TrainingScreenRouteState(this.user, this.currRelPathLeft, this.currRelPathMain);

  @override
  Widget build(BuildContext context) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    trainDir = "${this.user.root_path}/Training Data";


    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.green,
              alignment: Alignment.topCenter,
              height: screen_h/7,
              child: TrainTopBar(context),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    color: Colors.redAccent,
                    alignment: Alignment.topCenter,
                    width: screen_w/4.5,
                    child: leftTrainPanel(context, currRelPathLeft),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey,
                      //padding: EdgeInsets.all(10),
                      child: centerTrainPanel(context, currRelPathMain),
                    ),
                  ),
                  Container(
                    color: Colors.redAccent,
                    alignment: Alignment.topCenter,
                    width: screen_w/4.5,
                    child: rightTrainPanel(context, currRelPathLeft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget TrainTopBar(BuildContext context) {
    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          //constraints: BoxConstraints,
          height: screen_h/7,
          width: screen_w/5,
          color: Colors.blue,
          child: TrainSettingsWidget(context),
        ),
        Container(
          width: screen_w/5,
          height: screen_h/7,
          //color: Colors.greenAccent,
          child: ColorPickerWidget(context),
        ),
        Container(
          width: screen_w/5,
          color: Colors.orange,
          child: SizeSLider(context),
        ),
      ],
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

  Widget TrainSettingsWidget(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.0),
        //constraints: BoxConstraints.expand(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/train_settings_icon.png"),
              //fit: BoxFit.contain,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              splashColor: Colors.blueAccent,
            ),
          ),
        )

    );
  }

  Widget rightTrainPanel(BuildContext context, String currRelPathLeft) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: (screen_w/4) - 50,
          height: screen_h/4,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                lines = [DrawnLine([], Colors.black, 5)];
              });
            },
            child: Text('Clear', style: TextStyle(fontSize: screen_h/20)),
          ),
        ),
        Container(
          width: (screen_w/4) - 50,
          height: screen_h/4,
          child: ElevatedButton(
            onPressed: () {

              if (outCharacter != "" && chosenCharacter == outCharacter) {
                int numFiles = getNumFilesinDir(currDir);
                String newFName = chosenCharacter + numFiles.toString();
                saveDoc(currDir, newFName, DocObject(lines));
                setState(() {
                  lines = [DrawnLine([], Colors.black, 5)];
                });
                if (selectedOptions.contains("Random")) {
                  int n = getRandomNumber(randomCharsAndPathsList.length);
                  currDir = randomCharsAndPathsList[n][1];
                  chosenCharacter = randomCharsAndPathsList[n][0];
                  outCharacter = chosenCharacter;

                  setState(() {
                    numSamples = numFiles + 1;
                    textBelowCharacter = currDir + "\nSample Number: " + numSamples.toString();
                  });

                }
                setState(() {
                  numSamples = getNumFilesinDir(currDir) + 1;
                  textBelowCharacter = currDir + "\nSample Number: " + numSamples.toString();
                });
              } else {
                userWarningDialog(context, "Error!", "A character hasn't been chosen yet.\nTry again after choosing a character and hitting Enter.", "OK");
              }
            },
            child: Text('Train', style: TextStyle(fontSize: screen_h/20)),
          ),
        ),
      ],
    );

  }

  Widget centerTrainPanel(BuildContext context, String currRelPathLeft) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: (screen_w/2) - 10,
          height: screen_h/2.5,
          color: Colors.pink,
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(outCharacter, style: TextStyle(fontSize: screen_h/10), textAlign: TextAlign.center,),
                    Text(textBelowCharacter, style: TextStyle(fontSize: screen_h/65), textAlign: TextAlign.center,)
                  ]
              )
          )
        ),
        Container(
          width: (screen_w/2) - 10,
          height: screen_h/2.5,
          child: DrawingSurface(context, lines, Colors.pinkAccent, selectedWidth, selectedColor),
        ),
      ],
    );

  }

  Widget leftTrainPanel(BuildContext context, String currRelPathLeft) {

    if (dropBoxVariablesList.length == 0) { //if t

      setState(() {
        List<String> opts = ["Random", "Choose Char"];
        dropBoxVariablesList.add([opts, boxSelectOperation, 0]);
      });

    }

    List<Widget> dropDownBoxList = createDropDownBoxesFromVariablesList(context, dropBoxVariablesList);
    double screen_h = MediaQuery.of(context).size.height;

    if (chosenCharacter != "") {
      dropDownBoxList.add(createEnterButton(context));
    }

    return ListView.separated(

      separatorBuilder: (context, index) => SizedBox(height: screen_h/10),
      itemBuilder: (context, index) => dropDownBoxList[index],
      itemCount: dropDownBoxList.length,

        //children: dropDownBoxList
    );

  }

  Widget createDropDownBox(BuildContext context, List<String> options, Function operation, int boxIndex) {

    double screen_h = MediaQuery.of(context).size.height;

    return DropdownButton<String>(
      value: selectedOptions[boxIndex],
      hint: Text('Select', style: TextStyle(fontSize: screen_h/20)),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: TextStyle(fontSize: screen_h/20)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedOptions[boxIndex] = newValue!;
          boxSelectOperation(boxIndex, newValue, trainDir);
        });
      },
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

  Widget createEnterButton(BuildContext context) {
    //Unused Button

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Padding(
        padding:  EdgeInsets.symmetric(horizontal: screen_w/30),
        child: ElevatedButton(
            onPressed: () {
              enterButtonPressed();
              },
            child: Text('Enter', style: TextStyle(fontSize: screen_h/30))
        )
    );
  }

  List<Widget> createDropDownBoxesFromVariablesList(BuildContext context, List<List<dynamic>> dropBoxVariablesList) {
    List<Widget> out = [];

    for (List<dynamic> dropBoxVariables in dropBoxVariablesList) {
      out.add(createDropDownBox(context, dropBoxVariables[0], dropBoxVariables[1], dropBoxVariables[2]));
    }
    return out;
  }

  boxSelectOperation(int boxIndex, String selectedOption, String currentDir) {

    if(boxIndex == 0) {
      currDir = currentDir;
    }

    List<String> nextBoxOptions;

    if (boxIndex != dropBoxVariablesList.length - 1) {
      //if we are not on the last box.

      chosenCharacter = "";
      outCharacter = "";
      textBelowCharacter = "";
      dropBoxVariablesList = dropBoxVariablesList.sublist(0, boxIndex + 1);
      selectedOptions = selectedOptions.sublist(0, boxIndex + 1);
      selectedOptions.add(null);
      //re-create the current dir
      currDir = trainDir;
      for (String? option in selectedOptions) {
        if (option != "Choose Char" && option != null && option != selectedOption) {
          currDir = currDir + "/" + option;
        }
      }

      if (selectedOption == "Choose Char") {
        currDir = trainDir;
        nextBoxOptions = getDirFolders(currDir);
        dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      }
      else if (selectedOption == "Random" && boxIndex == 0) {
        createListToChooseFromRandomly(trainDir);
        int n = getRandomNumber(randomCharsAndPathsList.length);
        currDir = randomCharsAndPathsList[n][1];
        chosenCharacter = randomCharsAndPathsList[n][0];
        nextBoxOptions = getDirFolders(currDir);
        //dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      } else if (selectedOption == "Random") {
        createListToChooseFromRandomly(currDir);
        int n = getRandomNumber(randomCharsAndPathsList.length);
        currDir = randomCharsAndPathsList[n][1];
        chosenCharacter = randomCharsAndPathsList[n][0];
        nextBoxOptions = getDirFolders(currDir);
        //dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      } else {
        currDir = currDir + "/" + selectedOption;
        nextBoxOptions = getDirFolders(currDir);
        if (boxIndex >= 1 && nextBoxOptions.length > 0) {
          nextBoxOptions.add("Random");
        }
        dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      }

      return;
    }

    if (selectedOption == "Choose Char") {
      nextBoxOptions = getDirFolders(currDir);
      dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      selectedOptions.add(null);
    }
    else if (selectedOption == "Random" && boxIndex == 0) {
      nextBoxOptions = getDirFolders(currDir);
      createListToChooseFromRandomly(trainDir);
      int n = getRandomNumber(randomCharsAndPathsList.length);
      currDir = randomCharsAndPathsList[n][1];
      chosenCharacter = randomCharsAndPathsList[n][0];
    }
    else {
      currDir = trainDir;
      for (String? option in selectedOptions) {
        if (option != "Choose Char" && option != null && option != selectedOption) {
          currDir = currDir + "/" + option;
        }
      }

      if (selectedOption == "Random" && boxIndex >= 1) {
        createListToChooseFromRandomly(currDir);
        int n = getRandomNumber(randomCharsAndPathsList.length);
        currDir = randomCharsAndPathsList[n][1];
        chosenCharacter = randomCharsAndPathsList[n][0];
        nextBoxOptions = getDirFolders(currDir);
        //dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      } else {
        currDir = currDir + "/" + selectedOption;
        nextBoxOptions = getDirFolders(currDir);
      }

      if (boxIndex >= 1 && nextBoxOptions.length > 0) {
        nextBoxOptions.add("Random");
      }
      dropBoxVariablesList.add([nextBoxOptions, boxSelectOperation, boxIndex + 1]);
      selectedOptions.add(null);
    }

    if (nextBoxOptions.length == 0) {

      dropBoxVariablesList.removeLast();
      if (selectedOption == "Random") {
        chosenCharacter = basename(currDir);
      } else {
        chosenCharacter = selectedOption;
      }

      outCharacter = "";
      textBelowCharacter = "";
    } else if (selectedOption != "Random") {
      chosenCharacter = "";
      outCharacter = "";
      textBelowCharacter = "";

    }

    return;
  }

  enterButtonPressed() {

    int numSamples = getDirFiles(currDir).length + 1;

    setState(() {
      outCharacter = chosenCharacter;
      textBelowCharacter = currDir + "\nSample Number: " + numSamples.toString();
    });
    return;
  }

  createListToChooseFromRandomly(String pathToInitialFolder){
    randomCharsAndPathsList = [];
    List<String> foldsInside = getDirFolders(pathToInitialFolder);
    fillInRandomCharsAndPathsList(pathToInitialFolder, foldsInside);
    return;
  }

  fillInRandomCharsAndPathsList(String absPath, List<String> folds) {

    if (folds.length == 0) {
      String charName = basename(absPath);
      randomCharsAndPathsList.add([charName, absPath]);
      return;
    }

    for (String fold in folds) {
      String foldAbsPath = absPath + "/" + fold;
      List<String> foldsInside = getDirFolders(foldAbsPath);
      fillInRandomCharsAndPathsList(foldAbsPath, foldsInside);
    }

  }



}

List<String> getDirFiles(String folderPath) {
  //Returns a list of names of files in directory as String

  Directory dir = Directory(folderPath);

  List<FileSystemEntity> files = dir.listSync();

  List<String> out = [];

  for (FileSystemEntity file in files) {
    if (file is File) {
      String fname = basename(file.path);
      out.add(fname);
    }


  };

  return out;
}

List<String> getDirFolders(String folderPath) {
  //Returns a list of names of folders in directory as String

  Directory dir = Directory(folderPath);

  List<FileSystemEntity> files = dir.listSync();

  List<String> out = [];

  for (FileSystemEntity file in files) {

    if (file is Directory) {
      String fname = basename(file.path);
      out.add(fname);
    }


  };

  return out;
}

Color getContrastingTextColor(Color backgroundColor) {
  // Calculate the luminance of the background color
  double bgLuminance = backgroundColor.computeLuminance();

  // Choose white or black as the contrasting text color
  return bgLuminance > 0.5 ? Colors.black : Colors.white;
}

int getNumFilesinDir(String filePath) {
  List<String> fList = getDirFiles(filePath);
  return fList.length;
}

int getNumFoldersinDir(String folderPath) {
  List<String> fList = getDirFolders(folderPath);
  return fList.length;
}

int getRandomNumber(int n) {
  DateTime now = DateTime.now();
  Random random = Random(now.millisecondsSinceEpoch % 100000);
  return random.nextInt(n);
}

Future<void> saveDoc(String absPath, String file_name, DocObject doc_obj) async {

  String f_content = doc_obj.convertToText();

  writeData(absPath, file_name, f_content);

}

Future<void> writeData(String absPath, String file_name, String text) async {

  final myFile = File('$absPath/$file_name');
  // If data.txt doesn't exist, it will be created automatically

  await myFile.writeAsString(text);

}

Future<void> userWarningDialog(BuildContext context, String title, String content, String buttonText) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(buttonText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}




















