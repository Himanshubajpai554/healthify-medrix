import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';
import '../doctor_model.dart';

class DoctorScheduleDrawer extends StatelessWidget {
  final DoctorItem doctor;
  final VoidCallback onClose;
  final ValueChanged<DoctorStatus> onStatusChanged;

  const DoctorScheduleDrawer({
    super.key,
    required this.doctor,
    required this.onClose,
    required this.onStatusChanged,
  });

  Color _getStatusColor(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.available:
        return const Color(0xFF10B981);
      case DoctorStatus.inSurgery:
        return const Color(0xFF8B5CF6);
      case DoctorStatus.busy:
        return const Color(0xFFF59E0B);
      case DoctorStatus.offDuty:
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.available:
        return 'Available';
      case DoctorStatus.inSurgery:
        return 'In Surgery';
      case DoctorStatus.busy:
        return 'Busy';
      case DoctorStatus.offDuty:
        return 'Off Duty';
      default:
        return status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(doctor.status);
    final isDark = HealthifyGlassTheme.isDark(context);

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF061817).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2928) : AppTheme.backgroundColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : AppTheme.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: doctor.avatarGradientStart,
                      child: Text(
                        doctor.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${doctor.id} • ${doctor.department}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Drawer Body Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge Card
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 10),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(doctor.status),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${doctor.activePatients} Active Patients',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shift & Roster Info
                  _buildDetailTile(
                    context,
                    icon: Icons.access_time_rounded,
                    label: 'Shift Roster Hours',
                    value: doctor.shiftHours,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailTile(
                    context,
                    icon: Icons.business_outlined,
                    label: 'Specialty Department',
                    value: doctor.department,
                  ),
                  const SizedBox(height: 14),

                  _buildDetailTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: 'Clinical Experience',
                    value: '${doctor.experienceYears} Years Practice',
                  ),

                  const SizedBox(height: 24),
                  Divider(color: isDark ? Colors.white12 : AppTheme.borderLight),
                  const SizedBox(height: 16),

                  // Today's Appointment Roster
                  Text(
                    'Today\'s Shift Roster',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _buildScheduleSlot(context, '09:00 AM', 'Outpatient Consultations (Clinic 3)', true),
                      _buildScheduleSlot(context, '11:30 AM', 'Ward Rounds & Patient Inspection', true),
                      _buildScheduleSlot(context, '02:00 PM', 'Surgical Operation (OR-02)', doctor.status == DoctorStatus.inSurgery),
                      _buildScheduleSlot(context, '04:30 PM', 'Emergency Call Duty Block', false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Drawer Footer Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2928) : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? Colors.white12 : AppTheme.borderLight),
              ),
            ),
            child: Column(
              children: [
                GlassPrimaryButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing full appointment roster for ${doctor.name}')),
                    );
                    onClose();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('View Full Calendar Schedule'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSlot(BuildContext context, String time, String title, bool isCompleted) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted
                    ? (isDark ? Colors.white : AppTheme.textPrimary)
                    : (isDark ? Colors.white38 : AppTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white60 : AppTheme.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white38 : AppTheme.textMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}