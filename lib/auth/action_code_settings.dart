class IActionCodeSettings {
  final String? androidPackageName;
  final String? androidMinimumVersion;
  final bool androidInstallApp;
  final String? iOSBundleId;
  final String? dynamicLinkDomain;
  final bool handleCodeInApp;
  final String url;

  const IActionCodeSettings({
    this.androidPackageName,
    this.androidMinimumVersion,
    this.androidInstallApp = false,
    this.dynamicLinkDomain,
    this.handleCodeInApp = false,
    this.iOSBundleId,
    required this.url,
  });
}
