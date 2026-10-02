import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class AccountManagementSection extends StatelessWidget {
  final String doctorId;
  final String hospitalName;
  final VoidCallback onSignOut;

  const AccountManagementSection({
    super.key,
    required this.doctorId,
    required this.hospitalName,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: [
        // Account Status Card
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.manage_accounts_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Provider Account Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Overview of your professional account status and credentials.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 22, color: Color(0xFF10B981)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Account Status: Active Provider',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Registered under $hospitalName ($doctorId). Full clinical workspace privileges enabled.',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions Row: Sign Out & Deactivate Account
              Row(
                children: [
                  Expanded(
                    child: GlassSecondaryButton(
                      height: 42,
                      onPressed: onSignOut,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                          SizedBox(width: 6),
                          Text(
                            'Sign Out of Workspace',
                            style: TextStyle(fontSize: 12.5, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassSecondaryButton(
                      height: 42,
                      onPressed: () => _confirmDeactivateAccount(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.no_accounts_rounded, size: 16, color: Colors.redAccent),
                          SizedBox(width: 6),
                          Text(
                            'Deactivate Account',
                            style: TextStyle(fontSize: 12.5, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDeactivateAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = HealthifyGlassTheme.isDarkMode(dialogCtx);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                'Deactivate Provider Account?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account deactivation will immediately prevent access to doctor workflows and patient consultation queues until reactivated by an authorized hospital administrator.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Note: Statutory healthcare regulations require that all clinical notes, reports, and electronic health records previously entered remain archived and accessible for medical compliance.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(dialogCtx);
                onSignOut();
              },
              child: const Text('Confirm Deactivation', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
