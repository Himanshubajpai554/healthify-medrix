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

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    if (cases.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Emergency Cases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No cases match the selected operational filters or search query.',
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cases.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = cases[index];
          final isSelected = item.id == selectedCaseId;
          return _buildMobileEmergencyCard(context, item, isSelected, isDark);
        },
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: screenWidth - 320),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.08),
              ),
              horizontalMargin: 20,
              columnSpacing: 20,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 76,
              columns: const [
                DataColumn(label: Text('CASE ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('PATIENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('ARRIVAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('REASON', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('PRIORITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('ASSIGNED DOCTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
              ],
              rows: cases.map((item) {
                final isSelected = item.id == selectedCaseId;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (_) => onSelectCase(item),
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (isSelected) {
                      return HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1);
                    }
                    if (item.priority == EmergencyOperationalPriority.immediate && item.status != EmergencyCaseStatus.resolved) {
                      return Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.06);
                    }
                    return null;
                  }),
                  cells: [
                    // Case ID
                    DataCell(
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: item.priority.color.withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.emergency_rounded, size: 16, color: item.priority.color),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.id,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Patient
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.patientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.patientAge}y • ${item.patientGender} • Blood ${item.bloodGroup}',
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrival
                    DataCell(
                      Text(
                        formatTime(item.arrivalTime),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Reason
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          item.emergencyReason,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Priority Badge
                    DataCell(
                      _buildPriorityBadge(item.priority, isDark),
                    ),
                    // Assigned Doctor
                    DataCell(
                      Text(
                        item.assignedDoctor,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Location
                    DataCell(
                      Text(
                        item.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                    // Status Badge
                    DataCell(
                      _buildStatusBadge(item.status, isDark),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassSecondaryButton(
                            onPressed: () => onSelectCase(item),
                            height: 36,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_new_rounded, size: 16),
                                SizedBox(width: 4),
                                Text('Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 18, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            onSelected: (val) {
                              if (val == 'status') onUpdateStatus(item);
                              if (val == 'transfer') onTransferCase(item);
                              if (val == 'resolve') onResolveCase(item);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'status', child: Text('Update Case Status')),
                              const PopupMenuItem(value: 'transfer', child: Text('Transfer Department/Ward')),
                              if (item.status != EmergencyCaseStatus.resolved)
                                const PopupMenuItem(value: 'resolve', child: Text('Resolve / Close Case', style: TextStyle(color: Color(0xFF10B981)))),
                            ],
                          ),
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
    );
  }

  Widget _buildMobileEmergencyCard(
    BuildContext context,
    DoctorEmergencyCaseFullModel item,
    bool isSelected,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: HealthifyGlassTheme.primaryTeal, width: 2) : null,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.priority.color.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.emergency_rounded, size: 20, color: item.priority.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.id} • ${item.patientName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        '${item.patientAge}y • ${item.patientGender} • Blood ${item.bloodGroup}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriorityBadge(item.priority, isDark),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 15, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    const SizedBox(width: 4),
                    Text('Arrival: ${formatTime(item.arrivalTime)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                  ],
                ),
                _buildStatusBadge(item.status, isDark),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${item.emergencyReason}',
              style: TextStyle(
                fontSize: 12.5,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Assigned: ${item.assignedDoctor} (${item.location})',
              style: TextStyle(
                fontSize: 11.5,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: GlassPrimaryButton(
                    onPressed: () => onSelectCase(item),
                    height: 40,
                    color: item.priority == EmergencyOperationalPriority.immediate ? Colors.redAccent : HealthifyGlassTheme.primaryTeal,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Open Case', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) {
                    if (val == 'status') onUpdateStatus(item);
                    if (val == 'transfer') onTransferCase(item);
                    if (val == 'resolve') onResolveCase(item);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'status', child: Text('Update Case Status')),
                    const PopupMenuItem(value: 'transfer', child: Text('Transfer Department/Ward')),
                    if (item.status != EmergencyCaseStatus.resolved)
                      const PopupMenuItem(value: 'resolve', child: Text('Resolve / Close Case', style: TextStyle(color: Color(0xFF10B981)))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(EmergencyOperationalPriority priority, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priority.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: priority.color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(EmergencyCaseStatus status, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
