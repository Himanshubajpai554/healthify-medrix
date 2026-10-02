import 'dart:ui';
import 'package:flutter/material.dart';
import '../../patient/emergency/emergency_hospitals_modal.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorHeader extends StatelessWidget {
  final String doctorName;
  final String? title;
  final String? subtitle;
  final DoctorAvailability availabilityStatus;
  final ValueChanged<DoctorAvailability> onAvailabilityChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onThemeToggle;
  final int unreadNotificationsCount;

  const DoctorHeader({
    super.key,
    required this.doctorName,
    this.title,
    this.subtitle,
    required this.availabilityStatus,
    required this.onAvailabilityChanged,
    required this.onNotificationTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onThemeToggle,
    required this.unreadNotificationsCount,
  });

  Color _getStatusColor(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return const Color(0xFF10B981);
      case DoctorAvailability.busy:
        return Colors.amber.shade800;
      case DoctorAvailability.offline:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusBgColor(DoctorAvailability status, bool isDark) {
    final baseColor = _getStatusColor(status);
    return baseColor.withValues(alpha: isDark ? 0.18 : 0.10);
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

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 650;
    final primary = HealthifyGlassTheme.primaryTeal;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.075)
                : Colors.white.withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
          ),
          child: Row(
            children: [
              // 1. Page Title & Subtitle (Patient Header Style)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? 'Doctor Dashboard',
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCompact && subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // 2. Action Controls Row (Patient Header Style)
              Flexible(
                fit: FlexFit.loose,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Button / Input Pill
                      if (screenWidth >= 850)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: onSearchTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 190,
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 16,
                                    color: HealthifyGlassTheme.getTextMuted(isDark),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Search patients...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: HealthifyGlassTheme.getTextMuted(isDark),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                          tooltip: 'Search Patients',
                          onPressed: onSearchTap,
                        ),

                      // Emergency Quick Assist Pill
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => EmergencyHospitalsModal.show(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 15,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '24/7 ER Assist',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Doctor Portal Switcher & Status Pill
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(availabilityStatus, isDark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(availabilityStatus).withValues(alpha: 0.35),
                          ),
                        ),
                        child: PopupMenuButton<DoctorAvailability>(
                          onSelected: onAvailabilityChanged,
                          tooltip: 'Availability Status',
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(availabilityStatus),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DOCTOR PORTAL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '• ${_getStatusLabel(availabilityStatus)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(availabilityStatus),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 16,
                                color: _getStatusColor(availabilityStatus),
                              ),
                            ],
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: DoctorAvailability.available,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF10B981),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Available for Consults',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: DoctorAvailability.busy,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.remove_circle_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'In Surgery / Busy',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: DoctorAvailability.offline,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.do_not_disturb_on_rounded,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Offline / Off-Duty',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Notification Bell Action with Badge
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                            tooltip: 'Notifications',
                            onPressed: onNotificationTap,
                          ),
                          if (unreadNotificationsCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 15,
                                  minHeight: 15,
                                ),
                                child: Text(
                                  '$unreadNotificationsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Theme Toggle
                      IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                        tooltip: isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: onThemeToggle,
                      ),
                      const SizedBox(width: 6),

                      // Doctor Profile Shortcut Pill (Patient Header Style)
                      InkWell(
                        onTap: onProfileTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: HealthifyGlassTheme.getGlassBorder(isDark),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: primary,
                                child: Text(
                                  doctorName.isNotEmpty ? doctorName[0] : 'D',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                doctorName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
