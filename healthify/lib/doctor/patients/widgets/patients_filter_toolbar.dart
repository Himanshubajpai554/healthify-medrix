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

  // ═══════════════════════════════════════════════════════════════
  // HEALTHIFY COLORS
  // ═══════════════════════════════════════════════════════════════

  static const Color _primary = Color(0xFF0D9488);

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF172525);
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF647575);
  }

  Color _mutedText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.38)
        : const Color(0xFF8A9999);
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return _glassContainer(
      isDark: isDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return _buildCompactLayout(context, isDark);
          }

          return _buildDesktopLayout(context, isDark);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN GLASS CONTAINER
  // ═══════════════════════════════════════════════════════════════

  Widget _glassContainer({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _primary.withValues(alpha: isDark ? 0.025 : 0.018),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border(isDark)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP / LARGE TABLET
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(context, isDark),

        const SizedBox(height: 13),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildStatusChips(isDark)),

            const SizedBox(width: 12),

            _buildDropdown<String>(
              context: context,
              value: selectedGender,
              hint: 'Gender',
              width: 132,
              items: const [
                DropdownMenuItem(
                  value: 'All Genders',
                  child: Text('All Genders'),
                ),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (value) {
                onGenderChanged(value ?? 'All Genders');
              },
              isDark: isDark,
            ),

            const SizedBox(width: 8),

            _buildDropdown<String>(
              context: context,
              value: selectedDepartment,
              hint: 'Department',
              width: 145,
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
                  value: 'Nephrology',
                  child: Text('Nephrology'),
                ),
                DropdownMenuItem(
                  value: 'Dermatology',
                  child: Text('Dermatology'),
                ),
                DropdownMenuItem(
                  value: 'Emergency & ICU',
                  child: Text('Emergency & ICU'),
                ),
              ],
              onChanged: (value) {
                onDepartmentChanged(value ?? 'All Departments');
              },
              isDark: isDark,
            ),

            if (_hasActiveFilters) ...[
              const SizedBox(width: 8),
              _buildClearButton(isDark),
            ],
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COMPACT / MOBILE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCompactLayout(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(context, isDark),

        const SizedBox(height: 12),

        _buildStatusChips(isDark),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildDropdown<String>(
                context: context,
                value: selectedGender,
                hint: 'Gender',
                width: 132,
                items: const [
                  DropdownMenuItem(
                    value: 'All Genders',
                    child: Text('All Genders'),
                  ),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  onGenderChanged(value ?? 'All Genders');
                },
                isDark: isDark,
              ),

              const SizedBox(width: 8),

              _buildDropdown<String>(
                context: context,
                value: selectedDepartment,
                hint: 'Department',
                width: 145,
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
                    value: 'Nephrology',
                    child: Text('Nephrology'),
                  ),
                  DropdownMenuItem(
                    value: 'Dermatology',
                    child: Text('Dermatology'),
                  ),
                  DropdownMenuItem(
                    value: 'Emergency & ICU',
                    child: Text('Emergency & ICU'),
                  ),
                ],
                onChanged: (value) {
                  onDepartmentChanged(value ?? 'All Departments');
                },
                isDark: isDark,
              ),

              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                _buildClearButton(isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchField(BuildContext context, bool isDark) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.018),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(
          color: _primaryText(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _primary,
        decoration:
            GlassTextFieldTheme.getDecoration(
              context: context,
              hintText: 'Search by patient name, patient ID, phone, MRN...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _primary,
                size: 21,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
            ).copyWith(
              filled: true,
              fillColor: _surfaceStrong(isDark),
              hintStyle: TextStyle(color: _mutedText(isDark), fontSize: 12.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _primary.withValues(alpha: isDark ? 0.55 : 0.45),
                  width: 1.2,
                ),
              ),
            ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATUS CHIPS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            'All Patients',
            selectedCareStatus == null,
            () => onCareStatusChanged(null),
            isDark,
          ),

          const SizedBox(width: 7),

          _buildChip(
            'Active',
            selectedCareStatus == PatientCareStatus.active,
            () => onCareStatusChanged(PatientCareStatus.active),
            isDark,
          ),

          const SizedBox(width: 7),

          _buildChip(
            'New Patients',
            selectedCareStatus == PatientCareStatus.newPatient,
            () => onCareStatusChanged(PatientCareStatus.newPatient),
            isDark,
          ),

          const SizedBox(width: 7),

          _buildChip(
            'Follow-up Due',
            selectedCareStatus == PatientCareStatus.followUpDue,
            () => onCareStatusChanged(PatientCareStatus.followUpDue),
            isDark,
          ),

          const SizedBox(width: 7),

          _buildChip(
            'Admitted',
            selectedCareStatus == PatientCareStatus.admitted,
            () => onCareStatusChanged(PatientCareStatus.admitted),
            isDark,
          ),

          const SizedBox(width: 7),

          _buildChip(
            'Emergency',
            selectedCareStatus == PatientCareStatus.emergency,
            () => onCareStatusChanged(PatientCareStatus.emergency),
            isDark,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CHIP
  // ═══════════════════════════════════════════════════════════════

  Widget _buildChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _primary.withValues(alpha: isDark ? 0.16 : 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: GlassSelectionChip(
        label: label,
        isSelected: isSelected,
        onTap: onTap,
        activeColor: _primary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DROPDOWN
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
    required double width,
  }) {
    return Container(
      width: width,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.018),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF102625) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: _secondaryText(isDark),
          ),
          hint: Text(
            hint,
            style: TextStyle(fontSize: 11.5, color: _mutedText(isDark)),
          ),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _primaryText(isDark),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _primaryText(isDark),
                    ),
                    child: item.child,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CLEAR FILTERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildClearButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClearFilters,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: isDark ? 0.075 : 0.045),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: isDark ? 0.20 : 0.14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.filter_alt_off_rounded,
                size: 16,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 5),
              Text(
                'Clear',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
