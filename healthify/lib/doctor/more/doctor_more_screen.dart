import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorMoreScreen extends StatelessWidget {
  final bool embedInDashboard;
  final ValueChanged<int> onSelectFeature;
  final DoctorAvailability availabilityStatus;
  final String doctorName;
  final String specialty;

  const DoctorMoreScreen({
    super.key,
    this.embedInDashboard = false,
    required this.onSelectFeature,
    this.availabilityStatus = DoctorAvailability.available,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor Profile Card
        GlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    child: Text(
                      doctorName.isNotEmpty ? doctorName[0] : 'D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(availabilityStatus),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      '$specialty • Healthify Doctor Portal',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    availabilityStatus,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  availabilityStatus.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(availabilityStatus),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // SECTION 1: WORKSPACE
        _buildSectionHeader(context, 'WORKSPACE', isDark),
        const SizedBox(height: 10),
        _buildFeatureGrid(context, isDark, [
          _MoreFeatureItem(
            title: 'Analytics & Insights',
            subtitle: 'Patient volume, OPD metrics & performance',
            icon: Icons.insights_rounded,
            navIndex: 5,
            color: Colors.indigo,
          ),
          _MoreFeatureItem(
            title: 'Clinical Reports',
            subtitle: 'Laboratory, Radiology & Diagnostic Sign-offs',
            icon: Icons.assignment_rounded,
            navIndex: 6,
            color: Colors.amber.shade800,
          ),
        ]),

        const SizedBox(height: 24),

        // SECTION 2: CLINICAL WORKSPACE
        _buildSectionHeader(context, 'CLINICAL WORKSPACE', isDark),
        const SizedBox(height: 10),
        _buildFeatureGrid(context, isDark, [
          _MoreFeatureItem(
            title: 'Emergency Cases',
            subtitle: 'Triage, Trauma Unit & Active Emergencies',
            icon: Icons.emergency_rounded,
            navIndex: 7,
            badge: '2',
            color: Colors.redAccent,
          ),
          _MoreFeatureItem(
            title: 'Prescriptions',
            subtitle: 'OPD Medication & e-Prescription History',
            icon: Icons.medication_rounded,
            navIndex: 9,
            color: Colors.deepPurple,
          ),
        ]),

        const SizedBox(height: 24),

        // SECTION 3: SYSTEM
        _buildSectionHeader(context, 'SYSTEM', isDark),
        const SizedBox(height: 10),
        _buildFeatureGrid(context, isDark, [
          _MoreFeatureItem(
            title: 'Notifications',
            subtitle: 'Critical Alerts, Reminders & System Messages',
            icon: Icons.notifications_rounded,
            navIndex: 10,
            badge: '4',
            color: Colors.orange,
          ),
          _MoreFeatureItem(
            title: 'Settings & Profile',
            subtitle: 'Account, Consultation & Availability Config',
            icon: Icons.settings_rounded,
            navIndex: 11,
            color: Colors.blueGrey,
          ),
        ]),

        const SizedBox(height: 24),

        // SECTION 4: SUPPORT
        _buildSectionHeader(context, 'SUPPORT', isDark),
        const SizedBox(height: 10),
        _buildFeatureGrid(context, isDark, [
          _MoreFeatureItem(
            title: 'Help & Support',
            subtitle: 'Hospital Admin Contact, FAQs & Troubleshooting',
            icon: Icons.help_outline_rounded,
            navIndex: 12,
            color: Colors.teal,
          ),
        ]),
      ],
    );

    if (embedInDashboard) {
      return SingleChildScrollView(child: content);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: HealthifyGlassTheme.getTextMuted(isDark),
      ),
    );
  }

  Widget _buildFeatureGrid(
    BuildContext context,
    bool isDark,
    List<_MoreFeatureItem> items,
  ) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onSelectFeature(item.navIndex),
            borderRadius: BorderRadius.circular(16),
            child: GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GlassIconContainer(
                    icon: item.icon,
                    size: 40,
                    iconSize: 20,
                    color: item.color,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(
                                  isDark,
                                ),
                              ),
                            ),
                            if (item.badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: HealthifyGlassTheme.getTextMuted(isDark),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return const Color(0xFF10B981);
      case DoctorAvailability.busy:
        return Colors.amber;
      case DoctorAvailability.offline:
        return Colors.grey;
    }
  }
}

class _MoreFeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final int navIndex;
  final String? badge;
  final Color color;

  const _MoreFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.navIndex,
    this.badge,
    required this.color,
  });
}
