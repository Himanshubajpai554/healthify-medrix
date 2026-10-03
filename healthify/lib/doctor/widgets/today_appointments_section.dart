import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class TodayAppointmentsSection extends StatefulWidget {
  final List<DoctorAppointmentModel> appointments;
  final ValueChanged<DoctorAppointmentModel> onStartConsultation;
  final ValueChanged<DoctorAppointmentModel> onViewPatient;
  final ValueChanged<DoctorAppointmentModel> onReschedule;
  final ValueChanged<DoctorAppointmentModel> onMarkCompleted;
  final VoidCallback onViewAll;

  const TodayAppointmentsSection({
    super.key,
    required this.appointments,
    required this.onStartConsultation,
    required this.onViewPatient,
    required this.onReschedule,
    required this.onMarkCompleted,
    required this.onViewAll,
  });

  @override
  State<TodayAppointmentsSection> createState() =>
      _TodayAppointmentsSectionState();
}

class _TodayAppointmentsSectionState extends State<TodayAppointmentsSection> {
  String _selectedFilter = 'All';

  List<DoctorAppointmentModel> get _filteredAppointments {
    if (_selectedFilter == 'All') return widget.appointments;
    return widget.appointments.where((apt) {
      switch (_selectedFilter) {
        case 'Waiting':
          return apt.status == AppointmentStatus.waiting;
        case 'Upcoming':
          return apt.status == AppointmentStatus.upcoming;
        case 'In Consultation':
          return apt.status == AppointmentStatus.inConsultation;
        case 'Completed':
          return apt.status == AppointmentStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Appointments",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Chronological OPD & Consultation Schedule',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassSecondaryButton(
                height: 36,
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                  widget.onViewAll();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Waiting'),
                const SizedBox(width: 8),
                _buildFilterChip('Upcoming'),
                const SizedBox(width: 8),
                _buildFilterChip('In Consultation'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appointment Items List
          if (_filteredAppointments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 48,
                    color: HealthifyGlassTheme.getTextMuted(isDark),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No appointments found for "$_selectedFilter"',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAppointments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final apt = _filteredAppointments[index];
                return _buildAppointmentCard(context, apt, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () => setState(() => _selectedFilter = label),
      activeColor: HealthifyGlassTheme.primaryTeal,
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    DoctorAppointmentModel apt,
    bool isDark,
  ) {
    final isNext = apt.isNextUpcoming;
    final patient = apt.patient;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext
            ? HealthifyGlassTheme.primaryTeal.withValues(
                alpha: isDark ? 0.16 : 0.08,
              )
            : HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext
              ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.6)
              : HealthifyGlassTheme.getGlassBorder(isDark),
          width: isNext ? 1.6 : 1.0,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Appointment Time & Token Badge & Next In Line
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: HealthifyGlassTheme.primaryTeal.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${apt.appointmentTime} • ${apt.tokenNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                      ),
                    ),
                    if (isNext)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'NEXT IN LINE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(apt.status),
            ],
          ),
          const SizedBox(height: 12),

          // Patient Avatar, Name & Concern
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: HealthifyGlassTheme.primaryTeal,
                backgroundImage: NetworkImage(patient.avatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: Text(
                  patient.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient.name} (${patient.age} yrs)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${apt.appointmentType} • ${apt.department}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => widget.onViewPatient(apt),
                icon: const Icon(Icons.person_outline_rounded, size: 15),
                label: const Text('View Patient'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(
                    color: HealthifyGlassTheme.getTextSecondary(isDark)
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onStartConsultation(apt),
                icon: const Icon(Icons.video_call_rounded, size: 15),
                label: const Text('Start Consult'),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => widget.onReschedule(apt),
                icon: const Icon(Icons.schedule_rounded, size: 15),
                label: const Text('Reschedule'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (apt.status != AppointmentStatus.completed)
                IconButton(
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  onPressed: () => widget.onMarkCompleted(apt),
                  tooltip: 'Mark Completed',
                ),
            ],
          ),
        ],
      ),
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
        fg = Colors.amber.shade800;
        label = 'Waiting';
        break;
      case AppointmentStatus.inConsultation:
        bg = HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.18);
        fg = HealthifyGlassTheme.primaryTeal;
        label = 'In Consultation';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
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
