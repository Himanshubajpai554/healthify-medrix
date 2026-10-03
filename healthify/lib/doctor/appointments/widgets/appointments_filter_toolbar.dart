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

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);
  static const Color _danger = Color(0xFFEF4444);

  bool get _hasActiveFilters {
    return searchQuery.isNotEmpty ||
        selectedStatus != null ||
        selectedType != 'All Types' ||
        selectedDepartment != 'All Departments' ||
        selectedMode != 'All Modes';
  }

  Color _primaryColor(bool isDark) {
    return isDark ? _primaryDark : _primary;
  }

  Color _textPrimary(bool isDark) {
    return isDark ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark);
  }

  Color _textMuted(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.38)
        : HealthifyGlassTheme.getTextMuted(isDark);
  }

  Color _glassFill(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.70);
  }

  Color _glassBorder(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 850;

          if (isCompact) {
            return _buildCompactLayout(context, isDark);
          }

          return _buildDesktopLayout(context, isDark);
        },
      ),
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            // Search
            Expanded(flex: 2, child: _buildSearchField(context, isDark)),

            const SizedBox(width: 10),

            // Status
            Expanded(
              child: _buildDropdown<AppointmentStatus?>(
                context: context,
                value: selectedStatus,
                hint: 'Status',
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(
                    value: AppointmentStatus.upcoming,
                    child: Text('Upcoming'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.checkedIn,
                    child: Text('Checked In'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.waiting,
                    child: Text('Waiting'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.inConsultation,
                    child: Text('In Consultation'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.completed,
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.cancelled,
                    child: Text('Cancelled'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.noShow,
                    child: Text('No Show'),
                  ),
                ],
                onChanged: onStatusChanged,
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 10),

            // Type
            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedType,
                hint: 'Type',
                items: const [
                  DropdownMenuItem(
                    value: 'All Types',
                    child: Text('All Types'),
                  ),
                  DropdownMenuItem(
                    value: 'New Patient',
                    child: Text('New Patient'),
                  ),
                  DropdownMenuItem(
                    value: 'Follow-up',
                    child: Text('Follow-up'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency',
                    child: Text('Emergency'),
                  ),
                  DropdownMenuItem(
                    value: 'Consultation',
                    child: Text('Consultation'),
                  ),
                  DropdownMenuItem(
                    value: 'Teleconsultation',
                    child: Text('Teleconsultation'),
                  ),
                ],
                onChanged: (value) {
                  onTypeChanged(value ?? 'All Types');
                },
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 10),

            // Department
            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedDepartment,
                hint: 'Department',
                items: const [
                  DropdownMenuItem(
                    value: 'All Departments',
                    child: Text('All Depts'),
                  ),
                  DropdownMenuItem(
                    value: 'Cardiology',
                    child: Text('Cardiology'),
                  ),
                  DropdownMenuItem(
                    value: 'General Medicine',
                    child: Text('General Med'),
                  ),
                  DropdownMenuItem(
                    value: 'Orthopedics',
                    child: Text('Orthopedics'),
                  ),
                  DropdownMenuItem(
                    value: 'Dermatology',
                    child: Text('Dermatology'),
                  ),
                  DropdownMenuItem(
                    value: 'Pediatrics',
                    child: Text('Pediatrics'),
                  ),
                ],
                onChanged: (value) {
                  onDepartmentChanged(value ?? 'All Departments');
                },
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 10),

            // Mode
            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedMode,
                hint: 'Mode',
                items: const [
                  DropdownMenuItem(
                    value: 'All Modes',
                    child: Text('All Modes'),
                  ),
                  DropdownMenuItem(
                    value: 'In-Person',
                    child: Text('In-Person'),
                  ),
                  DropdownMenuItem(value: 'Video', child: Text('Video')),
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                ],
                onChanged: (value) {
                  onModeChanged(value ?? 'All Modes');
                },
                isDark: isDark,
              ),
            ),

            if (_hasActiveFilters) ...[
              const SizedBox(width: 8),
              _buildClearButton(isDark: isDark),
            ],
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // COMPACT
  // ==========================================================================

  Widget _buildCompactLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search
        _buildSearchField(context, isDark),

        const SizedBox(height: 10),

        // First row
        Row(
          children: [
            Expanded(
              child: _buildDropdown<AppointmentStatus?>(
                context: context,
                value: selectedStatus,
                hint: 'Status',
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(
                    value: AppointmentStatus.upcoming,
                    child: Text('Upcoming'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.checkedIn,
                    child: Text('Checked In'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.waiting,
                    child: Text('Waiting'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.inConsultation,
                    child: Text('In Consultation'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.completed,
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.cancelled,
                    child: Text('Cancelled'),
                  ),
                  DropdownMenuItem(
                    value: AppointmentStatus.noShow,
                    child: Text('No Show'),
                  ),
                ],
                onChanged: onStatusChanged,
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedType,
                hint: 'Type',
                items: const [
                  DropdownMenuItem(
                    value: 'All Types',
                    child: Text('All Types'),
                  ),
                  DropdownMenuItem(
                    value: 'New Patient',
                    child: Text('New Patient'),
                  ),
                  DropdownMenuItem(
                    value: 'Follow-up',
                    child: Text('Follow-up'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency',
                    child: Text('Emergency'),
                  ),
                  DropdownMenuItem(
                    value: 'Consultation',
                    child: Text('Consultation'),
                  ),
                  DropdownMenuItem(
                    value: 'Teleconsultation',
                    child: Text('Teleconsultation'),
                  ),
                ],
                onChanged: (value) {
                  onTypeChanged(value ?? 'All Types');
                },
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Second row
        Row(
          children: [
            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedDepartment,
                hint: 'Department',
                items: const [
                  DropdownMenuItem(
                    value: 'All Departments',
                    child: Text('All Depts'),
                  ),
                  DropdownMenuItem(
                    value: 'Cardiology',
                    child: Text('Cardiology'),
                  ),
                  DropdownMenuItem(
                    value: 'General Medicine',
                    child: Text('General Med'),
                  ),
                  DropdownMenuItem(
                    value: 'Orthopedics',
                    child: Text('Orthopedics'),
                  ),
                  DropdownMenuItem(
                    value: 'Dermatology',
                    child: Text('Dermatology'),
                  ),
                  DropdownMenuItem(
                    value: 'Pediatrics',
                    child: Text('Pediatrics'),
                  ),
                ],
                onChanged: (value) {
                  onDepartmentChanged(value ?? 'All Departments');
                },
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _buildDropdown<String>(
                context: context,
                value: selectedMode,
                hint: 'Mode',
                items: const [
                  DropdownMenuItem(
                    value: 'All Modes',
                    child: Text('All Modes'),
                  ),
                  DropdownMenuItem(
                    value: 'In-Person',
                    child: Text('In-Person'),
                  ),
                  DropdownMenuItem(value: 'Video', child: Text('Video')),
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                ],
                onChanged: (value) {
                  onModeChanged(value ?? 'All Modes');
                },
                isDark: isDark,
              ),
            ),
          ],
        ),

        if (_hasActiveFilters) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _buildClearButton(isDark: isDark),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // SEARCH FIELD
  // ==========================================================================

  Widget _buildSearchField(BuildContext context, bool isDark) {
    final primary = _primaryColor(isDark);

    return SizedBox(
      height: 42,
      child: TextField(
        onChanged: onSearchChanged,
        controller: TextEditingController(text: searchQuery)
          ..selection = TextSelection.collapsed(offset: searchQuery.length),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: _textPrimary(isDark),
        ),
        decoration: GlassTextFieldTheme.getDecoration(
          context: context,
          hintText: 'Search patient, MRN, phone...',
          prefixIcon: Icon(Icons.search_rounded, size: 19, color: primary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DROPDOWN
  // ==========================================================================

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
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: _glassFill(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _glassBorder(isDark), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textMuted(isDark),
            ),
          ),
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: _textMuted(isDark),
          ),
          dropdownColor: isDark
              ? const Color(0xFF102522)
              : const Color(0xFFF8FCFB),
          borderRadius: BorderRadius.circular(14),
          elevation: 8,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary(isDark),
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary(isDark),
                  ),
                  child: item.child,
                ),
              );
            }).toList();
          },
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary(isDark),
                ),
                child: item.child,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ==========================================================================
  // CLEAR FILTERS
  // ==========================================================================

  Widget _buildClearButton({required bool isDark}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClearFilters,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: _danger.withValues(alpha: isDark ? 0.08 : 0.055),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _danger.withValues(alpha: isDark ? 0.18 : 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt_off_rounded, size: 16, color: _danger),
              const SizedBox(width: 5),
              Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
