import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class EmergencyTableView extends StatelessWidget {
  final List<DoctorEmergencyCaseFullModel> cases;
  final ValueChanged<DoctorEmergencyCaseFullModel> onSelectCase;
  final ValueChanged<DoctorEmergencyCaseFullModel> onUpdateStatus;
  final ValueChanged<DoctorEmergencyCaseFullModel> onTransferCase;
  final ValueChanged<DoctorEmergencyCaseFullModel> onResolveCase;
  final String? selectedCaseId;

  const EmergencyTableView({
    super.key,
    required this.cases,
    required this.onSelectCase,
    required this.onUpdateStatus,
    required this.onTransferCase,
    required this.onResolveCase,
    this.selectedCaseId,
  });

  // ---------------------------------------------------------------------------
  // HEALTHIFY COLORS
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

  Color _textPrimary(bool isDark) {
    return HealthifyGlassTheme.getTextPrimary(isDark);
  }

  Color _textSecondary(bool isDark) {
    return HealthifyGlassTheme.getTextSecondary(isDark);
  }

  // ---------------------------------------------------------------------------
  // TIME
  // ---------------------------------------------------------------------------

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 850;

    if (cases.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    if (isMobile) {
      return _buildMobileList(context, isDark);
    }

    return _buildDesktopTable(context, isDark, screenWidth);
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.025),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                  border: Border.all(color: _primary.withValues(alpha: 0.15)),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 34,
                  color: _primary.withValues(alpha: 0.75),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'No Active Emergency Cases',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(isDark),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'No cases match the selected operational filters or search query.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: _textSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE
  // ---------------------------------------------------------------------------

  Widget _buildMobileList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cases.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cases[index];

        final isSelected = item.id == selectedCaseId;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.96, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 55)),
          curve: Curves.easeOutCubic,
          builder: (context, animationValue, child) {
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, (1 - animationValue) * 12),
                child: child,
              ),
            );
          },
          child: _buildMobileEmergencyCard(context, item, isSelected, isDark),
        );
      },
    );
  }

  Widget _buildMobileEmergencyCard(
    BuildContext context,
    DoctorEmergencyCaseFullModel item,
    bool isSelected,
    bool isDark,
  ) {
    return DynamicHoverGlassCard(
      margin: EdgeInsets.zero,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: () => onSelectCase(item),
      hasTealGlow: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? _primary.withValues(alpha: isDark ? 0.10 : 0.065)
                  : _surface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? _primary.withValues(alpha: isDark ? 0.50 : 0.35)
                    : _border(isDark),
                width: isSelected ? 1.25 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _primary.withValues(alpha: isDark ? 0.10 : 0.055)
                      : Colors.black.withValues(alpha: isDark ? 0.06 : 0.02),
                  blurRadius: isSelected ? 20 : 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------------------------
                // PATIENT HEADER
                // -----------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.priority.color.withValues(
                          alpha: isDark ? 0.14 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: item.priority.color.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        size: 21,
                        color: item.priority.color,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary(isDark),
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '${item.id} • ${item.patientAge}y • ${item.patientGender}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildPriorityBadge(item.priority, isDark),
                  ],
                ),

                const SizedBox(height: 12),

                Container(height: 1, color: _border(isDark)),

                const SizedBox(height: 12),

                // -----------------------------------------------------------
                // META INFORMATION
                // -----------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.access_time_rounded,
                        label: 'Arrival',
                        value: formatTime(item.arrivalTime),
                        isDark: isDark,
                      ),
                    ),

                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        value: item.location,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // -----------------------------------------------------------
                // REASON
                // -----------------------------------------------------------
                Text(
                  item.emergencyReason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary(isDark),
                  ),
                ),

                const SizedBox(height: 10),

                // -----------------------------------------------------------
                // DOCTOR + STATUS
                // -----------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _primary.withValues(
                                alpha: isDark ? 0.10 : 0.07,
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 15,
                              color: _primary,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: Text(
                              item.assignedDoctor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildStatusBadge(item.status, isDark),
                  ],
                ),

                const SizedBox(height: 14),

                // -----------------------------------------------------------
                // ACTIONS
                // -----------------------------------------------------------
                Row(
                  children: [
                    Expanded(child: _buildOpenButton(context, item, isDark)),

                    const SizedBox(width: 8),

                    _buildMoreButton(context, item, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE INFO ITEM
  // ---------------------------------------------------------------------------

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _primary),

        const SizedBox(width: 5),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary(isDark),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP TABLE
  // ---------------------------------------------------------------------------

  Widget _buildDesktopTable(
    BuildContext context,
    bool isDark,
    double screenWidth,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.07 : 0.025),
                blurRadius: 24,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: screenWidth - 320),
                child: DataTable(
                  horizontalMargin: 18,
                  columnSpacing: 20,
                  dataRowMinHeight: 72,
                  dataRowMaxHeight: 80,

                  headingRowHeight: 48,

                  headingRowColor: WidgetStateProperty.all(
                    isDark
                        ? _primary.withValues(alpha: 0.055)
                        : _primary.withValues(alpha: 0.035),
                  ),

                  headingTextStyle: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                    color: _textSecondary(isDark),
                  ),

                  columns: const [
                    DataColumn(label: Text('CASE ID')),
                    DataColumn(label: Text('PATIENT')),
                    DataColumn(label: Text('ARRIVAL')),
                    DataColumn(label: Text('REASON')),
                    DataColumn(label: Text('PRIORITY')),
                    DataColumn(label: Text('ASSIGNED DOCTOR')),
                    DataColumn(label: Text('LOCATION')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTIONS')),
                  ],

                  rows: cases.map((item) {
                    final isSelected = item.id == selectedCaseId;

                    final isCritical =
                        item.priority ==
                            EmergencyOperationalPriority.immediate &&
                        item.status != EmergencyCaseStatus.resolved;

                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (_) => onSelectCase(item),
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        if (isSelected) {
                          return _primary.withValues(
                            alpha: isDark ? 0.115 : 0.065,
                          );
                        }

                        if (isCritical) {
                          return Colors.redAccent.withValues(
                            alpha: isDark ? 0.035 : 0.022,
                          );
                        }

                        return null;
                      }),
                      cells: [
                        // ---------------------------------------------------
                        // CASE ID
                        // ---------------------------------------------------
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.priority.color.withValues(
                                    alpha: isDark ? 0.13 : 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.emergency_rounded,
                                  size: 16,
                                  color: item.priority.color,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Text(
                                item.id,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: _textPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---------------------------------------------------
                        // PATIENT
                        // ---------------------------------------------------
                        DataCell(
                          SizedBox(
                            width: 145,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.patientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                    color: _textPrimary(isDark),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.patientAge}y • ${item.patientGender} • ${item.bloodGroup}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: _textSecondary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // ARRIVAL
                        // ---------------------------------------------------
                        DataCell(
                          Text(
                            formatTime(item.arrivalTime),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary(isDark),
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // REASON
                        // ---------------------------------------------------
                        DataCell(
                          SizedBox(
                            width: 180,
                            child: Text(
                              item.emergencyReason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.3,
                                color: _textPrimary(isDark),
                              ),
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // PRIORITY
                        // ---------------------------------------------------
                        DataCell(_buildPriorityBadge(item.priority, isDark)),

                        // ---------------------------------------------------
                        // DOCTOR
                        // ---------------------------------------------------
                        DataCell(
                          SizedBox(
                            width: 130,
                            child: Text(
                              item.assignedDoctor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: _textPrimary(isDark),
                              ),
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // LOCATION
                        // ---------------------------------------------------
                        DataCell(
                          SizedBox(
                            width: 105,
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: _textSecondary(isDark),
                              ),
                            ),
                          ),
                        ),

                        // ---------------------------------------------------
                        // STATUS
                        // ---------------------------------------------------
                        DataCell(_buildStatusBadge(item.status, isDark)),

                        // ---------------------------------------------------
                        // ACTIONS
                        // ---------------------------------------------------
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDesktopOpenButton(context, item, isDark),

                              const SizedBox(width: 5),

                              _buildMoreButton(context, item, isDark),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP OPEN BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildDesktopOpenButton(
    BuildContext context,
    DoctorEmergencyCaseFullModel item,
    bool isDark,
  ) {
    return GlassSecondaryButton(
      onPressed: () => onSelectCase(item),
      height: 36,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_in_new_rounded, size: 15),
          SizedBox(width: 4),
          Text(
            'Open',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE OPEN BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildOpenButton(
    BuildContext context,
    DoctorEmergencyCaseFullModel item,
    bool isDark,
  ) {
    final buttonColor = item.priority == EmergencyOperationalPriority.immediate
        ? Colors.redAccent
        : _primary;

    return GlassPrimaryButton(
      onPressed: () => onSelectCase(item),
      height: 40,
      color: buttonColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.open_in_new_rounded, size: 17),
          SizedBox(width: 6),
          Text(
            'Open Case',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MORE MENU
  // ---------------------------------------------------------------------------

  Widget _buildMoreButton(
    BuildContext context,
    DoctorEmergencyCaseFullModel item,
    bool isDark,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        tooltip: 'More actions',
        icon: Icon(
          Icons.more_vert_rounded,
          size: 19,
          color: _textSecondary(isDark),
        ),
        onSelected: (value) {
          if (value == 'status') {
            onUpdateStatus(item);
          }

          if (value == 'transfer') {
            onTransferCase(item);
          }

          if (value == 'resolve') {
            onResolveCase(item);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'status',
            child: Text('Update Case Status'),
          ),
          const PopupMenuItem(
            value: 'transfer',
            child: Text('Transfer Department/Ward'),
          ),
          if (item.status != EmergencyCaseStatus.resolved)
            const PopupMenuItem(
              value: 'resolve',
              child: Text(
                'Resolve / Close Case',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRIORITY BADGE
  // ---------------------------------------------------------------------------

  Widget _buildPriorityBadge(
    EmergencyOperationalPriority priority,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: isDark ? 0.13 : 0.075),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: priority.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priority.color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS BADGE
  // ---------------------------------------------------------------------------

  Widget _buildStatusBadge(EmergencyCaseStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: isDark ? 0.13 : 0.075),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: status.color.withValues(alpha: 0.20)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}
