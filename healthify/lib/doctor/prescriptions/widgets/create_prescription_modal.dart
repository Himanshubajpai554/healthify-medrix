import 'package:flutter/material.dart';
import '../../../core/provider/repository_provider.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

/// CreatePrescriptionModal
///
/// Step 1 — Patient: loads assigned patients from the hospital `patients`
///           collection (filtered to the logged-in doctor when connected).
/// Step 2 — Consultation: loads completed appointments from `appointments`
///           for the selected patient.
/// Step 3 — Medicines: inline medicine builder (unchanged).
/// Step 4 — Confirm & activate.
///
/// In demo/offline mode (no Serverpod client) both lists are empty and a
/// banner is shown prompting the user to connect the backend.
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

  // ── Step 1: Patient ──────────────────────────────────────────────────────
  bool _loadingPatients = false;
  List<Map<String, dynamic>> _patients = [];
  String _selectedPatientId = '';
  String _selectedPatientName = '';
  int _patientAge = 0;
  String _patientGender = '';
  String _bloodGroup = '';
  List<String> _allergies = [];

  // ── Step 2: Consultation ─────────────────────────────────────────────────
  bool _loadingConsultations = false;
  List<Map<String, dynamic>> _consultations = [];
  String _selectedConsultationId = '';

  // ── Step 3: Medicines Builder ─────────────────────────────────────────────
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

  // ── Step 4: Instructions ──────────────────────────────────────────────────
  final _generalInstructionsController = TextEditingController(
    text: 'Continue prescribed medication as instructed and attend scheduled follow-up.',
  );

  bool _isSavingDraft = false;
  bool _isConfirmStepOpen = false;

  bool get _isLive => RepositoryContainer.instance.serverpodClient != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

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
    _fetchPatients();
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

  // ── Data loaders ──────────────────────────────────────────────────────────

  Future<void> _fetchPatients() async {
    if (!_isLive) return;
    setState(() => _loadingPatients = true);
    try {
      final container = RepositoryContainer.instance;
      final records = container.hospitalOperationalRepository!;
      final doctorId = container.currentDoctorId;
      // Load patients; when doctorId is set, filter to those assigned to this doctor.
      final rows = await records.list('patients', limit: 500);
      final filtered = doctorId.isEmpty
          ? rows
          : rows.where((row) {
              final assigned = row['assignedDoctorId'] ?? row['doctorId'] ?? '';
              return assigned == doctorId || assigned == '';
            }).toList();
      setState(() {
        _patients = filtered.map<Map<String, dynamic>>((row) => {
          'id': '${row['id'] ?? row['recordKey'] ?? ''}',
          'name': '${row['name'] ?? 'Unknown'}',
          'age': (row['age'] as num?)?.toInt() ?? 0,
          'gender': '${row['gender'] ?? ''}',
          'bloodGroup': '${row['bloodGroup'] ?? ''}',
          'allergies':
              (row['allergies'] as List? ?? const []).map((e) => '$e').toList(),
        }).where((p) => (p['id'] as String).isNotEmpty).toList();
        _loadingPatients = false;
        // If editing an existing draft, keep pre-selected patient.
        if (_selectedPatientId.isNotEmpty &&
            _patients.any((p) => p['id'] == _selectedPatientId)) {
          // Already selected — leave it.
        } else if (_patients.isNotEmpty) {
          _applyPatient(_patients.first);
        }
      });
    } catch (_) {
      setState(() => _loadingPatients = false);
    }
  }

  Future<void> _fetchConsultations(String patientId) async {
    if (!_isLive || patientId.isEmpty) return;
    setState(() {
      _loadingConsultations = true;
      _consultations = [];
      _selectedConsultationId = '';
    });
    try {
      final records = RepositoryContainer.instance.hospitalOperationalRepository!;
      final rows = (await records.list('appointments', limit: 500))
          .where((row) => '${row['patientId'] ?? ''}' == patientId)
          .toList();
      final done = rows
          .where((row) =>
              '${row['status'] ?? ''}'.toLowerCase() == 'completed' ||
              '${row['status'] ?? ''}'.toLowerCase() == 'inconsultation')
          .toList();
      setState(() {
        _consultations = done.map<Map<String, dynamic>>((row) {
          final dt = DateTime.tryParse('${row['dateTime'] ?? ''}');
          final label = dt != null
              ? '${dt.toLocal().toString().split(' ').first} • '
                '${row['department'] ?? ''} • ${row['type'] ?? 'Consultation'}'
              : '${row['id'] ?? ''} • ${row['department'] ?? ''}';
          return {'id': '${row['id'] ?? ''}', 'label': label};
        }).where((c) => (c['id'] as String).isNotEmpty).toList();
        if (_consultations.isNotEmpty) {
          _selectedConsultationId = _consultations.first['id'] as String;
        }
        _loadingConsultations = false;
      });
    } catch (_) {
      setState(() => _loadingConsultations = false);
    }
  }

  void _applyPatient(Map<String, dynamic> p) {
    _selectedPatientId = p['id'] as String;
    _selectedPatientName = p['name'] as String;
    _patientAge = p['age'] as int;
    _patientGender = p['gender'] as String;
    _bloodGroup = p['bloodGroup'] as String;
    _allergies = List<String>.from(p['allergies'] as List);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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

              // Offline banner
              if (!_isLive) _buildOfflineBanner(isDark),

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

  // ── Offline banner ────────────────────────────────────────────────────────

  Widget _buildOfflineBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline / demo mode — connect the app to the Serverpod backend to '
              'load real patients and consultations.',
              style: TextStyle(
                fontSize: 12.5,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────

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
    final color = isActive
        ? HealthifyGlassTheme.primaryTeal
        : HealthifyGlassTheme.getTextSecondary(isDark);
    return InkWell(
      onTap: () => setState(() {
        _currentStep = step;
        _isConfirmStepOpen = false;
      }),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isActive
                ? HealthifyGlassTheme.primaryTeal
                : isDark
                    ? Colors.white24
                    : Colors.black12,
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : color,
              ),
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

  // ── Step 1: Patient select ────────────────────────────────────────────────

  Widget _buildStep1PatientSelect(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Select Authorized Patient',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 6),
        Text(
          _isLive
              ? 'Patients assigned to your clinical care roster are displayed.'
              : 'Backend not connected — no patients available.',
          style: TextStyle(
              fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        const SizedBox(height: 14),
        if (_loadingPatients)
          const Center(child: CircularProgressIndicator())
        else if (_patients.isEmpty)
          _buildEmptyState(
            isDark,
            _isLive
                ? 'No patients are assigned to your account yet.'
                : 'Connect to the Serverpod backend to load patients.',
            Icons.person_search_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final p = _patients[idx];
              final isSelected = p['id'] == _selectedPatientId;
              final pAllergies = List<String>.from(p['allergies'] as List);
              return InkWell(
                onTap: () {
                  setState(() => _applyPatient(p));
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HealthifyGlassTheme.primaryTeal
                            .withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getGlassBorder(isDark),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getTextSecondary(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p['name']} (${p['id']})',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                            Text(
                              'Age: ${p['age']}y • Gender: ${p['gender']} • Blood: ${p['bloodGroup']}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color:
                                      HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                            if (pAllergies.isNotEmpty)
                              Text(
                                'Allergies: ${pAllergies.join(", ")}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent),
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
              onPressed: _selectedPatientId.isEmpty
                  ? null
                  : () {
                      _fetchConsultations(_selectedPatientId);
                      setState(() => _currentStep = 2);
                    },
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next: Select Consultation',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Step 2: Consultation select ───────────────────────────────────────────

  Widget _buildStep2ConsultationSelect(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Link Active Consultation',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 6),
        Text(
          _isLive
              ? 'Completed consultations for $_selectedPatientName are listed below.'
              : 'Backend not connected — no consultations available.',
          style: TextStyle(
              fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        const SizedBox(height: 14),
        if (_loadingConsultations)
          const Center(child: CircularProgressIndicator())
        else if (_consultations.isEmpty)
          _buildEmptyState(
            isDark,
            _isLive
                ? 'No completed consultations found for this patient.'
                : 'Connect to the backend to load consultations.',
            Icons.event_note_rounded,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _consultations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final con = _consultations[idx];
              final isSelected = con['id'] == _selectedConsultationId;
              return InkWell(
                onTap: () =>
                    setState(() => _selectedConsultationId = con['id'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HealthifyGlassTheme.primaryTeal
                            .withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getGlassBorder(isDark),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getTextSecondary(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${con['id']} • ${con['label']}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark)),
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
                  Text('Next: Add Medicines',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Step 3: Medication builder ────────────────────────────────────────────

  Widget _buildStep3MedicationBuilder(bool isDark) {
    final hasAllergies = _allergies.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Allergy banner
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
                      hasAllergies
                          ? 'RECORDED PATIENT ALLERGIES'
                          : 'NO RECORDED ALLERGIES',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: hasAllergies
                            ? Colors.redAccent
                            : const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      hasAllergies
                          ? 'Sensitivities for $_selectedPatientName: ${_allergies.join(", ")}'
                          : 'No drug allergies logged for $_selectedPatientName.',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: HealthifyGlassTheme.getTextPrimary(isDark)),
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
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 12),

        // Medicine entry form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.grey.withValues(alpha: 0.08),
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
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.primaryTeal),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _medNameController,
                        validator: (val) =>
                            val == null || val.trim().isEmpty
                                ? 'Medicine name required'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name *',
                          hintText: 'e.g. Amlodipine, Atorvastatin',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _dosageController,
                        validator: (val) =>
                            val == null || val.trim().isEmpty
                                ? 'Dosage required'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Dosage *',
                          hintText: 'e.g. 5 mg, 10 mg',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                        value: _selectedFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _frequencies
                            .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(f,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFrequency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRoute,
                        decoration: InputDecoration(
                          labelText: 'Route *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _routes
                            .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRoute = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        validator: (val) =>
                            val == null || val.trim().isEmpty
                                ? 'Duration required'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Duration *',
                          hintText: 'e.g. 30 days',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
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
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                        Icon(
                            _editingMedIndex != null
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            size: 18),
                        const SizedBox(width: 6),
                        Text(
                            _editingMedIndex != null
                                ? 'Update Medicine'
                                : 'Add Medicine',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Configured Medicines (${_addedMedicines.length})',
          style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark)),
        ),
        const SizedBox(height: 8),
        if (_addedMedicines.isEmpty)
          _buildEmptyState(isDark,
              'No medicines added yet. Use the form above.', Icons.medication_rounded)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addedMedicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final m = _addedMedicines[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(isDark)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_rounded,
                          color: HealthifyGlassTheme.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.medicineName} (${m.dosage})',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark)),
                          ),
                          Text(
                            '${m.frequency} • ${m.route} • ${m.duration}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    HealthifyGlassTheme.getTextSecondary(isDark)),
                          ),
                          if (m.instructions.isNotEmpty)
                            Text(
                              'Instructions: ${m.instructions}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          size: 18, color: HealthifyGlassTheme.primaryTeal),
                      onPressed: () => _editMedicine(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      onPressed: () =>
                          setState(() => _addedMedicines.removeAt(idx)),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 16),

        // General instructions
        TextFormField(
          controller: _generalInstructionsController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'General Prescription Instructions & Dietary Advice',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),

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
                    const SnackBar(
                        content: Text(
                            'Please add at least 1 medicine before proceeding.')),
                  );
                  return;
                }
                setState(() => _isConfirmStepOpen = true);
              },
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Review & Confirm Order',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Confirmation step ─────────────────────────────────────────────────────

  Widget _buildFinalConfirmationStep(bool isDark) {
    final container = RepositoryContainer.instance;
    final doctorLabel = container.currentDoctorName.isNotEmpty
        ? '${container.currentDoctorName} (${container.currentDoctorSpecialty})'
        : 'Attending Doctor';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.primaryTeal
                .withValues(alpha: isDark ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: HealthifyGlassTheme.primaryTeal, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINAL PRESCRIPTION REVIEW & CONFIRMATION',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                    Text(
                      'Please verify all medication dosages and allergy alignment before activating.',
                      style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Patient: $_selectedPatientName ($_selectedPatientId)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text('Consultation: $_selectedConsultationId',
                  style: const TextStyle(fontSize: 12.5)),
              Text('Attending Doctor: $doctorLabel',
                  style: const TextStyle(fontSize: 12.5)),
              const Divider(),
              Text('Prescribed Medications (${_addedMedicines.length}):',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ..._addedMedicines.map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_rounded,
                          size: 16, color: HealthifyGlassTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${m.medicineName} ${m.dosage} '
                          '(${m.frequency}, ${m.route}, ${m.duration})',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600),
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
                  Text('Confirm & Activate Prescription',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    fontSize: 12.5,
                    color: HealthifyGlassTheme.getTextSecondary(isDark))),
          ),
        ],
      ),
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
      _selectedFrequency =
          _frequencies.contains(med.frequency) ? med.frequency : _frequencies[0];
      _selectedRoute = _routes.contains(med.route) ? med.route : _routes[0];
      _durationController.text = med.duration;
      _instructionsController.text = med.instructions;
    });
  }

  DoctorPrescriptionFullModel _buildDraftModel({required bool isActive}) {
    final container = RepositoryContainer.instance;
    final now = DateTime.now();
    return DoctorPrescriptionFullModel(
      id: widget.existingDraft?.id ??
          'RX-${now.microsecondsSinceEpoch}',
      patientId: _selectedPatientId,
      patientName: _selectedPatientName,
      patientAge: _patientAge,
      patientGender: _patientGender,
      bloodGroup: _bloodGroup,
      allergies: _allergies,
      doctorName: container.currentDoctorName.isNotEmpty
          ? container.currentDoctorName
          : 'Unknown Doctor',
      doctorQualification: '',
      registrationNumber: '',
      department: container.currentDoctorSpecialty,
      consultationId: _selectedConsultationId,
      date: now,
      status: isActive ? PrescriptionStatus.active : PrescriptionStatus.draft,
      medicines: List.from(_addedMedicines),
      generalInstructions: _generalInstructionsController.text.trim(),
      lastSaved: now,
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-${now.millisecondsSinceEpoch}',
          timestamp: now,
          action: isActive ? 'Activated' : 'Saved Draft',
          performedBy: container.currentDoctorName,
          details: isActive
              ? 'Prescription verified and activated.'
              : 'Draft prescription saved.',
        ),
      ],
    );
  }

  void _saveDraft() async {
    setState(() => _isSavingDraft = true);
    await Future.delayed(const Duration(milliseconds: 100));
    final draft = _buildDraftModel(isActive: false);
    widget.onSaveComplete(draft, true);
    if (mounted) Navigator.pop(context);
  }

  void _confirmAndActivatePrescription() async {
    final rx = _buildDraftModel(isActive: true);
    widget.onSaveComplete(rx, false);
    if (mounted) Navigator.pop(context);
  }
}
