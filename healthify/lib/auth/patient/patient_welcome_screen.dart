import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import './patient_login_screen.dart';
import './patient_signup_screen.dart';
import '../doctor/doctor_signup_screen.dart';
import '../signup/signup_screen.dart';

class PatientWelcomeScreen extends StatelessWidget {
  const PatientWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);
    final mutedTextColor = HealthifyGlassTheme.getTextMuted(isDark);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      body: AnimatedPulseBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: isDesktop ? 40 : 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 540 : 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. BRANDING & LOGO
                    GlassIconContainer(
                      icon: Icons.healing_rounded,
                      size: 68,
                      iconSize: 36,
                      color: HealthifyGlassTheme.primaryTeal,
                      borderRadius: 22,
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'HEALTHIFY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: HealthifyGlassTheme.primaryTeal,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your Trustworthy Gateway to Nearby Hospitals, Doctors & Real-time Care',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2. TRUSTED HEALTHCARE GLASS FEATURE CARD
                    GlassCard(
                      borderRadius: 22,
                      hasTealGlow: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: HealthifyGlassTheme.primaryTeal
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: HealthifyGlassTheme.primaryTeal,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Verified Healthcare Network',
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            context: context,
                            icon: Icons.domain_rounded,
                            title: 'Nearby Hospitals & Live ICU Beds',
                            subtitle:
                                'Real-time bed capacity & blood bank reserves',
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            context: context,
                            icon: Icons.medical_services_rounded,
                            title: 'Specialist Doctors & Direct Booking',
                            subtitle:
                                'Instant slot reservation & token tracking',
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            context: context,
                            icon: Icons.psychology_rounded,
                            title: 'AI Symptom & Triage Analyzer',
                            subtitle:
                                'Match health concerns to relevant departments',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3. PRIMARY CTA - GET STARTED
                    GlassPrimaryButton(
                      height: 54,
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const PatientSignupScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4. SECONDARY CTA - SIGN IN
                    GlassSecondaryButton(
                      height: 52,
                      onPressed: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const PatientLoginScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In to Existing Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // DOCTOR & HOSPITAL PORTAL ACCESS GLASS CARD
                    GlassCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.business_center_outlined,
                                size: 18,
                                color: HealthifyGlassTheme.primaryTeal,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Are you a Doctor or Hospital Admin?',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      FadePageRoute(
                                        page: const DoctorSignupScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.medical_services_outlined,
                                    size: 16,
                                    color: Colors.indigo,
                                  ),
                                  label: const Text(
                                    'Doctor Portal',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    side: BorderSide(
                                      color: Colors.indigo.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      FadePageRoute(
                                        page: const HospitalSignupScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.local_hospital_outlined,
                                    size: 16,
                                    color: HealthifyGlassTheme.primaryTeal,
                                  ),
                                  label: const Text(
                                    'Hospital Portal',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: HealthifyGlassTheme.primaryTeal,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    side: BorderSide(
                                      color: HealthifyGlassTheme.primaryTeal
                                          .withValues(alpha: 0.4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Privacy Footer Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: mutedTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HIPAA & GDPR Compliant Security',
                          style: TextStyle(fontSize: 12, color: mutedTextColor),
                        ),
                      ],
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

  Widget _buildFeatureRow({
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
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
