import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class TransferEmergencyCaseModal extends StatefulWidget {
  final DoctorEmergencyCaseFullModel emergencyCase;
  final Function(EmergencyTransferInfoModel transferInfo) onTransferConfirmed;

  const TransferEmergencyCaseModal({
    super.key,
    required this.emergencyCase,
    required this.onTransferConfirmed,
  });

  @override
  State<TransferEmergencyCaseModal> createState() => _TransferEmergencyCaseModalState();
}

class _TransferEmergencyCaseModalState extends State<TransferEmergencyCaseModal> {
  final _formKey = GlobalKey<FormState>();
  String _department = 'Cardiac Care Unit (CCU)';
  String _ward = 'ICU Bed 04 - Block A';
  String _doctor = 'Dr. Marcus Vance (Interventional Cardiology)';
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _departments = [
    'Cardiac Care Unit (CCU)',
    'Intensive Care Unit (ICU)',
    'Neurology / Stroke Ward',
    'General Surgery',
    'Orthopedics & Trauma',
    'External Hospital / Specialist Facility',
  ];

  final List<String> _wards = [
    'ICU Bed 04 - Block A',
    'CCU Bed 02',
    'Surgical OT 01 / Recovery',
    'Specialist Ward 3B',
    'External Ambulance Transfer',
  ];

  final List<String> _doctors = [
    'Dr. Marcus Vance (Interventional Cardiology)',
    'Dr. Elena Rostova (Critical Care Specialist)',
    'Dr. Aris Thorne (Trauma Surgeon)',
    'Dr. Sarah Jenkins (Lead ER Specialist)',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transferInfo = EmergencyTransferInfoModel(
        transferredToDepartment: _department,
        transferredToWard: _ward,
        transferredToDoctor: _doctor,
        reason: _reasonController.text.trim(),
        transferNotes: _notesController.text.trim(),
        transferredBy: 'Dr. Sarah Jenkins',
        timestamp: DateTime.now(),
      );

      widget.onTransferConfirmed(transferInfo);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isMobileWidth = MediaQuery.of(context).size.width < 540;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.swap_horiz_rounded,
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transfer Emergency Case',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Case ID: ${widget.emergencyCase.id} • ${widget.emergencyCase.patientName}',
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

                  // Department
                  Text(
                    'Destination Department',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _department,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: _buildInputDecoration(isDark),
                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _department = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Ward / Location & Receiving Doctor
                  if (isMobileWidth) ...[
                    Text(
                      'Destination Ward / Bed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _ward,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: _buildInputDecoration(isDark),
                      items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _ward = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Receiving Doctor',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _doctor,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: _buildInputDecoration(isDark),
                      items: _doctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _doctor = val);
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination Ward / Bed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _ward,
                                isExpanded: true,
                                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                decoration: _buildInputDecoration(isDark),
                                items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _ward = val);
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
                              Text(
                                'Receiving Doctor',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _doctor,
                                isExpanded: true,
                                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                decoration: _buildInputDecoration(isDark),
                                items: _doctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _doctor = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Reason
                  Text(
                    'Reason for Transfer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _reasonController,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter the reason for transfer.';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(isDark, hint: 'e.g. Requires urgent emergency cardiac catheterization (Primary PCI).'),
                  ),
                  const SizedBox(height: 14),

                  // Clinical Handover Notes
                  Text(
                    'Clinical Handover Notes & Instructions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    decoration: _buildInputDecoration(isDark, hint: 'e.g. Aspirin 325mg & Clopidogrel 300mg given. Patient continuously monitored on telemetry.'),
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
                        child: const Row(
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Confirm Transfer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(bool isDark, {String? hint}) {
    return InputDecoration(
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
    );
  }
}
