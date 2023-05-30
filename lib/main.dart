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

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  String user_name = "srini11";

  String appRootDirPath = await _getDirPath();



  String userPath = await createDirectory(user_name, appRootDirPath);

  String userRootPath = await createDirectory("root", userPath);

  //temporary user
  User u = User(user_name, appRootDirPath, userRootPath, userPath);

  //------------------------->Start of temporary deletable code, written for convenience:

  createConvenienceFolders(userRootPath);

  return runApp(MaterialApp(
    home: HomeScreenRoute(u, u.username + "/", u.username + "/root/"),
  )
  );
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

Future<void> createConvenienceFolders(String userRootPath) async {

  String trainDir = await createDirectory("Training Data", userRootPath);

  String letsDir = await createDirectory("Letters", trainDir);
  String numsDir = await createDirectory("Numbers", trainDir);
  String symbsDir = await createDirectory("Symbols", trainDir);

  String capsDir = await createDirectory("Capitals", letsDir);
  String smalsDir = await createDirectory("Smalls", letsDir);

  String ADir = await createDirectory("A", capsDir);
  String BDir = await createDirectory("B", capsDir);
  String CDir = await createDirectory("C", capsDir);
  String DDir = await createDirectory("D", capsDir);
  String EDir = await createDirectory("E", capsDir);
  String FDir = await createDirectory("F", capsDir);
  String GDir = await createDirectory("G", capsDir);
  String HDir = await createDirectory("H", capsDir);
  String IDir = await createDirectory("I", capsDir);
  String JDir = await createDirectory("J", capsDir);
  String KDir = await createDirectory("K", capsDir);
  String LDir = await createDirectory("L", capsDir);
  String MDir = await createDirectory("M", capsDir);
  String NDir = await createDirectory("N", capsDir);
  String ODir = await createDirectory("O", capsDir);
  String PDir = await createDirectory("P", capsDir);
  String QDir = await createDirectory("Q", capsDir);
  String RDir = await createDirectory("R", capsDir);
  String SDir = await createDirectory("S", capsDir);
  String TDir = await createDirectory("T", capsDir);
  String UDir = await createDirectory("U", capsDir);
  String VDir = await createDirectory("V", capsDir);
  String WDir = await createDirectory("W", capsDir);
  String XDir = await createDirectory("X", capsDir);
  String YDir = await createDirectory("Y", capsDir);
  String ZDir = await createDirectory("Z", capsDir);


  String aDir = await createDirectory("a", smalsDir);
  String bDir = await createDirectory("b", smalsDir);
  String cDir = await createDirectory("c", smalsDir);
  String dDir = await createDirectory("d", smalsDir);
  String eDir = await createDirectory("e", smalsDir);
  String fDir = await createDirectory("f", smalsDir);
  String gDir = await createDirectory("g", smalsDir);
  String hDir = await createDirectory("h", smalsDir);
  String iDir = await createDirectory("i", smalsDir);
  String jDir = await createDirectory("j", smalsDir);
  String kDir = await createDirectory("k", smalsDir);
  String lDir = await createDirectory("l", smalsDir);
  String mDir = await createDirectory("m", smalsDir);
  String nDir = await createDirectory("n", smalsDir);
  String oDir = await createDirectory("o", smalsDir);
  String pDir = await createDirectory("p", smalsDir);
  String qDir = await createDirectory("q", smalsDir);
  String rDir = await createDirectory("r", smalsDir);
  String sDir = await createDirectory("s", smalsDir);
  String tDir = await createDirectory("t", smalsDir);
  String uDir = await createDirectory("u", smalsDir);
  String vDir = await createDirectory("v", smalsDir);
  String wDir = await createDirectory("w", smalsDir);
  String xDir = await createDirectory("x", smalsDir);
  String yDir = await createDirectory("y", smalsDir);
  String zDir = await createDirectory("z", smalsDir);

  String zeroDir = await createDirectory("Zero", numsDir);
  String oneDir = await createDirectory("One", numsDir);
  String twoDir = await createDirectory("Two", numsDir);
  String threeDir = await createDirectory("Three", numsDir);
  String fourDir = await createDirectory("Four", numsDir);
  String fiveDir = await createDirectory("Five", numsDir);
  String sixDir = await createDirectory("Six", numsDir);
  String sevenDir = await createDirectory("Seven", numsDir);
  String eightDir = await createDirectory("Eight", numsDir);
  String nineDir = await createDirectory("Nine", numsDir);

  String plusDir = await createDirectory("Plus", symbsDir);
  String minusDir = await createDirectory("Minus", symbsDir);
  String alphaDir = await createDirectory("Alpha", symbsDir);
  String integralDir = await createDirectory("Integral", symbsDir);
  String summationDir = await createDirectory("Summation", symbsDir);
  String thetaDir = await createDirectory("Theta", symbsDir);
  String piDir = await createDirectory("Pi", symbsDir);


  return;
}