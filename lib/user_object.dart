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


//User class, takes in username to find out user details


class User {
  String username;
  String user_path;
  String root_path;
  String app_root_dir;

  User(this.username, this.app_root_dir, this.root_path, this.user_path);
}



