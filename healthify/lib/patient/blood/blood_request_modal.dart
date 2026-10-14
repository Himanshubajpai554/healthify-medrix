import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/queries/domain_queries.dart' as queries;
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class BloodRequestModal extends StatefulWidget {
  final String initialBloodGroup;
  final String initialHospital;
  final VoidCallback? onRequestSubmitted;

  const BloodRequestModal({
    super.key,
    this.initialBloodGroup = 'O+',
    this.initialHospital = 'City Care Hospital',
    this.onRequestSubmitted,
  });

  static void show(
    BuildContext context, {
    String initialBloodGroup = 'O+',
    String initialHospital = 'City Care Hospital',
    VoidCallback? onRequestSubmitted,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BloodRequestModal(
        initialBloodGroup: initialBloodGroup,
        initialHospital: initialHospital,
        onRequestSubmitted: onRequestSubmitted,
      ),
    );
  }

  @override
  State<BloodRequestModal> createState() => _BloodRequestModalState();
}

class _BloodRequestModalState extends State<BloodRequestModal> {
  final _formKey = GlobalKey<FormState>();
  late String _patientName;
  late String _patientId;
  late String _bloodGroup;
  late int _units;
  late String _component;
  late String _hospital;
  String? _hospitalId;
  List<dynamic> _hospitals = const [];
  late String _urgency;
  late String _phone;

  final List<String> _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _components = ['PRBC', 'Platelets', 'SDP', 'FFP', 'Whole Blood'];
  final List<String> _urgencies = ['Routine', 'Urgent (within 6h)', 'Emergency SOS (Immediate)'];

  @override
  void initState() {
    super.initState();
    _patientName = 'Patient';
    _patientId = 'Authenticated account';
    _bloodGroup = widget.initialBloodGroup;
    _units = 2;
    _component = 'PRBC';
    _hospital = widget.initialHospital;
    _urgency = 'Urgent (within 6h)';
    _phone = '+91 98765 43210';
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final hospitals = await RepositoryContainer.instance.patientDiscoveryRepository
          .searchHospitals(const queries.HospitalSearchQuery(pageSize: 100));
      if (!mounted) return;
      setState(() {
        _hospitals = hospitals;
        final preferred = hospitals.where((h) => h.name == widget.initialHospital);
        final selected = preferred.isNotEmpty ? preferred.first : (hospitals.isEmpty ? null : hospitals.first);
        _hospitalId = selected?.id;
        if (selected != null) _hospital = selected.name;
      });
    } catch (_) {
      if (mounted) setState(() => _hospitals = const []);
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final portal = RepositoryContainer.instance.patientPortalRepository;
      if (portal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to submit a blood request.')),
        );
        return;
      }
      final id = 'BLOOD-${DateTime.now().toUtc().microsecondsSinceEpoch}';
      final urgency = _urgency.startsWith('Emergency') ? 'Emergency SOS'
          : (_urgency.startsWith('Urgent') ? 'Urgent' : 'Routine');
      try {
        await portal.save('patientBloodRequests', id, {
          'id': id,
          'patientName': _patientName,
          'bloodGroup': _bloodGroup,
          'unitsNeeded': _units,
          'componentType': _component,
          'hospitalName': _hospital,
          'hospitalId': _hospitalId,
          'urgencyLevel': urgency,
          'contactPhone': _phone,
          'status': 'Pending',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Blood request was not saved: $error')),
          );
        }
        return;
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      if (widget.onRequestSubmitted != null) {
        widget.onRequestSubmitted!();
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Blood Request $id submitted. The hospital will contact you.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: const [
              Icon(Icons.assignment_outlined, color: Colors.redAccent, size: 24),
              SizedBox(width: 10),
              Text(
                'Request Blood Requirement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Submit your requirement to match with available blood bank stock.',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
          ),
          const Divider(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Info Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: Colors.teal),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient: $_patientName ($_patientId)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              const Text(
                                'Logged in patient record',
                                style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Blood Group Selection
                    const Text('Blood Group Needed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _bloodGroup,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _bloodGroup = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Component Type & Units Needed
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Component', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _component,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: _components.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _component = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Units Needed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                initialValue: _units,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: List.generate(10, (i) => i + 1)
                                    .map((u) => DropdownMenuItem(value: u, child: Text('$u Units')))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _units = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Hospital / Location Context
                    const Text('Hospital / Admission Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_hospitalId),
                      initialValue: _hospitalId,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.domain_rounded, color: Colors.redAccent, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      hint: Text(_hospitals.isEmpty ? 'No verified hospitals available' : 'Select hospital'),
                      items: _hospitals.map((hospital) => DropdownMenuItem<String>(
                        value: hospital.id,
                        child: Text(hospital.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      validator: (val) => val == null ? 'Select a verified hospital' : null,
                      onChanged: (val) {
                        final selected = _hospitals.where((h) => h.id == val);
                        if (selected.isNotEmpty) setState(() {
                          _hospitalId = val;
                          _hospital = selected.first.name;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Urgency Level
                    const Text('Urgency Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _urgency,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _urgency = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Contact Phone
                    const Text('Contact Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_rounded, color: Colors.teal, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter phone number' : null,
                      onSaved: (val) => _phone = val ?? '',
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitRequest,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                'Submit Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
