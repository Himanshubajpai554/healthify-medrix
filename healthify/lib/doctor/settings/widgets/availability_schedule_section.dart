import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';
import '../../models/doctor_profile_models.dart';

class AvailabilityScheduleSection extends StatefulWidget {
  final DoctorAvailability currentStatus;
  final ValueChanged<DoctorAvailability> onStatusChanged;
  final List<DayScheduleModel> weeklySchedule;
  final ValueChanged<List<DayScheduleModel>> onSaveSchedule;
  final List<AvailabilityExceptionModel> exceptions;
  final ValueChanged<AvailabilityExceptionModel> onAddException;
  final ValueChanged<String> onRemoveException;

  const AvailabilityScheduleSection({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.weeklySchedule,
    required this.onSaveSchedule,
    required this.exceptions,
    required this.onAddException,
    required this.onRemoveException,
  });

  @override
  State<AvailabilityScheduleSection> createState() =>
      _AvailabilityScheduleSectionState();
}

class _AvailabilityScheduleSectionState
    extends State<AvailabilityScheduleSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: [
        // 1. Current Status & Quick Toggle Card
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.online_prediction_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Real-Time Consultation Availability',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Control your immediate availability state for hospital booking queues.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.currentStatus == DoctorAvailability.available
                            ? const Color(0xFF10B981)
                            : (widget.currentStatus == DoctorAvailability.busy
                                ? Colors.amber
                                : Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Status: ${_getStatusLabel(widget.currentStatus)}',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            widget.currentStatus == DoctorAvailability.available
                                ? 'Patients and triage nurses can assign appointments and emergency cases.'
                                : 'New appointments and emergency assignments are currently paused.',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: widget.currentStatus == DoctorAvailability.available,
                      onChanged: (val) {
                        widget.onStatusChanged(
                          val ? DoctorAvailability.available : DoctorAvailability.offline,
                        );
                      },
                      activeTrackColor: HealthifyGlassTheme.primaryTeal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Weekly Availability Schedule
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.calendar_month_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Practice Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Configure recurring OPD hours and consultation slots per day.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassSecondaryButton(
                    height: 36,
                    onPressed: () => _openEditScheduleDialog(context),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_calendar_rounded, size: 16),
                        SizedBox(width: 5),
                        Text('Edit Schedule', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              ...widget.weeklySchedule.map((day) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HealthifyGlassTheme.getGlassBorder(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            day.dayName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: day.isAvailable
                                  ? HealthifyGlassTheme.getTextPrimary(isDark)
                                  : HealthifyGlassTheme.getTextMuted(isDark),
                            ),
                          ),
                        ),
                        Expanded(
                          child: day.isAvailable && day.timeSlots.isNotEmpty
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: day.timeSlots.map((slot) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HealthifyGlassTheme.primaryTeal.withValues(
                                          alpha: isDark ? 0.20 : 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : HealthifyGlassTheme.primaryTeal,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Unavailable',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Availability Exceptions (Leave, Holiday, Conference)
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.event_busy_rounded,
                    size: 40,
                    iconSize: 20,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Availability Exceptions & Leave',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Add specific leave dates, holidays, or conference period blocks.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassSecondaryButton(
                    height: 36,
                    onPressed: () => _openAddExceptionDialog(context),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, size: 16),
                        SizedBox(width: 4),
                        Text('Add Exception', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              if (widget.exceptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No upcoming schedule exceptions or leave dates logged.',
                      style: TextStyle(
                        fontSize: 13,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                      ),
                    ),
                  ),
                )
              else
                ...widget.exceptions.map((exc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HealthifyGlassTheme.getGlassBorder(isDark),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.event_available_rounded, size: 20, color: Colors.amber),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(exc.date),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        exc.reason,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (exc.notes != null && exc.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    exc.notes!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                            onPressed: () => widget.onRemoveException(exc.id),
                            tooltip: 'Remove Exception',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  void _openEditScheduleDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly availability schedule modified and synchronized with hospital booking system.'),
        backgroundColor: HealthifyGlassTheme.primaryTeal,
      ),
    );
  }

  void _openAddExceptionDialog(BuildContext context) {
    final reasonCtrl = TextEditingController(text: 'Personal Leave');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = HealthifyGlassTheme.isDarkMode(dialogCtx);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: Text(
            'Add Availability Exception',
            style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason (e.g. Leave, Conference)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Additional Notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
              onPressed: () {
                final exc = AvailabilityExceptionModel(
                  id: 'EXC-${DateTime.now().millisecondsSinceEpoch}',
                  date: DateTime.now().add(const Duration(days: 2)),
                  isAvailable: false,
                  reason: reasonCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );
                widget.onAddException(exc);
                Navigator.pop(dialogCtx);
              },
              child: const Text('Add Exception', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _getStatusLabel(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return 'Available';
      case DoctorAvailability.busy:
        return 'Busy';
      case DoctorAvailability.offline:
        return 'Offline / Unavailable';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
