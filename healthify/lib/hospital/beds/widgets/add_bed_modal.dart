import 'dart:ui';
import 'package:flutter/material.dart';
import '../bed_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class AddBedModal extends StatefulWidget {
  final Function(BedItem) onBedAdded;

  const AddBedModal({super.key, required this.onBedAdded});

  @override
  State<AddBedModal> createState() => _AddBedModalState();
}

class _AddBedModalState extends State<AddBedModal> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  
  String _selectedType = 'General';
  int _selectedFloor = 1;
  BedStatus _selectedStatus = BedStatus.available;
  bool _isVisibleToPatientApp = true;
  
  final Map<String, bool> _equipment = {
    'Ventilator': false,
    'Oxygen Unit': true,
    'Cardiac Monitor': false,
    'Infusion Pump': false,
  };

  final List<String> _bedTypes = [
    'General',
    'ICU',
    'Emergency',
    'Private',
    'Pediatric',
    'NICU',
  ];

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final selectedEquipList = _equipment.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final newBed = BedItem(
        id: _idController.text.trim().toUpperCase(),
        type: _selectedType,
        ward: _selectedType,
        floor: _selectedFloor,
        status: _selectedStatus,
        equipment: selectedEquipList,
        lastUpdated: 'Just now',
        isVisibleToPatientApp: _isVisibleToPatientApp,
      );

      widget.onBedAdded(newBed);
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
            constraints: const BoxConstraints(maxHeight: 650),
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
                              icon: Icons.add_location_alt_outlined,
                              color: AppTheme.primaryColor,
                              size: 38,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add New Bed Unit',
                                style: TextStyle(
                                  fontSize: 20,
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

                  // Form fields in scroll view
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bed ID Input
                          Text(
                            'Bed Identifier Code',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _idController,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'e.g. ICU-09, G-105, E-04',
                              prefixIcon: const Icon(Icons.pin_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a bed ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Bed Type & Floor Dropdowns in a Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ward / Unit Type',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedType,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select type',
                                      ),
                                      items: _bedTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedType = val);
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
                                      'Floor Number',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      initialValue: _selectedFloor,
                                      dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                      decoration: GlassTextFieldTheme.getDecoration(
                                        context: context,
                                        hintText: 'Select floor',
                                      ),
                                      items: [1, 2, 3, 4, 5].map((floor) {
                                        return DropdownMenuItem(
                                          value: floor,
                                          child: Text('Floor $floor'),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedFloor = val);
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
                            'Initial Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<BedStatus>(
                            isExpanded: true,
                            initialValue: _selectedStatus,
                            dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'Select status',
                            ),
                            items: BedStatus.values.map((status) {
                              String label = status.name[0].toUpperCase() + status.name.substring(1);
                              return DropdownMenuItem(
                                value: status,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Equipment checklist
                          Text(
                            'Installed Equipment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _equipment.keys.map((equip) {
                              final isChecked = _equipment[equip]!;
                              return GlassSelectionChip(
                                label: equip,
                                isSelected: isChecked,
                                onTap: () {
                                  setState(() {
                                    _equipment[equip] = !isChecked;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Patient App Visibility Switch
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Visible in Patient Search App',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'Allows real-time bed availability queries for external transfers.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                              ),
                            ),
                            value: _isVisibleToPatientApp,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (val) {
                              setState(() => _isVisibleToPatientApp = val);
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
                          onPressed: _submitForm,
                          child: const Text('Add Bed'),
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