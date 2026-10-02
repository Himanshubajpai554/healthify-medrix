import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';
import '../../models/patient_profile_models.dart';
import 'add_clinical_note_modal.dart';

class PatientNotesTab extends StatelessWidget {
  final PatientModel patient;
  final List<PatientNoteModel> notes;
  final VoidCallback onNoteAdded;

  const PatientNotesTab({
    super.key,
    required this.patient,
    required this.notes,
    required this.onNoteAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Add Note Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical Notes & Observations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Doctor observations, internal notes, and consultation records',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            GlassPrimaryButton(
              onPressed: () {
                AddClinicalNoteModal.show(
                  context: context,
                  patient: patient,
                  onNoteAdded: onNoteAdded,
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.post_add_rounded, size: 16),
                  SizedBox(width: 4),
                  Text('Add Clinical Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (notes.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No clinical notes recorded yet for this patient.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Column(
            children: notes.map((note) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
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
                                  color: (note.isInternalPrivate ? Colors.indigo : AppTheme.primaryTeal).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  note.isInternalPrivate ? Icons.lock_outline_rounded : Icons.visibility_outlined,
                                  color: note.isInternalPrivate ? Colors.indigo : AppTheme.primaryTeal,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${note.authorDoctor} (${note.authorSpecialty})',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  Text(
                                    'Recorded on ${note.date}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Private vs Patient-Visible Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: note.isInternalPrivate ? Colors.indigo.withValues(alpha: 0.12) : AppTheme.primaryTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: note.isInternalPrivate ? Colors.indigo.withValues(alpha: 0.3) : AppTheme.primaryTeal.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  note.isInternalPrivate ? Icons.lock_rounded : Icons.public_rounded,
                                  size: 12,
                                  color: note.isInternalPrivate ? Colors.indigo : AppTheme.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  note.isInternalPrivate ? 'Internal (Doctor Only)' : 'Patient Visible',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: note.isInternalPrivate ? Colors.indigo : AppTheme.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 12),

                      Text(
                        note.content,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.45),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
