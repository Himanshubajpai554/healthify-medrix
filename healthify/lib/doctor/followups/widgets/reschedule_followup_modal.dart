import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class RescheduleFollowUpModal extends StatefulWidget {
  final DoctorFollowUpFullModel followUp;
  final Function(DateTime newDate, String newTimeSlot, String reason) onRescheduleConfirmed;

  const RescheduleFollowUpModal({
    super.key,
    required this.followUp,
    required this.onRescheduleConfirmed,
  });

  @override
  State<RescheduleFollowUpModal> createState() => _RescheduleFollowUpModalState();
}

class _RescheduleFollowUpModalState extends State<RescheduleFollowUpModal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _newDate;
  String _newTimeSlot = '11:00 AM';
  final _reasonController = TextEditingController();

  final List<String> _timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _newDate = widget.followUp.followUpDate.add(const Duration(days: 3));
    _newTimeSlot = widget.followUp.followUpTime;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onRescheduleConfirmed(_newDate, _newTimeSlot, _reasonController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.update_rounded,
                      size: 40,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reschedule Follow-up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'ID: ${widget.followUp.id} • ${widget.followUp.patientName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current Schedule Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, color: isDark ? Colors.white60 : const Color(0xFF64748B), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Current Date & Time: ${widget.followUp.followUpDate.day}/${widget.followUp.followUpDate.month}/${widget.followUp.followUpDate.year} at ${widget.followUp.followUpTime}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // New Date Picker Trigger
                Text('New Follow-up Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _newDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (picked != null) setState(() => _newDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_newDate.day}/${_newDate.month}/${_newDate.year}',
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                        const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF0D9488)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // New Time Slot Dropdown
                Text('New Time Slot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _newTimeSlot,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
                  ),
                  items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _newTimeSlot = val);
                  },
                ),
                const SizedBox(height: 14),

                // Reschedule Reason
                Text('Reason for Rescheduling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a reason for rescheduling.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. Patient requested morning slot due to work conflict.',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassSecondaryButton(
                      onPressed: () => Navigator.of(context).pop(),
                      height: 40,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    GlassPrimaryButton(
                      onPressed: _submit,
                      height: 40,
                      child: const Text('Confirm Reschedule'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
