import 'dart:ui';
import 'package:flutter/material.dart';
import '../blood_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class AddBloodUnitsModal extends StatefulWidget {
  final Function(BloodInventoryUnit) onUnitAdded;

  const AddBloodUnitsModal({super.key, required this.onUnitAdded});

  @override
  State<AddBloodUnitsModal> createState() => _AddBloodUnitsModalState();
}

class _AddBloodUnitsModalState extends State<AddBloodUnitsModal> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController(text: '1');

  String _bloodGroup = 'O+';
  String _component = 'Whole Blood';
  String _storage = 'Refrigerator A';
  InventoryUnitStatus _status = InventoryUnitStatus.available;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _components = ['Whole Blood', 'RBC', 'Fresh Frozen Plasma', 'Platelets', 'Cryoprecipitate'];
  final List<String> _storages = ['Refrigerator A', 'Refrigerator B', 'Freezer A', 'Quarantine Storage'];

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newUnitId = 'BG-${(10000 + (DateTime.now().millisecondsSinceEpoch % 89999))}';
      final newUnit = BloodInventoryUnit(
        unitId: newUnitId,
        bloodGroup: _bloodGroup,
        component: _component,
        quantityUnits: int.tryParse(_unitsController.text.trim()) ?? 1,
        collectionDate: DateTime.now().subtract(const Duration(days: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 35)),
        status: _status,
        storageLocation: _storage,
        lastUpdated: 'Just now',
      );

      widget.onUnitAdded(newUnit);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 620),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const GlassIconContainer(
                              icon: Icons.bloodtype_outlined,
                              color: Color(0xFFE11D48),
                              size: 38,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add Blood Inventory Units',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Blood Group & Component Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Blood Group',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _bloodGroup,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select group',
                                      ),
                                      items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _bloodGroup = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Component',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _component,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select component',
                                      ),
                                      items: _components.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _component = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quantity & Storage Unit Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity (Units)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _unitsController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Enter units',
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Enter quantity';
                                        if (int.tryParse(val.trim()) == null) return 'Invalid number';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Storage Location',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _storage,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select location',
                                      ),
                                      items: _storages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _storage = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Initial Status
                          Text(
                            'Inventory Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<InventoryUnitStatus>(
                            isExpanded: true,
                            initialValue: _status,
                            dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'Select status',
                            ),
                            items: const [
                              DropdownMenuItem(value: InventoryUnitStatus.available, child: Text('Available')),
                              DropdownMenuItem(value: InventoryUnitStatus.reserved, child: Text('Reserved')),
                              DropdownMenuItem(value: InventoryUnitStatus.quarantine, child: Text('Quarantine')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GlassSecondaryButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassPrimaryButton(
                          color: const Color(0xFFE11D48),
                          onPressed: _submitForm,
                          child: const Text('Add Units'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}