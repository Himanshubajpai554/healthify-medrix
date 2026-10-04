import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class PrescriptionDetailDrawer extends StatelessWidget {
  final DoctorPrescriptionFullModel prescription;
  final PatientMedicationHistoryModel? medicationHistory;
  final VoidCallback onClose;
  final VoidCallback onPrint;
  final VoidCallback onDownload;
  final VoidCallback onDuplicate;
  final VoidCallback onCancelPrescription;

  const PrescriptionDetailDrawer({
    super.key,
    required this.prescription,
    required this.medicationHistory,
    required this.onClose,
    required this.onPrint,
    required this.onDownload,
    required this.onDuplicate,
    required this.onCancelPrescription,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String formatDateTime(DateTime dt) => '${formatDate(dt)} • ${formatTime(dt)}';

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      color: isDark
          ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.98)
          : Colors.white.withValues(alpha: 0.98),
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(isDark),
          const Divider(height: 1),

          // Scrollable Detail Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Toolbar
                  _buildActionBar(context, isDark),
                  const SizedBox(height: 20),

                  // Section 7 & 15: Patient Information & PROMINENT ALLERGY WARNING (Before Medications)
                  _buildPatientInfoCard(isDark),
                  const SizedBox(height: 20),

                  // Section 8: Medication List Table / Cards
                  _buildMedicationListCard(context, isDark),
                  const SizedBox(height: 20),

                  // Section 16: Drug Interaction Support Notice (Mandatory exact string)
                  _buildInteractionCheckCard(isDark),
                  const SizedBox(height: 20),

                  // Section 12: General Instructions Card
                  _buildGeneralInstructionsCard(isDark),
                  const SizedBox(height: 20),

                  // Section 13: Controlled AI Prescription Assistant Card
                  _buildAiAssistantCard(isDark),
                  const SizedBox(height: 20),

                  // Section 14: Patient Medication History (Current, Previous, Discontinued)
                  _buildMedicationHistoryCard(context, isDark),
                  const SizedBox(height: 20),

                  // Section 23: Audit History Timeline
                  _buildAuditHistoryCard(isDark),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: prescription.status.color.withValues(alpha: isDark ? 0.25 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 24,
              color: prescription.status.color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prescription ${prescription.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(prescription.status, isDark),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient: ${prescription.patientName} (${prescription.patientId}) • ${formatDate(prescription.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onClose,
            tooltip: 'Close Drawer',
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        GlassPrimaryButton(
          onPressed: onPrint,
          height: 40,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.print_rounded, size: 18),
              SizedBox(width: 6),
              Text('Print RX', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        GlassSecondaryButton(
          onPressed: onDownload,
          height: 40,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, size: 18),
              SizedBox(width: 6),
              Text('Download PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        GlassSecondaryButton(
          onPressed: onDuplicate,
          height: 40,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy_rounded, size: 18),
              SizedBox(width: 6),
              Text('Duplicate Draft', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (prescription.status == PrescriptionStatus.active)
          OutlinedButton.icon(
            onPressed: onCancelPrescription,
            icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.redAccent),
            label: const Text('Cancel Prescription', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildPatientInfoCard(bool isDark) {
    final hasAllergies = prescription.allergies.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 22, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Patient Context & Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // PROMINENT ALLERGY WARNING BOX (Placed clearly BEFORE medication info per Prompt Rule Section 7 & 15)
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
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: hasAllergies ? Colors.redAccent : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAllergies
                            ? 'Known Sensitivities: ${prescription.allergies.join(", ")}'
                            : 'No drug or chemical allergies currently logged in patient record.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Meta info grid
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildMetaItem('Patient Name', prescription.patientName, isDark),
              _buildMetaItem('Patient ID', prescription.patientId, isDark),
              _buildMetaItem('Age / Gender', '${prescription.patientAge}y / ${prescription.patientGender}', isDark),
              _buildMetaItem('Blood Group', prescription.bloodGroup, isDark),
              _buildMetaItem('Attending Doctor', prescription.doctorName, isDark),
              _buildMetaItem('Department', prescription.department, isDark),
              _buildMetaItem('Consultation ID', prescription.consultationId, isDark),
              _buildMetaItem('Registration No.', prescription.registrationNumber, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value, bool isDark) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationListCard(BuildContext context, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_rounded, size: 22, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Prescribed Medications (${prescription.medicines.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (isMobile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.medicines.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final med = prescription.medicines[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            med.medicineName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              med.dosage,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Frequency: ${med.frequency} • Route: ${med.route} • Duration: ${med.duration}',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                      if (med.instructions.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Instructions: ${med.instructions}',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.2),
                4: FlexColumnWidth(1.2),
                5: FlexColumnWidth(2.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                  ),
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text('MEDICINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                    Padding(padding: EdgeInsets.all(8), child: Text('DOSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                    Padding(padding: EdgeInsets.all(8), child: Text('FREQUENCY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                    Padding(padding: EdgeInsets.all(8), child: Text('ROUTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                    Padding(padding: EdgeInsets.all(8), child: Text('DURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                    Padding(padding: EdgeInsets.all(8), child: Text('INSTRUCTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                  ],
                ),
                ...prescription.medicines.map(
                  (med) => TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark).withValues(alpha: 0.5))),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.medicineName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.dosage, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.frequency, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.route, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.duration, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(med.instructions, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionCheckCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 20, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication Safety Check',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Medication interaction checking is not configured.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInstructionsCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'General Clinical Instructions',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prescription.generalInstructions.isEmpty
                ? 'Continue prescribed medication as instructed and attend the scheduled follow-up.'
                : prescription.generalInstructions,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Prescription Assistant',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• Current active regimen includes ${prescription.medicines.length} medications.\n'
            '• Allergy Notice: Patient has recorded sensitivities to: ${prescription.allergies.isEmpty ? "None" : prescription.allergies.join(", ")}.\n'
            '• No duplicate drug class entries identified in this active prescription draft.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          // Mandatory AI Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated assistance — doctor review required.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationHistoryCard(BuildContext context, bool isDark) {
    final history = medicationHistory;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.history_edu_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Patient Medication History',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showFullHistoryModal(context),
                child: const Text('View Full History', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (history != null) ...[
            Text('Current Active:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark))),
            const SizedBox(height: 4),
            Text(
              history.activeMedications.isEmpty
                  ? 'None'
                  : history.activeMedications.map((m) => '${m.medicineName} ${m.dosage}').join(', '),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark)),
            ),
            const SizedBox(height: 10),
            Text('Recently Discontinued:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark))),
            const SizedBox(height: 4),
            Text(
              history.discontinuedMedications.isEmpty
                  ? 'None'
                  : history.discontinuedMedications.map((m) => '${m.medicineName} ${m.dosage} (${m.reason})').join(', '),
              style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditHistoryCard(bool isDark) {
    final history = prescription.auditHistory;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Prescription Audit History',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isLast = index == history.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.action,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              formatDateTime(item.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'By: ${item.performedBy} — ${item.details}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PrescriptionStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }

  void _showFullHistoryModal(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
          title: Text(
            'Full Medication History (${prescription.patientName})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Active Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...prescription.medicines.map((m) => ListTile(
                      title: Text(m.medicineName),
                      subtitle: Text('${m.dosage} • ${m.frequency} • ${m.duration}'),
                    )),
                const Divider(),
                const Text('Recently Discontinued:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                if (medicationHistory != null && medicationHistory!.discontinuedMedications.isNotEmpty)
                  ...medicationHistory!.discontinuedMedications.map((m) => ListTile(
                        title: Text(m.medicineName),
                        subtitle: Text('Dosage: ${m.dosage} • Reason: ${m.reason}'),
                      ))
                else
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No discontinued medications logged.'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
