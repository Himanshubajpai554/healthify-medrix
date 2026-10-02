import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/reports_models.dart';

enum ReportSortOption {
  newest,
  oldest,
  patientName,
  pendingFirst,
}

extension ReportSortOptionExtension on ReportSortOption {
  String get label {
    switch (this) {
      case ReportSortOption.newest:
        return 'Newest First';
      case ReportSortOption.oldest:
        return 'Oldest First';
      case ReportSortOption.patientName:
        return 'Patient Name';
      case ReportSortOption.pendingFirst:
        return 'Pending First';
    }
  }
}

class ReportsFilterToolbar extends StatelessWidget {
  final ReportCategory selectedCategory;
  final ValueChanged<ReportCategory> onCategoryChanged;
  final ReportStatus? selectedStatus;
  final ValueChanged<ReportStatus?> onStatusChanged;
  final String? selectedDepartment;
  final ValueChanged<String?> onDepartmentChanged;
  final List<String> availableDepartments;
  final ReportSortOption selectedSort;
  final ValueChanged<ReportSortOption> onSortChanged;
  final VoidCallback onResetFilters;

  const ReportsFilterToolbar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.availableDepartments,
    required this.selectedSort,
    required this.onSortChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Category Tabs Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ReportCategory.values.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    showCheckmark: false,
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    label: Text(cat.label),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                    selected: isSelected,
                    selectedColor: HealthifyGlassTheme.primaryTeal,
                    backgroundColor: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (_) => onCategoryChanged(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Filters & Sort Controls
          if (isMobile)
            Row(
              children: [
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: () => _showMobileFilterBottomSheet(context),
                    height: 42,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Filter & Sort', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (selectedStatus != null ||
                    selectedDepartment != null ||
                    selectedCategory != ReportCategory.all) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
                    onPressed: onResetFilters,
                    tooltip: 'Reset Filters',
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                // Status Filter Dropdown
                _buildDropdown<ReportStatus?>(
                  context: context,
                  label: 'Status:',
                  value: selectedStatus,
                  items: [
                    const DropdownMenuItem<ReportStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...ReportStatus.values.map(
                      (s) => DropdownMenuItem<ReportStatus?>(
                        value: s,
                        child: Text(s.label),
                      ),
                    ),
                  ],
                  onChanged: onStatusChanged,
                  isDark: isDark,
                ),
                const SizedBox(width: 14),

                // Department Filter Dropdown
                _buildDropdown<String?>(
                  context: context,
                  label: 'Dept:',
                  value: selectedDepartment,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Departments'),
                    ),
                    ...availableDepartments.map(
                      (d) => DropdownMenuItem<String?>(
                        value: d,
                        child: Text(d),
                      ),
                    ),
                  ],
                  onChanged: onDepartmentChanged,
                  isDark: isDark,
                ),
                const Spacer(),

                // Sort Dropdown
                _buildDropdown<ReportSortOption>(
                  context: context,
                  label: 'Sort By:',
                  value: selectedSort,
                  items: ReportSortOption.values.map(
                    (opt) => DropdownMenuItem<ReportSortOption>(
                      value: opt,
                      child: Text(opt.label),
                    ),
                  ).toList(),
                  onChanged: (val) {
                    if (val != null) onSortChanged(val);
                  },
                  isDark: isDark,
                ),

                if (selectedStatus != null ||
                    selectedDepartment != null ||
                    selectedCategory != ReportCategory.all) ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: onResetFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Reset', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isDense: true,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              dropdownColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileFilterBottomSheet(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setStateModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Status Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Statuses'),
                        selected: selectedStatus == null,
                        onSelected: (_) {
                          onStatusChanged(null);
                          setStateModal(() {});
                        },
                      ),
                      ...ReportStatus.values.map(
                        (st) => ChoiceChip(
                          label: Text(st.label),
                          selected: selectedStatus == st,
                          onSelected: (_) {
                            onStatusChanged(st);
                            setStateModal(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Department Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Departments'),
                        selected: selectedDepartment == null,
                        onSelected: (_) {
                          onDepartmentChanged(null);
                          setStateModal(() {});
                        },
                      ),
                      ...availableDepartments.map(
                        (dept) => ChoiceChip(
                          label: Text(dept),
                          selected: selectedDepartment == dept,
                          onSelected: (_) {
                            onDepartmentChanged(dept);
                            setStateModal(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReportSortOption.values.map(
                      (opt) => ChoiceChip(
                        label: Text(opt.label),
                        selected: selectedSort == opt,
                        onSelected: (_) {
                          onSortChanged(opt);
                          setStateModal(() {});
                        },
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onResetFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Reset All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          onPressed: () => Navigator.pop(context),
                          height: 44,
                          child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
