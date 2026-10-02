import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class PendingReportsWidget extends StatelessWidget {
  final List<PendingReportModel> reports;
  final ValueChanged<PendingReportModel> onReviewReport;

  const PendingReportsWidget({
    super.key,
    required this.reports,
    required this.onReviewReport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.assignment_late_rounded,
                    size: 38,
                    iconSize: 20,
                    color: Colors.amber,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports Requiring Review',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Laboratory & Radiology results awaiting clinical sign-off',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${reports.where((r) => !r.isReviewed).length} Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Report List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportItem(context, report, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    PendingReportModel report,
    bool isDark,
  ) {
    final patient = report.patient;
    final isUrgent = report.priority == ReportPriority.urgent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? Colors.amber.shade700.withValues(alpha: 0.5)
              : HealthifyGlassTheme.getGlassBorder(isDark),
          width: isUrgent ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isUrgent ? Colors.amber : HealthifyGlassTheme.primaryTeal)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              report.reportType.contains('X-Ray') || report.reportType.contains('ECG')
                  ? Icons.monitor_heart_rounded
                  : Icons.science_rounded,
              color: isUrgent ? Colors.amber.shade800 : HealthifyGlassTheme.primaryTeal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Patient & Report details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      report.reportType,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Patient: ${patient.name} (${patient.mrn}) • ${report.date}',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          GlassPrimaryButton(
            height: 38,
            onPressed: () => onReviewReport(report),
            color: report.isReviewed
                ? const Color(0xFF10B981)
                : HealthifyGlassTheme.primaryTeal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  report.isReviewed
                      ? Icons.check_circle_rounded
                      : Icons.rate_review_rounded,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  report.isReviewed ? 'Reviewed' : 'Review Report',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
