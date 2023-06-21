part of '../../utils.dart';

class SizeConfig {
  final BuildContext context;
  final DeviceConfig config;
  final bool detectScreen;
  final Size? _requireSize;
  final Size screenSize;

  SizeConfig(
    this.context, [
    this.detectScreen = true,
    this.config = const DeviceConfig(),
    this._requireSize,
  ]) : screenSize = MediaQuery.of(context).size;

  static SizeConfig of(
    BuildContext context, {
    bool detectScreen = true,
    DeviceConfig config = const DeviceConfig(),
    Size? size,
  }) {
    return SizeConfig(context, detectScreen, config, size);
  }

  Size get size => _requireSize ?? screenSize;

  double get width => size.width;

  double get height => size.height;

  double get diagonal => sqrt((width * width) + (height * height));

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get screenDiagonal =>
      sqrt((screenWidth * screenWidth) + (screenHeight * screenHeight));

  bool get isMobile =>
      config.isMobile(screenWidth, screenHeight) && screenWidth < 500;

  bool get isTab =>
      config.isTab(screenWidth, screenHeight) && screenWidth >= 500;

  bool get isLaptop =>
      config.isLaptop(screenWidth, screenHeight) && screenWidth > 1020;

  bool get isDesktop =>
      config.isDesktop(screenWidth, screenHeight) && screenWidth > 1366;

  bool get isTV => screenWidth > config.desktop.width && screenWidth > 1800;

  DeviceType get deviceType => config.deviceType(screenWidth, screenHeight);

  double get _detectedPixel => detectScreen ? _suggestedPixel : width;

  double get _detectedSpace => detectScreen ? _suggestedSpace : width;

  double get _screenVariant {
    return 4;
  }

  double get _fontVariant {
    //return 0;
    if (isTV) {
      return 100;
    } else if (isDesktop) {
      return 75;
    } else if (isLaptop) {
      return 50;
    } else if (isTab) {
      return 25;
    } else {
      return 0;
    }
  }

  double get _suggestedPixel {
    if (width > height) {
      return height;
    } else {
      return width;
    }
  }

  double get _suggestedSpace {
    if (width > height) {
      return height;
    } else {
      return width;
    }
  }

  double percentageSize(double totalSize, double percentageSize) {
    if (percentageSize > 100) return totalSize;
    if (percentageSize < 0) return 0;
    return totalSize * (percentageSize / 100);
  }

  double dividedSize(double totalSize, double dividedLength) {
    if (dividedLength > totalSize) return totalSize;
    if (dividedLength < 0) return 0;
    return totalSize / dividedLength;
  }

  double fontSize(double initialSize) => px(initialSize);

  double px(double? initialSize, [bool any = true]) {
    return value(initialSize, any);
  }

  double dx(double? initialSize, [bool any = true]) {
    final x = (initialSize ?? 0) / _screenVariant;
    final v = !any && x < 0 ? 1.0 : x;
    return percentageSize(diagonal, v);
  }

  double pixel(double? initialSize, [bool any = true]) {
    final x = (initialSize ?? 0) / _screenVariant;
    final v = !any && x < 0 ? 1.0 : x;
    return percentageSize(_detectedPixel, v);
  }

  double value(double? initialSize, [bool any = true]) {
    final x = (initialSize ?? 0) * (_fontVariant / 100);
    final v = !any && x < 0 ? 1.0 : x;
    final r = ((initialSize ?? 0) + v);
    return r;
  }

  double pixelPercentage(double percentage) {
    if (percentage > 100) return _detectedPixel;
    if (percentage < 0) return 0;
    return _detectedPixel * (percentage / 100);
  }

  double space(double? initialSize) {
    final x = (initialSize ?? 0) / _screenVariant;
    final v = x < 0 ? 1.0 : x;
    return percentageSize(_detectedSpace, v);
  }

  double spacePercentage(double percentage) {
    if (percentage > 100) return _detectedSpace;
    if (percentage < 0) return 0;
    return _detectedSpace * (percentage / 100);
  }

  double squire({double percentage = 100}) =>
      percentageSize(_detectedPixel, percentage);

  double percentageWidth(double percentage) =>
      percentageSize(width, percentage);

  double percentageHeight(double percentage) =>
      percentageSize(height, percentage);

  double percentageFontSize(double percentage) =>
      percentageSize(_detectedPixel, percentage);

  double percentageSpace(double percentage) =>
      percentageSize(_detectedPixel, percentage);

  // Optional
  double percentageSpaceHorizontal(double percentage) =>
      percentageSpace(percentage);

  double percentageSpaceVertical(double percentage) =>
      percentageSize(height, percentage);

  double dividedSpace(double dividedLength) =>
      dividedSize(_detectedPixel, dividedLength);

  // Optional
  double dividedSpaceHorizontal(double dividedLength) =>
      dividedSpace(dividedLength);

  double dividedSpaceVertical(double dividedLength) =>
      dividedSize(height, dividedLength);
}
