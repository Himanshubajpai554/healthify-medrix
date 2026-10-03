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

/// Extension on BuildContext for quick access to responsive properties
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isLargeDesktop => Responsive.isLargeDesktop(this);
  bool get isTabletOrLarger => Responsive.isTabletOrLarger(this);

  DeviceType get deviceType => Responsive.getDeviceType(this);

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop && largeDesktop != null) return largeDesktop;
    if (isDesktop) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  EdgeInsets get responsivePadding => Responsive.pagePadding(this);
}

/// Flexible Grid that automatically adjusts items per row based on maxItemWidth or crossAxisCount
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double maxItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.maxItemWidth = 320.0,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxItemWidth,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Adaptive Layout widget that displays Row on tablet/desktop and Column on mobile
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool forceColumnOnTablet;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
    this.forceColumnOnTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final useColumn = isMobile || (forceColumnOnTablet && isTablet);

    if (useColumn) {
      List<Widget> spacedChildren = [];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(SizedBox(height: spacing));
        }
      }
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    } else {
      List<Widget> spacedChildren = [];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(Expanded(child: children[i]));
        if (i < children.length - 1) {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    }
  }
}

/// Smoothly animated container for responsive transitions
class AnimatedResponsiveLayout extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedResponsiveLayout({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}