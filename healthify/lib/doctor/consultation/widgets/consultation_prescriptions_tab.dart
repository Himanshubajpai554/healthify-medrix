import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/consultation_models.dart';

class ConsultationPrescriptionsTab extends StatefulWidget {
  final List<ConsultationPrescriptionItemModel> prescriptions;
  final ValueChanged<List<ConsultationPrescriptionItemModel>> onChanged;
  final VoidCallback onSavePrescription;

  const ConsultationPrescriptionsTab({
    super.key,
    required this.prescriptions,
    required this.onChanged,
    required this.onSavePrescription,
  });

  @override
  State<ConsultationPrescriptionsTab> createState() => _ConsultationPrescriptionsTabState();
}

class _ConsultationPrescriptionsTabState extends State<ConsultationPrescriptionsTab> {
  late List<ConsultationPrescriptionItemModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.prescriptions);
  }

  void _addMedicine() {
    setState(() {
      _items.add(
        ConsultationPrescriptionItemModel(
          id: 'MED-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          drugName: '',
          dosage: '',
          frequency: 'Once daily (OD)',
          duration: '30 Days',
          instructions: 'After breakfast',
        ),
      );
    });
    widget.onChanged(_items);
  }

  void _removeMedicine(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.onChanged(_items);
  }

  void _updateMedicine(int index, ConsultationPrescriptionItemModel item) {
    setState(() {
      _items[index] = item;
    });
    widget.onChanged(_items);
  }

  bool _validatePrescriptions() {
    for (var item in _items) {
      if (item.drugName.trim().isEmpty || item.dosage.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-Prescription Builder (Rx)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Add validated medications, dosages, and pharmacy instructions',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                GlassSecondaryButton(
                  height: 38,
                  onPressed: _addMedicine,
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: AppTheme.primaryTeal),
                      SizedBox(width: 4),
                      Text('Add Medicine', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassPrimaryButton(
                  height: 38,
                  onPressed: () {
                    if (!_validatePrescriptions()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete medicine name and dosage for all prescription entries.'),
                          backgroundColor: Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    widget.onSavePrescription();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-Prescription saved & queued for pharmacy fulfillment.'),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.check_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Save Prescription', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_items.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.medication_outlined, size: 40, color: AppTheme.textMuted),
                  const SizedBox(height: 10),
                  const Text('No medications added to this prescription yet.', style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 14),
                  GlassPrimaryButton(
                    onPressed: _addMedicine,
                    child: const Text('+ Add First Medicine'),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return _buildMedicineCard(index, item);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMedicineCard(int index, ConsultationPrescriptionItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Medication Details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => _removeMedicine(index),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.drugName,
                    onChanged: (val) => _updateMedicine(index, item.copyWith(drugName: val)),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Atorvastatin / Amlodipine',
                      labelText: 'Medicine Name (Required)',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.dosage,
                    onChanged: (val) => _updateMedicine(index, item.copyWith(dosage: val)),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. 40 mg',
                      labelText: 'Dosage (Required)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.frequency,
                    onChanged: (val) => _updateMedicine(index, item.copyWith(frequency: val)),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Once daily (OD)',
                      labelText: 'Frequency',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: item.duration,
                    onChanged: (val) => _updateMedicine(index, item.copyWith(duration: val)),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. 30 Days',
                      labelText: 'Duration',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.instructions,
                    onChanged: (val) => _updateMedicine(index, item.copyWith(instructions: val)),
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Take strictly after dinner',
                      labelText: 'Instructions',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
