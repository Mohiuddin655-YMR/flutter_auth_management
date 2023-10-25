import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_androssy/services.dart';

class ScreenView extends StatelessWidget {
  final bool authShowLeading;
  final EdgeInsetsGeometry? padding;
  final Color? toolbarColor;
  final Color? toolbarIconTint;
  final double elevation;
  final double? toolbarHeight;
  final Color? background;
  final String backgroundImage;
  final Color? statusBarColor;
  final Brightness statusBarBrightness;
  final String? title;
  final Color? titleColor;
  final double? titleExtraSize;
  final bool titleCenter;
  final double? titleSize;
  final TextStyle titleStyle;
  final FontWeight? titleWeight;
  final Widget? body;
  final bool behindAppbar;
  final bool behindBody;
  final bool resizeToAvoidBottomInset;
  final List<Widget>? actions;

  final OnViewBuilder? onTitleBuilder;
  final OnViewBuilder? onLeadingBuilder;

  const ScreenView({
    Key? key,
    this.authShowLeading = true,
    this.background,
    this.backgroundImage = "",
    this.behindAppbar = false,
    this.behindBody = true,
    this.toolbarColor = Colors.transparent,
    this.elevation = 0.5,
    this.toolbarIconTint,
    this.toolbarHeight,
    this.padding,
    this.resizeToAvoidBottomInset = false,
    this.statusBarColor,
    this.statusBarBrightness = Brightness.dark,
    this.title,
    this.titleCenter = false,
    this.titleColor = Colors.black,
    this.titleExtraSize,
    this.titleSize = 20,
    this.titleStyle = const TextStyle(),
    this.titleWeight,
    this.actions,
    this.body,
    this.onTitleBuilder,
    this.onLeadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: behindAppbar,
      extendBody: behindBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: authShowLeading,
        elevation: toolbarColor != Colors.transparent ? elevation : 0,
        toolbarHeight: toolbarHeight,
        backgroundColor: toolbarColor,
        centerTitle: titleCenter,
        actionsIconTheme: IconThemeData(
          color: toolbarIconTint,
        ),
        iconTheme: IconThemeData(
          color: toolbarIconTint,
        ),
        leading: onLeadingBuilder?.call(context, null),
        actions: actions,
        title: onTitleBuilder?.call(context, title) ??
            Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: titleStyle.copyWith(
                color: titleColor,
                fontSize: titleSize,
                fontWeight: titleWeight,
                letterSpacing: titleExtraSize,
              ),
            ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: statusBarColor ?? toolbarColor ?? Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
          statusBarBrightness: statusBarBrightness,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: padding,
        decoration: BoxDecoration(
          image: backgroundImage.isNotEmpty
              ? DecorationImage(
                  image: ExactAssetImage(backgroundImage),
                  fit: BoxFit.fill,
                )
              : null,
        ),
        child: body,
      ),
    );
  }
}
