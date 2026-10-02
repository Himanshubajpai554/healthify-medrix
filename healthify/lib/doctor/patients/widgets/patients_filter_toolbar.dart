import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientsFilterToolbar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final PatientCareStatus? selectedCareStatus;
  final ValueChanged<PatientCareStatus?> onCareStatusChanged;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final String selectedDepartment;
  final ValueChanged<String> onDepartmentChanged;
  final VoidCallback onClearFilters;

  const PatientsFilterToolbar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCareStatus,
    required this.onCareStatusChanged,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
    required this.onClearFilters,
  });

  bool get _hasActiveFilters {
    return searchQuery.isNotEmpty ||
        selectedCareStatus != null ||
        selectedGender != 'All Genders' ||
        selectedDepartment != 'All Departments';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Prominent Search Input
          SizedBox(
            height: 44,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: GlassTextFieldTheme.getDecoration(
                context: context,
                hintText: 'Search by patient name, patient ID, phone, MRN...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Row 2: Status Quick Chips & Dropdown Filters
          Row(
            children: [
              // Quick Filter Chips (Horizontal Scroll)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('All Patients', selectedCareStatus == null, () => onCareStatusChanged(null), isDark),
                      const SizedBox(width: 6),
                      _buildChip('Active', selectedCareStatus == PatientCareStatus.active, () => onCareStatusChanged(PatientCareStatus.active), isDark),
                      const SizedBox(width: 6),
                      _buildChip('New Patients', selectedCareStatus == PatientCareStatus.newPatient, () => onCareStatusChanged(PatientCareStatus.newPatient), isDark),
                      const SizedBox(width: 6),
                      _buildChip('Follow-up Due', selectedCareStatus == PatientCareStatus.followUpDue, () => onCareStatusChanged(PatientCareStatus.followUpDue), isDark),
                      const SizedBox(width: 6),
                      _buildChip('Admitted', selectedCareStatus == PatientCareStatus.admitted, () => onCareStatusChanged(PatientCareStatus.admitted), isDark),
                      const SizedBox(width: 6),
                      _buildChip('Emergency', selectedCareStatus == PatientCareStatus.emergency, () => onCareStatusChanged(PatientCareStatus.emergency), isDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Additional Dropdown 1: Gender
              SizedBox(
                width: 130,
                child: _buildDropdown<String>(
                  context: context,
                  value: selectedGender,
                  hint: 'Gender',
                  items: const [
                    DropdownMenuItem(value: 'All Genders', child: Text('All Genders')),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (val) => onGenderChanged(val ?? 'All Genders'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),

              // Additional Dropdown 2: Department
              SizedBox(
                width: 140,
                child: _buildDropdown<String>(
                  context: context,
                  value: selectedDepartment,
                  hint: 'Department',
                  items: const [
                    DropdownMenuItem(value: 'All Departments', child: Text('All Depts')),
                    DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
                    DropdownMenuItem(value: 'General Medicine', child: Text('General Med')),
                    DropdownMenuItem(value: 'Nephrology', child: Text('Nephrology')),
                    DropdownMenuItem(value: 'Dermatology', child: Text('Dermatology')),
                    DropdownMenuItem(value: 'Emergency & ICU', child: Text('Emergency & ICU')),
                  ],
                  onChanged: (val) => onDepartmentChanged(val ?? 'All Departments'),
                  isDark: isDark,
                ),
              ),

              // Clear Filters Button
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      activeColor: HealthifyGlassTheme.primaryTeal,
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextMuted(isDark))),
          isExpanded: true,
          style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
