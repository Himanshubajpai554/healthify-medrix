import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/reports_models.dart';

class AttachReportModal extends StatefulWidget {
  final DoctorReportFullModel report;
  final Function(String consultationId) onAttachConfirmed;

  const AttachReportModal({
    super.key,
    required this.report,
    required this.onAttachConfirmed,
  });

  @override
  State<AttachReportModal> createState() => _AttachReportModalState();
}

class _AttachReportModalState extends State<AttachReportModal> {
  String _selectedConsultationId = 'CON-10029';

  final List<Map<String, String>> _mockConsultations = [
    {
      'id': 'CON-10029',
      'title': 'Cardiology Follow-up & Risk Assessment',
      'date': 'Sep 28, 2026',
      'doctor': 'Dr. Sarah Jenkins',
    },
    {
      'id': 'CON-09941',
      'title': 'General Clinical Evaluation & Routine Checkup',
      'date': 'Sep 20, 2026',
      'doctor': 'Dr. Sarah Jenkins',
    },
    {
      'id': 'CON-09812',
      'title': 'OPD Consultation - Chest & Dyspnea Review',
      'date': 'Aug 14, 2026',
      'doctor': 'Dr. Sarah Jenkins',
    },
  ];

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
                const GlassIconContainer(
                  icon: Icons.link_rounded,
                  size: 40,
                  iconSize: 22,
                  color: HealthifyGlassTheme.primaryTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attach Report to Consultation',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Report: ${widget.report.title} (${widget.report.id})',
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
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Select Target Patient Consultation (${widget.report.patientName}):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockConsultations.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final con = _mockConsultations[idx];
                final isSelected = con['id'] == _selectedConsultationId;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedConsultationId = con['id']!);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1)
                          : (isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getGlassBorder(isDark),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? HealthifyGlassTheme.primaryTeal : HealthifyGlassTheme.getTextSecondary(isDark),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${con['title']} (${con['id']})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Date: ${con['date']} • Doctor: ${con['doctor']}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                GlassPrimaryButton(
                  onPressed: () {
                    widget.onAttachConfirmed(_selectedConsultationId);
                    Navigator.pop(context);
                  },
                  height: 42,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Confirm Attachment', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
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
