import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

class AccessDeniedWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onReturnToDashboard;

  const AccessDeniedWidget({
    super.key,
    this.title = 'Access Restricted',
    this.message = 'You do not have permission to access this section.',
    this.onReturnToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gpp_maybe_rounded, color: Colors.redAccent, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 24),
              if (onReturnToDashboard != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.dashboard_rounded),
                    label: const Text('Return to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onReturnToDashboard,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
