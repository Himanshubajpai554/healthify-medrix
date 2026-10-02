import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class EmergencyHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onNewEmergencyPressed;
  final VoidCallback onRefreshPressed;
  final String lastUpdatedText;

  const EmergencyHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onNewEmergencyPressed,
    required this.onRefreshPressed,
    this.lastUpdatedText = 'Just now',
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  size: 26,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Emergency Cases',
                          style: TextStyle(
                            fontSize: isCompact ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Live Update Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE • $lastUpdatedText',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monitor and manage active emergency cases in real time.',
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
                  onPressed: onNewEmergencyPressed,
                  height: 42,
                  color: Colors.redAccent,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_alert_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('New Emergency Case', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Refresh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassPrimaryButton(
                    onPressed: onNewEmergencyPressed,
                    height: 42,
                    color: Colors.redAccent,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_alert_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('New Emergency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Search Bar
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
                      hintText: 'Search emergency cases by patient name, patient ID, case ID, phone number...',
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
