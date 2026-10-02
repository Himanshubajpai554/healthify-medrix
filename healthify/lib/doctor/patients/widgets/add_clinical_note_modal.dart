import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AddClinicalNoteModal {
  static void show({
    required BuildContext context,
    required PatientModel patient,
    required VoidCallback onNoteAdded,
  }) {
    ClinicalNoteType noteType = ClinicalNoteType.internalNote;
    final noteController = TextEditingController();

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return StatefulBuilder(
          builder: (context, setState) {
            final isInternal = noteType == ClinicalNoteType.internalNote;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.note_add_rounded,
                        size: 40,
                        iconSize: 20,
                        color: HealthifyGlassTheme.primaryTeal,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Clinical Note',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              'Patient: ${patient.name} (${patient.mrn})',
                              style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Select Note Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChoiceChip('Consultation Note', ClinicalNoteType.consultationNote, noteType, (val) => setState(() => noteType = val)),
                        const SizedBox(width: 6),
                        _buildChoiceChip('Follow-up Note', ClinicalNoteType.followUpNote, noteType, (val) => setState(() => noteType = val)),
                        const SizedBox(width: 6),
                        _buildChoiceChip('Observation', ClinicalNoteType.observation, noteType, (val) => setState(() => noteType = val)),
                        const SizedBox(width: 6),
                        _buildChoiceChip('Internal Note (Private)', ClinicalNoteType.internalNote, noteType, (val) => setState(() => noteType = val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Private / Public Visibility Distinction Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isInternal ? Colors.indigo.withValues(alpha: 0.15) : HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isInternal ? Colors.indigo.withValues(alpha: 0.3) : HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isInternal ? Icons.lock_outline_rounded : Icons.visibility_outlined,
                          size: 16,
                          color: isInternal ? Colors.indigo : HealthifyGlassTheme.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isInternal
                                ? 'PRIVATE NOTE: Visible ONLY to doctors and medical team in Medrix EHR.'
                                : 'PATIENT VISIBLE: Included in patient consultation summary on Patient App.',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isInternal ? Colors.indigo : HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Type clinical findings, patient symptoms, or internal notes...',
                      labelText: 'Clinical Note Details',
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GlassPrimaryButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onNoteAdded();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Clinical note added to ${patient.name}\'s EHR file.'),
                                backgroundColor: HealthifyGlassTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Save Note'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildChoiceChip(String label, ClinicalNoteType value, ClinicalNoteType groupValue, ValueChanged<ClinicalNoteType> onSelected) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: HealthifyGlassTheme.primaryTeal,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      onSelected: (val) {
        if (val) onSelected(value);
      },
    );
  }
}
