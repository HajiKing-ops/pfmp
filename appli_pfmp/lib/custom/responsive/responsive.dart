import 'dart:math' as math;

import 'package:flutter/material.dart';

enum DeviceSize { mobile, tablet, desktop }

class Responsive {
  static const double mobileMaxWidth = 650;
  static const double tabletMaxWidth = 1100;

  static DeviceSize deviceOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) {
      return DeviceSize.mobile;
    }
    if (width < tabletMaxWidth) {
      return DeviceSize.tablet;
    }
    return DeviceSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceOf(context) == DeviceSize.mobile;

  static bool isTablet(BuildContext context) =>
      deviceOf(context) == DeviceSize.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceOf(context) == DeviceSize.desktop;

  static int platformCode(BuildContext context) {
    switch (deviceOf(context)) {
      case DeviceSize.desktop:
        return 1;
      case DeviceSize.tablet:
        return 2;
      case DeviceSize.mobile:
        return 3;
    }
  }

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) {
      return 12;
    }
    if (width < tabletMaxWidth) {
      return 18;
    }
    return 25;
  }

  static double modalWidth(BuildContext context, {double max = 600}) {
    final width = MediaQuery.of(context).size.width;
    return math.min(max, math.max(280, width - (pagePadding(context) * 2)));
  }

  static double modalHeight(BuildContext context, {double max = 600}) {
    final height = MediaQuery.of(context).size.height;
    return math.min(max, math.max(240, height - (pagePadding(context) * 2)));
  }
}

class ResponsiveScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final bool fillViewport;

  const ResponsiveScrollView({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 1200,
    this.fillViewport = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: fillViewport ? constraints.maxHeight : 0,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.breakpoint = 560,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      },
    );
  }
}

class ResponsiveWrapGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;

  const ResponsiveWrapGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final columns = math
            .max(1, (availableWidth / minItemWidth).floor())
            .toInt();
        final itemWidth =
            (availableWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
