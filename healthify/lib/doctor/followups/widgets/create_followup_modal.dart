import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class CreateFollowUpModal extends StatefulWidget {
  final Function(DoctorFollowUpFullModel newFollowUp) onCreateSubmitted;

  const CreateFollowUpModal({
    super.key,
    required this.onCreateSubmitted,
  });

  @override
  State<CreateFollowUpModal> createState() => _CreateFollowUpModalState();
}

class _CreateFollowUpModalState extends State<CreateFollowUpModal> {
  int _currentStep = 1;

  // Step 1: Select Patient
  final _patientSearchController = TextEditingController();
  final String _selectedPatientName = 'Rahul Sharma';
  final String _selectedPatientId = 'MED-PAT-10482';
  final String _selectedPatientPhone = '+91 98765 43210';
  final int _selectedPatientAge = 42;
  final String _selectedPatientGender = 'Male';
  final String _selectedBloodGroup = 'B+';
  final List<String> _selectedAllergies = const ['Penicillin'];

  // Step 2: Related Consultation
  String _relatedConsultationId = 'CON-10029';
  final String _relatedConsultationSummary = 'Cardiology Follow-up (28 Sep 2026)';

  // Step 3 & 4: Date & Time
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 7));
  String _followUpTime = '10:30 AM';

  // Step 5: Department
  String _department = 'Cardiology';

  // Step 6: Doctor
  String _doctorName = 'Dr. Sarah Jenkins';

  // Step 7: Reason
  final _reasonController = TextEditingController(text: 'Review progress and discuss recently completed reports.');

  // Step 8: Additional Notes
  final _additionalNotesController = TextEditingController();

  final List<String> _departments = [
    'Cardiology',
    'General Medicine',
    'Neurology',
    'Orthopedics',
    'Pulmonology',
    'Other',
  ];

  final List<String> _doctors = [
    'Dr. Sarah Jenkins',
    'Dr. Marcus Vance',
    'Dr. Elena Rostova',
    'Dr. Aris Thorne',
  ];

  @override
  void dispose() {
    _patientSearchController.dispose();
    _reasonController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final fuId = 'FU-${DateTime.now().year}-${10000 + DateTime.now().millisecond}';

    final newFollowUp = DoctorFollowUpFullModel(
      id: fuId,
      patientId: _selectedPatientId,
      patientName: _selectedPatientName,
      patientAge: _selectedPatientAge,
      patientGender: _selectedPatientGender,
      bloodGroup: _selectedBloodGroup,
      allergies: _selectedAllergies,
      phone: _selectedPatientPhone,
      followUpDate: _followUpDate,
      followUpTime: _followUpTime,
      department: _department,
      doctorName: _doctorName,
      reason: _reasonController.text.trim().isEmpty ? 'Routine follow-up evaluation.' : _reasonController.text.trim(),
      additionalNotes: _additionalNotesController.text.trim(),
      createdDate: DateTime.now(),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.scheduled,
      previousConsultation: PreviousConsultationSummaryModel(
        id: _relatedConsultationId,
        date: DateTime.now().subtract(const Duration(days: 7)),
        doctorName: _doctorName,
        department: _department,
        reason: 'Previous clinical consultation',
        clinicalNotesSummary: _relatedConsultationSummary,
        reportIds: const [],
        prescriptionIds: const [],
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up $fuId created',
        ),
      ],
      rescheduleHistory: const [],
      notes: const [],
    );

    widget.onCreateSubmitted(newFollowUp);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 780),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.event_repeat_rounded,
                    size: 40,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Patient Follow-up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Step $_currentStep of 8 — Clinical follow-up scheduling wizard',
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
              const SizedBox(height: 16),

              // Stepper progress indicator
              _buildStepIndicator(isDark),
              const SizedBox(height: 20),

              // Step Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(isDark),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 1)
                    GlassSecondaryButton(
                      onPressed: () => setState(() => _currentStep--),
                      height: 42,
                      child: const Text('Back'),
                    )
                  else
                    GlassSecondaryButton(
                      onPressed: () => Navigator.of(context).pop(),
                      height: 42,
                      child: const Text('Cancel'),
                    ),
                  if (_currentStep < 8)
                    GlassPrimaryButton(
                      onPressed: () => setState(() => _currentStep++),
                      height: 42,
                      child: const Row(
                        children: [
                          Text('Next Step'),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    )
                  else
                    GlassPrimaryButton(
                      onPressed: _submitForm,
                      height: 42,
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Schedule Follow-up'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = ['Patient', 'Consult', 'Date', 'Time', 'Dept', 'Doctor', 'Reason', 'Notes'];
    return Row(
      children: List.generate(steps.length, (index) {
        final stepNum = index + 1;
        final isActive = stepNum == _currentStep;
        final isPassed = stepNum < _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0D9488)
                        : isPassed
                            ? (isDark ? Colors.teal.shade900.withValues(alpha: 0.4) : const Color(0xFFCCFBF1))
                            : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF0D9488)
                          : isPassed
                              ? const Color(0xFF0D9488).withValues(alpha: 0.5)
                              : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$stepNum. ${steps[index]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive || isPassed ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? Colors.white
                            : isPassed
                                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488))
                                : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
              ),
              if (index < steps.length - 1) const SizedBox(width: 3),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1SelectPatient(isDark);
      case 2:
        return _buildStep2Consultation(isDark);
      case 3:
        return _buildStep3Date(isDark);
      case 4:
        return _buildStep4Time(isDark);
      case 5:
        return _buildStep5Department(isDark);
      case 6:
        return _buildStep6Doctor(isDark);
      case 7:
        return _buildStep7Reason(isDark);
      case 8:
        return _buildStep8Notes(isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1SelectPatient(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Select Patient', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        TextFormField(
          controller: _patientSearchController,
          decoration: const InputDecoration(hintText: 'Search patient by name, ID, or phone...'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0D9488)),
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Color(0xFF0D9488), child: Text('RS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_selectedPatientName ($_selectedPatientId)', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    Text('Age: $_selectedPatientAge • Gender: $_selectedPatientGender • Blood Group: $_selectedBloodGroup', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
                    Text('Phone: $_selectedPatientPhone', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Consultation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Related Consultation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _relatedConsultationId,
          decoration: const InputDecoration(labelText: 'Select Previous Consultation'),
          items: const [
            DropdownMenuItem(value: 'CON-10029', child: Text('CON-10029 • Cardiology Follow-up (28 Sep 2026)')),
            DropdownMenuItem(value: 'CON-09941', child: Text('CON-09941 • General OPD Review (20 Sep 2026)')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _relatedConsultationId = val);
          },
        ),
      ],
    );
  }

  Widget _buildStep3Date(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Follow-up Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        CalendarDatePicker(
          initialDate: _followUpDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
          onDateChanged: (d) => setState(() => _followUpDate = d),
        ),
      ],
    );
  }

  Widget _buildStep4Time(bool isDark) {
    final times = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Follow-up Time Slot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times.map((t) {
            final isSelected = _followUpTime == t;
            return ChoiceChip(
              label: Text(t),
              selected: isSelected,
              onSelected: (_) => setState(() => _followUpTime = t),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep5Department(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Department', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _department,
          decoration: const InputDecoration(labelText: 'Department'),
          items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _department = val);
          },
        ),
      ],
    );
  }

  Widget _buildStep6Doctor(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 6: Assigned Doctor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _doctorName,
          decoration: const InputDecoration(labelText: 'Lead Doctor'),
          items: _doctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _doctorName = val);
          },
        ),
      ],
    );
  }

  Widget _buildStep7Reason(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 7: Follow-up Reason', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        TextFormField(
          controller: _reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g. Review progress and discuss recently completed reports.',
          ),
        ),
      ],
    );
  }

  Widget _buildStep8Notes(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 8: Additional Notes & Review', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        const SizedBox(height: 12),
        TextFormField(
          controller: _additionalNotesController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Optional instructions for receptionist or patient...',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              Text('Patient: $_selectedPatientName ($_selectedPatientId)', style: const TextStyle(fontSize: 12)),
              Text('Date: ${_followUpDate.day}/${_followUpDate.month}/${_followUpDate.year} at $_followUpTime', style: const TextStyle(fontSize: 12)),
              Text('Department: $_department • Doctor: $_doctorName', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
