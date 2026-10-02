import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentsFilterToolbar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final AppointmentStatus? selectedStatus;
  final ValueChanged<AppointmentStatus?> onStatusChanged;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final String selectedDepartment;
  final ValueChanged<String> onDepartmentChanged;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onClearFilters;

  const AppointmentsFilterToolbar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.selectedMode,
    required this.onModeChanged,
    required this.onClearFilters,
  });

  bool get _hasActiveFilters {
    return searchQuery.isNotEmpty ||
        selectedStatus != null ||
        selectedType != 'All Types' ||
        selectedDepartment != 'All Departments' ||
        selectedMode != 'All Modes';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'Search patient, MRN, phone...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Status Dropdown
              Expanded(
                child: _buildDropdown<AppointmentStatus?>(
                  context: context,
                  value: selectedStatus,
                  hint: 'Status',
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: AppointmentStatus.upcoming, child: Text('Upcoming')),
                    DropdownMenuItem(value: AppointmentStatus.checkedIn, child: Text('Checked In')),
                    DropdownMenuItem(value: AppointmentStatus.waiting, child: Text('Waiting')),
                    DropdownMenuItem(value: AppointmentStatus.inConsultation, child: Text('In Consultation')),
                    DropdownMenuItem(value: AppointmentStatus.completed, child: Text('Completed')),
                    DropdownMenuItem(value: AppointmentStatus.cancelled, child: Text('Cancelled')),
                    DropdownMenuItem(value: AppointmentStatus.noShow, child: Text('No Show')),
                  ],
                  onChanged: onStatusChanged,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),

              // Type Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  context: context,
                  value: selectedType,
                  hint: 'Type',
                  items: const [
                    DropdownMenuItem(value: 'All Types', child: Text('All Types')),
                    DropdownMenuItem(value: 'New Patient', child: Text('New Patient')),
                    DropdownMenuItem(value: 'Follow-up', child: Text('Follow-up')),
                    DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                    DropdownMenuItem(value: 'Consultation', child: Text('Consultation')),
                    DropdownMenuItem(value: 'Teleconsultation', child: Text('Teleconsultation')),
                  ],
                  onChanged: (val) => onTypeChanged(val ?? 'All Types'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),

              // Department Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  context: context,
                  value: selectedDepartment,
                  hint: 'Department',
                  items: const [
                    DropdownMenuItem(value: 'All Departments', child: Text('All Depts')),
                    DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
                    DropdownMenuItem(value: 'General Medicine', child: Text('General Med')),
                    DropdownMenuItem(value: 'Orthopedics', child: Text('Orthopedics')),
                    DropdownMenuItem(value: 'Dermatology', child: Text('Dermatology')),
                    DropdownMenuItem(value: 'Pediatrics', child: Text('Pediatrics')),
                  ],
                  onChanged: (val) => onDepartmentChanged(val ?? 'All Departments'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),

              // Clear Filters Button
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextMuted(isDark))),
          isExpanded: true,
          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
