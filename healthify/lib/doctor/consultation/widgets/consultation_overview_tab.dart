import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/consultation_models.dart';
import 'consultation_ai_summary_card.dart';

class ConsultationOverviewTab extends StatefulWidget {
  final ConsultationFullModel consultation;
  final ValueChanged<ConsultationFullModel> onChanged;
  final VoidCallback onRefreshAISummary;
  final VoidCallback onSaveNote;

  const ConsultationOverviewTab({
    super.key,
    required this.consultation,
    required this.onChanged,
    required this.onRefreshAISummary,
    required this.onSaveNote,
  });

  @override
  State<ConsultationOverviewTab> createState() => _ConsultationOverviewTabState();
}

class _ConsultationOverviewTabState extends State<ConsultationOverviewTab> {
  late TextEditingController _reasonController;
  late TextEditingController _concernController;
  late TextEditingController _durationController;
  late TextEditingController _symptomsController;
  late TextEditingController _historyController;

  late TextEditingController _bpSysController;
  late TextEditingController _bpDiaController;
  late TextEditingController _hrController;
  late TextEditingController _tempController;
  late TextEditingController _respController;
  late TextEditingController _spo2Controller;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _obsController;

  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final c = widget.consultation;
    _reasonController = TextEditingController(text: c.reasonForVisit);
    _concernController = TextEditingController(text: c.patientReported.primaryConcern);
    _durationController = TextEditingController(text: c.patientReported.duration);
    _symptomsController = TextEditingController(text: c.patientReported.reportedSymptoms);
    _historyController = TextEditingController(text: c.patientReported.relevantHistory);

    _bpSysController = TextEditingController(text: c.vitals.bpSystolic);
    _bpDiaController = TextEditingController(text: c.vitals.bpDiastolic);
    _hrController = TextEditingController(text: c.vitals.heartRate);
    _tempController = TextEditingController(text: c.vitals.temperature);
    _respController = TextEditingController(text: c.vitals.respiratoryRate);
    _spo2Controller = TextEditingController(text: c.vitals.oxygenSaturation);
    _weightController = TextEditingController(text: c.vitals.weight);
    _heightController = TextEditingController(text: c.vitals.height);
    _obsController = TextEditingController(text: c.vitals.additionalObservations);

    _notesController = TextEditingController(text: c.clinicalNotes);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _concernController.dispose();
    _durationController.dispose();
    _symptomsController.dispose();
    _historyController.dispose();

    _bpSysController.dispose();
    _bpDiaController.dispose();
    _hrController.dispose();
    _tempController.dispose();
    _respController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _obsController.dispose();

    _notesController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final updated = widget.consultation.copyWith(
      reasonForVisit: _reasonController.text,
      patientReported: widget.consultation.patientReported.copyWith(
        primaryConcern: _concernController.text,
        duration: _durationController.text,
        reportedSymptoms: _symptomsController.text,
        relevantHistory: _historyController.text,
      ),
      vitals: widget.consultation.vitals.copyWith(
        bpSystolic: _bpSysController.text,
        bpDiastolic: _bpDiaController.text,
        heartRate: _hrController.text,
        temperature: _tempController.text,
        respiratoryRate: _respController.text,
        oxygenSaturation: _spo2Controller.text,
        weight: _weightController.text,
        height: _heightController.text,
        additionalObservations: _obsController.text,
      ),
      clinicalNotes: _notesController.text,
    );
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Clinical Summary Box
          ConsultationAISummaryCard(
            aiSummary: widget.consultation.aiSummary,
            onRefreshSummary: widget.onRefreshAISummary,
          ),
          const SizedBox(height: 18),

          // Section A: REASON FOR VISIT
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('A. REASON FOR VISIT', Icons.assignment_outlined, AppTheme.primaryTeal),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  onChanged: (_) => _notifyChanges(),
                  maxLines: 2,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: "Describe the patient's reason for consultation today...",
                    labelText: "Reason for today's visit (Required)",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section B: PATIENT-REPORTED INFORMATION
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('B. PATIENT-REPORTED INFORMATION', Icons.record_voice_over_outlined, AppTheme.accentColor),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _concernController,
                        onChanged: (_) => _notifyChanges(),
                        decoration: GlassTextFieldTheme.getDecoration(
                          context: context,
                          hintText: 'e.g. Exertional chest tightness',
                          labelText: 'Primary Concern',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _durationController,
                        onChanged: (_) => _notifyChanges(),
                        decoration: GlassTextFieldTheme.getDecoration(
                          context: context,
                          hintText: 'e.g. 2 Weeks',
                          labelText: 'Duration',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _symptomsController,
                  onChanged: (_) => _notifyChanges(),
                  maxLines: 2,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Describe symptoms as reported directly by the patient...',
                    labelText: 'Patient-Reported Symptoms',
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _historyController,
                  onChanged: (_) => _notifyChanges(),
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Relevant family history or medical background...',
                    labelText: 'Relevant History',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section C: CLINICAL OBSERVATIONS (VITALS)
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('C. CLINICAL OBSERVATIONS & TRIAGE VITALS', Icons.monitor_heart_outlined, const Color(0xFF10B981)),
                const SizedBox(height: 14),

                // Vitals Inputs Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 750;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _bpSysController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '120',
                                  labelText: 'BP Systolic (mmHg)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _bpDiaController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '80',
                                  labelText: 'BP Diastolic (mmHg)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _hrController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '76',
                                  labelText: 'Heart Rate (bpm)',
                                ),
                              ),
                            ),
                            if (isWide) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _spo2Controller,
                                  onChanged: (_) => _notifyChanges(),
                                  keyboardType: TextInputType.number,
                                  decoration: GlassTextFieldTheme.getDecoration(
                                    context: context,
                                    hintText: '98',
                                    labelText: 'SpO2 (%)',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (!isWide) ...[
                              Expanded(
                                child: TextField(
                                  controller: _spo2Controller,
                                  onChanged: (_) => _notifyChanges(),
                                  keyboardType: TextInputType.number,
                                  decoration: GlassTextFieldTheme.getDecoration(
                                    context: context,
                                    hintText: '98',
                                    labelText: 'SpO2 (%)',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: TextField(
                                controller: _tempController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '98.6',
                                  labelText: 'Temp (°F)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _respController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '16',
                                  labelText: 'Resp Rate (/min)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '78.5',
                                  labelText: 'Weight (kg)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                onChanged: (_) => _notifyChanges(),
                                keyboardType: TextInputType.number,
                                decoration: GlassTextFieldTheme.getDecoration(
                                  context: context,
                                  hintText: '175',
                                  labelText: 'Height (cm)',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _obsController,
                  onChanged: (_) => _notifyChanges(),
                  maxLines: 2,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Enter physical examination observations and clinical signs...',
                    labelText: 'Additional Clinical Observations',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section D: CLINICAL NOTES & VISIBILITY CONTROL
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('D. CLINICAL NOTES & VISIBILITY', Icons.edit_note_rounded, const Color(0xFF6366F1)),
                    GlassSecondaryButton(
                      height: 34,
                      onPressed: widget.onSaveNote,
                      child: const Row(
                        children: [
                          Icon(Icons.save_outlined, size: 14, color: AppTheme.primaryTeal),
                          SizedBox(width: 4),
                          Text('Save Note', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Note Visibility Selection Toggle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.consultation.noteVisibility == NoteVisibility.internalPrivate
                        ? Colors.indigo.withValues(alpha: 0.10)
                        : AppTheme.primaryTeal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.consultation.noteVisibility == NoteVisibility.internalPrivate
                          ? Colors.indigo.withValues(alpha: 0.25)
                          : AppTheme.primaryTeal.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.consultation.noteVisibility == NoteVisibility.internalPrivate ? Icons.lock_outline_rounded : Icons.visibility_outlined,
                        color: widget.consultation.noteVisibility == NoteVisibility.internalPrivate ? Colors.indigo : AppTheme.primaryTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.consultation.noteVisibility == NoteVisibility.internalPrivate
                                  ? 'INTERNAL PRIVATE NOTE: Visible ONLY to doctors & clinical care team in Medrix EHR.'
                                  : 'PATIENT VISIBLE NOTE: Accessible to patient in Consultation Summary on Patient App.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.consultation.noteVisibility == NoteVisibility.internalPrivate ? Colors.indigo : AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SegmentedButton<NoteVisibility>(
                        segments: const [
                          ButtonSegment(
                            value: NoteVisibility.internalPrivate,
                            label: Text('Internal (Private)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            icon: Icon(Icons.lock_rounded, size: 14),
                          ),
                          ButtonSegment(
                            value: NoteVisibility.patientVisible,
                            label: Text('Patient Visible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            icon: Icon(Icons.public_rounded, size: 14),
                          ),
                        ],
                        selected: {widget.consultation.noteVisibility},
                        onSelectionChanged: (newSelection) {
                          widget.onChanged(widget.consultation.copyWith(noteVisibility: newSelection.first));
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: _notesController,
                  onChanged: (_) => _notifyChanges(),
                  maxLines: 5,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Enter clinical notes, progress observations, advice, or bullet points...',
                    labelText: 'Clinical Notes',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
