import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class CreatePrescriptionModal extends StatefulWidget {
  final DoctorPrescriptionFullModel? existingDraft;
  final Function(DoctorPrescriptionFullModel rx, bool isDraft) onSaveComplete;

  const CreatePrescriptionModal({
    super.key,
    this.existingDraft,
    required this.onSaveComplete,
  });

  @override
  State<CreatePrescriptionModal> createState() => _CreatePrescriptionModalState();
}

class _CreatePrescriptionModalState extends State<CreatePrescriptionModal> {
  int _currentStep = 1;

  // Step 1: Patient
  String _selectedPatientId = 'MED-PAT-10482';
  String _selectedPatientName = 'Rahul Sharma';
  int _patientAge = 42;
  String _patientGender = 'Male';
  String _bloodGroup = 'B+';
  List<String> _allergies = ['Penicillin', 'Sulfa Drugs'];

  final List<Map<String, dynamic>> _mockPatients = [
    {
      'id': 'MED-PAT-10482',
      'name': 'Rahul Sharma',
      'age': 42,
      'gender': 'Male',
      'bloodGroup': 'B+',
      'allergies': ['Penicillin', 'Sulfa Drugs'],
    },
    {
      'id': 'MED-PAT-10391',
      'name': 'Priya Patel',
      'age': 38,
      'gender': 'Female',
      'bloodGroup': 'O+',
      'allergies': ['NSAIDs', 'Aspirin'],
    },
    {
      'id': 'MED-PAT-10519',
      'name': 'Amit Verma',
      'age': 56,
      'gender': 'Male',
      'bloodGroup': 'A+',
      'allergies': <String>[],
    },
    {
      'id': 'MED-PAT-10220',
      'name': 'Ananya Sen',
      'age': 29,
      'gender': 'Female',
      'bloodGroup': 'AB+',
      'allergies': ['Amoxicillin'],
    },
    {
      'id': 'MED-PAT-10115',
      'name': 'Vikram Malhotra',
      'age': 61,
      'gender': 'Male',
      'bloodGroup': 'O-',
      'allergies': ['Codeine'],
    },
  ];

  // Step 2: Consultation
  String _selectedConsultationId = 'CON-10029';
  final List<Map<String, String>> _mockConsultations = [
    {'id': 'CON-10029', 'label': '04 Oct 2026 • Cardiology • Follow-up & Risk Assessment'},
    {'id': 'CON-09941', 'label': '20 Sep 2026 • Cardiology • Routine Clinical Evaluation'},
    {'id': 'CON-09812', 'label': '14 Aug 2026 • General OPD • Chest Review'},
  ];

  // Step 3: Medicines Builder
  final List<PrescriptionMedicineModel> _addedMedicines = [];
  final _medFormKey = GlobalKey<FormState>();

  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController(text: '30 days');
  final _instructionsController = TextEditingController();

  String _selectedFrequency = 'Once daily';
  String _selectedRoute = 'Oral';

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Thrice daily',
    'Every 8 hours',
    'Every 12 hours',
    'As needed (PRN)',
    'At bedtime',
  ];

  final List<String> _routes = [
    'Oral',
    'Sublingual',
    'Intravenous (IV)',
    'Intramuscular (IM)',
    'Subcutaneous',
    'Topical',
    'Inhalation',
    'Eye Drops',
    'Nasal Spray',
  ];

  int? _editingMedIndex;

  // Step 4: Instructions
  final _generalInstructionsController = TextEditingController(
    text: 'Continue prescribed medication as instructed and attend scheduled follow-up.',
  );

  bool _isSavingDraft = false;
  bool _isConfirmStepOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingDraft != null) {
      final draft = widget.existingDraft!;
      _selectedPatientId = draft.patientId;
      _selectedPatientName = draft.patientName;
      _patientAge = draft.patientAge;
      _patientGender = draft.patientGender;
      _bloodGroup = draft.bloodGroup;
      _allergies = List.from(draft.allergies);
      _selectedConsultationId = draft.consultationId;
      _addedMedicines.addAll(draft.medicines);
      _generalInstructionsController.text = draft.generalInstructions;
    }
  }

  @override
  void dispose() {
    _medNameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _generalInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.edit_note_rounded,
                        size: 40,
                        iconSize: 22,
                        color: HealthifyGlassTheme.primaryTeal,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingDraft != null
                                ? 'Edit Prescription Draft (${widget.existingDraft!.id})'
                                : 'Create New Prescription Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Select patient, attach consultation, and configure medication regimen.',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Step Stepper Indicator
              _buildStepIndicator(isDark),
              const SizedBox(height: 20),

              // Step Content
              if (_isConfirmStepOpen)
                _buildFinalConfirmationStep(isDark)
              else if (_currentStep == 1)
                _buildStep1PatientSelect(isDark)
              else if (_currentStep == 2)
                _buildStep2ConsultationSelect(isDark)
              else
                _buildStep3MedicationBuilder(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: [
        _buildStepBadge(1, '1. Select Patient', _currentStep == 1, isDark),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 2, color: HealthifyGlassTheme.getGlassBorder(isDark))),
        const SizedBox(width: 8),
        _buildStepBadge(2, '2. Consultation', _currentStep == 2, isDark),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 2, color: HealthifyGlassTheme.getGlassBorder(isDark))),
        const SizedBox(width: 8),
        _buildStepBadge(3, '3. Add Medicines', _currentStep == 3, isDark),
      ],
    );
  }

  Widget _buildStepBadge(int step, String title, bool isActive, bool isDark) {
    final color = isActive ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getTextSecondary(isDark);
    return InkWell(
      onTap: () => setState(() {
        _currentStep = step;
        _isConfirmStepOpen = false;
      }),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isActive ? HealthifyGlassTheme.primaryTeal : isDark ? Colors.white24 : Colors.black12,
            child: Text(
              '$step',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.white : color),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1PatientSelect(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Select Authorized Patient',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 6),
        Text(
          'Only patients assigned to your clinical care roster are displayed.',
          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        const SizedBox(height: 14),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockPatients.length,
          separatorBuilder: (_, index) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final p = _mockPatients[idx];
            final isSelected = p['id'] == _selectedPatientId;
            final pAllergies = List<String>.from(p['allergies'] as List);
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPatientId = p['id'] as String;
                  _selectedPatientName = p['name'] as String;
                  _patientAge = p['age'] as int;
                  _patientGender = p['gender'] as String;
                  _bloodGroup = p['bloodGroup'] as String;
                  _allergies = pAllergies;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1)
                      : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getGlassBorder(isDark),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getTextSecondary(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p['name']} (${p['id']})',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                          ),
                          Text(
                            'Age: ${p['age']}y • Gender: ${p['gender']} • Blood: ${p['bloodGroup']}',
                            style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                          ),
                          if (pAllergies.isNotEmpty)
                            Text(
                              'Allergies: ${pAllergies.join(", ")}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GlassPrimaryButton(
              onPressed: () => setState(() => _currentStep = 2),
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next: Select Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2ConsultationSelect(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Link Active Consultation',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the clinical encounter associated with this prescription order.',
          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        const SizedBox(height: 14),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockConsultations.length,
          separatorBuilder: (_, index) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final con = _mockConsultations[idx];
            final isSelected = con['id'] == _selectedConsultationId;
            return InkWell(
              onTap: () => setState(() => _selectedConsultationId = con['id']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1) : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getGlassBorder(isDark),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getTextSecondary(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${con['id']} • ${con['label']}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: const Text('Back'),
            ),
            GlassPrimaryButton(
              onPressed: () => setState(() => _currentStep = 3),
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next: Add Medicines', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3MedicationBuilder(bool isDark) {
    final hasAllergies = _allergies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PROMINENT ALLERGY WARNING BANNER (Placed directly near Medication Builder per Section 15)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasAllergies
                ? Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.08)
                : const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasAllergies
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : const Color(0xFF10B981).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasAllergies ? Icons.warning_rounded : Icons.verified_user_rounded,
                color: hasAllergies ? Colors.redAccent : const Color(0xFF10B981),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAllergies ? 'RECORDED PATIENT ALLERGIES' : 'NO RECORDED ALLERGIES',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: hasAllergies ? Colors.redAccent : const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      hasAllergies
                          ? 'Sensitivities for $_selectedPatientName: ${_allergies.join(", ")}'
                          : 'No drug allergies logged for $_selectedPatientName.',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Step 3: Add & Configure Medications',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 12),

        // Add Medicine Form Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
          ),
          child: Form(
            key: _medFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingMedIndex != null ? 'Edit Medicine Entry' : 'Add Medicine Entry',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _medNameController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Medicine name required' : null,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name *',
                          hintText: 'e.g. Amlodipine, Atorvastatin',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _dosageController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Dosage required' : null,
                        decoration: InputDecoration(
                          labelText: 'Dosage *',
                          hintText: 'e.g. 5 mg, 10 mg',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFrequency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRoute,
                        decoration: InputDecoration(
                          labelText: 'Route *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _routes.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRoute = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Duration required' : null,
                        decoration: InputDecoration(
                          labelText: 'Duration *',
                          hintText: 'e.g. 30 days',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Instructions & Timing',
                    hintText: 'e.g. Take after breakfast with water.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GlassPrimaryButton(
                    onPressed: _addOrUpdateMedicine,
                    height: 38,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_editingMedIndex != null ? Icons.check_rounded : Icons.add_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(_editingMedIndex != null ? 'Update Medicine' : 'Add Medicine', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Added Medicines List
        Text(
          'Configured Medicines (${_addedMedicines.length})',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 8),
        if (_addedMedicines.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'No medicines added yet. Use the form above to add medications.',
                style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addedMedicines.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final m = _addedMedicines[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_rounded, color: HealthifyGlassTheme.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.medicineName} (${m.dosage})',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                          ),
                          Text(
                            '${m.frequency} • ${m.route} • ${m.duration}',
                            style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                          ),
                          if (m.instructions.isNotEmpty)
                            Text(
                              'Instructions: ${m.instructions}',
                              style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                      onPressed: () => _editMedicine(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () => setState(() => _addedMedicines.removeAt(idx)),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 16),

        // Section 12: General Instructions Field
        TextFormField(
          controller: _generalInstructionsController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'General Prescription Instructions & Dietary Advice',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),

        // Bottom Actions Row: Save Draft vs Confirm Order
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(_isSavingDraft ? 'Saving Draft...' : 'Save Draft'),
            ),
            GlassPrimaryButton(
              onPressed: () {
                if (_addedMedicines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least 1 medicine before proceeding.')),
                  );
                  return;
                }
                setState(() => _isConfirmStepOpen = true);
              },
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Review & Confirm Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalConfirmationStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: HealthifyGlassTheme.primaryTeal, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINAL PRESCRIPTION REVIEW & CONFIRMATION',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                    Text(
                      'Please verify all medication dosages and allergy alignment before activating this prescription.',
                      style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Summary Box
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: $_selectedPatientName ($_selectedPatientId)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text('Consultation: $_selectedConsultationId', style: const TextStyle(fontSize: 12.5)),
              Text('Attending Doctor: Dr. Sarah Jenkins (Cardiology)', style: const TextStyle(fontSize: 12.5)),
              const Divider(),
              Text('Prescribed Medications (${_addedMedicines.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._addedMedicines.map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${m.medicineName} ${m.dosage} (${m.frequency}, ${m.route}, ${m.duration})',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _isConfirmStepOpen = false),
              child: const Text('Back to Edit'),
            ),
            GlassPrimaryButton(
              onPressed: _confirmAndActivatePrescription,
              height: 44,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, size: 20),
                  SizedBox(width: 6),
                  Text('Confirm & Activate Prescription', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addOrUpdateMedicine() {
    if (!_medFormKey.currentState!.validate()) return;

    final newMed = PrescriptionMedicineModel(
      id: 'MED-${DateTime.now().millisecondsSinceEpoch}',
      medicineName: _medNameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _selectedFrequency,
      route: _selectedRoute,
      duration: _durationController.text.trim(),
      instructions: _instructionsController.text.trim(),
    );

    setState(() {
      if (_editingMedIndex != null) {
        _addedMedicines[_editingMedIndex!] = newMed;
        _editingMedIndex = null;
      } else {
        _addedMedicines.add(newMed);
      }
      _medNameController.clear();
      _dosageController.clear();
      _instructionsController.clear();
    });
  }

  void _editMedicine(int index) {
    final med = _addedMedicines[index];
    setState(() {
      _editingMedIndex = index;
      _medNameController.text = med.medicineName;
      _dosageController.text = med.dosage;
      _selectedFrequency = _frequencies.contains(med.frequency) ? med.frequency : _frequencies[0];
      _selectedRoute = _routes.contains(med.route) ? med.route : _routes[0];
      _durationController.text = med.duration;
      _instructionsController.text = med.instructions;
    });
  }

  void _saveDraft() async {
    setState(() => _isSavingDraft = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final draft = DoctorPrescriptionFullModel(
      id: widget.existingDraft?.id ?? 'RX-2026-${(1000 + DateTime.now().millisecond % 8999).toString()}',
      patientId: _selectedPatientId,
      patientName: _selectedPatientName,
      patientAge: _patientAge,
      patientGender: _patientGender,
      bloodGroup: _bloodGroup,
      allergies: _allergies,
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: _selectedConsultationId,
      date: DateTime.now(),
      status: PrescriptionStatus.draft,
      medicines: List.from(_addedMedicines),
      generalInstructions: _generalInstructionsController.text.trim(),
      lastSaved: DateTime.now(),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-DRAFT-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          action: 'Saved Draft',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Draft prescription saved.',
        ),
      ],
    );

    widget.onSaveComplete(draft, true);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _confirmAndActivatePrescription() async {
    final rx = DoctorPrescriptionFullModel(
      id: widget.existingDraft?.id ?? 'RX-2026-${(1000 + DateTime.now().millisecond % 8999).toString()}',
      patientId: _selectedPatientId,
      patientName: _selectedPatientName,
      patientAge: _patientAge,
      patientGender: _patientGender,
      bloodGroup: _bloodGroup,
      allergies: _allergies,
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: _selectedConsultationId,
      date: DateTime.now(),
      status: PrescriptionStatus.active,
      medicines: List.from(_addedMedicines),
      generalInstructions: _generalInstructionsController.text.trim(),
      lastSaved: DateTime.now(),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-ACT-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          action: 'Activated',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Prescription verified and activated.',
        ),
      ],
    );

    widget.onSaveComplete(rx, false);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
