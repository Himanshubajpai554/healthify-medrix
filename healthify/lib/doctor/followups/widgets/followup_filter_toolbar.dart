import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class FollowUpFilterToolbar extends StatelessWidget {
  final FollowUpStatus? selectedStatus;
  final ValueChanged<FollowUpStatus?> onStatusChanged;
  final String? selectedDepartment;
  final ValueChanged<String?> onDepartmentChanged;
  final List<String> availableDepartments;
  final FollowUpSortOption selectedSort;
  final ValueChanged<FollowUpSortOption> onSortChanged;
  final VoidCallback onResetFilters;

  const FollowUpFilterToolbar({
    super.key,
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
    final isDesktop = screenWidth >= 1024;

    if (!isDesktop) {
      return _buildMobileToolbar(context, isDark);
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Status Chips / Dropdown
          Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<FollowUpStatus?>(
            value: selectedStatus,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...FollowUpStatus.values.map(
                (st) => DropdownMenuItem(
                  value: st,
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: st.color),
                      const SizedBox(width: 8),
                      Text(st.label),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),

          const SizedBox(width: 20),
          const SizedBox(height: 20, child: VerticalDivider(width: 1)),
          const SizedBox(width: 20),

          // Department Dropdown
          Text(
            'Department:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: selectedDepartment,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Departments')),
              ...availableDepartments.map(
                (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
              ),
            ],
            onChanged: onDepartmentChanged,
          ),

          const SizedBox(width: 20),
          const SizedBox(height: 20, child: VerticalDivider(width: 1)),
          const SizedBox(width: 20),

          // Sort Dropdown
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<FollowUpSortOption>(
            value: selectedSort,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            items: const [
              DropdownMenuItem(value: FollowUpSortOption.soonest, child: Text('Soonest Date')),
              DropdownMenuItem(value: FollowUpSortOption.latest, child: Text('Latest Date')),
              DropdownMenuItem(value: FollowUpSortOption.patientName, child: Text('Patient Name')),
            ],
            onChanged: (val) {
              if (val != null) onSortChanged(val);
            },
          ),

          const Spacer(),

          // Reset Filters Button
          TextButton.icon(
            onPressed: onResetFilters,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Reset', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileToolbar(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassSecondaryButton(
          onPressed: () => _openMobileFilterBottomSheet(context, isDark),
          height: 38,
          child: const Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 16),
              SizedBox(width: 6),
              Text('Filter & Sort'),
            ],
          ),
        ),
        if (selectedStatus != null || selectedDepartment != null)
          TextButton(
            onPressed: onResetFilters,
            child: const Text('Clear Filters', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
          ),
      ],
    );
  }

  void _openMobileFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter & Sort Follow-ups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FollowUpStatus?>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...FollowUpStatus.values.map(
                    (st) => DropdownMenuItem(value: st, child: Text(st.label)),
                  ),
                ],
                onChanged: (val) {
                  onStatusChanged(val);
                  Navigator.pop(bContext);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Departments')),
                  ...availableDepartments.map(
                    (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
                  ),
                ],
                onChanged: (val) {
                  onDepartmentChanged(val);
                  Navigator.pop(bContext);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GlassPrimaryButton(
                  onPressed: () => Navigator.pop(bContext),
                  height: 42,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
