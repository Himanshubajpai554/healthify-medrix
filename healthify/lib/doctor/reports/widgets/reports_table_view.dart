import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/reports_models.dart';

class ReportsTableView extends StatelessWidget {
  final List<DoctorReportFullModel> reports;
  final ValueChanged<DoctorReportFullModel> onSelectReport;
  final ValueChanged<DoctorReportFullModel> onAttachReport;
  final String? selectedReportId;

  const ReportsTableView({
    super.key,
    required this.reports,
    required this.onSelectReport,
    required this.onAttachReport,
    this.selectedReportId,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    if (reports.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.find_in_page_rounded,
                size: 56,
                color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Medical Reports Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria, category tab, or filter parameters.',
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reports.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = reports[index];
          final isSelected = report.id == selectedReportId;
          return _buildMobileReportCard(context, report, isSelected, isDark);
        },
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: screenWidth - 320),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.08),
              ),
              horizontalMargin: 20,
              columnSpacing: 24,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 74,
              columns: const [
                DataColumn(label: Text('REPORT DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('PATIENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('CATEGORY & MODALITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('DATE UPLOADED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
              ],
              rows: reports.map((report) {
                final isSelected = report.id == selectedReportId;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (_) => onSelectReport(report),
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (isSelected) {
                      return HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1);
                    }
                    return null;
                  }),
                  cells: [
                    // Report details
                    DataCell(
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              report.modality.icon,
                              size: 20,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                report.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                report.id,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Patient
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            report.patientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${report.patientId} • ${report.patientAge}y/${report.patientGender[0]}',
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category & Modality
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            report.category.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.modality.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Department
                    DataCell(
                      Text(
                        report.department,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Date
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formatDate(report.uploadedDate),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            formatTime(report.uploadedDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    DataCell(
                      _buildStatusBadge(report.status, isDark),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassSecondaryButton(
                            onPressed: () => onSelectReport(report),
                            height: 36,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  report.status == ReportStatus.pendingReview
                                      ? Icons.rate_review_rounded
                                      : Icons.visibility_rounded,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  report.status == ReportStatus.pendingReview ? 'Review' : 'View',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.link_rounded,
                              size: 18,
                              color: report.attachedConsultationId != null
                                  ? HealthifyGlassTheme.primaryTeal
                                  : HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                            tooltip: report.attachedConsultationId != null
                                ? 'Attached to consultation'
                                : 'Attach to consultation',
                            onPressed: () => onAttachReport(report),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileReportCard(
    BuildContext context,
    DoctorReportFullModel report,
    bool isSelected,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: HealthifyGlassTheme.primaryTeal, width: 2)
            : null,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    report.modality.icon,
                    size: 22,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${report.id} • ${report.department}',
                        style: TextStyle(
                          fontSize: 11,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(report.status, isDark),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 16, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    const SizedBox(width: 6),
                    Text(
                      '${report.patientName} (${report.patientAge}y/${report.patientGender[0]})',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
                Text(
                  formatDate(report.uploadedDate),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
            if (report.summaryAiText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  report.summaryAiText,
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: () => onSelectReport(report),
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          report.status == ReportStatus.pendingReview
                              ? Icons.rate_review_rounded
                              : Icons.visibility_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          report.status == ReportStatus.pendingReview ? 'Review Report' : 'View Report',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.link_rounded,
                    color: report.attachedConsultationId != null
                        ? HealthifyGlassTheme.primaryTeal
                        : HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  onPressed: () => onAttachReport(report),
                  tooltip: 'Attach to Consultation',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status, bool isDark) {
    Color bg;
    Color fg;
    switch (status) {
      case ReportStatus.newReport:
        bg = Colors.indigo.withValues(alpha: isDark ? 0.25 : 0.12);
        fg = isDark ? Colors.indigo.shade200 : Colors.indigo.shade700;
        break;
      case ReportStatus.pendingReview:
        bg = Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15);
        fg = isDark ? Colors.amber.shade300 : Colors.amber.shade800;
        break;
      case ReportStatus.reviewed:
        bg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.15);
        fg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
        break;
      case ReportStatus.archived:
        bg = Colors.grey.withValues(alpha: isDark ? 0.25 : 0.12);
        fg = HealthifyGlassTheme.getTextSecondary(isDark);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
