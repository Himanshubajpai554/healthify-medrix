import 'dart:math' as math;
import 'package:flutter/material.dart';
import './glass_components.dart';

class AnimatedPulseBackground extends StatefulWidget {
  final Widget child;

  const AnimatedPulseBackground({super.key, required this.child});

  @override
  State<AnimatedPulseBackground> createState() => _AnimatedPulseBackgroundState();
}

class _AnimatedPulseBackgroundState extends State<AnimatedPulseBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      color: HealthifyGlassTheme.getBackgroundColor(isDark),
      child: Stack(
        children: [
          // Ambient Background Soft Teal/Blue Glow Layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final value = _controller.value;
                final moveX = math.sin(value * math.pi * 2) * 35;
                final moveY = math.cos(value * math.pi * 2) * 25;

                final glowColor1 = const Color(0xFF0D9488);
                final glowColor2 = const Color(0xFF0F766E);
                final glowColor3 = const Color(0xFF0284C7);

                return Stack(
                  children: [
                    // Top-right subtle glow
                    Positioned(
                      top: -100 + moveY,
                      right: -100 + moveX,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              glowColor1.withValues(alpha: isDark ? 0.18 : 0.10),
                              glowColor1.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-left subtle glow
                    Positioned(
                      bottom: -120 - moveY,
                      left: -100 - moveX,
                      child: Container(
                        width: 460,
                        height: 460,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              glowColor2.withValues(alpha: isDark ? 0.16 : 0.08),
                              glowColor2.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Center subtle accent glow
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.35 + (moveX * 0.5),
                      left: MediaQuery.of(context).size.width * 0.4 + (moveY * 0.5),
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              glowColor3.withValues(alpha: isDark ? 0.10 : 0.05),
                              glowColor3.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Foreground Content
          widget.child,
        ],
      ),
    );
  }
}