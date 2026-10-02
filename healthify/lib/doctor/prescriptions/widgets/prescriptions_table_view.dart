import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class PrescriptionsTableView extends StatelessWidget {
  final List<DoctorPrescriptionFullModel> prescriptions;
  final ValueChanged<DoctorPrescriptionFullModel> onSelectPrescription;
  final ValueChanged<DoctorPrescriptionFullModel> onEditPrescription;
  final ValueChanged<DoctorPrescriptionFullModel> onDuplicatePrescription;
  final ValueChanged<DoctorPrescriptionFullModel> onCancelPrescription;
  final String? selectedPrescriptionId;

  const PrescriptionsTableView({
    super.key,
    required this.prescriptions,
    required this.onSelectPrescription,
    required this.onEditPrescription,
    required this.onDuplicatePrescription,
    required this.onCancelPrescription,
    this.selectedPrescriptionId,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

    if (prescriptions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medication_liquid_rounded,
                size: 56,
                color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Prescriptions Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search criteria, status filter, or department selection.',
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
        itemCount: prescriptions.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final rx = prescriptions[index];
          final isSelected = rx.id == selectedPrescriptionId;
          return _buildMobilePrescriptionCard(context, rx, isSelected, isDark);
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
              columnSpacing: 24,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 74,
              columns: const [
                DataColumn(label: Text('PRESCRIPTION ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('PATIENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('DOCTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('DEPARTMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('MEDICINES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5))),
              ],
              rows: prescriptions.map((rx) {
                final isSelected = rx.id == selectedPrescriptionId;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (_) => onSelectPrescription(rx),
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (isSelected) {
                      return HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.1);
                    }
                    return null;
                  }),
                  cells: [
                    // RX ID
                    DataCell(
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: rx.status.color.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.receipt_long_rounded, size: 18, color: rx.status.color),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            rx.id,
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
                            rx.patientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${rx.patientId} • ${rx.patientAge}y/${rx.patientGender[0]}',
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date
                    DataCell(
                      Text(
                        formatDate(rx.date),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Doctor
                    DataCell(
                      Text(
                        rx.doctorName,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Department
                    DataCell(
                      Text(
                        rx.department,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                    // Medicines Count
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${rx.medicines.length} Medicines',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                    ),
                    // Status Badge
                    DataCell(
                      _buildStatusBadge(rx.status, isDark),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassSecondaryButton(
                            onPressed: () => onSelectPrescription(rx),
                            height: 36,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.visibility_rounded, size: 16),
                                SizedBox(width: 4),
                                Text('View', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (rx.status == PrescriptionStatus.draft)
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                              tooltip: 'Edit Draft',
                              onPressed: () => onEditPrescription(rx),
                            ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 18, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            onSelected: (val) {
                              if (val == 'duplicate') {
                                onDuplicatePrescription(rx);
                              } else if (val == 'cancel') {
                                onCancelPrescription(rx);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'duplicate',
                                child: Row(
                                  children: [
                                    Icon(Icons.copy_rounded, size: 16),
                                    SizedBox(width: 8),
                                    Text('Duplicate as Draft', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              if (rx.status == PrescriptionStatus.active)
                                const PopupMenuItem(
                                  value: 'cancel',
                                  child: Row(
                                    children: [
                                      Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Cancel Prescription', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
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

  Widget _buildMobilePrescriptionCard(
    BuildContext context,
    DoctorPrescriptionFullModel rx,
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
                    color: rx.status.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_long_rounded, size: 20, color: rx.status.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescription ${rx.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        '${rx.department} • ${formatDate(rx.date)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(rx.status, isDark),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 16, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                const SizedBox(width: 6),
                Text(
                  '${rx.patientName} (${rx.patientId})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Text(
                  '${rx.medicines.length} Medicines',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: () => onSelectPrescription(rx),
                    height: 40,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('View Prescription', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) {
                    if (val == 'duplicate') {
                      onDuplicatePrescription(rx);
                    } else if (val == 'cancel') {
                      onCancelPrescription(rx);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate as Draft'),
                    ),
                    if (rx.status == PrescriptionStatus.active)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Text('Cancel Prescription', style: TextStyle(color: Colors.redAccent)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PrescriptionStatus status, bool isDark) {
    final bg = status.color.withValues(alpha: isDark ? 0.25 : 0.12);
    final fg = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
