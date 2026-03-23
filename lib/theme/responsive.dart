import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double maxContentWidth = 480;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isNarrowMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 375;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets safePadding(BuildContext context) =>
      MediaQuery.paddingOf(context);

  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < 375) return 16;
    if (width < mobileBreakpoint) return 20;
    return 24;
  }

  static double cardPadding(BuildContext context) {
    return screenWidth(context) < 375 ? 14 : 20;
  }

  static double fontSize(BuildContext context, double base) {
    final width = screenWidth(context);
    if (width < 360) return base * 0.88;
    if (width < 375) return base * 0.92;
    return base;
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
