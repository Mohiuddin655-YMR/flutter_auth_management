import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

class DashboardMobileBody extends StatelessWidget {
  const DashboardMobileBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const LinearLayout(
      widthMax: 420,
      layoutGravity: LayoutGravity.center,
      children: [
        TextView(
          text: "Mobile View",
          textColor: Colors.grey,
          textSize: 32,
          textFontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
