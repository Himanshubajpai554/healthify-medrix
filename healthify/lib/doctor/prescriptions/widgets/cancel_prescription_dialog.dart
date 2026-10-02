import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class CancelPrescriptionDialog extends StatefulWidget {
  final DoctorPrescriptionFullModel prescription;
  final Function(String reason) onConfirmCancel;

  const CancelPrescriptionDialog({
    super.key,
    required this.prescription,
    required this.onConfirmCancel,
  });

  @override
  State<CancelPrescriptionDialog> createState() => _CancelPrescriptionDialogState();
}

class _CancelPrescriptionDialogState extends State<CancelPrescriptionDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: isDark ? 0.25 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel Prescription ${widget.prescription.id}?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Patient: ${widget.prescription.patientName} (${widget.prescription.patientId})',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
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
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Cancelling this prescription will mark it as inactive in the patient\'s medical record. A mandatory reason must be logged for clinical audit compliance.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: TextFormField(
                controller: _reasonController,
                maxLines: 3,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a cancellation reason' : null,
                style: TextStyle(
                  fontSize: 13.5,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter clinical reason (e.g., Patient reported GI intolerance, medication substituted)...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Keep Active'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onConfirmCancel(_reasonController.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Confirm Cancellation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
