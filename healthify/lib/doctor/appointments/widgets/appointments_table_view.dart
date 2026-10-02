import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentsTableView extends StatelessWidget {
  final List<DoctorAppointmentModel> appointments;
  final ValueChanged<DoctorAppointmentModel> onStartConsultation;
  final ValueChanged<DoctorAppointmentModel> onViewPatient;
  final ValueChanged<DoctorAppointmentModel> onViewDetails;
  final ValueChanged<DoctorAppointmentModel> onReschedule;
  final ValueChanged<DoctorAppointmentModel> onCancel;
  final ValueChanged<DoctorAppointmentModel> onCallPatient;

  const AppointmentsTableView({
    super.key,
    required this.appointments,
    required this.onStartConsultation,
    required this.onViewPatient,
    required this.onViewDetails,
    required this.onReschedule,
    required this.onCancel,
    required this.onCallPatient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (!isDesktop) {
      return _buildMobileCardList(context, isDark);
    }

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Table Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildHeaderCell('TIME & TOKEN', flex: 2, isDark: isDark),
                _buildHeaderCell('PATIENT', flex: 3, isDark: isDark),
                _buildHeaderCell('APPOINTMENT TYPE', flex: 2, isDark: isDark),
                _buildHeaderCell('DEPARTMENT / REASON', flex: 3, isDark: isDark),
                _buildHeaderCell('STATUS', flex: 2, isDark: isDark),
                _buildHeaderCell('ACTIONS', flex: 2, alignRight: true, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (context, index) => const Divider(height: 12, thickness: 0.8),
            itemBuilder: (context, index) {
              final apt = appointments[index];
              return _buildTableRow(context, apt, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {required int flex, required bool isDark, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: HealthifyGlassTheme.getTextMuted(isDark),
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, DoctorAppointmentModel apt, bool isDark) {
    final patient = apt.patient;

    return InkWell(
      onTap: () => onViewDetails(apt),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Time & Token
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.appointmentTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    'Token ${apt.tokenNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                  ),
                  if (apt.checkedInTime != null)
                    Text(
                      'Arrived ${apt.checkedInTime}',
                      style: TextStyle(fontSize: 10, color: HealthifyGlassTheme.getTextMuted(isDark)),
                    ),
                ],
              ),
            ),

            // Patient
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    backgroundImage: NetworkImage(patient.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          '${patient.age} yrs • ${patient.gender} • ${patient.mrn}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Appointment Type
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.appointmentType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    apt.consultationMode,
                    style: TextStyle(
                      fontSize: 11,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Department / Reason
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.department,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    apt.reasonForVisit,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status Badge
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusBadge(apt.status),
              ),
            ),

            // Action Buttons / Popup Menu
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (apt.status == AppointmentStatus.waiting || apt.status == AppointmentStatus.checkedIn || apt.status == AppointmentStatus.upcoming)
                    ElevatedButton.icon(
                      onPressed: () => onStartConsultation(apt),
                      icon: const Icon(Icons.video_call_rounded, size: 14),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HealthifyGlassTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 4),

                  // 3-Dot Contextual Action Menu
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'view_patient':
                          onViewPatient(apt);
                          break;
                        case 'view_details':
                          onViewDetails(apt);
                          break;
                        case 'start':
                          onStartConsultation(apt);
                          break;
                        case 'reschedule':
                          onReschedule(apt);
                          break;
                        case 'cancel':
                          onCancel(apt);
                          break;
                        case 'call':
                          onCallPatient(apt);
                          break;
                      }
                    },
                    icon: Icon(Icons.more_vert_rounded, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    itemBuilder: (context) => _buildContextualMenuItems(apt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildContextualMenuItems(DoctorAppointmentModel apt) {
    final items = <PopupMenuEntry<String>>[];

    items.add(const PopupMenuItem(value: 'view_patient', child: Text('View Patient Profile')));
    items.add(const PopupMenuItem(value: 'view_details', child: Text('View Appointment Details')));

    if (apt.status == AppointmentStatus.waiting) {
      items.add(const PopupMenuItem(value: 'call', child: Text('Call Patient')));
      items.add(const PopupMenuItem(value: 'start', child: Text('Start Consultation')));
    } else if (apt.status == AppointmentStatus.upcoming || apt.status == AppointmentStatus.checkedIn) {
      items.add(const PopupMenuItem(value: 'start', child: Text('Start Consultation')));
    }

    if (apt.status != AppointmentStatus.completed && apt.status != AppointmentStatus.cancelled) {
      items.add(const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')));
      items.add(const PopupMenuItem(value: 'cancel', child: Text('Cancel Appointment', style: TextStyle(color: Colors.redAccent))));
    }

    return items;
  }

  Widget _buildMobileCardList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final apt = appointments[index];
        final patient = apt.patient;

        return GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          onTap: () => onViewDetails(apt),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${apt.appointmentTime} • Token ${apt.tokenNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                  ),
                  _buildStatusBadge(apt.status),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    backgroundImage: NetworkImage(patient.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.name} (${patient.age} yrs)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '${apt.appointmentType} • ${apt.department}',
                          style: TextStyle(
                            fontSize: 12,
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
                'Reason: ${apt.reasonForVisit}',
                style: TextStyle(
                  fontSize: 12.5,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onStartConsultation(apt),
                    icon: const Icon(Icons.video_call_rounded, size: 14),
                    label: const Text('Start Consult'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => onViewPatient(apt),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('View Patient'),
                  ),
                  OutlinedButton(
                    onPressed: () => onReschedule(apt),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('Reschedule'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AppointmentStatus.upcoming:
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade700;
        label = 'Upcoming';
        break;
      case AppointmentStatus.checkedIn:
        bg = Colors.teal.withValues(alpha: 0.15);
        fg = Colors.teal.shade700;
        label = 'Checked In';
        break;
      case AppointmentStatus.waiting:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade900;
        label = 'Waiting';
        break;
      case AppointmentStatus.inConsultation:
        bg = HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.18);
        fg = HealthifyGlassTheme.primaryTeal;
        label = 'In Consult';
        break;
      case AppointmentStatus.completed:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bg = Colors.redAccent.withValues(alpha: 0.15);
        fg = Colors.redAccent;
        label = 'Cancelled';
        break;
      case AppointmentStatus.noShow:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey.shade700;
        label = 'No Show';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
