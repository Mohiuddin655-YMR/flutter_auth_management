import 'package:flutter/material.dart';
import 'package:flutter_andomie/core.dart';
import 'package:flutter_androssy/services.dart';

class ResponsiveLayout extends StatelessWidget {
  final DeviceConfig config;

  final Widget mobile;
  final Widget? desktop;
  final Widget? tab;
  final Widget? laptop;
  final Widget? other;
  final Size? initialSize;

  const ResponsiveLayout({
    super.key,
    this.config = const DeviceConfig(),
    required this.mobile,
    this.desktop,
    this.tab,
    this.laptop,
    this.other,
    this.initialSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cx = size.width;
    final cy = size.height;
    if (config.isMobile(cx, cy)) {
      return mobile;
    } else if (config.isTab(cx, cy)) {
      return tab ?? mobile;
    } else if (config.isLaptop(cx, cy)) {
      return laptop ?? desktop ?? mobile;
    } else if (config.isDesktop(cx, cy)) {
      return desktop ?? mobile;
    } else {
      return other ?? desktop ?? mobile;
    }
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     print('layout builder is calling');
    //     final cx = initialSize?.width ?? constraints.maxWidth;
    //     final cy = initialSize?.height ?? constraints.maxHeight;
    //     if (config.isMobile(cx, cy)) {
    //       return mobile;
    //     } else if (config.isTab(cx, cy)) {
    //       return tab ?? mobile;
    //     } else if (config.isLaptop(cx, cy)) {
    //       return laptop ?? desktop ?? mobile;
    //     } else if (config.isDesktop(cx, cy)) {
    //       return desktop ?? mobile;
    //     } else {
    //       return other ?? desktop ?? mobile;
    //     }
    //   },
    // );
  }
}

class ResponsiveBody extends StatefulWidget {
  final int? flex;
  final FlexFit? fit;
  final Color? background;
  final bool detectChild, detectScreen;
  final DeviceConfig config;
  final Widget Function(BuildContext context, SizeConfig config) builder;

  const ResponsiveBody({
    Key? key,
    this.background,
    this.flex,
    this.fit,
    this.detectChild = false,
    this.detectScreen = false,
    this.config = const DeviceConfig(),
    required this.builder,
  }) : super(key: key);

  @override
  State<ResponsiveBody> createState() => _ResponsiveBodyState();
}

class _ResponsiveBodyState extends State<ResponsiveBody> {
  Size? _size;

  @override
  Widget build(BuildContext context) {
    final config = SizeConfig.of(
      context,
      config: widget.config,
      detectScreen: widget.detectScreen,
      size: widget.detectChild ? _size : null,
    );
    return widget.flex != null
        ? Flexible(
            fit: widget.fit ?? FlexFit.loose,
            flex: widget.flex ?? 1,
            child: _parent(context, config),
          )
        : _parent(context, config);
  }

  Widget _parent(BuildContext context, SizeConfig config) => widget.detectChild
      ? WidgetWrapper(
          wrapper: (size) => setState(() => _size = size),
          child: _child(context, config),
        )
      : _child(context, config);

  Widget _child(BuildContext context, SizeConfig config) => Container(
        color: widget.background,
        child: widget.builder.call(context, config),
      );
}
