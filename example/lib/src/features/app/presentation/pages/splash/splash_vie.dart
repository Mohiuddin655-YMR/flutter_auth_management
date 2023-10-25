import 'dart:async';

import 'package:flutter/material.dart';

class AppSplashView extends StatefulWidget {
  final PositionalFlex flex;
  final int duration;
  final EdgeInsetsGeometry? contentPadding;
  final Color? statusBarColor;
  final Brightness statusBarBrightness;
  final Widget? custom;
  final String? title, subtitle;
  final bool titleAllCaps;
  final Color? titleColor, subtitleColor;
  final double? titleExtraSize, subtitleExtraSize;
  final EdgeInsetsGeometry? titlePadding, subtitleMargin;
  final double? titleSize, subtitleSize;
  final TextStyle titleStyle;
  final TextStyle? subtitleStyle;
  final FontWeight? titleWeight, subtitleWeight;
  final String? logo;
  final Color? logoColor;
  final EdgeInsetsGeometry? logoPadding;
  final double? logoSize;
  final Widget? bottom;

  final Future Function()? onExecute;
  final Function(BuildContext context)? onRoute;

  const AppSplashView({
    super.key,
    this.contentPadding,
    this.flex = const PositionalFlex(),
    this.duration = 5000,
    this.statusBarColor = Colors.white,
    this.statusBarBrightness = Brightness.dark,
    this.custom,
    this.onRoute,
    this.onExecute,
    this.title,
    this.subtitle,
    this.titleAllCaps = false,
    this.titleColor,
    this.subtitleColor,
    this.titleExtraSize,
    this.subtitleExtraSize,
    this.titlePadding,
    this.subtitleMargin,
    this.titleSize = 20,
    this.subtitleSize,
    this.titleStyle = const TextStyle(),
    this.subtitleStyle,
    this.titleWeight = FontWeight.bold,
    this.subtitleWeight,
    this.logo,
    this.logoColor,
    this.logoPadding,
    this.logoSize,
    this.bottom,
  });

  @override
  State<AppSplashView> createState() => _AppSplashViewState();
}

class _AppSplashViewState extends State<AppSplashView> {
  late Timer _timer;

  @override
  void initState() {
    if (widget.onExecute != null) {
      widget.onExecute
          ?.call()
          .whenComplete(() => widget.onRoute?.call(context));
    } else {
      _timer = Timer(Duration(milliseconds: widget.duration),
          () => widget.onRoute?.call(context));
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Spacer(flex: widget.flex.top),
            Container(
              padding: widget.contentPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: widget.custom ??
                          Column(
                            children: [
                              Container(
                                margin: widget.logoPadding,
                                child: Image.asset(
                                  widget.logo ?? "",
                                  width: widget.logoSize ?? 70,
                                  height: widget.logoSize ?? 70,
                                  color: widget.logoColor,
                                ),
                              ),
                              Container(
                                margin: widget.titlePadding ??
                                    const EdgeInsets.only(top: 16),
                                child: Text(
                                  widget.titleAllCaps
                                      ? (widget.title ?? "").toUpperCase()
                                      : widget.title ?? "",
                                  textAlign: TextAlign.center,
                                  style: widget.titleStyle.copyWith(
                                    color: widget.titleColor,
                                    fontSize: widget.titleSize,
                                    fontWeight: widget.titleWeight,
                                    letterSpacing: widget.titleExtraSize,
                                  ),
                                ),
                              ),
                              Container(
                                padding: widget.subtitleMargin ??
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                child: Text(
                                  widget.subtitle ?? "",
                                  textAlign: TextAlign.center,
                                  style: (widget.subtitleStyle ??
                                          widget.titleStyle)
                                      .copyWith(
                                    color: widget.subtitleColor,
                                    fontSize: widget.subtitleSize ??
                                        ((widget.titleSize ?? 1) * 0.5),
                                    fontWeight: widget.subtitleWeight,
                                    letterSpacing: widget.subtitleExtraSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: widget.flex.bottom),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: widget.bottom ?? const SizedBox(),
        ),
      ],
    );
  }
}

class PositionalFlex {
  final int top;
  final int bottom;

  const PositionalFlex({
    int top = 2,
    int bottom = 3,
  })  : top = top > 0 ? top : 1,
        bottom = bottom > 0 ? bottom : 2;
}
