import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop, largeDesktop }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? largeDesktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.largeDesktop,
  });

  static const double mobileBreakPoint = 600.0;
  static const double tabletBreakPoint = 1024.0;
  static const double desktopBreakPoint = 1440.0;

  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakPoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakPoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakPoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakPoint;

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= mobileBreakPoint && width < tabletBreakPoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakPoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakPoint;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakPoint;

  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakPoint) return mobile;
    if (width < tabletBreakPoint) return tablet;
    if (width < desktopBreakPoint) return desktop;
    return largeDesktop;
  }

  static double maxContentWidth(BuildContext context) => 1600.0;

  static EdgeInsets pagePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < mobileBreakPoint) {
      return const EdgeInsets.all(16);
    } else if (width < tabletBreakPoint) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakPoint && largeDesktop != null) {
      return largeDesktop!;
    }
    if (width >= tabletBreakPoint) {
      return desktop;
    }
    if (width >= mobileBreakPoint && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}