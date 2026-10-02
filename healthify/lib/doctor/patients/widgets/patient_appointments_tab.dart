import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientAppointmentsTab extends StatelessWidget {
  final List<DoctorAppointmentModel> appointments;

  const PatientAppointmentsTab({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = appointments.where((a) => a.status == AppointmentStatus.upcoming || a.status == AppointmentStatus.waiting || a.status == AppointmentStatus.checkedIn).toList();
    final completed = appointments.where((a) => a.status == AppointmentStatus.completed).toList();
    final cancelled = appointments.where((a) => a.status == AppointmentStatus.cancelled).toList();
    final noShow = appointments.where((a) => a.status == AppointmentStatus.noShow).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader('Upcoming & Active Appointments', Icons.calendar_today_rounded, AppTheme.primaryTeal),
          const SizedBox(height: 10),
          ...upcoming.map((apt) => _buildAppointmentCard(apt)),
          const SizedBox(height: 20),
        ],

        if (completed.isNotEmpty) ...[
          _buildSectionHeader('Completed Consultations', Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
          const SizedBox(height: 10),
          ...completed.map((apt) => _buildAppointmentCard(apt)),
          const SizedBox(height: 20),
        ],

        if (cancelled.isNotEmpty) ...[
          _buildSectionHeader('Cancelled Appointments', Icons.cancel_outlined, const Color(0xFFEF4444)),
          const SizedBox(height: 10),
          ...cancelled.map((apt) => _buildAppointmentCard(apt)),
          const SizedBox(height: 20),
        ],

        if (noShow.isNotEmpty) ...[
          _buildSectionHeader('No Show Log', Icons.person_off_outlined, const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          ...noShow.map((apt) => _buildAppointmentCard(apt)),
        ],

        if (appointments.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No appointment history recorded for this patient.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(DoctorAppointmentModel apt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_rounded, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Token ${apt.tokenNumber} • ${apt.appointmentType}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      _buildStatusBadge(apt.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${apt.appointmentTime} • ${apt.department} • ${apt.consultationMode}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${apt.reasonForVisit}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AppointmentStatus.upcoming:
      case AppointmentStatus.checkedIn:
      case AppointmentStatus.waiting:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        label = 'Scheduled';
        break;
      case AppointmentStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'Cancelled';
        break;
      case AppointmentStatus.noShow:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'No Show';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppTheme.textSecondary;
        label = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
