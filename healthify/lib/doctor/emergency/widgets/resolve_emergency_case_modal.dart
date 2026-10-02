import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class ResolveEmergencyCaseModal extends StatefulWidget {
  final DoctorEmergencyCaseFullModel emergencyCase;
  final Function(EmergencyResolutionInfoModel resolutionInfo) onResolveConfirmed;

  const ResolveEmergencyCaseModal({
    super.key,
    required this.emergencyCase,
    required this.onResolveConfirmed,
  });

  @override
  State<ResolveEmergencyCaseModal> createState() => _ResolveEmergencyCaseModalState();
}

class _ResolveEmergencyCaseModalState extends State<ResolveEmergencyCaseModal> {
  final _formKey = GlobalKey<FormState>();
  EmergencyDisposition _disposition = EmergencyDisposition.discharged;
  final _resolutionNoteController = TextEditingController();
  final _dischargeSummaryController = TextEditingController();
  final _dischargeMedsController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void dispose() {
    _resolutionNoteController.dispose();
    _dischargeSummaryController.dispose();
    _dischargeMedsController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final resolutionInfo = EmergencyResolutionInfoModel(
        disposition: _disposition,
        resolutionNote: _resolutionNoteController.text.trim(),
        resolvedBy: 'Dr. Sarah Jenkins',
        timestamp: DateTime.now(),
      );

      widget.onResolveConfirmed(resolutionInfo);
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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 750),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.check_circle_outline_rounded,
                      size: 40,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resolve Emergency Case',
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
                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disposition selection
                        Text(
                          'Patient Disposition / Outcome',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<EmergencyDisposition>(
                          initialValue: _disposition,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          decoration: _buildInputDecoration(isDark),
                          items: EmergencyDisposition.values.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(d.label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _disposition = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Resolution Note
                        Text(
                          'Resolution / Outcome Note',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _resolutionNoteController,
                          maxLines: 2,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a resolution note summarizing clinical decision.';
                            }
                            return null;
                          },
                          decoration: _buildInputDecoration(
                            isDark,
                            hint: 'e.g. Acute coronary syndrome ruled out after serial troponins and ECGs. Stable for discharge.',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Discharge Summary
                        Text(
                          'Discharge Summary',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _dischargeSummaryController,
                          maxLines: 3,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          decoration: _buildInputDecoration(
                            isDark,
                            hint: 'Summarize ER treatment, observations, diagnostic findings, and clinical status at discharge.',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Discharge Medications
                        Text(
                          'Discharge Medications (Comma separated)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _dischargeMedsController,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          decoration: _buildInputDecoration(
                            isDark,
                            hint: 'e.g. Aspirin 75mg OD x 30 days, Atorvastatin 20mg HS',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Follow up instructions
                        Text(
                          'Follow-up Advice & Red Flag Warnings',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _followUpController,
                          maxLines: 2,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                          decoration: _buildInputDecoration(
                            isDark,
                            hint: 'e.g. Follow up in OPD Cardiology in 5 days. Return immediately to ER if chest pain recurs.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

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
                          Icon(Icons.check_circle_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Complete & Resolve Case'),
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
