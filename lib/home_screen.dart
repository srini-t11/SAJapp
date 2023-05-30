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
import 'file_manager.dart';
import 'user_object.dart';
import 'training_screen.dart';




class HomeScreenRoute extends StatelessWidget {
  User user;

  String currRelativePathLeft;
  String currRelativePathMain;

  //number of times smaller the icon width and height are in relation to 4 buttons area

  //key for container 4 buttons are in

  HomeScreenRoute(this.user, this.currRelativePathLeft, this.currRelativePathMain);

  //builds the home screen template
  @override
  Widget build(BuildContext context){

    //String rootFolderName = _getDirPath().then((String rootDir){
      //createDirectory("testFolder", rootDir);
    //});

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.grey,
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Container(
              color: Colors.green,
              alignment: Alignment.topLeft,
              height: screen_h/5,
              width: 9*screen_w/10,
              child: Center(
                child: Container(
                  color: Colors.red,
                  alignment: Alignment.topLeft,
                  height: screen_h/5,
                  width: screen_w/5,
                  child: Center(
                    child: Card(
                      color: Colors.yellow,
                      elevation: 50,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: IconButton(
                              icon: Image.asset('assets/images/profile_icon.png'),
                              iconSize: screen_w/11,
                              onPressed: () {},
                            ),
                          ),
                          Text('Profile'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(50),
                color: Colors.purple,
                alignment: Alignment.topLeft,
                width: 9*screen_w/10,
                child: Container(
                  color: Colors.amber,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Card(
                                    color: Colors.teal,
                                    elevation: 10,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: IconButton(
                                            icon: Image.asset('assets/images/new_doc_icon.png'),
                                            iconSize: screen_w/11,
                                            onPressed: () {
                                              sendToNewDoc(context);
                                            },
                                              ),
                                              ),
                                              Text('New Document'),
                                              ],
                                              ),
                                              ),
                                              ),
                                Expanded(
                                  child: Card(
                                    color: Colors.teal,
                                    elevation: 10,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: IconButton(
                                            icon: Image.asset('assets/images/manage_files_icon.png'),
                                            iconSize: screen_w/11,
                                            onPressed: () {
                                              sendToFileManager(context, this.user);
                                              },
                                          ),
                                        ),
                                        Text('Manage Files'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Card(
                                    color: Colors.teal,
                                    elevation: 10,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: IconButton(
                                            icon: Image.asset('assets/images/train_icon.png'),
                                            iconSize: screen_w/11,
                                            onPressed: () {
                                              sendToTraining(context, this.user);
                                            },
                                          ),
                                        ),
                                        Text('Train Handwriting'),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Card(
                                    color: Colors.teal,
                                    elevation: 10,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: IconButton(
                                            icon: Image.asset('assets/images/verify_icon.png'),
                                            iconSize: screen_w/11,
                                            onPressed: () {},
                                          ),
                                        ),
                                        Text('Verify Symbols'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ]
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  //sends to new doc page when new document button is pushed
  Future<void> sendToNewDoc(BuildContext context) async {
    String? fileName = await _getNameFromDialogBox(context, "File Name:", "Untitled");

    String absFPath = "${user.root_path}/${fileName!}";
    File file = File(absFPath);
    // Check if the file exists
    bool fileExists = file.existsSync();

    if (fileExists){
      userWarningDialog(context, "Error: File Already Exists", "Be creative with your file names, this one already exists in the folder.", "Ok");
      return;
    }

    String nonNullableStringFileName = fileName;
    if (nonNullableStringFileName == '') {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewDocRoute(user, "${user.username}/root", nonNullableStringFileName, [DrawnLine([], Colors.black, 5)])),
      );
    }
    );
  }

  //sends to training page when train button is pushed
  Future<void> sendToTraining(BuildContext context, User u) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrainingScreenRoute(u, u.username + "/", u.username + "/root/")),
      );
    }
    );
  }

}







//fills space available with colored block
Widget filler(Color c) {
  return Container(
    color: c,
  );
}

//sends to file manager page when files button is pushed
Future<void> sendToFileManager(BuildContext context, User u) async {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileManagerRoute(u, u.username + "/", u.username + "/root/")),
    );
  }
  );
}

Future<String> _getRootDirPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> createDirectory(String folderName, String path) async {

  final Directory _folderToCreate = Directory('${path}/${folderName}/');

  if(await _folderToCreate.exists()){ //if folder already exists return path
    return _folderToCreate.path;
  }else{//if folder does not exist, creates folder and then return its path
    final Directory _folderToCreateNew=await _folderToCreate.create(recursive: true);
    return _folderToCreateNew.path;
  }

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