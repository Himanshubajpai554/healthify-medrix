import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class CriticalAlertsWidget extends StatefulWidget {
  final Function(String)? onActionTap;

  const CriticalAlertsWidget({super.key, this.onActionTap});

  @override
  State<CriticalAlertsWidget> createState() => _CriticalAlertsWidgetState();
}

class _CriticalAlertsWidgetState extends State<CriticalAlertsWidget> {
  final List<Map<String, String>> _alerts = [
    {
      'id': '1',
      'level': 'CRITICAL',
      'title': 'ICU Bed #104 Ventilator Pressure Drop',
      'time': '3 mins ago',
      'action': 'Dispatch Tech',
    },
    {
      'id': '2',
      'level': 'WARNING',
      'title': 'O-Negative Blood stock critically low (2 units)',
      'time': '12 mins ago',
      'action': 'Order Reserve',
    },
    {
      'id': '3',
      'level': 'WARNING',
      'title': 'Emergency Ward reached 90% capacity limit',
      'time': '25 mins ago',
      'action': 'Trigger Overflow',
    },
  ];

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
                      icon: Icons.warning_amber_rounded,
                      color: Color(0xFFE11D48),
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Needs Urgent Attention',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFF9F1239),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_alerts.length} Active',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'All alerts resolved! Hospital operating normally.',
                style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontWeight: FontWeight.w600),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final isCritical = alert['level'] == 'CRITICAL';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCritical
                          ? const Color(0xFFE11D48).withValues(alpha: 0.4)
                          : const Color(0xFFD97706).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCritical ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          alert['level']!,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert['title']!,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              alert['time']!,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? Colors.white54 : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassPrimaryButton(
                        height: 36,
                        borderRadius: 8,
                        color: isCritical ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                        onPressed: () {
                          final action = alert['action']!;
                          setState(() {
                            _alerts.removeAt(index);
                          });
                          if (widget.onActionTap != null) {
                            widget.onActionTap!('Action "$action" executed successfully');
                          }
                        },
                        child: Text(
                          alert['action']!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class AiHospitalInsightsWidget extends StatelessWidget {
  const AiHospitalInsightsWidget({super.key});

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
            children: [
              const GlassIconContainer(
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.primaryColor,
                size: 34,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Medrix AI Predictive Capacity Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.primaryDeep,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInsightTile(
            context,
            'Intake Surge Expected',
            'ER Intakes expected to rise +25% between 18:00 - 22:00 based on historical Monday traffic.',
            Icons.trending_up_rounded,
            const Color(0xFF0284C7),
          ),
          const SizedBox(height: 10),
          _buildInsightTile(
            context,
            'Discharge Optimization',
            '12 patients scheduled for discharge by 14:00, which will free 8 General Ward beds.',
            Icons.task_alt_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          _buildInsightTile(
            context,
            'Blood Inventory Warning',
            'Recommend placing an automated order for 10 units of O-negative blood before Friday.',
            Icons.water_drop_outlined,
            const Color(0xFFE11D48),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(BuildContext context, String title, String desc, IconData icon, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BloodBankSnapshotWidget extends StatelessWidget {
  const BloodBankSnapshotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final bloodData = [
      {'type': 'A+', 'units': 85, 'status': 'Healthy', 'color': const Color(0xFF10B981)},
      {'type': 'A-', 'units': 18, 'status': 'Adequate', 'color': const Color(0xFF0284C7)},
      {'type': 'B+', 'units': 92, 'status': 'Healthy', 'color': const Color(0xFF10B981)},
      {'type': 'B-', 'units': 14, 'status': 'Low', 'color': const Color(0xFFF59E0B)},
      {'type': 'AB+', 'units': 40, 'status': 'Healthy', 'color': const Color(0xFF10B981)},
      {'type': 'AB-', 'units': 6, 'status': 'Critical', 'color': const Color(0xFFEF4444)},
      {'type': 'O+', 'units': 110, 'status': 'Healthy', 'color': const Color(0xFF10B981)},
      {'type': 'O-ve', 'units': 2, 'status': 'CRITICAL LOW', 'color': const Color(0xFFEF4444)},
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
                      icon: Icons.bloodtype_outlined,
                      color: Color(0xFFE11D48),
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Blood Bank Inventory Grid',
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
                '367 Total Units',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: bloodData.map((b) {
              final color = b['color'] as Color;
              return Container(
                width: 78,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3), width: 1.2),
                ),
                child: Column(
                  children: [
                    Text(
                      b['type'] as String,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${b['units']} units',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b['status'] as String,
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PatientAppSyncWidget extends StatelessWidget {
  const PatientAppSyncWidget({super.key});

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
            children: [
              const GlassIconContainer(
                icon: Icons.sync_rounded,
                color: AppTheme.accentColor,
                size: 34,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Healthify Patient App Sync Status',
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
          const SizedBox(height: 16),

          _buildSyncRow(context, 'Public Bed Availability Broadcast', '42 Free Beds Visible', Icons.wifi_tethering_rounded, const Color(0xFF10B981)),
          Divider(color: HealthifyGlassTheme.getGlassBorder(isDark), height: 16),
          _buildSyncRow(context, 'Live ER Wait Time Broadcast', '14 Minutes (Normal)', Icons.access_time_filled_rounded, AppTheme.accentColor),
          Divider(color: HealthifyGlassTheme.getGlassBorder(isDark), height: 16),
          _buildSyncRow(context, 'Tele-consult Open Slots', '12 Available Today', Icons.video_call_rounded, AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildSyncRow(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class AttentionTaskListWidget extends StatefulWidget {
  const AttentionTaskListWidget({super.key});

  @override
  State<AttentionTaskListWidget> createState() => _AttentionTaskListWidgetState();
}

class _AttentionTaskListWidgetState extends State<AttentionTaskListWidget> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Approve weekend shift roster for ER nurses', 'completed': false},
    {'title': 'Confirm blood supplier delivery for O-ve reserve', 'completed': false},
    {'title': 'Conduct daily ICU equipment audit with Chief Engineer', 'completed': false},
    {'title': 'Review morning discharge summaries with Dr. Chen', 'completed': true},
    {'title': 'Authorize oxygen bulk tank refill request', 'completed': false},
  ];

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
                      icon: Icons.check_box_outlined,
                      color: AppTheme.primaryColor,
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'What Needs Attention Today',
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
              Text(
                '${_tasks.where((t) => t['completed'] as bool).length} / ${_tasks.length} Done',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tasks.length,
            separatorBuilder: (context, index) => Divider(color: HealthifyGlassTheme.getGlassBorder(isDark), height: 12),
            itemBuilder: (context, index) {
              final t = _tasks[index];
              final isDone = t['completed'] as bool;
              return InkWell(
                onTap: () {
                  setState(() {
                    _tasks[index]['completed'] = !isDone;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      activeColor: AppTheme.primaryColor,
                      checkColor: Colors.white,
                      side: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.5),
                      onChanged: (val) {
                        setState(() {
                          _tasks[index]['completed'] = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        t['title'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDone
                              ? (isDark ? Colors.white38 : AppTheme.textMuted)
                              : (isDark ? Colors.white : AppTheme.textPrimary),
                          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RecentActivityFeedWidget extends StatelessWidget {
  const RecentActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final activities = [
      {'time': '10:42 AM', 'desc': 'Patient John Doe admitted to ICU Bed #108 by Dr. Smith', 'icon': Icons.king_bed_outlined, 'color': AppTheme.primaryColor},
      {'time': '10:35 AM', 'desc': 'Emergency Blood Request dispatched for O+ (2 units) to OR 3', 'icon': Icons.bloodtype_outlined, 'color': const Color(0xFFE11D48)},
      {'time': '10:20 AM', 'desc': 'Lab results uploaded for Patient #PAT-8842 (CBC Complete)', 'icon': Icons.science_outlined, 'color': AppTheme.accentColor},
      {'time': '10:05 AM', 'desc': 'Dr. Robert Chen signed off on 4 discharge summaries', 'icon': Icons.check_circle_outline_rounded, 'color': const Color(0xFF10B981)},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIconContainer(
                icon: Icons.history_rounded,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                size: 34,
                iconSize: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recent Hospital Activity Log',
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
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(color: HealthifyGlassTheme.getGlassBorder(isDark), height: 14),
            itemBuilder: (context, index) {
              final act = activities[index];
              final color = act['color'] as Color;

              return Row(
                children: [
                  GlassIconContainer(
                    icon: act['icon'] as IconData,
                    color: color,
                    size: 28,
                    iconSize: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      act['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    act['time'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.white38 : AppTheme.textMuted,
                    ),
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