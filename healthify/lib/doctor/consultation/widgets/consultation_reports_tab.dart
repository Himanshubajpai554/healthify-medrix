import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';
import '../../models/consultation_models.dart';

class ConsultationReportsTab extends StatelessWidget {
  final List<PatientReportModel> reports;
  final List<ConsultationAttachmentModel> attachments;
  final ValueChanged<String> onToggleAttachReport;

  const ConsultationReportsTab({
    super.key,
    required this.reports,
    required this.attachments,
    required this.onToggleAttachReport,
  });

  void _openReportPreview(BuildContext context, PatientReportModel report) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${report.title} • Reference Preview',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.attachmentUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.black,
                        child: Image.network(
                          report.attachmentUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const Text('Report Parameter Findings:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  Column(
                    children: report.labValues.entries.map((val) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(val.key, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            Text(val.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassSecondaryButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnostic Laboratory & Imaging Reports',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Reference and attach official patient diagnostic records to today\'s consultation',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (reports.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No previous diagnostic reports available.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Column(
            children: reports.map((report) {
              final isAbnormal = report.status.toLowerCase().contains('abnormal') || report.status.toLowerCase().contains('elevated');

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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isAbnormal ? const Color(0xFFEF4444) : AppTheme.primaryTeal).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  report.category == ReportCategory.radiology
                                      ? Icons.camera_rounded
                                      : (report.category == ReportCategory.cardiology ? Icons.monitor_heart_rounded : Icons.science_rounded),
                                  color: isAbnormal ? const Color(0xFFEF4444) : AppTheme.primaryTeal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  Text(
                                    '${report.date} • ${report.labName} • Ordered by ${report.orderingDoctor}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAbnormal ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              report.status,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAbnormal ? const Color(0xFFDC2626) : const Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 12),

                      // Parameter summary
                      Column(
                        children: report.labValues.entries.map((val) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(val.key, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                Text(val.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GlassSecondaryButton(
                            height: 36,
                            onPressed: () => _openReportPreview(context, report),
                            child: const Row(
                              children: [
                                Icon(Icons.remove_red_eye_rounded, size: 14, color: AppTheme.primaryTeal),
                                SizedBox(width: 4),
                                Text('Preview Report', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassPrimaryButton(
                            height: 36,
                            onPressed: () => onToggleAttachReport(report.id),
                            child: const Row(
                              children: [
                                Icon(Icons.attach_file_rounded, size: 14),
                                SizedBox(width: 4),
                                Text('Attach to Consultation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
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
