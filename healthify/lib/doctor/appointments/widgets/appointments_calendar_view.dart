import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentsCalendarView extends StatefulWidget {
  final List<DoctorAppointmentModel> appointments;
  final ValueChanged<DoctorAppointmentModel> onSelectAppointment;

  const AppointmentsCalendarView({
    super.key,
    required this.appointments,
    required this.onSelectAppointment,
  });

  @override
  State<AppointmentsCalendarView> createState() => _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  String _calendarMode = 'Day'; // 'Day' or 'Week'

  final timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Selector Header (Day / Week)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Clinical Calendar View',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              Row(
                children: [
                  _buildModeChip('Day'),
                  const SizedBox(width: 8),
                  _buildModeChip('Week'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time Slots Block Schedule
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeSlots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final slot = timeSlots[index];
              final matchingApt = widget.appointments.firstWhere(
                (a) => a.appointmentTime == slot,
                orElse: () => DoctorAppointmentModel(
                  id: '',
                  patient: const PatientModel(
                    id: '',
                    name: 'Available Slot',
                    age: 0,
                    gender: '',
                    avatarUrl: '',
                    phone: '',
                    bloodGroup: '',
                    mrn: '',
                    lastVisitDate: '',
                    lastVisitDoctor: '',
                    primaryConcern: '',
                  ),
                  appointmentTime: slot,
                  appointmentType: 'Open Slot',
                  department: 'OPD',
                  status: AppointmentStatus.upcoming,
                  tokenNumber: '',
                  reasonForVisit: 'Open for booking',
                  date: DateTime.now(),
                ),
              );

              final isBooked = matchingApt.id.isNotEmpty;

              return InkWell(
                onTap: isBooked ? () => widget.onSelectAppointment(matchingApt) : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? HealthifyGlassTheme.primaryTeal.withValues(
                            alpha: isDark ? 0.16 : 0.08,
                          )
                        : HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isBooked
                          ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4)
                          : HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Time indicator
                      SizedBox(
                        width: 80,
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isBooked
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getTextMuted(isDark),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 24, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                      const SizedBox(width: 14),

                      // Details
                      Expanded(
                        child: Row(
                          children: [
                            if (isBooked) ...[
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: HealthifyGlassTheme.primaryTeal,
                                backgroundImage: NetworkImage(matchingApt.patient.avatarUrl),
                                onBackgroundImageError: (exception, stackTrace) {},
                                child: Text(
                                  matchingApt.patient.name[0],
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBooked ? matchingApt.patient.name : '09:30 ─ Available Slot',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isBooked ? FontWeight.bold : FontWeight.w500,
                                      color: isBooked
                                          ? HealthifyGlassTheme.getTextPrimary(isDark)
                                          : HealthifyGlassTheme.getTextMuted(isDark),
                                    ),
                                  ),
                                  if (isBooked)
                                    Text(
                                      '${matchingApt.appointmentType} • ${matchingApt.department}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isBooked)
                        Icon(Icons.chevron_right_rounded, color: HealthifyGlassTheme.getTextSecondary(isDark), size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode) {
    final isSelected = _calendarMode == mode;
    return GlassSelectionChip(
      label: mode,
      isSelected: isSelected,
      onTap: () => setState(() => _calendarMode = mode),
      activeColor: HealthifyGlassTheme.primaryTeal,
    );
  }
}
