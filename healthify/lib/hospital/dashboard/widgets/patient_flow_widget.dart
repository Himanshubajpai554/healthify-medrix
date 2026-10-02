import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class LivePatientFlowWidget extends StatelessWidget {
  const LivePatientFlowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.alt_route_rounded,
                      color: AppTheme.primaryColor,
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live Patient Intake Flow',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Avg Wait: 14 mins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flow Steps Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFlowStep(
                  context,
                  'Arrivals & Triage',
                  '124 Patients',
                  Icons.login_rounded,
                  const Color(0xFF0284C7),
                ),
                _buildFlowArrow(context),
                _buildFlowStep(
                  context,
                  'Waiting Area',
                  '18 Waiting',
                  Icons.chair_outlined,
                  const Color(0xFFF59E0B),
                ),
                _buildFlowArrow(context),
                _buildFlowStep(
                  context,
                  'Active Consult',
                  '32 In Session',
                  Icons.medical_information_outlined,
                  AppTheme.primaryColor,
                ),
                _buildFlowArrow(context),
                _buildFlowStep(
                  context,
                  'Admitted Ward',
                  '14 Beds',
                  Icons.king_bed_outlined,
                  const Color(0xFF8B5CF6),
                ),
                _buildFlowArrow(context),
                _buildFlowStep(
                  context,
                  'Discharged',
                  '60 Cleared',
                  Icons.check_circle_outline_rounded,
                  const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: isDark ? Colors.white38 : AppTheme.textMuted,
        size: 16,
      ),
    );
  }
}

class TodayAppointmentsWidget extends StatefulWidget {
  const TodayAppointmentsWidget({super.key});

  @override
  State<TodayAppointmentsWidget> createState() =>
      _TodayAppointmentsWidgetState();
}

class _TodayAppointmentsWidgetState extends State<TodayAppointmentsWidget> {
  String _selectedFilter = 'All';

  final List<Map<String, String>> _appointments = const [
    {
      'time': '09:00 AM',
      'patient': 'Sarah Jenkins',
      'doctor': 'Dr. Robert Chen',
      'dept': 'Cardiology',
      'status': 'Completed',
    },
    {
      'time': '09:30 AM',
      'patient': 'Michael Vance',
      'doctor': 'Dr. Amanda Lewis',
      'dept': 'Neurology',
      'status': 'In Consultation',
    },
    {
      'time': '10:15 AM',
      'patient': 'Eleanor Vance',
      'doctor': 'Dr. Sarah Jenkins',
      'dept': 'Pediatrics',
      'status': 'Pending',
    },
    {
      'time': '11:00 AM',
      'patient': 'David Miller',
      'doctor': 'Dr. Marcus Brody',
      'dept': 'Orthopedics',
      'status': 'Pending',
    },
    {
      'time': '11:45 AM',
      'patient': 'Sophia Martinez',
      'doctor': 'Dr. Emily Watson',
      'dept': 'General Medicine',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, String>> get _filteredList {
    if (_selectedFilter == 'All') return _appointments;
    return _appointments.where((a) => a['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GlassIconContainer(
                        icon: Icons.calendar_today_rounded,
                        color: AppTheme.accentColor,
                        size: 34,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Appointments Roster",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '146 Scheduled Today (98 Completed, 32 Pending)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              // Filter tabs
              Wrap(
                spacing: 6,
                children: ['All', 'Pending', 'In Consultation', 'Completed']
                    .map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentColor
                                : HealthifyGlassTheme.getGlassSurface(isDark),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentColor
                                  : HealthifyGlassTheme.getGlassBorder(isDark),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white70
                                        : AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Appointments List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredList.length,
            separatorBuilder: (context, index) => Divider(
              color: HealthifyGlassTheme.getGlassBorder(isDark),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final item = _filteredList[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['time']!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['patient']!,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${item['doctor']} • ${item['dept']}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? Colors.white70
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, item['status']!),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    Color bg;
    Color fg;

    switch (status) {
      case 'Completed':
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        fg = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        break;
      case 'In Consultation':
        bg = isDark ? const Color(0xFF075985) : const Color(0xFFE0F2FE);
        fg = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        break;
      case 'Pending':
        bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case 'Cancelled':
      default:
        bg = isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);
        fg = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class DoctorAvailabilityWidget extends StatelessWidget {
  const DoctorAvailabilityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final depts = [
      {
        'name': 'Emergency Medicine',
        'active': '10 / 10',
        'status': '100% On Duty',
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Cardiology',
        'active': '6 / 8',
        'status': '2 in Surgery',
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'Neurology',
        'active': '4 / 5',
        'status': '1 in OPD',
        'color': AppTheme.accentColor,
      },
      {
        'name': 'Orthopedics',
        'active': '5 / 6',
        'status': 'Normal Load',
        'color': const Color(0xFF0D9488),
      },
      {
        'name': 'Pediatrics',
        'active': '4 / 5',
        'status': '1 On Leave',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.badge_outlined,
                      color: AppTheme.primaryColor,
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Doctor Roster & Availability',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '38 / 52 Active',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: depts.length,
            separatorBuilder: (context, index) => Divider(
              color: HealthifyGlassTheme.getGlassBorder(isDark),
              height: 16,
            ),
            itemBuilder: (context, index) {
              final d = depts[index];
              final color = d['color'] as Color;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            d['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        d['status'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? Colors.white70
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d['active'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}