import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

class FormProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const FormProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final percentage = (progress * 100).toInt();
    final isComplete = percentage == 100;

    final primaryColor = HealthifyGlassTheme.primaryTeal;
    final successColor = const Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  size: 16,
                  color: isComplete ? successColor : primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Form Completion',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Container(
                key: ValueKey<int>(percentage),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isComplete
                      ? successColor.withValues(alpha: isDark ? 0.20 : 0.12)
                      : primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isComplete
                        ? successColor.withValues(alpha: 0.4)
                        : primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$percentage% Complete',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isComplete
                        ? (isDark ? Colors.greenAccent : successColor)
                        : (isDark ? Colors.tealAccent : primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 6,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.02, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isComplete
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [HealthifyGlassTheme.primaryTeal, HealthifyGlassTheme.primaryDarkTeal],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}