import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentsHeader extends StatelessWidget {
  final String doctorName;
  final DoctorAvailability availabilityStatus;
  final ValueChanged<DoctorAvailability> onAvailabilityChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onThemeToggle;
  final VoidCallback onAddAvailability;
  final VoidCallback onViewSchedule;
  final bool isCalendarView;
  final VoidCallback onToggleCalendarView;
  final int unreadNotificationsCount;

  const AppointmentsHeader({
    super.key,
    required this.doctorName,
    required this.availabilityStatus,
    required this.onAvailabilityChanged,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onThemeToggle,
    required this.onAddAvailability,
    required this.onViewSchedule,
    required this.isCalendarView,
    required this.onToggleCalendarView,
    required this.unreadNotificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
        border: Border(
          bottom: BorderSide(
            color: HealthifyGlassTheme.getGlassBorder(isDark),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Page Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: HealthifyGlassTheme.primaryTeal.withValues(
                              alpha: isDark ? 0.22 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Clinical Schedule',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Manage your schedule and patient consultations.',
                        style: TextStyle(
                          fontSize: 13,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Availability Dropdown Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(availabilityStatus, isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(availabilityStatus).withValues(alpha: 0.4),
                  ),
                ),
                child: PopupMenuButton<DoctorAvailability>(
                  onSelected: onAvailabilityChanged,
                  tooltip: 'Change Status',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(availabilityStatus),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusLabel(availabilityStatus),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(availabilityStatus),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 18,
                        color: _getStatusColor(availabilityStatus),
                      ),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: DoctorAvailability.available,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Text('Available'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: DoctorAvailability.busy,
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle_rounded, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text('Busy'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: DoctorAvailability.offline,
                      child: Row(
                        children: [
                          Icon(Icons.do_not_disturb_on_rounded, color: Colors.grey, size: 18),
                          SizedBox(width: 8),
                          Text('Offline'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Search Button
              IconButton(
                icon: Icon(Icons.search_rounded, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                onPressed: onSearchTap,
                tooltip: 'Search Patients & Appointments',
              ),

              // Notifications
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    onPressed: onNotificationTap,
                    tooltip: 'Notifications',
                  ),
                  if (unreadNotificationsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unreadNotificationsCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // Theme Toggle
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
                onPressed: onThemeToggle,
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 4),

              // Profile Avatar
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  child: Text(
                    doctorName.isNotEmpty ? doctorName[0] : 'D',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),

          // Header Actions Toolbar (Primary "+ Add Availability" & Secondary "View Schedule")
          if (!isMobile) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                GlassPrimaryButton(
                  onPressed: onAddAvailability,
                  height: 38,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('+ Add Availability', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GlassSecondaryButton(
                  onPressed: onViewSchedule,
                  height: 38,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('View Schedule', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                // View Mode Switcher (List View / Calendar View)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (isCalendarView) onToggleCalendarView();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: !isCalendarView ? HealthifyGlassTheme.primaryTeal : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.view_list_rounded,
                                size: 16,
                                color: !isCalendarView ? Colors.white : HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'List View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !isCalendarView ? Colors.white : HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (!isCalendarView) onToggleCalendarView();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isCalendarView ? HealthifyGlassTheme.primaryTeal : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_view_week_rounded,
                                size: 16,
                                color: isCalendarView ? Colors.white : HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Calendar View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCalendarView ? Colors.white : HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return const Color(0xFF10B981);
      case DoctorAvailability.busy:
        return Colors.amber.shade700;
      case DoctorAvailability.offline:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusBgColor(DoctorAvailability status, bool isDark) {
    return _getStatusColor(status).withValues(alpha: isDark ? 0.20 : 0.12);
  }

  String _getStatusLabel(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return 'Available';
      case DoctorAvailability.busy:
        return 'Busy';
      case DoctorAvailability.offline:
        return 'Offline';
    }
  }
}
