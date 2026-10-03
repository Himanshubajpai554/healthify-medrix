import 'dart:ui';
import 'package:flutter/material.dart';
import '../../patient/emergency/emergency_hospitals_modal.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
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

  // ── Palette (mirrors Patient Dashboard exactly) ──────────────────────
  static const Color _primary = Color(0xFF0D9488);

  static Color _surfaceStrong(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);

  static Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.88);

  static Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;

  static Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  static Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  // ── Availability helpers ─────────────────────────────────────────────
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

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 850;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            border: Border(bottom: BorderSide(color: _border(isDark))),
          ),
          child: Row(
            children: [
              // ── 1. Branded Title (matches Patient header) ────────
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: isDark ? 0.14 : 0.11),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: _primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: _primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'HEALTHIFY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _primary,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!isCompact)
                                  TextSpan(
                                    text: ' | Doctor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _primaryText(isDark),
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!isCompact && subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: _secondaryText(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Action Controls Row ───────────────────────────
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _border(isDark)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 16,
                                    color: _secondaryText(isDark),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Search patients...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _secondaryText(isDark),
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
                            color: _primaryText(isDark),
                          ),
                          tooltip: 'Search Patients',
                          onPressed: onSearchTap,
                        ),

                      // Emergency Quick Assist Pill
                      if (screenWidth >= 650)
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
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                          ),
                          tooltip: '24/7 ER Assist',
                          onPressed: () => EmergencyHospitalsModal.show(context),
                        ),
                      const SizedBox(width: 6),

                      // Doctor Status & Portal Switcher Pill
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _primary.withValues(
                            alpha: isDark ? 0.10 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _primary.withValues(alpha: 0.25),
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
                              const Icon(
                                Icons.medical_services_rounded,
                                size: 15,
                                color: _primary,
                              ),
                              if (!isCompact) ...[
                                const SizedBox(width: 4),
                                const Text(
                                  'DOCTOR',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _primary,
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
                              ],
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 16,
                                color: _primary,
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

                      // Notification Bell with Badge
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_rounded,
                              color: _primaryText(isDark),
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
                          color: _primaryText(isDark),
                        ),
                        tooltip: isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: onThemeToggle,
                      ),
                      const SizedBox(width: 6),

                      // Doctor Profile Shortcut Pill
                      InkWell(
                        onTap: onProfileTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _surface(isDark),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _border(isDark)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: _primary,
                                child: Text(
                                  doctorName.isNotEmpty ? doctorName[0] : 'D',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (!isCompact) ...[
                                const SizedBox(width: 8),
                                Text(
                                  doctorName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryText(isDark),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: _secondaryText(isDark),
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
