import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HealthifyGlassTheme {
  // Colors
  static const Color lightBackground = Color(0xFFF3FAF9);
  static const Color darkBackground = Color(0xFF061817);

  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryDarkTeal = Color(0xFF0F766E);

  static Color glassSurfaceLight = Colors.white.withValues(alpha: 0.72);
  static Color glassStrongSurfaceLight = Colors.white.withValues(alpha: 0.90);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.88);

  static Color glassSurfaceDark = Colors.white.withValues(alpha: 0.045);
  static Color glassStrongSurfaceDark = Colors.white.withValues(alpha: 0.075);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.085);

  static const Color textPrimaryLight = AppTheme.textPrimary; // #0F172A
  static const Color textSecondaryLight = AppTheme.textSecondary; // #475569
  static const Color textMutedLight = AppTheme.textMuted; // #94A3B8

  static const Color textPrimaryDark = Colors.white;
  static Color textSecondaryDark = Colors.white.withValues(alpha: 0.55);
  static Color textMutedDark = Colors.white.withValues(alpha: 0.38);

  static const Color errorColor = Colors.redAccent;

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static bool isDark(BuildContext context) => isDarkMode(context);

  static Color getBackgroundColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color getGlassSurface(bool isDark, {bool isStrong = false}) {
    if (isDark) {
      return isStrong ? glassStrongSurfaceDark : glassSurfaceDark;
    } else {
      return isStrong ? glassStrongSurfaceLight : glassSurfaceLight;
    }
  }

  static Color getGlassBorder(bool isDark) =>
      isDark ? glassBorderDark : glassBorderLight;

  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;

  static Color getTextMuted(bool isDark) =>
      isDark ? textMutedDark : textMutedLight;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isStrong;
  final bool hasTealGlow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.isStrong = false,
    this.hasTealGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: isStrong),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          if (hasTealGlow)
            BoxShadow(
              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 30,
              spreadRadius: 2,
            ),
        ],
      ),
      child: child,
    );

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    Widget glassWidget = RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: cardContent,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}

/// Advanced 3D Hover & Glow Glass Card with isolated RepaintBoundary
class DynamicHoverGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isStrong;
  final bool hasTealGlow;
  final VoidCallback? onTap;
  final Color? glowColor;
  final double hoverTranslateY;

  const DynamicHoverGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.margin,
    this.isStrong = false,
    this.hasTealGlow = false,
    this.onTap,
    this.glowColor,
    this.hoverTranslateY = -5.0,
  });

  @override
  State<DynamicHoverGlassCard> createState() => _DynamicHoverGlassCardState();
}

class _DynamicHoverGlassCardState extends State<DynamicHoverGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final accentGlow = widget.glowColor ?? HealthifyGlassTheme.primaryTeal;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(
        0.0,
        _isHovered ? widget.hoverTranslateY : 0.0,
        0.0,
      ),
      padding: widget.padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: widget.isStrong
            ? HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true)
            : (_isHovered
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.88))
                : HealthifyGlassTheme.getGlassSurface(isDark)),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isHovered
              ? accentGlow.withValues(alpha: isDark ? 0.6 : 0.45)
              : HealthifyGlassTheme.getGlassBorder(isDark),
          width: _isHovered ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: isDark ? (_isHovered ? 0.35 : 0.20) : (_isHovered ? 0.08 : 0.035)),
            blurRadius: _isHovered ? 32 : 22,
            offset: Offset(0, _isHovered ? 16 : 8),
          ),
          if (widget.hasTealGlow || _isHovered)
            BoxShadow(
              color: accentGlow.withValues(
                  alpha: _isHovered ? (isDark ? 0.28 : 0.16) : (isDark ? 0.12 : 0.06)),
              blurRadius: _isHovered ? 34 : 24,
              spreadRadius: _isHovered ? 2 : 1,
            ),
        ],
      ),
      child: widget.child,
    );

    if (widget.margin != null) {
      cardContent = Padding(padding: widget.margin!, child: cardContent);
    }

    Widget result = RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: cardContent,
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: result,
      ),
    );
  }
}

/// Multi-Layer Desktop Side Inspector Drawer
class GlassSideInspectorPane extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final double width;

  const GlassSideInspectorPane({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.width = 420,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: isOpen ? 0 : -width - 40,
      width: width,
      child: RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: 40,
                offset: const Offset(-10, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.94)
                      : Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GlassIconContainer(
                            icon: icon,
                            size: 42,
                            iconSize: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: onClose,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    // Inspector Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class GlassTextFieldTheme {
  static InputDecoration getDecoration({
    required BuildContext context,
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.075)
          : Colors.white.withValues(alpha: 0.90),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: TextStyle(
        color: HealthifyGlassTheme.getTextMuted(isDark),
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: HealthifyGlassTheme.getTextSecondary(isDark),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon != null
          ? IconTheme(
              data: IconThemeData(
                color: HealthifyGlassTheme.getTextSecondary(isDark),
                size: 20,
              ),
              child: prefixIcon,
            )
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: HealthifyGlassTheme.primaryTeal,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: HealthifyGlassTheme.errorColor,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: HealthifyGlassTheme.errorColor,
          width: 2.0,
        ),
      ),
    );
  }
}

class GlassPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Color color;

  const GlassPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = 15,
    this.isLoading = false,
    this.color = HealthifyGlassTheme.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class GlassSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;

  const GlassSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 50,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.70),
              foregroundColor: HealthifyGlassTheme.primaryTeal,
              side: BorderSide(
                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassSelectionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const GlassSelectionChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor = HealthifyGlassTheme.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : HealthifyGlassTheme.getGlassSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : HealthifyGlassTheme.getGlassBorder(isDark),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? activeColor
                    : HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: isDark ? Colors.tealAccent : activeColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GlassIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final double borderRadius;

  const GlassIconContainer({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.color,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final iconColor = color ?? HealthifyGlassTheme.primaryTeal;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: iconColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: isDark ? Colors.tealAccent : iconColor,
        ),
      ),
    );
  }
}

Future<T?> showHealthifyGlassBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = true,
}) {
  final isDark = HealthifyGlassTheme.isDarkMode(context);
  final screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth >= 600) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.94)
                        : Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, right: 16),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: builder(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                    width: 1.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      // Drag Handle
                      Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      builder(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}