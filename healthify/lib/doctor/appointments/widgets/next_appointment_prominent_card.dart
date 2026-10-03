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
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;

          final patientInfoWidget = Column(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.name} (${patient.age} yrs)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '${appointment.appointmentType} • ${appointment.department}',
                          overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 14,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Previous: ${patient.lastVisitDate}',
                        style: TextStyle(
                          fontSize: 11,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Status: Waiting',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: HealthifyGlassTheme.primaryTeal.withValues(
                          alpha: isDark ? 0.25 : 0.14,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: HealthifyGlassTheme.primaryTeal.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'NEXT UP',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appointment.appointmentTime,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              appointment.tokenNumber,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: patientInfoWidget),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassPrimaryButton(
                      onPressed: onStartConsultation,
                      height: 47,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_call_rounded, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'Start Consultation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassSecondaryButton(
                      onPressed: onViewPatient,
                      height: 40,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'View Patient',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              // Left Accent Column
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.25 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: HealthifyGlassTheme.primaryTeal.withValues(
                      alpha: 0.4,
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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

              Expanded(child: patientInfoWidget),
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
                        Text(
                          'Start Consultation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                        Text(
                          'View Patient',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
