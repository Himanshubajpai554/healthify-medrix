import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class ReportsHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onUploadPressed;
  final VoidCallback onRefreshPressed;

  const ReportsHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onUploadPressed,
    required this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 768;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const GlassIconContainer(
                icon: Icons.assignment_rounded,
                size: 48,
                iconSize: 26,
                color: HealthifyGlassTheme.primaryTeal,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: isCompact ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Review and manage patient medical diagnostic reports & imaging.',
                      style: TextStyle(
                        fontSize: 13,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                GlassSecondaryButton(
                  onPressed: onRefreshPressed,
                  height: 42,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Refresh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GlassPrimaryButton(
                  onPressed: onUploadPressed,
                  height: 42,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Upload Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: onRefreshPressed,
                    height: 42,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Refresh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassPrimaryButton(
                    onPressed: onUploadPressed,
                    height: 42,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Upload Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Search Input
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: searchQuery,
                        selection: TextSelection.collapsed(offset: searchQuery.length),
                      ),
                    ),
                    onChanged: onSearchChanged,
                    style: TextStyle(
                      fontSize: 14,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by patient name, patient ID, report title, or ID (e.g. REP-2026...)...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    onPressed: onClearSearch,
                    tooltip: 'Clear Search',
                  ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
