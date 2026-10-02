import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class AppointmentsEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onManageAvailability;
  final VoidCallback? onViewUpcoming;
  final bool isError;
  final VoidCallback? onRetry;

  const AppointmentsEmptyState({
    super.key,
    this.title = 'No appointments today',
    this.message = 'Your schedule is clear. You can manage your availability or view upcoming appointments.',
    this.onManageAvailability,
    this.onViewUpcoming,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassIconContainer(
              icon: isError ? Icons.error_outline_rounded : Icons.event_available_rounded,
              size: 64,
              iconSize: 32,
              color: isError ? Colors.redAccent : HealthifyGlassTheme.primaryTeal,
              borderRadius: 20,
            ),
            const SizedBox(height: 16),

            Text(
              isError ? 'Unable to load appointments' : title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              isError ? 'There was a network issue connecting to the hospital servers.' : message,
              style: TextStyle(
                fontSize: 13.5,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (isError)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  foregroundColor: Colors.white,
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  if (onManageAvailability != null)
                    GlassPrimaryButton(
                      onPressed: onManageAvailability,
                      height: 42,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_calendar_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Manage Availability', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  if (onViewUpcoming != null)
                    GlassSecondaryButton(
                      onPressed: onViewUpcoming,
                      height: 42,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upcoming_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('View Upcoming', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
