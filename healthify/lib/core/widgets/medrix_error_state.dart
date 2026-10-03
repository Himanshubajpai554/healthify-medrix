import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

class MedrixErrorState extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback? onRetry;
  final String retryLabel;

  const MedrixErrorState({
    super.key,
    this.title = 'Unable to Load Data',
    required this.errorMessage,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        borderRadius: 20,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlassIconContainer(
                icon: Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 64,
                iconSize: 36,
                borderRadius: 20,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                    height: 1.4,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                AppRetryButton(
                  onPressed: onRetry!,
                  label: retryLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

typedef AppErrorState = MedrixErrorState;

class AppRetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AppRetryButton({
    super.key,
    required this.onPressed,
    this.label = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return GlassPrimaryButton(
      height: 44,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
