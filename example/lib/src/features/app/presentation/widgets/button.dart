import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Color? primary;
  final double? width, height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding, margin;
  final bool enabled;
  final Function()? onPressed;
  final Future<bool> Function()? onExecute;

  const AppButton({
    Key? key,
    required this.text,
    this.primary,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.enabled = true,
    this.onPressed,
    this.onExecute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureButton(
        text: text,
        backgroundState: (state) => primary,
        padding: padding,
        margin: margin,
        borderRadius: borderRadius ?? 0,
        enabled: enabled,
        onClick: onPressed,
        onExecute: onExecute,
      ),
    );
  }
}
