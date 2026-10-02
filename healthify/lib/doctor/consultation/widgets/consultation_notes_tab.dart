import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/consultation_models.dart';

class ConsultationNotesTab extends StatelessWidget {
  final ConsultationFullModel consultation;
  final ValueChanged<ConsultationFullModel> onChanged;

  const ConsultationNotesTab({
    super.key,
    required this.consultation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivate = consultation.noteVisibility == NoteVisibility.internalPrivate;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clinical Examination Notes & Observations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    'Detailed notes, clinical findings, differential considerations & instructions',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
              GlassSecondaryButton(
                height: 36,
                onPressed: () {
                  final current = consultation.clinicalNotes;
                  final bulleted = '$current\n• ';
                  onChanged(consultation.copyWith(clinicalNotes: bulleted));
                },
                child: const Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, size: 14, color: AppTheme.primaryTeal),
                    SizedBox(width: 4),
                    Text('Add Bullet Point', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visibility Switch Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrivate ? Colors.indigo.withValues(alpha: 0.10) : AppTheme.primaryTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isPrivate ? Colors.indigo.withValues(alpha: 0.25) : AppTheme.primaryTeal.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  isPrivate ? Icons.lock_outline_rounded : Icons.visibility_outlined,
                  color: isPrivate ? Colors.indigo : AppTheme.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isPrivate
                        ? 'Internal Note Mode: Strictly private. Only accessible to doctors & care team in Medrix EHR.'
                        : 'Patient Visible Mode: Will be included in the patient\'s accessible consultation summary.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrivate ? Colors.indigo : AppTheme.primaryTeal,
                    ),
                  ),
                ),
                SegmentedButton<NoteVisibility>(
                  segments: const [
                    ButtonSegment(
                      value: NoteVisibility.internalPrivate,
                      label: Text('Internal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      icon: Icon(Icons.lock_rounded, size: 12),
                    ),
                    ButtonSegment(
                      value: NoteVisibility.patientVisible,
                      label: Text('Patient Visible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      icon: Icon(Icons.public_rounded, size: 12),
                    ),
                  ],
                  selected: {consultation.noteVisibility},
                  onSelectionChanged: (set) => onChanged(consultation.copyWith(noteVisibility: set.first)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Text Editor Area
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: TextFormField(
              initialValue: consultation.clinicalNotes,
              onChanged: (val) => onChanged(consultation.copyWith(clinicalNotes: val)),
              maxLines: 12,
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Type comprehensive clinical observations, examination findings, differential diagnosis notes, or patient instructions here...',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
