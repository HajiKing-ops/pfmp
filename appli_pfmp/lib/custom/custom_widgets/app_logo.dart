import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double maxWidth;

  const AppLogo({
    super.key,
    required this.height,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height, maxWidth: maxWidth),
        child: Image.asset(
          'images/logo-noir.png',
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
      ),
    );
  }
}
