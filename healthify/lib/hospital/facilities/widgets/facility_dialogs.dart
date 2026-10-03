import 'dart:ui';
import 'package:flutter/material.dart';
import '../facility_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class ViewFacilityModal extends StatelessWidget {
  final FacilityModel facility;

  const ViewFacilityModal({
    super.key,
    required this.facility,
  });

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
            width: 480,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.business_rounded,
                      color: AppTheme.primaryColor,
                      size: 40,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            facility.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppTheme.textSecondary,
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

                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (facility.description.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white54 : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildDetailRow(
                        context,
                        'Status',
                        _buildAvailabilityBadge(context, facility.availability),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Capacity / Details',
                        Text(
                          facility.capacity,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Operating Hours',
                        Text(
                          facility.operatingHours,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Location / Floor',
                        Text(
                          facility.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Patient Visibility',
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: facility.isVisibleToPatients
                                ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                                : HealthifyGlassTheme.getGlassSurface(isDark),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                facility.isVisibleToPatients ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 13,
                                color: facility.isVisibleToPatients
                                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                    : (isDark ? Colors.white38 : AppTheme.textMuted),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                facility.isVisibleToPatients ? 'Visible to Patients' : 'Hidden from Patients',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: facility.isVisibleToPatients
                                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                      : (isDark ? Colors.white70 : AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Last Updated',
                        Text(
                          facility.lastUpdated,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassPrimaryButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, Widget content) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : AppTheme.textSecondary,
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context, String status) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    Color bg;
    Color fg;

    switch (status) {
      case 'Available':
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        fg = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
        break;
      case 'Limited':
        bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        break;
      case 'Unavailable':
        bg = isDark ? const Color(0xFF881337) : const Color(0xFFFFE4E6);
        fg = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
        break;
      case 'Maintenance':
      default:
        bg = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9);
        fg = isDark ? Colors.white70 : const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }
}

class AddEditFacilityModal extends StatefulWidget {
  final FacilityModel? facility;
  final Function(FacilityModel) onSave;

  const AddEditFacilityModal({
    super.key,
    this.facility,
    required this.onSave,
  });

  @override
  State<AddEditFacilityModal> createState() => _AddEditFacilityModalState();
}

class _AddEditFacilityModalState extends State<AddEditFacilityModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _operatingHoursController;
  late TextEditingController _locationController;

  late String _category;
  late String _availability;
  late bool _isVisibleToPatients;

  final List<String> _categories = [
    'Diagnostic',
    'Emergency',
    'Surgery',
    'Imaging',
    'Laboratory',
    'Pharmacy',
    'Specialized Care',
    'Other'
  ];

  final List<String> _availabilities = [
    'Available',
    'Limited',
    'Unavailable',
    'Maintenance'
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.facility;
    _nameController = TextEditingController(text: f?.name ?? '');
    _descriptionController = TextEditingController(text: f?.description ?? '');
    _capacityController = TextEditingController(text: f?.capacity ?? '');
    _operatingHoursController = TextEditingController(text: f?.operatingHours ?? '24/7');
    _locationController = TextEditingController(text: f?.location ?? '');

    _category = f?.category ?? 'Diagnostic';
    _availability = f?.availability ?? 'Available';
    _isVisibleToPatients = f?.isVisibleToPatients ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _operatingHoursController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.facility != null;
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
                  Row(
                    children: [
                      GlassIconContainer(
                        icon: isEditing ? Icons.edit_note_rounded : Icons.add_business_rounded,
                        color: AppTheme.primaryColor,
                        size: 40,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Facility' : 'Add New Facility',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
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
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'e.g. MRI Scanner Unit 2',
                              labelText: 'Facility Name',
                              prefixIcon: const Icon(Icons.business_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter facility name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _category,
                            dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'Select category',
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            items: _categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _category = val);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'Brief summary of facility capabilities',
                              labelText: 'Description',
                              prefixIcon: const Icon(Icons.notes_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _capacityController,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'e.g. 10 beds, 2 machines, Full Service',
                              labelText: 'Capacity / Details',
                              prefixIcon: const Icon(Icons.inventory_2_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter capacity details';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _operatingHoursController,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'e.g. 24/7 or 8:00 AM – 8:00 PM',
                              labelText: 'Operating Hours',
                              prefixIcon: const Icon(Icons.access_time_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _locationController,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'e.g. Diagnostic Block, Floor 2',
                              labelText: 'Location / Floor',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _availability,
                            dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: 'Select state',
                              labelText: 'Availability State',
                              prefixIcon: const Icon(Icons.rule_rounded),
                            ),
                            items: _availabilities
                                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _availability = val);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: HealthifyGlassTheme.getGlassSurface(isDark),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Patient Visibility',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Expose availability to Patient App',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white70 : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isVisibleToPatients,
                                  activeTrackColor: AppTheme.primaryColor,
                                  onChanged: (val) {
                                    setState(() => _isVisibleToPatients = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  const SizedBox(height: 16),

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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newFacility = FacilityModel(
                                id: widget.facility?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: _nameController.text.trim(),
                                category: _category,
                                availability: _availability,
                                capacity: _capacityController.text.trim(),
                                operatingHours: _operatingHoursController.text.trim(),
                                location: _locationController.text.trim(),
                                description: _descriptionController.text.trim(),
                                isVisibleToPatients: _isVisibleToPatients,
                                lastUpdated: 'Just now',
                              );
                              widget.onSave(newFacility);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEditing ? 'Save Changes' : 'Add Facility'),
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