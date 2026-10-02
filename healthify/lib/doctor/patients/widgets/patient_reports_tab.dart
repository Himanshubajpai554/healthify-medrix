import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';

class PatientReportsTab extends StatefulWidget {
  final List<PatientReportModel> reports;

  const PatientReportsTab({
    super.key,
    required this.reports,
  });

  @override
  State<PatientReportsTab> createState() => _PatientReportsTabState();
}

class _PatientReportsTabState extends State<PatientReportsTab> {
  ReportCategory _selectedCategory = ReportCategory.all;

  void _openReportAttachmentModal(BuildContext context, PatientReportModel report) {
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
                      Expanded(
                        child: Text(
                          '${report.title} • ${report.attachmentType ?? "Scan View"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (report.attachmentUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 320,
                        width: double.infinity,
                        color: Colors.black,
                        child: Image.network(
                          report.attachmentUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded, size: 48, color: Colors.white54),
                                  SizedBox(height: 8),
                                  Text('Scan Image Preview Not Available', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (report.clinicalNotes != null) ...[
                    const Text('Radiologist / Pathologist Remarks:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text(report.clinicalNotes!, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassSecondaryButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close Viewer'),
                      ),
                      const SizedBox(width: 10),
                      GlassPrimaryButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading original diagnostic report PDF...')),
                          );
                          Navigator.pop(context);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.download_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Download Full PDF'),
                          ],
                        ),
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
    final filteredReports = widget.reports.where((r) {
      if (_selectedCategory == ReportCategory.all) return true;
      return r.category == _selectedCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Reports', ReportCategory.all),
              const SizedBox(width: 8),
              _buildFilterChip('Laboratory', ReportCategory.laboratory),
              const SizedBox(width: 8),
              _buildFilterChip('Radiology', ReportCategory.radiology),
              const SizedBox(width: 8),
              _buildFilterChip('Pathology', ReportCategory.pathology),
              const SizedBox(width: 8),
              _buildFilterChip('Cardiology', ReportCategory.cardiology),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (filteredReports.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No diagnostic reports found under this category.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Column(
            children: filteredReports.map((report) {
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
                          Expanded(
                            child: Row(
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      ),
                                      Text(
                                        'Ordered by ${report.orderingDoctor} • ${report.labName} • ${report.date}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAbnormal ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              report.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isAbnormal ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 14),

                      // Lab Values Grid / Preview
                      const Text('Report Test Parameters & Findings:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                      const SizedBox(height: 8),
                      Column(
                        children: report.labValues.entries.map((val) {
                          final isHighValue = val.value.toLowerCase().contains('high') || val.value.toLowerCase().contains('elevated');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(val.key, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                Text(
                                  val.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isHighValue ? const Color(0xFFDC2626) : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 14),

                      // Bottom Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (report.attachmentUrl != null) ...[
                            GlassSecondaryButton(
                              onPressed: () => _openReportAttachmentModal(context, report),
                              child: const Row(
                                children: [
                                  Icon(Icons.remove_red_eye_rounded, size: 14, color: AppTheme.primaryTeal),
                                  SizedBox(width: 4),
                                  Text('View Scan / Image', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          GlassSecondaryButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloading report PDF...')),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.download_rounded, size: 14, color: AppTheme.textPrimary),
                                SizedBox(width: 4),
                                Text('Download PDF', style: TextStyle(fontSize: 12)),
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

  Widget _buildFilterChip(String label, ReportCategory category) {
    final isSelected = _selectedCategory == category;

    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }
}
