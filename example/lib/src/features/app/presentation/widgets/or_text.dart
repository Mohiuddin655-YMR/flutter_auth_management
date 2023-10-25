import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

class OrText extends StatelessWidget {
  final double? marginTop;
  final double? marginBottom;
  final Color textColor;
  final Color? lineColor;

  const OrText({
    Key? key,
    this.marginTop,
    this.marginBottom,
    this.textColor = Colors.grey,
    this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearLayout(
      width: double.infinity,
      orientation: Axis.horizontal,
      paddingHorizontal: 12,
      marginTop: marginTop,
      marginBottom: marginBottom,
      crossGravity: CrossAxisAlignment.center,
      children: [
        YMRView(
          background: (lineColor ?? textColor).withAlpha(50),
          flex: 1,
          height: 1.5,
          marginEnd: 8,
        ),
        RawTextView(
          text: "Or",
          textColor: textColor,
          textSize: 16,
        ),
        YMRView(
          background: (lineColor ?? textColor).withAlpha(50),
          flex: 1,
          height: 1.5,
          marginStart: 8,
        ),
      ],
    );
  }
}
