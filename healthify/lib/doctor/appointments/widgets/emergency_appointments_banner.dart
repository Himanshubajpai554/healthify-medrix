import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class EmergencyAppointmentsBanner extends StatelessWidget {
  final List<DoctorEmergencyCaseModel> emergencyCases;
  final ValueChanged<DoctorEmergencyCaseModel> onViewPatient;
  final ValueChanged<DoctorEmergencyCaseModel> onOpenMedicalRecord;

  const EmergencyAppointmentsBanner({
    super.key,
    required this.emergencyCases,
    required this.onViewPatient,
    required this.onOpenMedicalRecord,
  });

  @override
  Widget build(BuildContext context) {
    if (emergencyCases.isEmpty) return const SizedBox.shrink();
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: emergencyCases.map((item) {
        final patient = item.patient;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.emergency_rounded, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'EMERGENCY ADMISSION',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Arrived ${item.arrivalTime}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${patient.name} (${patient.age} yrs • ${patient.gender})',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                'Location: ${item.assignedBed} • ${item.department} (${item.currentStatus})',
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onViewPatient(item),
                            icon: const Icon(Icons.person_pin_rounded, size: 14),
                            label: const FittedBox(fit: BoxFit.scaleDown, child: Text('View Patient')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => onOpenMedicalRecord(item),
                            icon: const Icon(Icons.medical_services_rounded, size: 14),
                            label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Medical Record')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emergency_rounded, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'EMERGENCY ADMISSION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Arrived ${item.arrivalTime}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${patient.name} (${patient.age} yrs • ${patient.gender})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Location: ${item.assignedBed} • ${item.department} (${item.currentStatus})',
                          style: TextStyle(
                            fontSize: 12,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onViewPatient(item),
                        icon: const Icon(Icons.person_pin_rounded, size: 14),
                        label: const Text('View Patient'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => onOpenMedicalRecord(item),
                        icon: const Icon(Icons.medical_services_rounded, size: 14),
                        label: const Text('Open Medical Record'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
