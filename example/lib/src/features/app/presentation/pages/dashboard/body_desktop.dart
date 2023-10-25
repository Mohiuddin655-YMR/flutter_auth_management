import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

class DashboardDesktopBody extends StatelessWidget {
  const DashboardDesktopBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const LinearLayout(
      widthMax: 1000,
      layoutGravity: LayoutGravity.center,
      children: [
        TextView(
          text: "Desktop View",
          textColor: Colors.grey,
          textSize: 32,
          textFontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
