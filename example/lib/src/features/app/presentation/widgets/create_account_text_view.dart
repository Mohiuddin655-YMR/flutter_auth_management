import 'package:flutter/material.dart';

class CreateAccountTextView extends StatelessWidget {
  final double? width, height;
  final EdgeInsets? margin, padding;
  final String text;
  final double? textSize;
  final Color? textColor;
  final FontWeight? textWeight;
  final String buttonText;
  final Color? buttonTextColor;
  final FontWeight? buttonTextWeight;
  final TextAlign? textAlign;
  final Function()? onPressed;

  const CreateAccountTextView({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.text = "Don't have an account? ",
    this.textAlign,
    this.textColor,
    this.textSize,
    this.textWeight,
    this.buttonText = "Sign up",
    this.buttonTextColor,
    this.buttonTextWeight = FontWeight.bold,
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
          child: Text.rich(
            TextSpan(
              text: text,
              children: [
                TextSpan(
                  text: buttonText,
                  style: TextStyle(
                    fontWeight: buttonTextWeight,
                    color: buttonTextColor,
                  ),
                ),
              ],
            ),
            textAlign: textAlign,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontWeight: textWeight,
            ),
          ),
        ),
      ),
    );
  }
}
