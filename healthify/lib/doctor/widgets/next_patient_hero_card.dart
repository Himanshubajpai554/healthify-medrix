import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';

class NextPatientHeroCard extends StatelessWidget {
  final DoctorAppointmentModel appointment;
  final VoidCallback onStartConsultation;
  final VoidCallback onViewMedicalHistory;

  const NextPatientHeroCard({
    super.key,
    required this.appointment,
    required this.onStartConsultation,
    required this.onViewMedicalHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final patient = appointment.patient;

    return GlassCard(
      borderRadius: 24,
      hasTealGlow: true,
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          // Background Medical Pattern Icon
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              Icons.medical_services_outlined,
              size: 140,
              color: HealthifyGlassTheme.primaryTeal.withValues(
                alpha: isDark ? 0.08 : 0.05,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Appointment Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HealthifyGlassTheme.primaryTeal.withValues(
                        alpha: isDark ? 0.25 : 0.14,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HealthifyGlassTheme.primaryTeal.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 16,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NEXT UP • TOKEN ${appointment.tokenNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 14,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appointment.appointmentTime,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Patient Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    backgroundImage: NetworkImage(patient.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Text(
                      patient.name[0],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                patient.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(
                                    isDark,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.black.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${patient.age} yrs • ${patient.gender}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: HealthifyGlassTheme.getTextSecondary(
                                    isDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MRN: ${patient.mrn} • Blood: ${patient.bloodGroup}',
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

              // Reason for Visit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_information_rounded,
                          size: 15,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Reason for Visit:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.reasonForVisit,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              // Clinical Alerts if present
              if (appointment.clinicalAlert != null ||
                  patient.allergies.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningBg.withValues(
                      alpha: isDark ? 0.2 : 0.8,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warningBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: AppTheme.warningIcon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appointment.clinicalAlert ??
                              'Allergies: ${patient.allergies.join(", ")}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Action Buttons Row
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  GlassPrimaryButton(
                    onPressed: onStartConsultation,
                    height: 46,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_call_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Start Consultation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassSecondaryButton(
                    onPressed: onViewMedicalHistory,
                    height: 46,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'View Medical History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
