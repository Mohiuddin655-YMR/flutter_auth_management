import 'package:flutter/material.dart';
import 'package:flutter_androssy/core.dart';
import 'package:flutter_androssy/widgets.dart';

class HomeActivity extends AndrossyActivity<HomeController> {
  const HomeActivity({
    super.key,
  });

  @override
  HomeController init(BuildContext context) {
    return HomeController();
  }

  @override
  Widget? onCreateTitle(BuildContext context) {
    return const TextView(text: "Home");
  }

  @override
  Widget onCreate(BuildContext context, AndrossyInstance instance) {
    return const TextView(
      width: double.infinity,
      height: double.infinity,
      gravity: Alignment.center,
      text: "Home",
      textSize: 32,
      textColor: Colors.grey,
    );
  }
}

class HomeController extends AndrossyController {}
