import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

enum PasswordStrength { none, weak, medium, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.none;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[@$!%*?&#_]').hasMatch(password)) score++;

    if (password.length < 6 || score <= 1) return PasswordStrength.weak;
    if (score == 2 || score == 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Color get color {
    switch (strength) {
      case PasswordStrength.weak:
        return const Color(0xFFEF4444);
      case PasswordStrength.medium:
        return const Color(0xFFF59E0B);
      case PasswordStrength.strong:
        return const Color(0xFF10B981);
      case PasswordStrength.none:
        return Colors.transparent;
    }
  }

  String get labelText {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak password (Add numbers/uppercase)';
      case PasswordStrength.medium:
        return 'Medium strength (Add special characters)';
      case PasswordStrength.strong:
        return 'Strong & secure password!';
      case PasswordStrength.none:
        return '';
    }
  }

  double get progressValue {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
      case PasswordStrength.none:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressValue,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strength.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            labelText,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}