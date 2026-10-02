import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class DepartmentDistributionSection extends StatelessWidget {
  final DepartmentDistributionModel departmentDistribution;

  const DepartmentDistributionSection({
    super.key,
    required this.departmentDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final shares = departmentDistribution.shares;

    final colors = [
      const Color(0xFF0D9488), // Teal
      const Color(0xFF3B82F6), // Blue
      Colors.redAccent,       // Emergency / Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFD97706), // Amber
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Department & Service Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            'Personal encounter distribution across clinical services',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Stacked Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: List.generate(shares.length, (index) {
                  final item = shares[index];
                  final color = colors[index % colors.length];

                  return Expanded(
                    flex: item.percentage.round(),
                    child: Container(color: color),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of breakdown shares
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shares.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = shares[index];
              final color = colors[index % colors.length];

              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.department,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item.count} visits',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${item.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
