import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  final double? width, height;
  final EdgeInsets? margin, padding;
  final String text;
  final double? textSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final Function()? onPressed;

  const AppTextButton({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.fontWeight,
    this.text = "",
    this.textAlign,
    this.textColor,
    this.textSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AbsorbPointer(
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          child: Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
