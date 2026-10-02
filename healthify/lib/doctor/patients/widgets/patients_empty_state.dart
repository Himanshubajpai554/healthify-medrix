import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class PatientsEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClearFilters;
  final bool isError;
  final VoidCallback? onRetry;

  const PatientsEmptyState({
    super.key,
    this.title = 'No patients found',
    this.message = 'Try changing your filters or search terms.',
    this.onClearFilters,
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
              icon: isError ? Icons.error_outline_rounded : Icons.search_off_rounded,
              size: 64,
              iconSize: 32,
              color: isError ? Colors.redAccent : HealthifyGlassTheme.primaryTeal,
              borderRadius: 20,
            ),
            const SizedBox(height: 16),

            Text(
              isError ? 'Unable to load patients' : title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              isError ? 'Network timeout connecting to clinical patient server.' : message,
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
            else if (onClearFilters != null)
              GlassPrimaryButton(
                onPressed: onClearFilters,
                height: 42,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Clear Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
