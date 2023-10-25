import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

class ToolbarView extends YMRView<ToolbarController> {
  final Widget? action;
  final Widget? leading;
  final Widget? title;

  const ToolbarView({
    super.key,
    this.action,
    this.leading,
    this.title,
  });

  @override
  ToolbarController initController() {
    return ToolbarController();
  }

  @override
  ToolbarController attachController(ToolbarController controller) {
    return controller.fromToolbar(this);
  }

  @override
  Widget? attach(BuildContext context, ToolbarController controller) {
    return StackLayout(
      width: double.infinity,
      children: [
        YMRView(
          position: const ViewPosition(top: 0, left: 0, bottom: 0),
          child: leading,
        ),
        YMRView(
          positionType: ViewPositionType.center,
          child: title,
        ),
        YMRView(
          position: const ViewPosition(top: 0, right: 0, bottom: 0),
          child: action,
        ),
      ],
    );
  }
}

class ToolbarController extends ViewController {
  ToolbarController fromToolbar(
    YMRView<ViewController> view,
  ) {
    super.fromView(view);
    return this;
  }
}
