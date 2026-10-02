import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class NextAppointmentProminentCard extends StatelessWidget {
  final DoctorAppointmentModel appointment;
  final VoidCallback onStartConsultation;
  final VoidCallback onViewPatient;

  const NextAppointmentProminentCard({
    super.key,
    required this.appointment,
    required this.onStartConsultation,
    required this.onViewPatient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final patient = appointment.patient;

    return GlassCard(
      borderRadius: 22,
      hasTealGlow: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left Accent Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.primaryTeal.withValues(
                alpha: isDark ? 0.25 : 0.14,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'NEXT UP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.appointmentTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    appointment.tokenNumber,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Patient Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      backgroundImage: NetworkImage(patient.avatarUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: Text(
                        patient.name[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.name} (${patient.age} years)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '${appointment.appointmentType} • ${appointment.department}',
                          style: TextStyle(
                            fontSize: 12,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.history_rounded, size: 14, color: HealthifyGlassTheme.getTextMuted(isDark)),
                    const SizedBox(width: 4),
                    Text(
                      'Previous visit: ${patient.lastVisitDate}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Status: Waiting',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Actions
          Wrap(
            direction: Axis.vertical,
            spacing: 8,
            children: [
              GlassPrimaryButton(
                onPressed: onStartConsultation,
                height: 38,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_call_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Start Consultation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GlassSecondaryButton(
                onPressed: onViewPatient,
                height: 38,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('View Patient', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
