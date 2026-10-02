import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';

class PatientMedicalHistoryTab extends StatefulWidget {
  final List<MedicalHistoryItemModel> historyItems;

  const PatientMedicalHistoryTab({
    super.key,
    required this.historyItems,
  });

  @override
  State<PatientMedicalHistoryTab> createState() => _PatientMedicalHistoryTabState();
}

class _PatientMedicalHistoryTabState extends State<PatientMedicalHistoryTab> {
  MedicalHistoryCategory _selectedCategory = MedicalHistoryCategory.all;

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.historyItems.where((item) {
      if (_selectedCategory == MedicalHistoryCategory.all) return true;
      return item.category == _selectedCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Events', MedicalHistoryCategory.all),
              const SizedBox(width: 8),
              _buildFilterChip('Consultations', MedicalHistoryCategory.consultation),
              const SizedBox(width: 8),
              _buildFilterChip('Reports & Labs', MedicalHistoryCategory.report),
              const SizedBox(width: 8),
              _buildFilterChip('Procedures', MedicalHistoryCategory.procedure),
              const SizedBox(width: 8),
              _buildFilterChip('Admissions', MedicalHistoryCategory.admission),
              const SizedBox(width: 8),
              _buildFilterChip('Prescriptions', MedicalHistoryCategory.prescription),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Chronological Timeline View
        if (filteredList.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No medical history entries found for selected filter.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final isLast = index == filteredList.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Node Column
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.badgeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: item.badgeColor, width: 2),
                          ),
                          child: Icon(item.icon, size: 18, color: item.badgeColor),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppTheme.borderLight,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Content Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: item.badgeColor.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: item.badgeColor.withValues(alpha: 0.25)),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: item.badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.event_outlined, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.date,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.person_outline_rounded, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.doctorName} (${item.department})',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.summary,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, MedicalHistoryCategory category) {
    final isSelected = _selectedCategory == category;

    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }
}
