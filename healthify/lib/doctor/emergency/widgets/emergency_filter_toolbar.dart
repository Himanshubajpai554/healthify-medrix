import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';
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

  // ---------------------------------------------------------------------------
  // HEALTHIFY THEME
  // ---------------------------------------------------------------------------

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? const Color(0xFF0D9488).withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : AppTheme.textPrimary;
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 768;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 12 : 13,
              ),
              decoration: BoxDecoration(
                color: _surface(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.08 : 0.025,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusFilters(context, isDark, isMobile),

                  const SizedBox(height: 12),

                  Container(height: 1, color: _border(isDark)),

                  const SizedBox(height: 11),

                  if (isMobile)
                    _buildMobileControls(context, isDark)
                  else
                    _buildDesktopControls(context, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS CHIPS
  // ---------------------------------------------------------------------------

  Widget _buildStatusFilters(BuildContext context, bool isDark, bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatusChip(
            label: 'All Statuses',
            color: _primary,
            selected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
            isDark: isDark,
          ),

          ...EmergencyCaseStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildStatusChip(
                label: status.label,
                color: status.color,
                selected: selectedStatus == status,
                onTap: () => onStatusChanged(status),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),

            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      Color.lerp(color, Colors.black, 0.15) ?? color,
                    ],
                  )
                : null,

            color: selected ? null : _surfaceStrong(isDark),

            border: Border.all(
              color: selected ? color.withValues(alpha: 0.75) : _border(isDark),
              width: selected ? 1.1 : 1,
            ),

            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.035 : 0.015,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),

              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : _primaryText(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildDesktopControls(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildDropdown<EmergencyOperationalPriority?>(
            context: context,
            label: 'Priority',
            icon: Icons.priority_high_rounded,
            value: selectedPriority,
            items: [
              const DropdownMenuItem<EmergencyOperationalPriority?>(
                value: null,
                child: Text('All Priorities'),
              ),
              ...EmergencyOperationalPriority.values.map(
                (priority) => DropdownMenuItem<EmergencyOperationalPriority?>(
                  value: priority,
                  child: Text(priority.label),
                ),
              ),
            ],
            onChanged: onPriorityChanged,
            isDark: isDark,
          ),

          const SizedBox(width: 10),

          _buildDropdown<String?>(
            context: context,
            label: 'Department',
            icon: Icons.local_hospital_rounded,
            value: selectedDepartment,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Departments'),
              ),
              ...availableDepartments.map(
                (department) => DropdownMenuItem<String?>(
                  value: department,
                  child: Text(department),
                ),
              ),
            ],
            onChanged: onDepartmentChanged,
            isDark: isDark,
          ),

          const SizedBox(width: 10),

          _buildDropdown<String?>(
            context: context,
            label: 'Doctor',
            icon: Icons.person_rounded,
            value: selectedDoctor,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Doctors'),
              ),
              ...availableDoctors.map(
                (doctor) => DropdownMenuItem<String?>(
                  value: doctor,
                  child: Text(doctor),
                ),
              ),
            ],
            onChanged: onDoctorChanged,
            isDark: isDark,
          ),

          const SizedBox(width: 12),

          if (_hasActiveFilters) _buildResetButton(isDark),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DROPDOWN
  // ---------------------------------------------------------------------------

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.only(left: 11),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.035 : 0.018),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _primary),

          const SizedBox(width: 6),

          Text(
            '$label:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _secondaryText(isDark),
            ),
          ),

          const SizedBox(width: 4),

          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isDense: true,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: isDark ? const Color(0xFF13202A) : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: _secondaryText(isDark),
              ),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _primaryText(isDark),
              ),
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE CONTROLS
  // ---------------------------------------------------------------------------

  Widget _buildMobileControls(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterButton(
            isDark: isDark,
            onPressed: () => _showMobileFilterBottomSheet(context),
          ),
        ),

        if (_hasActiveFilters) ...[
          const SizedBox(width: 8),

          _buildResetIconButton(isDark),
        ],
      ],
    );
  }

  Widget _buildFilterButton({
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 43,
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tune_rounded, size: 18, color: _primary),
              const SizedBox(width: 7),
              Text(
                'Filter Cases',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _primaryText(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetIconButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onResetFilters,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.055),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: isDark ? 0.18 : 0.13),
            ),
          ),
          child: const Icon(
            Icons.filter_alt_off_rounded,
            size: 18,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onResetFilters,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.055),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.redAccent.withValues(alpha: isDark ? 0.18 : 0.13),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_off_rounded,
                size: 15,
                color: Colors.redAccent,
              ),
              SizedBox(width: 5),
              Text(
                'Reset',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIVE FILTER CHECK
  // ---------------------------------------------------------------------------

  bool get _hasActiveFilters {
    return selectedStatus != null ||
        selectedPriority != null ||
        selectedDepartment != null ||
        selectedDoctor != null;
  }

  // ---------------------------------------------------------------------------
  // MOBILE FILTER SHEET
  // ---------------------------------------------------------------------------

  void _showMobileFilterBottomSheet(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) {
        return SafeArea(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D171D).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  border: Border.all(color: _border(isDark)),
                ),
                child: StatefulBuilder(
                  builder: (context, setSheetState) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // -------------------------------------------------
                          // HANDLE
                          // -------------------------------------------------
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _secondaryText(
                                  isDark,
                                ).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // -------------------------------------------------
                          // HEADER
                          // -------------------------------------------------
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _primary.withValues(
                                    alpha: isDark ? 0.12 : 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: _primary.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: _primary,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Filter Emergency Cases',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryText(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Refine cases by priority, department or doctor.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: _secondaryText(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded),
                                color: _secondaryText(isDark),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // -------------------------------------------------
                          // PRIORITY
                          // -------------------------------------------------
                          _buildMobileSectionTitle(
                            'Priority',
                            Icons.priority_high_rounded,
                            isDark,
                          ),

                          const SizedBox(height: 9),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChoiceChip(
                                label: 'All Priorities',
                                selected: selectedPriority == null,
                                color: _primary,
                                isDark: isDark,
                                onTap: () {
                                  onPriorityChanged(null);
                                  setSheetState(() {});
                                },
                              ),

                              ...EmergencyOperationalPriority.values.map(
                                (priority) => _buildChoiceChip(
                                  label: priority.label,
                                  selected: selectedPriority == priority,
                                  color: _primary,
                                  isDark: isDark,
                                  onTap: () {
                                    onPriorityChanged(priority);
                                    setSheetState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // DEPARTMENT
                          // -------------------------------------------------
                          _buildMobileSectionTitle(
                            'Department',
                            Icons.local_hospital_rounded,
                            isDark,
                          ),

                          const SizedBox(height: 9),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChoiceChip(
                                label: 'All Departments',
                                selected: selectedDepartment == null,
                                color: _primary,
                                isDark: isDark,
                                onTap: () {
                                  onDepartmentChanged(null);
                                  setSheetState(() {});
                                },
                              ),

                              ...availableDepartments.map(
                                (department) => _buildChoiceChip(
                                  label: department,
                                  selected: selectedDepartment == department,
                                  color: _primary,
                                  isDark: isDark,
                                  onTap: () {
                                    onDepartmentChanged(department);
                                    setSheetState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // -------------------------------------------------
                          // DOCTOR
                          // -------------------------------------------------
                          _buildMobileSectionTitle(
                            'Doctor',
                            Icons.person_rounded,
                            isDark,
                          ),

                          const SizedBox(height: 9),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChoiceChip(
                                label: 'All Doctors',
                                selected: selectedDoctor == null,
                                color: _primary,
                                isDark: isDark,
                                onTap: () {
                                  onDoctorChanged(null);
                                  setSheetState(() {});
                                },
                              ),

                              ...availableDoctors.map(
                                (doctor) => _buildChoiceChip(
                                  label: doctor,
                                  selected: selectedDoctor == doctor,
                                  color: _primary,
                                  isDark: isDark,
                                  onTap: () {
                                    onDoctorChanged(doctor);
                                    setSheetState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // -------------------------------------------------
                          // ACTIONS
                          // -------------------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    onResetFilters();

                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: BorderSide(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _buildApplyButton(
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildMobileSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: _primaryText(isDark),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE CHOICE CHIP
  // ---------------------------------------------------------------------------

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? color.withValues(alpha: isDark ? 0.16 : 0.09)
                : _surfaceStrong(isDark),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.45) : _border(isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? (isDark ? Colors.white : _primaryDark)
                      : _primaryText(isDark),
                ),
              ),

              if (selected) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: isDark ? Colors.white : _primaryDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APPLY BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildApplyButton({required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Apply Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
