import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class EmergencyCaseDetailDrawer extends StatefulWidget {
  final DoctorEmergencyCaseFullModel emergencyCase;
  final VoidCallback onClose;
  final VoidCallback onStartConsultation;
  final VoidCallback onAddNotePressed;
  final VoidCallback onUpdateStatusPressed;
  final VoidCallback onTransferPressed;
  final VoidCallback onResolvePressed;
  final Function(EmergencyObservationsModel obs) onSaveObservations;
  final Function(EmergencyNoteType type, String content, bool isInternal) onSaveNote;
  final VoidCallback onCreatePrescription;

  const EmergencyCaseDetailDrawer({
    super.key,
    required this.emergencyCase,
    required this.onClose,
    required this.onStartConsultation,
    required this.onAddNotePressed,
    required this.onUpdateStatusPressed,
    required this.onTransferPressed,
    required this.onResolvePressed,
    required this.onSaveObservations,
    required this.onSaveNote,
    required this.onCreatePrescription,
  });

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  static String formatDateTime(DateTime dt) => '${formatDate(dt)} • ${formatTime(dt)}';

  @override
  State<EmergencyCaseDetailDrawer> createState() => _EmergencyCaseDetailDrawerState();
}

class _EmergencyCaseDetailDrawerState extends State<EmergencyCaseDetailDrawer> {
  // Observations Form
  late TextEditingController _bpSysController;
  late TextEditingController _bpDiaController;
  late TextEditingController _hrController;
  late TextEditingController _tempController;
  late TextEditingController _rrController;
  late TextEditingController _spo2Controller;
  late TextEditingController _weightController;
  late TextEditingController _obsNotesController;

  // Notes Form
  EmergencyNoteType _selectedNoteType = EmergencyNoteType.emergencyNote;
  bool _isInternalPrivateNote = true;
  late TextEditingController _noteContentController;
  bool _isEditingObs = false;

  @override
  void initState() {
    super.initState();
    final obs = widget.emergencyCase.observations;
    _bpSysController = TextEditingController(text: obs?.bpSystolic ?? '120');
    _bpDiaController = TextEditingController(text: obs?.bpDiastolic ?? '80');
    _hrController = TextEditingController(text: obs?.heartRate ?? '76');
    _tempController = TextEditingController(text: obs?.temperature ?? '37.0');
    _rrController = TextEditingController(text: obs?.respiratoryRate ?? '16');
    _spo2Controller = TextEditingController(text: obs?.oxygenSaturation ?? '98');
    _weightController = TextEditingController(text: obs?.weight ?? '75');
    _obsNotesController = TextEditingController(text: obs?.additionalObservations ?? '');
    _noteContentController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant EmergencyCaseDetailDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emergencyCase.id != widget.emergencyCase.id) {
      final obs = widget.emergencyCase.observations;
      _bpSysController.text = obs?.bpSystolic ?? '120';
      _bpDiaController.text = obs?.bpDiastolic ?? '80';
      _hrController.text = obs?.heartRate ?? '76';
      _tempController.text = obs?.temperature ?? '37.0';
      _rrController.text = obs?.respiratoryRate ?? '16';
      _spo2Controller.text = obs?.oxygenSaturation ?? '98';
      _weightController.text = obs?.weight ?? '75';
      _obsNotesController.text = obs?.additionalObservations ?? '';
      _noteContentController.clear();
    }
  }

  @override
  void dispose() {
    _bpSysController.dispose();
    _bpDiaController.dispose();
    _hrController.dispose();
    _tempController.dispose();
    _rrController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _obsNotesController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

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

          // Scrollable Content Workspace
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Bar Toolbar
                  _buildActionBar(context, isDark),
                  const SizedBox(height: 20),

                  // Section 9: Patient Emergency Snapshot & PROMINENT ALLERGIES BANNER
                  _buildPatientSnapshotCard(isDark),
                  const SizedBox(height: 20),

                  // Section 10: Emergency Reason Card
                  _buildEmergencyReasonCard(isDark),
                  const SizedBox(height: 20),

                  // Section 11: Emergency Observations & Vitals Card
                  _buildObservationsCard(isDark),
                  const SizedBox(height: 20),

                  // Section 12: Real-time Emergency Timeline Card
                  _buildTimelineCard(isDark),
                  const SizedBox(height: 20),

                  // Section 13: Emergency Notes Editor & Log Card
                  _buildNotesCard(isDark),
                  const SizedBox(height: 20),

                  // Section 14 & 15: Linked Reports & Prescriptions Integration Card
                  _buildReportsAndPrescriptionsCard(context, isDark),
                  const SizedBox(height: 20),

                  // Section 21: Controlled AI Case Summary Card
                  _buildAiCaseSummaryCard(isDark),
                  const SizedBox(height: 20),

                  // Section 22: Audit Trail Card
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
    final item = widget.emergencyCase;

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
              color: item.priority.color.withValues(alpha: isDark ? 0.25 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emergency_rounded,
              size: 24,
              color: item.priority.color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Emergency Case ${item.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    _buildPriorityBadge(item.priority, isDark),
                    _buildStatusBadge(item.status, isDark),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient: ${item.patientName} (${item.patientId}) • Arrival: ${EmergencyCaseDetailDrawer.formatTime(item.arrivalTime)} • ${item.location}',
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
            onPressed: widget.onClose,
            tooltip: 'Close Drawer',
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, bool isDark) {
    final item = widget.emergencyCase;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        GlassPrimaryButton(
          onPressed: widget.onStartConsultation,
          height: 42,
          color: HealthifyGlassTheme.primaryTeal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 20),
              const SizedBox(width: 6),
              Text(
                item.consultationId != null ? 'Open Emergency Consultation' : 'Start Emergency Consultation',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        GlassSecondaryButton(
          onPressed: widget.onUpdateStatusPressed,
          height: 42,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.published_with_changes_rounded, size: 18),
              SizedBox(width: 6),
              Text('Update Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        GlassSecondaryButton(
          onPressed: widget.onTransferPressed,
          height: 42,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_rounded, size: 18),
              SizedBox(width: 6),
              Text('Transfer Case', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        if (item.status != EmergencyCaseStatus.resolved)
          GlassPrimaryButton(
            onPressed: widget.onResolvePressed,
            height: 42,
            color: const Color(0xFF10B981),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 18),
                SizedBox(width: 6),
                Text('Resolve / Close Case', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPatientSnapshotCard(bool isDark) {
    final item = widget.emergencyCase;
    final hasAllergies = item.allergies.isNotEmpty;

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
                'Patient Emergency Snapshot',
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

          // PROMINENT ALLERGIES WARNING BANNER (Prompt Rule Section 9: Allergies prominently visible!)
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
                      const SizedBox(height: 2),
                      Text(
                        hasAllergies
                            ? 'Known Sensitivities: ${item.allergies.join(", ")}'
                            : 'No drug sensitivities currently logged.',
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

          // Snapshot Meta Grid
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildMetaItem('Patient Name', item.patientName, isDark),
              _buildMetaItem('Patient ID', item.patientId, isDark),
              _buildMetaItem('Age / Gender', '${item.patientAge}y / ${item.patientGender}', isDark),
              _buildMetaItem('Blood Group', item.bloodGroup, isDark),
              _buildMetaItem('Known Conditions', item.knownConditions.isEmpty ? 'None Logged' : item.knownConditions.join(', '), isDark),
              _buildMetaItem('Current Medications', '${item.currentMedications.length} Active Regimens', isDark),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Emergency Contact Action Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.contact_phone_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Emergency Contact: ${item.emergencyContactName} (${item.emergencyContactRelation}) • ${item.emergencyContactPhone}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dialing ${item.emergencyContactPhone}...')),
                  );
                },
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: const Text('Call Contact', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
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

  Widget _buildEmergencyReasonCard(bool isDark) {
    final item = widget.emergencyCase;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Recorded Reason for Arrival',
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
            item.emergencyReason,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Text(
            'Patient-Reported Symptom Log:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
          const SizedBox(height: 4),
          Text(
            item.patientReportedInfo,
            style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          ),
          const SizedBox(height: 10),

          Text(
            'Triage Arrival Notes & Referral:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
          const SizedBox(height: 4),
          Text(
            'Arrival Method: ${item.arrivalMethod} • Referral: ${item.referralSource}\nNotes: ${item.arrivalNotes}',
            style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsCard(bool isDark) {
    final obs = widget.emergencyCase.observations;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_heart_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Text(
                    'Emergency Vitals & Observations',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(_isEditingObs ? Icons.close_rounded : Icons.edit_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                onPressed: () => setState(() => _isEditingObs = !_isEditingObs),
                tooltip: 'Edit Vitals Form',
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (_isEditingObs) ...[
            // Form View for Entering Vitals
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bpSysController,
                    decoration: const InputDecoration(labelText: 'BP Systolic (mmHg)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _bpDiaController,
                    decoration: const InputDecoration(labelText: 'BP Diastolic (mmHg)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _hrController,
                    decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempController,
                    decoration: const InputDecoration(labelText: 'Temp (°C)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rrController,
                    decoration: const InputDecoration(labelText: 'Resp Rate (/min)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _spo2Controller,
                    decoration: const InputDecoration(labelText: 'SpO2 (%)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _obsNotesController,
              decoration: const InputDecoration(labelText: 'Additional Clinical Observations'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GlassPrimaryButton(
                onPressed: () {
                  final newObs = EmergencyObservationsModel(
                    bpSystolic: _bpSysController.text.trim(),
                    bpDiastolic: _bpDiaController.text.trim(),
                    heartRate: _hrController.text.trim(),
                    temperature: _tempController.text.trim(),
                    respiratoryRate: _rrController.text.trim(),
                    oxygenSaturation: _spo2Controller.text.trim(),
                    weight: _weightController.text.trim(),
                    additionalObservations: _obsNotesController.text.trim(),
                    recordedBy: 'Dr. Sarah Jenkins',
                    recordedAt: DateTime.now(),
                  );
                  widget.onSaveObservations(newObs);
                  setState(() => _isEditingObs = false);
                },
                height: 38,
                child: const Text('Save Vitals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              ),
            ),
          ] else if (obs != null) ...[
            // Read-Only Grid View
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildVitalMetric('Blood Pressure', obs.bpText, Icons.speed_rounded, isDark),
                _buildVitalMetric('Heart Rate', '${obs.heartRate} bpm', Icons.favorite_rounded, isDark),
                _buildVitalMetric('Temperature', '${obs.temperature} °C', Icons.thermostat_rounded, isDark),
                _buildVitalMetric('SpO2', '${obs.oxygenSaturation} %', Icons.air_rounded, isDark),
                _buildVitalMetric('Resp Rate', '${obs.respiratoryRate} /min', Icons.reorder_rounded, isDark),
              ],
            ),
            if (obs.additionalObservations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes: ${obs.additionalObservations}',
                style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: HealthifyGlassTheme.getTextPrimary(isDark)),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Recorded by ${obs.recordedBy} at ${EmergencyCaseDetailDrawer.formatTime(obs.recordedAt)}',
              style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark)),
            ),
          ] else ...[
            Text('No vitals or observations recorded yet.', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalMetric(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: HealthifyGlassTheme.primaryTeal),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(bool isDark) {
    final timeline = widget.emergencyCase.timeline;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Real-Time Case Timeline',
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
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              final isLast = index == timeline.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 34,
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
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                            Text(
                              EmergencyCaseDetailDrawer.formatTime(item.timestamp),
                              style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                          ],
                        ),
                        Text('Actor: ${item.actor}', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                        if (item.optionalNote != null)
                          Text('Note: ${item.optionalNote}', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                        const SizedBox(height: 10),
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

  Widget _buildNotesCard(bool isDark) {
    final notes = widget.emergencyCase.notes;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 22, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Emergency Case Notes',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add Note Form Box
          Container(
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
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<EmergencyNoteType>(
                          value: _selectedNoteType,
                          items: EmergencyNoteType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedNoteType = val);
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isInternalPrivateNote,
                          onChanged: (val) => setState(() => _isInternalPrivateNote = val ?? true),
                        ),
                        const Text('Internal Private Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteContentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter clinical observations, handover details, or emergency notes...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GlassPrimaryButton(
                    onPressed: () {
                      if (_noteContentController.text.trim().isEmpty) return;
                      widget.onSaveNote(_selectedNoteType, _noteContentController.text.trim(), _isInternalPrivateNote);
                      _noteContentController.clear();
                    },
                    height: 36,
                    child: const Text('Add Note', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Notes List
          if (notes.isEmpty)
            Text('No emergency notes recorded yet.', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final n = notes[idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: n.isInternalPrivate ? Colors.amber.withValues(alpha: isDark ? 0.12 : 0.06) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${n.noteType.label} • ${n.author}',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: n.isInternalPrivate ? Colors.amber.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              n.isInternalPrivate ? 'Internal Private' : 'Patient Visible',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: n.isInternalPrivate ? Colors.amber.shade900 : Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n.content, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      const SizedBox(height: 4),
                      Text(EmergencyCaseDetailDrawer.formatDateTime(n.createdAt), style: TextStyle(fontSize: 10.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReportsAndPrescriptionsCard(BuildContext context, bool isDark) {
    final item = widget.emergencyCase;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_shared_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Reports & Active Prescriptions',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Linked Reports (${item.attachedReportIds.length}): ${item.attachedReportIds.join(", ")}',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          ),
          const SizedBox(height: 8),
          Text(
            'Linked Prescriptions (${item.attachedPrescriptionIds.length}): ${item.attachedPrescriptionIds.join(", ")}',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/doctor-reports'),
                icon: const Icon(Icons.description_rounded, size: 16),
                label: const Text('View Patient Reports'),
              ),
              const SizedBox(width: 10),
              GlassPrimaryButton(
                onPressed: widget.onCreatePrescription,
                height: 38,
                child: const Text('Create Prescription', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiCaseSummaryCard(bool isDark) {
    final item = widget.emergencyCase;

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
                'AI Case Summary',
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
            'Emergency case ${item.id} registered at ${EmergencyCaseDetailDrawer.formatTime(item.arrivalTime)}. Patient has ${item.attachedReportIds.length} recent reports and ${item.currentMedications.length} active prescriptions recorded in medical history.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          // Mandatory AI Notice
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
                    'AI-generated summary — verify against original patient records.',
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

  Widget _buildAuditHistoryCard(bool isDark) {
    final history = widget.emergencyCase.auditHistory;
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
                'Case Audit History',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...history.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${EmergencyCaseDetailDrawer.formatTime(item.timestamp)} • ${item.action} (${item.actor})',
                style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(EmergencyOperationalPriority priority, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: priority.color),
      ),
    );
  }

  Widget _buildStatusBadge(EmergencyCaseStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: status.color),
      ),
    );
  }
}
