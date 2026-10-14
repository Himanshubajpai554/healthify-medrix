import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/prescription_model.dart';
import '../../core/provider/repository_provider.dart';
import '../../theme/app_theme.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  final String patientId;

  const PatientPrescriptionsScreen({super.key, this.patientId = 'PAT-8842'});

  @override
  State<PatientPrescriptionsScreen> createState() => _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState extends State<PatientPrescriptionsScreen> {
  static const Color _primary = Color(0xFF0D9488);

  bool _isLoading = true;
  List<PrescriptionIndex> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final rows = await RepositoryContainer.instance.patientPortalRepository
              ?.list('patientPrescriptions') ??
          const <Map<String, dynamic>>[];
      PrescriptionStatus parseStatus(Object? value) => PrescriptionStatus.values
          .where((item) => item.name == value)
          .firstOrNull ?? PrescriptionStatus.signed;
      PharmacyFulfillmentStatus parseFulfillment(Object? value) =>
          PharmacyFulfillmentStatus.values.where((item) => item.name == value).firstOrNull ??
          PharmacyFulfillmentStatus.pending;
      final items = rows.map((row) => PrescriptionIndex(
        id: '${row['id']}',
        hospitalId: '${row['hospitalId'] ?? ''}',
        patientId: widget.patientId,
        hospitalPatientLinkId: row['hospitalPatientLinkId'] as String?,
        doctorId: '${row['doctorId'] ?? ''}',
        appointmentId: row['appointmentId'] as String?,
        admissionId: row['admissionId'] as String?,
        prescriptionReference: '${row['prescriptionReference'] ?? row['id']}',
        signedAt: DateTime.tryParse('${row['signedAt']}') ?? DateTime.now(),
        status: parseStatus(row['status']),
        pharmacyFulfillmentStatus: parseFulfillment(row['pharmacyFulfillmentStatus']),
        medications: (row['medications'] as List? ?? const []).whereType<Map>().map((m) => PrescriptionItem(
          medicationName: '${m['medicationName'] ?? ''}',
          dosage: '${m['dosage'] ?? ''}',
          frequency: '${m['frequency'] ?? ''}',
          durationDays: (m['durationDays'] as num?)?.toInt() ?? 0,
          instructions: '${m['instructions'] ?? ''}',
        )).toList(),
        clinicalNotes: row['clinicalNotes'] as String?,
        instructions: '${row['instructions'] ?? ''}',
        createdAt: DateTime.tryParse('${row['createdAt']}') ?? DateTime.now(),
        updatedAt: DateTime.tryParse('${row['updatedAt']}') ?? DateTime.now(),
      )).toList();
      if (mounted) setState(() { _prescriptions = items; _isLoading = false; });
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load prescriptions: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Prescription Index (Signed)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _prescriptions.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final item = _prescriptions[index];
                    return _buildPrescriptionCard(item, isDark);
                  },
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No active prescriptions found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your verified prescriptions from doctors will appear here automatically.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionIndex item, bool isDark) {
    final firstMed = item.medications.isNotEmpty ? item.medications.first : null;
    final medTitle = firstMed != null ? firstMed.medicationName : item.prescriptionReference;
    final medDosage = firstMed != null ? '${firstMed.dosage} • ${firstMed.frequency}' : item.instructions;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medication_rounded, color: _primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Rx #${item.prescriptionReference} • $medDosage',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Doctor ID: ${item.doctorId}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Signed: ${item.signedAt.month}/${item.signedAt.day}/${item.signedAt.year}',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
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
}
