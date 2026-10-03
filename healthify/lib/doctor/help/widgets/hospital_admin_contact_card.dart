import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class HospitalAdminContactCard extends StatelessWidget {
  final HospitalAdminContactModel contact;

  const HospitalAdminContactCard({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.domain_rounded,
                size: 40,
                iconSize: 20,
                color: Colors.purple,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Administrator Contact',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Direct operations desk for ${contact.hospitalName}.',
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 480;

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.purple,
                            child: Text(
                              contact.adminName.isNotEmpty ? contact.adminName[0] : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.adminName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                                  ),
                                ),
                                Text(
                                  '${contact.role} • ${contact.department}',
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
                      const SizedBox(height: 10),
                      Text(
                        'Phone: ${contact.phone} • Email: ${contact.email}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Office Hours: ${contact.officeHours}',
                        style: TextStyle(
                          fontSize: 11,
                          color: HealthifyGlassTheme.getTextMuted(isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: GlassSecondaryButton(
                          height: 38,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling Hospital Admin (${contact.phone})...'),
                                backgroundColor: HealthifyGlassTheme.primaryTeal,
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_rounded, size: 14),
                              SizedBox(width: 4),
                              Text('Call Admin', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.purple,
                      child: Text(
                        contact.adminName.isNotEmpty ? contact.adminName[0] : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.adminName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            '${contact.role} • ${contact.department}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${contact.phone} • Email: ${contact.email}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                          Text(
                            'Office Hours: ${contact.officeHours}',
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GlassSecondaryButton(
                      height: 38,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling Hospital Admin (${contact.phone})...'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Call Admin', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
