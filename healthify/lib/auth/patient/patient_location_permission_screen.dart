import 'package:flutter/material.dart';
import '../../patient/dashboard/patient_dashboard_screen.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';

class PatientLocationPermissionScreen extends StatefulWidget {
  const PatientLocationPermissionScreen({super.key});

  @override
  State<PatientLocationPermissionScreen> createState() => _PatientLocationPermissionScreenState();
}

class _PatientLocationPermissionScreenState extends State<PatientLocationPermissionScreen> {
  bool _isRequesting = false;

  void _proceedToHome({bool locationGranted = true}) {
    setState(() => _isRequesting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isRequesting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locationGranted
                ? 'Location access granted! Displaying nearby ER hospitals.'
                : 'Defaulting to central location. You can enable GPS anytime.',
          ),
          backgroundColor: HealthifyGlassTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to PATIENT HOME (PatientDashboardScreen)
      Navigator.pushAndRemoveUntil(
        context,
        FadePageRoute(page: const PatientDashboardScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      body: AnimatedPulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 20,
                vertical: isDesktop ? 24 : 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 500 : 420),
                child: GlassCard(
                  borderRadius: 24,
                  hasTealGlow: true,
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Location Map Graphic Box
                      Center(
                        child: GlassIconContainer(
                          icon: Icons.location_on_rounded,
                          size: 72,
                          iconSize: 44,
                          color: HealthifyGlassTheme.primaryTeal,
                          borderRadius: 22,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Enable Location for Nearby Healthcare Discovery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: HealthifyGlassTheme.primaryTeal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Explicit Explanation Glass Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '“Use your location to find nearby hospitals, doctors, and available healthcare facilities in real-time.”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Location Benefits List
                      _buildBenefitItem(
                        context: context,
                        icon: Icons.local_hospital_outlined,
                        title: 'Find Closest ER & ICU Beds',
                        subtitle: 'Rank trauma centers by distance & real-time readiness',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        context: context,
                        icon: Icons.bloodtype_outlined,
                        title: 'Locate Nearest Blood Banks',
                        subtitle: 'Check live O- and rare blood group inventory',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        context: context,
                        icon: Icons.directions_car_outlined,
                        title: 'Instant GPS Navigation',
                        subtitle: 'One-tap emergency ambulance routing',
                      ),

                      const SizedBox(height: 28),

                      // PRIMARY CTA: ALLOW LOCATION ACCESS
                      GlassPrimaryButton(
                        height: 52,
                        isLoading: _isRequesting,
                        onPressed: () => _proceedToHome(locationGranted: true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.my_location_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Allow Location Access',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SECONDARY CTA: NOT NOW / ENTER MANUALLY
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: _isRequesting ? null : () => _proceedToHome(locationGranted: false),
                          child: Text(
                            'Not Now / Enter Location Manually',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      children: [
        GlassIconContainer(
          icon: icon,
          size: 38,
          iconSize: 18,
          color: HealthifyGlassTheme.primaryTeal,
          borderRadius: 10,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}