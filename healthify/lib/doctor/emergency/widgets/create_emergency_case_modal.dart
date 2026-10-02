import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class CreateEmergencyCaseModal extends StatefulWidget {
  final Function(DoctorEmergencyCaseFullModel newCase) onCreateSubmitted;

  const CreateEmergencyCaseModal({
    super.key,
    required this.onCreateSubmitted,
  });

  @override
  State<CreateEmergencyCaseModal> createState() => _CreateEmergencyCaseModalState();
}

class _CreateEmergencyCaseModalState extends State<CreateEmergencyCaseModal> {
  int _currentStep = 1;

  // Step 1: Patient Information
  final _patientIdController = TextEditingController(text: 'MED-PAT-${10500 + DateTime.now().second * 7}');
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  String _patientGender = 'Male';
  String _bloodGroup = 'O+';
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _knownConditionsController = TextEditingController();

  // Step 2: Emergency Details
  final _emergencyReasonController = TextEditingController();
  final _patientReportedInfoController = TextEditingController();
  final _arrivalNotesController = TextEditingController();

  // Step 3: Arrival Info
  String _arrivalMethod = 'Ambulance - 108';
  final _referralSourceController = TextEditingController(text: 'Self / Direct ER Walk-in');
  DateTime _arrivalTime = DateTime.now();

  // Step 4: Priority
  EmergencyOperationalPriority _priority = EmergencyOperationalPriority.immediate;

  // Step 5: Department & Location & Doctor
  String _department = 'Cardiology';
  String _assignedDoctor = 'Dr. Sarah Jenkins';
  final _locationController = TextEditingController(text: 'Emergency Bay 01 (Resuscitation)');

  final List<String> _departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics & Trauma',
    'Pulmonology',
    'General Emergency',
    'ICU / Critical Care',
  ];

  final List<String> _doctors = [
    'Dr. Sarah Jenkins',
    'Dr. Marcus Vance',
    'Dr. Elena Rostova',
    'Dr. Aris Thorne',
  ];

  final List<String> _arrivalMethods = [
    'Ambulance - 108',
    'Ambulance - Private',
    'Self Walk-in',
    'Hospital Transfer',
    'Police / Rescue Bring-in',
  ];

  @override
  void dispose() {
    _patientIdController.dispose();
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactRelationController.dispose();
    _emergencyContactPhoneController.dispose();
    _allergiesController.dispose();
    _knownConditionsController.dispose();
    _emergencyReasonController.dispose();
    _patientReportedInfoController.dispose();
    _arrivalNotesController.dispose();
    _referralSourceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final caseId = 'EMR-${DateTime.now().year}-${1000 + DateTime.now().millisecond % 9000}';
    final age = int.tryParse(_patientAgeController.text.trim()) ?? 35;
    final allergies = _allergiesController.text.trim().isEmpty
        ? <String>[]
        : _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final conditions = _knownConditionsController.text.trim().isEmpty
        ? <String>[]
        : _knownConditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final newCase = DoctorEmergencyCaseFullModel(
      id: caseId,
      patientId: _patientIdController.text.trim().isEmpty ? 'MED-PAT-10999' : _patientIdController.text.trim(),
      patientName: _patientNameController.text.trim().isEmpty ? 'Unknown Patient (Unidentified)' : _patientNameController.text.trim(),
      patientAge: age,
      patientGender: _patientGender,
      bloodGroup: _bloodGroup,
      allergies: allergies,
      knownConditions: conditions,
      currentMedications: const [],
      emergencyContactName: _emergencyContactNameController.text.trim(),
      emergencyContactRelation: _emergencyContactRelationController.text.trim(),
      emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
      arrivalTime: _arrivalTime,
      arrivalMethod: _arrivalMethod,
      referralSource: _referralSourceController.text.trim(),
      emergencyReason: _emergencyReasonController.text.trim().isEmpty
          ? 'Emergency triage evaluation required.'
          : _emergencyReasonController.text.trim(),
      patientReportedInfo: _patientReportedInfoController.text.trim(),
      arrivalNotes: _arrivalNotesController.text.trim(),
      priority: _priority,
      status: EmergencyCaseStatus.waiting,
      assignedDoctor: _assignedDoctor,
      department: _department,
      location: _locationController.text.trim().isEmpty ? 'ER Holding Bay' : _locationController.text.trim(),
      notes: [],
      attachedReportIds: const [],
      attachedPrescriptionIds: const [],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'ER Desk',
          action: 'Emergency case $caseId registered via Triage Intake',
          optionalNote: 'Priority: ${_priority.label}',
        ),
      ],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          actor: 'ER Intake Desk',
          action: 'Case Created',
        ),
      ],
    );

    widget.onCreateSubmitted(newCase);
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
                    icon: Icons.add_alert_rounded,
                    size: 40,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Emergency Case Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Step $_currentStep of 6 — Record patient triage & operational priority',
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
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
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
                  if (_currentStep < 6)
                    GlassPrimaryButton(
                      onPressed: () {
                        // Validation logic per step
                        if (_currentStep == 1 && _patientNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter patient name (or Unidentified).')),
                          );
                        }
                        setState(() => _currentStep++);
                      },
                      height: 42,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Register Emergency Case'),
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
    final steps = ['Patient', 'Reason', 'Arrival', 'Priority', 'Assign', 'Review'];
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
                        fontSize: 11,
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
              if (index < steps.length - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1PatientInfo(isDark);
      case 2:
        return _buildStep2Reason(isDark);
      case 3:
        return _buildStep3Arrival(isDark);
      case 4:
        return _buildStep4Priority(isDark);
      case 5:
        return _buildStep5Assignment(isDark);
      case 6:
        return _buildStep6Review(isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1PatientInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Patient Intake Profile', Icons.person_outline_rounded, isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _patientNameController,
                label: 'Patient Full Name',
                hint: 'e.g. Rahul Sharma or Unidentified Male',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _patientIdController,
                label: 'Patient ID',
                hint: 'MED-PAT-XXXXX',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _patientAgeController,
                label: 'Age (Years)',
                hint: 'e.g. 42',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Gender',
                value: _patientGender,
                items: const ['Male', 'Female', 'Other'],
                onChanged: (val) => setState(() => _patientGender = val!),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Blood Group',
                value: _bloodGroup,
                items: const ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-', 'Unknown'],
                onChanged: (val) => setState(() => _bloodGroup = val!),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Emergency Contact & Allergies', Icons.contact_phone_outlined, isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _emergencyContactNameController,
                label: 'Contact Name',
                hint: 'e.g. Sunita Sharma',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _emergencyContactRelationController,
                label: 'Relation',
                hint: 'e.g. Spouse / Parent',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _emergencyContactPhoneController,
                label: 'Contact Phone',
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _allergiesController,
          label: 'Recorded Allergies (Comma separated)',
          hint: 'e.g. Penicillin, NSAIDs, Latex',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _knownConditionsController,
          label: 'Known Medical Conditions (Comma separated)',
          hint: 'e.g. Hypertension, Diabetes, Asthma',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStep2Reason(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Emergency Reason & Chief Complaint', Icons.medical_services_outlined, isDark),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emergencyReasonController,
          label: 'Chief Emergency Reason / Intake Diagnosis',
          hint: 'e.g. Acute retrosternal chest pain radiating to left arm with diaphoresis.',
          maxLines: 3,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _patientReportedInfoController,
          label: 'Patient-Reported Information / Symptoms',
          hint: 'Describe onset, severity, duration, and associated symptoms as reported by patient or bystander.',
          maxLines: 3,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _arrivalNotesController,
          label: 'Initial Triage Notes',
          hint: 'e.g. Triage Nurse recorded elevated BP and tachycardia. STAT ECG ordered.',
          maxLines: 2,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStep3Arrival(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Arrival Information', Icons.local_shipping_outlined, isDark),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Arrival Method',
          value: _arrivalMethod,
          items: _arrivalMethods,
          onChanged: (val) => setState(() => _arrivalMethod = val!),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _referralSourceController,
          label: 'Referral Source / Origin',
          hint: 'e.g. Self / Direct ER Walk-in, City Clinic, Trauma Transfer',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Text(
          'Arrival Timestamp',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intake Time: ${_arrivalTime.hour.toString().padLeft(2, '0')}:${_arrivalTime.minute.toString().padLeft(2, '0')} (${_arrivalTime.day}/${_arrivalTime.month}/${_arrivalTime.year})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              GlassSecondaryButton(
                onPressed: () => setState(() => _arrivalTime = DateTime.now()),
                height: 32,
                child: const Text('Set to Now', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Priority(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Operational Triage Priority', Icons.priority_high_rounded, isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.blue.shade700 : const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Operational priority is assigned strictly by authorized clinical staff based on triage assessment.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.blue.shade200 : const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...EmergencyOperationalPriority.values.map((p) {
          final isSelected = _priority == p;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _priority = p),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? p.color.withValues(alpha: 0.12)
                      : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? p.color : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? p.color : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: p.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p == EmergencyOperationalPriority.immediate
                            ? 'Life-threatening condition requiring immediate STAT resuscitation/intervention.'
                            : p == EmergencyOperationalPriority.high
                                ? 'Urgent condition requiring priority assessment within 15 minutes.'
                                : 'Standard emergency case requiring routine ER evaluation.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep5Assignment(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Department & Doctor Assignment', Icons.apartment_rounded, isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Department',
                value: _department,
                items: _departments,
                onChanged: (val) => setState(() => _department = val!),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Assigned Lead Doctor',
                value: _assignedDoctor,
                items: _doctors,
                onChanged: (val) => setState(() => _assignedDoctor = val!),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _locationController,
          label: 'Location / ER Bay / Station',
          hint: 'e.g. Emergency Bay 01 (Resuscitation), Waiting Area B',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStep6Review(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Review Emergency Intake Summary', Icons.fact_check_outlined, isDark),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _patientNameController.text.trim().isEmpty ? 'Unidentified Patient' : _patientNameController.text.trim(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _priority.color),
                    ),
                    child: Text(
                      '${_priority.label} Priority',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _priority.color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${_patientIdController.text} • Age: ${_patientAgeController.text} • Gender: $_patientGender • Blood Group: $_bloodGroup',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
              const Divider(height: 20),
              _buildReviewRow('Emergency Reason', _emergencyReasonController.text.isEmpty ? 'Not specified' : _emergencyReasonController.text, isDark),
              _buildReviewRow('Arrival Method', _arrivalMethod, isDark),
              _buildReviewRow('Assigned Doctor', '$_assignedDoctor ($_department)', isDark),
              _buildReviewRow('Location', _locationController.text, isDark),
              if (_allergiesController.text.isNotEmpty)
                _buildReviewRow('Allergies', _allergiesController.text, isDark, isWarning: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, bool isDark, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                color: isWarning
                    ? Colors.redAccent
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
