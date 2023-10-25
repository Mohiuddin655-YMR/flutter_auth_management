import 'package:flutter/material.dart';
import 'package:flutter_androssy/services.dart';
import 'package:flutter_androssy/widgets.dart';

class OAuthButton extends StatelessWidget {
  final String text;
  final Color? background;
  final dynamic icon;
  final OnViewClickListener? onClick;

  const OAuthButton({
    Key? key,
    required this.text,
    this.background,
    this.icon,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      background: background,
      width: double.infinity,
      borderRadiusBR: 25,
      borderRadiusTL: 25,
      paddingHorizontal: 50,
      height: 50,
      paddingVertical: 0,
      iconSize: 28,
      marginTop: 24,
      onClick: onClick,
      text: text,
      textSize: 16,
      textColor: Colors.white,
      textFontWeight: FontWeight.w500,
      icon: icon,
      rippleColor: Colors.black12,
      centerText: true,
      iconColorEnabled: false,
      iconAlignment: IconAlignment.start,
    );
  }
}
