import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class ExportAnalyticsModal extends StatefulWidget {
  final AnalyticsDateRange dateRange;
  final Function(String format) onExportConfirmed;

  const ExportAnalyticsModal({
    super.key,
    required this.dateRange,
    required this.onExportConfirmed,
  });

  @override
  State<ExportAnalyticsModal> createState() => _ExportAnalyticsModalState();
}

class _ExportAnalyticsModalState extends State<ExportAnalyticsModal> {
  String _format = 'PDF';
  bool _includeCharts = true;
  bool _includeRecentActivity = true;

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.download_rounded,
                    size: 40,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Analytics Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Period: ${widget.dateRange.dateRangeText}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Export Format', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('PDF Document (.pdf)')),
                      selected: _format == 'PDF',
                      onSelected: (_) => setState(() => _format = 'PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('CSV Data (.csv)')),
                      selected: _format == 'CSV',
                      onSelected: (_) => setState(() => _format = 'CSV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Include chart summaries & distribution', style: TextStyle(fontSize: 13)),
                value: _includeCharts,
                onChanged: (val) => setState(() => _includeCharts = val ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Include recent clinical activity log', style: TextStyle(fontSize: 13)),
                value: _includeRecentActivity,
                onChanged: (val) => setState(() => _includeRecentActivity = val ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassSecondaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    height: 40,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GlassPrimaryButton(
                    onPressed: () {
                      widget.onExportConfirmed(_format);
                      Navigator.of(context).pop();
                    },
                    height: 40,
                    child: Row(
                      children: [
                        const Icon(Icons.file_download_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Export $_format'),
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
  }
}
