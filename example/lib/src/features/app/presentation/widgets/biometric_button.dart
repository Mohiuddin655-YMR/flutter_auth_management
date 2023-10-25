import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';

import '../../../../../index.dart';

class BiometricButton extends StatelessWidget {
  final bool isVisible;
  final bool isSupportedDevices;

  final Function(BuildContext context)? onLogin;

  const BiometricButton({
    super.key,
    this.isVisible = true,
    this.isSupportedDevices = true,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return isVisible &&
            !kIsWeb &&
            (isSupportedDevices || Platform.isAndroid || Platform.isIOS)
        ? IconView(
            marginTop: 24,
            padding: 8,
            icon: Platform.isIOS ? AppIcons.faceId : Icons.fingerprint,
            tint: AppColors.primary,
            size: 50,
            onClick: onLogin,
          )
        : const SizedBox();
  }
}
