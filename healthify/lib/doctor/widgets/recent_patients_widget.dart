import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class RecentPatientsWidget extends StatelessWidget {
  final List<PatientModel> patients;
  final ValueChanged<PatientModel> onPatientTap;

  const RecentPatientsWidget({
    super.key,
    required this.patients,
    required this.onPatientTap,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.people_rounded,
                    size: 38,
                    iconSize: 20,
                    color: Colors.indigo,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Patients',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Patients consulted under your care recently',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Patients Grid/List
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 1100
                  ? 3
                  : MediaQuery.of(context).size.width >= 600
                      ? 2
                      : 1,
              mainAxisExtent: 100,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return InkWell(
                onTap: () => onPatientTap(patient),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              patient.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${patient.age} yrs • Blood: ${patient.bloodGroup}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Last Seen: ${patient.lastVisitDate}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: HealthifyGlassTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
