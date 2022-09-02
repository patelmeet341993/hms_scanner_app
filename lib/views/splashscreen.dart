import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controllers/navigation_controller.dart';
import 'authentication/login_screen.dart';
import 'homescreen/homescreen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ThemeData themeData;

  Future<void> checkLogin() async {
    await Future.delayed(Duration(seconds: 3));

    if(Random().nextBool()) {
      NavigationController.isFirst = false;
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
    }
    else {
      NavigationController.isFirst = false;
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      child: Scaffold(
        body: Center(
          child: LoadingAnimationWidget.inkDrop(color: themeData.primaryColor, size: 40),
        ),
      ),
    );
  }
}
