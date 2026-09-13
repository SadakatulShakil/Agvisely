import 'package:flutter/material.dart';

/// The Agvisely wordmark. Sourced from the exported PNG (the supplied
/// "SVG" was a raster image in an SVG shell, which flutter_svg can't
/// render reliably). Aspect ratio ~2.33:1.
class AppLogo extends StatelessWidget {
  final double height;
  const AppLogo({super.key, this.height = 72});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/agvisely-logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
