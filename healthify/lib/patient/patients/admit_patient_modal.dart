import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class AdmitPatientModal extends StatefulWidget {
  final Function(PatientItem) onPatientAdmitted;

  const AdmitPatientModal({super.key, required this.onPatientAdmitted});

  @override
  State<AdmitPatientModal> createState() => _AdmitPatientModalState();
}

class _AdmitPatientModalState extends State<AdmitPatientModal> {
  int _tabIndex = 0; // 0 = New Patient, 1 = Lookup Existing Patient
  final _formKey = GlobalKey<FormState>();

  // New Patient Fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _doctorController = TextEditingController(text: 'Dr. Sarah Jenkins');

  String _gender = 'Female';
  String _bloodGroup = 'O+';
  String _ward = 'General Ward A';
  PatientStatus _status = PatientStatus.admitted;
  final DateTime _admissionDate = DateTime.now();

  // Lookup Existing Fields
  final _lookupSearchController = TextEditingController();
  List<Patient> _matchingPatients = [];
  Patient? _selectedExistingPatient;
  bool _isSearching = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _wards = [
    'General Ward A',
    'General Ward B',
    'ICU Main',
    'ICU Emergency',
    'Observation Unit',
    'Private Suite 101',
    'Pediatric Ward',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _doctorController.dispose();
    _lookupSearchController.dispose();
    super.dispose();
  }

  Future<void> _performPatientLookup(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _matchingPatients = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final repo = RepositoryScope.of(context).patientRepository;
    final allGlobal = await repo.getGlobalPatients();
    final q = query.trim().toLowerCase();

    setState(() {
      _matchingPatients = allGlobal.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q) ||
          p.phone.contains(q)).toList();
      _isSearching = false;
    });
  }

  void _submitForm() {
    if (_tabIndex == 0) {
      if (_formKey.currentState!.validate()) {
        final newId = 'PT-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
        final newPatient = PatientItem(
          id: newId,
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 30,
          gender: _gender,
          bloodGroup: _bloodGroup,
          ward: _ward,
          admissionDate: _admissionDate,
          status: _status,
          doctorName: _doctorController.text.trim(),
          vitals: {
            'BP': '120/80',
            'Heart Rate': '75 bpm',
            'SpO2': '98%',
            'Temp': '98.6 °F',
          },
        );

        widget.onPatientAdmitted(newPatient);
        Navigator.pop(context);
      }
    } else {
      if (_selectedExistingPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an existing patient to admit.')),
        );
        return;
      }

      final p = _selectedExistingPatient!;
      final admittedPatient = PatientItem(
        id: p.id,
        name: p.name,
        age: p.age,
        gender: p.gender,
        bloodGroup: p.bloodGroup,
        ward: _ward,
        admissionDate: DateTime.now(),
        status: _status,
        doctorName: _doctorController.text.trim(),
        vitals: {
          'BP': '120/80',
          'Heart Rate': '75 bpm',
          'SpO2': '98%',
          'Temp': '98.6 °F',
        },
      );

      widget.onPatientAdmitted(admittedPatient);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 540,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Admit Patient Workflow',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Mode Selector Tabs
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _tabIndex = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? AppTheme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'New Patient Intake',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabIndex == 0 ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _tabIndex = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? AppTheme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Lookup Existing Patient',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabIndex == 1 ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 14),

                // Form Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    child: _tabIndex == 0
                        ? _buildNewPatientForm()
                        : _buildLookupExistingPatientForm(),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(_tabIndex == 0 ? 'Admit Patient' : 'Confirm Readmission'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

  Widget _buildNewPatientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        const Text('Patient Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Jane Cooper',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter patient name';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        // Age & Gender Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Age', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 45',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Enter age';
                      if (int.tryParse(value.trim()) == null) return 'Invalid age';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: ['Female', 'Male', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Blood Group & Initial Status Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _bloodGroup = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admission Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<PatientStatus>(
                    initialValue: _status,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: PatientStatus.admitted, child: Text('Admitted')),
                      DropdownMenuItem(value: PatientStatus.icu, child: Text('ICU (Critical)')),
                      DropdownMenuItem(value: PatientStatus.observation, child: Text('Observation')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Assigned Ward
        const Text('Assigned Ward / Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _ward,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _ward = val);
          },
        ),
        const SizedBox(height: 14),

        // Attending Physician
        const Text('Attending Physician', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _doctorController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLookupExistingPatientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search Registered Patient', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _lookupSearchController,
          onChanged: _performPatientLookup,
          decoration: InputDecoration(
            hintText: 'Search by Patient Name, ID, or Phone...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        if (_matchingPatients.isNotEmpty) ...[
          const Text('Select Patient to Admit:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ..._matchingPatients.map((p) {
            final isSelected = _selectedExistingPatient?.id == p.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderLight),
              ),
              child: ListTile(
                onTap: () => setState(() => _selectedExistingPatient = p),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(p.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('ID: ${p.id} • ${p.age} Yrs • ${p.gender} • Blood: ${p.bloodGroup}'),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
              ),
            );
          }),
          const SizedBox(height: 14),
        ] else if (_lookupSearchController.text.isNotEmpty && !_isSearching) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No existing registered patient matches search query.')),
          ),
        ],

        if (_selectedExistingPatient != null) ...[
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 14),

          // Ward Selection for Existing Patient
          const Text('Assigned Ward / Unit for Admission', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _ward,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _ward = val);
            },
          ),
          const SizedBox(height: 14),

          const Text('Attending Physician', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _doctorController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }
}