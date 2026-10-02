import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class EmergencyFilterToolbar extends StatelessWidget {
  final EmergencyCaseStatus? selectedStatus;
  final ValueChanged<EmergencyCaseStatus?> onStatusChanged;
  final EmergencyOperationalPriority? selectedPriority;
  final ValueChanged<EmergencyOperationalPriority?> onPriorityChanged;
  final String? selectedDepartment;
  final ValueChanged<String?> onDepartmentChanged;
  final List<String> availableDepartments;
  final String? selectedDoctor;
  final ValueChanged<String?> onDoctorChanged;
  final List<String> availableDoctors;
  final VoidCallback onResetFilters;

  const EmergencyFilterToolbar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.availableDepartments,
    required this.selectedDoctor,
    required this.onDoctorChanged,
    required this.availableDoctors,
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
          // Status Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    showCheckmark: false,
                    label: const Text('All Statuses'),
                    selected: selectedStatus == null,
                    selectedColor: HealthifyGlassTheme.primaryTeal,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: selectedStatus == null ? FontWeight.bold : FontWeight.w500,
                      color: selectedStatus == null ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                    backgroundColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.08),
                    onSelected: (_) => onStatusChanged(null),
                  ),
                ),
                ...EmergencyCaseStatus.values.map((st) {
                  final isSelected = selectedStatus == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(st.label),
                      selected: isSelected,
                      selectedColor: st.color,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      backgroundColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.08),
                      onSelected: (_) => onStatusChanged(st),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Priority & Department Filter Row
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
                        Text('Filter Cases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (selectedStatus != null || selectedPriority != null || selectedDepartment != null || selectedDoctor != null) ...[
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
                // Priority Filter Dropdown
                _buildDropdown<EmergencyOperationalPriority?>(
                  context: context,
                  label: 'Priority:',
                  value: selectedPriority,
                  items: [
                    const DropdownMenuItem<EmergencyOperationalPriority?>(
                      value: null,
                      child: Text('All Priorities'),
                    ),
                    ...EmergencyOperationalPriority.values.map(
                      (p) => DropdownMenuItem<EmergencyOperationalPriority?>(
                        value: p,
                        child: Text(p.label),
                      ),
                    ),
                  ],
                  onChanged: onPriorityChanged,
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
                const SizedBox(width: 14),

                // Doctor Filter Dropdown
                _buildDropdown<String?>(
                  context: context,
                  label: 'Doctor:',
                  value: selectedDoctor,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Doctors'),
                    ),
                    ...availableDoctors.map(
                      (doc) => DropdownMenuItem<String?>(
                        value: doc,
                        child: Text(doc),
                      ),
                    ),
                  ],
                  onChanged: onDoctorChanged,
                  isDark: isDark,
                ),
                const Spacer(),

                if (selectedStatus != null || selectedPriority != null || selectedDepartment != null || selectedDoctor != null) ...[
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
                        'Filter Emergency Cases',
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
                  const Text('Priority Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All Priorities'),
                        selected: selectedPriority == null,
                        onSelected: (_) {
                          onPriorityChanged(null);
                          setStateModal(() {});
                        },
                      ),
                      ...EmergencyOperationalPriority.values.map(
                        (p) => ChoiceChip(
                          label: Text(p.label),
                          selected: selectedPriority == p,
                          onSelected: (_) {
                            onPriorityChanged(p);
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
