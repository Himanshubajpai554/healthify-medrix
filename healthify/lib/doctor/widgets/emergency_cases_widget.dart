import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class EmergencyCasesWidget extends StatelessWidget {
  final List<DoctorEmergencyCaseModel> emergencyCases;
  final ValueChanged<DoctorEmergencyCaseModel> onViewPatient;
  final ValueChanged<DoctorEmergencyCaseModel> onOpenMedicalRecord;

  const EmergencyCasesWidget({
    super.key,
    required this.emergencyCases,
    required this.onViewPatient,
    required this.onOpenMedicalRecord,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.emergency_rounded,
                size: 38,
                iconSize: 20,
                color: Colors.redAccent,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Emergency & Critical Cases',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${emergencyCases.length} Active',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Assigned emergency admissions requiring doctor triage',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emergency Cases Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: emergencyCases.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = emergencyCases[index];
              return _buildEmergencyItem(context, item, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(
    BuildContext context,
    DoctorEmergencyCaseModel item,
    bool isDark,
  ) {
    final patient = item.patient;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CRITICAL EMERGENCY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Arrived: ${item.arrivalTime}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.redAccent,
                child: Text(
                  patient.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient.name} (${patient.age} yrs • ${patient.gender})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Location: ${item.assignedBed} • ${item.department}',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.monitor_heart_rounded, size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  'Current Status: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.currentStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onViewPatient(item),
                  icon: const Icon(Icons.person_pin_rounded, size: 14),
                  label: const Text('View Patient', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onOpenMedicalRecord(item),
                  icon: const Icon(Icons.medical_services_rounded, size: 14),
                  label: const Text('Medical Record', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
