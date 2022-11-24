/*
* File : App Theme Notifier (Listener)
* Version : 1.0.0
* */

import 'package:flutter/material.dart';
import 'package:hms_models/utils/shared_pref_manager.dart';

import '../configs/constants.dart';

class AppThemeProvider extends ChangeNotifier {

  int _themeMode = 1;

  AppThemeProvider() {
    init();
  }

  init() async {
    int? data =  await SharedPrefManager().getInt(SharePrefrenceKeys.appThemeMode);
    if(data==null) {
      _themeMode = 1;
    }
    else {
      _themeMode = data;
    }
    notifyListeners();
  }

  int get themeMode => _themeMode;

  Future<void> updateTheme(int themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    SharedPrefManager().setInt("themeMode", themeMode);
  }
}