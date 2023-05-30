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


class FileManagerRoute extends StatefulWidget {

  User user;

  String currRelativePathLeft;
  String currRelativePathMain;

  FileManagerRoute(this.user, this.currRelativePathLeft, this.currRelativePathMain){}

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FileManagerRouteState(user, this.currRelativePathLeft, this.currRelativePathMain);
  }

}

class FileManagerRouteState extends State<FileManagerRoute> {

  //String? currDirPath = null;



  User user;
  String currRelPathLeft;
  String currRelPathMain;

  FileManagerRouteState(this.user, this.currRelPathLeft, this.currRelPathMain);

  @override
  Widget build(BuildContext context) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.green,
              alignment: Alignment.topCenter,
              height: screen_h/7,
              child: FileManagerTopBar(context, user, currRelPathLeft),
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    color: Colors.blueGrey,
                    alignment: Alignment.topCenter,
                    width: screen_w/3,
                    child: sideFilePanel(context, currRelPathLeft),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey,
                      //padding: EdgeInsets.all(10),
                      child: mainFilePanel(context, currRelPathMain),
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

  Widget FileManagerTopBar(BuildContext context, User user, String relPath) {
    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          //constraints: BoxConstraints,
          //height: screen_h/7,
          width: screen_w/3,
          //color: Colors.orangeAccent,
          child: Text("  File Manager  :",
            style: TextStyle(fontSize: screen_h/20),
          ),
        ),
        Container(
          width: screen_w*3/5,
          //height: screen_h/7,
          child: currentDirWidget(context, relPath),
        ),
        Container(
            width: screen_w*1/15,
            color: Colors.lightGreen,
          child: Center(
            child: newFileOrFolderButtonWidget(context),
          )
          ),
      ],
    );
  }

  Widget newFileOrFolderButtonWidget(BuildContext context) {

    //double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    String absolutePath = "${user.app_root_dir}/$currRelPathMain";
    List lines = [DrawnLine([], Colors.black, 5.0)];
    DocObject emptyDocObj =  DocObject(lines);

    return PopupMenuButton<int>(
      icon: Image.asset('assets/images/new_icon.png'),
      itemBuilder: (context) => [
        // popupmenu item 1
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Container(
                width: screen_w/30,
                //height: screen_h/50,
                child: Image.asset('assets/images/file_icon.png'),
              ),
              const SizedBox(
                // sized box with width 10
                width: 10,
              ),
              const Text("Create File")
            ],
          ),
        ),
        // popupmenu item 2
        PopupMenuItem(
          value: 2,
          // row has two child icon and text
          child: Row(
            children: [
              SizedBox(
                width: screen_w/30,
                //height: screen_h/50,
                child: Image.asset('assets/images/folder_icon.png'),
              ),
              const SizedBox(
                // sized box with width 10
                width: 10,
              ),
              const Text("Create Folder")
            ],
          ),
        ),
      ],
      //offset: Offset(0, 100),
      elevation: 20,
      // on selected we show the dialog box
      onSelected: (value) async {
        // if value 1 show dialog
        if (value == 1) {

          String? fileName = await _getNameFromDialogBox(context, "File Name", "Untitled");


          String absFPath = "${user.app_root_dir}/$currRelPathMain/${fileName!}";
          File file = File(absFPath);
          // Check if the file exists
          bool fileExists = file.existsSync();

          if (fileExists){
            userWarningDialog(context, "Error: File Already Exists", "Be creative with your file names, this one already exists in the folder.", "Ok");
            return;
          }

          saveDoc(currRelPathMain, fileName, emptyDocObj);
          // if value 2 show dialog
        } else if (value == 2) {

          String? folderName = await _getNameFromDialogBox(context, "Folder Name", "Untitled");

          createDirectory(folderName!, absolutePath);
        }
      },
    );
  }

  Widget currentDirWidget(BuildContext context, String relPath) {
    double screen_h = MediaQuery.of(context).size.height;
    //double screen_w = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.green,
      child: Text(relPath,
        style: TextStyle(fontSize: screen_h/20),
      ),
    );
  }

  Widget sideFilePanel(BuildContext context, String currRelPathLeft) {

    //double screen_h = MediaQuery.of(context).size.height;
    //double screen_w = MediaQuery.of(context).size.width;

    String fold_path = user.app_root_dir + "/" + currRelPathLeft;

    List<Widget> arr = listOfLeftFolders(context, fold_path, basename(currRelPathMain));

    return ListView(
      children: arr,
    );

  }

  Widget leftPanelFolderWidget(BuildContext context, String fName, bool isSelected) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    Color color;

    if (isSelected) {
      color = Colors.lightGreen;
    } else {
      color = Colors.blue;
    }

    //const val = screen_h/20;

    return Container(
      padding: const EdgeInsets.all(5),
      height: screen_h/8,
      //color: Colors.blueGrey,
      child: Material(
        color: color,
        child: InkWell(
          onTap: () => goToFolderFromLeftPanel(context, fName, user, currRelPathLeft, currRelPathMain),
          child: Center(
            child: Row(
              children: <Widget>[
                Container(
                  width: screen_w/50,
                ),
                Image.asset('assets/images/folder_icon.png', height: screen_h/12),
                Container(
                  width: screen_w/50,
                ),
                Expanded(
                    child: Text(fName, style: TextStyle(fontSize: screen_h/25), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Widget mainFilePanel(BuildContext context, String currRelPathMain) {

    //double screen_h = MediaQuery.of(context).size.height;
    //double screen_w = MediaQuery.of(context).size.width;


    String fold_path = user.app_root_dir + "/" + currRelPathMain;

    var arr = listOfMainFiles(context, fold_path);
    arr.addAll(listOfMainFolders(context, fold_path));

    return ListView(
      children: arr,
    );

  }

  Widget mainPanelFWidget(BuildContext context, String fName, bool isFolder) {

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    String img_asset_str;

    if (isFolder) {
      img_asset_str = 'assets/images/folder_icon.png';
    } else {
      img_asset_str = 'assets/images/file_icon.png';
    }

    //const val = screen_h/20;

    return Container(
      padding: const EdgeInsets.all(5),
      height: screen_h/12,
      color: Colors.blueGrey,
      child: Material(
        color: Colors.lightGreen,
        child: InkWell(
          onTap: () => mainPanelFPressed(context, fName, user, currRelPathLeft, currRelPathMain, isFolder),
          child: Center(
            child: Row(
              children: <Widget>[
                Container(
                  width: screen_w/50,
                ),
                Image.asset(img_asset_str, height: screen_h/15),
                Container(
                  width: screen_w/50,
                ),
                Expanded(
                  child: Text(fName, style: TextStyle(fontSize: screen_h/30), overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                IconButton(
                  icon: Image.asset('assets/images/delete_icon.png', height: screen_h/25),
                  iconSize: screen_h/15,
                  onPressed: () => deleteF(context, fName, user, currRelPathMain, currRelPathLeft, isFolder),
                ),
                IconButton(
                  icon: Image.asset('assets/images/options_icon.png', height: screen_h/15),
                  iconSize: screen_h/15,
                  onPressed: () {},
                ),

              ],
            ),
          ),

        ),
      ),
    );
  }

  List<Widget> listOfLeftFolders(BuildContext context, String folderPath, String selectedFolderName) {

    //returns a list of 'leftPanelFolderWidget';

    var leftFileWidge;

    List<String> filesAsStrings = getDirFolders(folderPath);
    var out_arr = <Widget> [];

    for (String fileName in filesAsStrings) {
      if (fileName == selectedFolderName) {
        leftFileWidge = leftPanelFolderWidget(context, fileName, true);

      } else {
        leftFileWidge = leftPanelFolderWidget(context, fileName, false);
      }

      out_arr.add(leftFileWidge);


    }

    return out_arr;
  }

  List<Widget> listOfMainFiles(BuildContext context, String folderPath) {

    //returns a list of 'leftPanelFolderWidget';

    var mainFileWidge;

    List<String> filesAsStrings = getDirFiles(folderPath);
    var out_arr = <Widget> [];

    for (String fileName in filesAsStrings) {

      mainFileWidge = mainPanelFWidget(context, fileName, false);

      out_arr.add(mainFileWidge);

    };

    return out_arr;
  }

  List<Widget> listOfMainFolders(BuildContext context, String folderPath) {

    //returns a list of 'leftPanelFolderWidget';

    var mainFileWidge;

    List<String> filesAsStrings = getDirFolders(folderPath);
    var out_arr = <Widget> [];

    for (String fileName in filesAsStrings) {

      mainFileWidge = mainPanelFWidget(context, fileName, true);

      out_arr.add(mainFileWidge);

    };

    return out_arr;
  }

  Future<String?> _getNameFromDialogBox(BuildContext context, String titleString, String hintText) async {
    TextEditingController textFieldController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleString),
          content: TextField(
            controller: textFieldController,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                String inputValue = textFieldController.text;
                Navigator.of(context).pop(inputValue);
              },
            ),
          ],
        );
      },
    );
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

Future<void> saveDoc(String relPath, String file_name, DocObject doc_obj) async {

  String f_content = doc_obj.convertToText();

  writeData(relPath, file_name, f_content);

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

Future<String?> readData(String relPath, String file_name) async {

  final dirPath = await _getDirPath();
  final myFile = File('$dirPath/$relPath/$file_name');
  String data = await myFile.readAsString(encoding: utf8);


  return data;
}

String getFileNameFromPath(String path) {
  return basename(path);
}

void goToFolderFromLeftPanel(BuildContext context, String foldName, User u, String currRelPathLeft, String currRelPathMain) {


  String newRelPathMain = currRelPathLeft + "/" + foldName + "/";

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FileManagerRoute(u, currRelPathLeft, newRelPathMain)),
    );

  }
  );
}

void mainPanelFPressed(BuildContext context, String fName, User u, String currRelPathLeft, String currRelPathMain, bool isFolder) async {
  List drawnLines = [];
  if (isFolder) {
    goToFolderFromMainPanel(context, fName, u, currRelPathLeft, currRelPathMain);
  } else {
    String? fileAsText = await readData(currRelPathMain, fName);

    drawnLines = DocObject([]).convertTextToDocLines(fileAsText);
    drawnLines.add(DrawnLine([], Colors.black, 5));
    goToFileFromMainPanel(context, u, fName, currRelPathMain, drawnLines);
  }

  return;
}

void goToFileFromMainPanel(BuildContext context, User user, String fileName, String relPath, List drawnLines) {

  //String absPath = "${user.app_root_dir}/$relPath/$fileName";
  //String fileAsText = ;


  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewDocRoute(user, relPath, fileName, drawnLines)),
    );
  }
  );
}

void goToFolderFromMainPanel(BuildContext context, String foldName, User u, String currRelPathLeft, String currRelPathMain) {


  String newRelPathLeft = currRelPathMain;
  String newRelPathMain = currRelPathMain + "/" + foldName + "/";

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileManagerRoute(u, newRelPathLeft, newRelPathMain)),
    );
  }
  );
}

void deleteF(BuildContext context, String fName, User user, String relPathMain, String relPathLeft, bool isFolder) async {

  String fAbsPath = "${user.app_root_dir}/$relPathMain$fName";

  bool? wantsToDelete = await deleteConfirmationDialog(context, fName);

  if (wantsToDelete != true) {
    return;
  } else if (isFolder) {
    Directory dir = Directory(fAbsPath);
    dir.deleteSync(recursive: true);


  } else {
    File fil = File(fAbsPath);
    fil.deleteSync(recursive: true);

  }

  goToFolderFromLeftPanel(context, getFileNameFromPath(relPathMain), user, relPathLeft, relPathMain);

  return;

}

Future<bool?> deleteConfirmationDialog(BuildContext context, String fName) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to delete $fName?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
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



















