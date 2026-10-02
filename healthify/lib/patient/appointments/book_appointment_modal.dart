import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class BookAppointmentModal extends StatefulWidget {
  final DoctorSearchResult? initialDoctor;
  final Function(String message)? onSuccess;

  const BookAppointmentModal({
    super.key,
    this.initialDoctor,
    this.onSuccess,
  });

  static void show(BuildContext context, {DoctorSearchResult? doctor, Function(String)? onSuccess}) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BookAppointmentModal(
        initialDoctor: doctor,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<BookAppointmentModal> createState() => _BookAppointmentModalState();
}

class _BookAppointmentModalState extends State<BookAppointmentModal> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDoctorName;
  late String _selectedSpecialty;
  late String _selectedHospital;
  late String _selectedSlot;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _availableSlots = const [
    'Today 10:30 AM',
    'Today 02:00 PM',
    'Today 04:30 PM',
    'Tomorrow 09:30 AM',
    'Tomorrow 11:15 AM',
    'Tomorrow 03:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctorName = widget.initialDoctor?.name ?? 'Dr. Sarah Jenkins';
    _selectedSpecialty = widget.initialDoctor?.specialty ?? 'Cardiology';
    _selectedHospital = widget.initialDoctor?.hospitalName ?? 'St. Jude Memorial Hospital';
    _selectedSlot = widget.initialDoctor?.availableSlots.firstOrNull ?? _availableSlots.first;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pop(context);

        final tokenNum = '#${(10 + DateTime.now().second % 40)}';
        final msg = 'Appointment booked with $_selectedDoctorName for $_selectedSlot! Token $tokenNum assigned.';
        if (widget.onSuccess != null) {
          widget.onSuccess!(msg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.teal, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Book Doctor Consultation',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Select doctor, time slot & describe symptoms',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.borderLight),
            const SizedBox(height: 16),

            // Doctor Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDoctorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '$_selectedSpecialty • $_selectedHospital',
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Select Slot
            const Text(
              'Select Preferred Time Slot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.5,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedSlot = slot);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Patient Reason / Symptoms input
            const Text(
              'Health Concern / Symptoms (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Chest tightness, shortness of breath for 2 days...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  _isSubmitting ? 'Booking Appointment...' : 'Confirm Appointment Booking',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}