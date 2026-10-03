import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';
import '../doctor_model.dart';

class AddDoctorModal extends StatefulWidget {
  final Function(DoctorItem) onDoctorAdded;

  const AddDoctorModal({super.key, required this.onDoctorAdded});

  @override
  State<AddDoctorModal> createState() => _AddDoctorModalState();
}

class _AddDoctorModalState extends State<AddDoctorModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _expController = TextEditingController(text: '8');

  String _department = 'Cardiology';
  DoctorStatus _status = DoctorStatus.available;
  String _shiftHours = '08:00 AM - 04:00 PM';

  final List<String> _departments = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Emergency',
    'General Surgery',
    'ICU Medicine',
  ];

  final List<String> _shifts = [
    '08:00 AM - 04:00 PM (Morning)',
    '04:00 PM - 12:00 AM (Evening)',
    '12:00 AM - 08:00 AM (Night)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _expController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newId = 'DOC-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999))}';
      final formattedName = _nameController.text.trim().startsWith('Dr.')
          ? _nameController.text.trim()
          : 'Dr. ${_nameController.text.trim()}';

      final newDoctor = DoctorItem(
        id: newId,
        name: formattedName,
        department: _department,
        status: _status,
        activePatients: 0,
        phone: _phoneController.text.trim().isEmpty ? '+1 (555) 019-2831' : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? 'physician@healthify.org' : _emailController.text.trim(),
        experienceYears: int.tryParse(_expController.text.trim()) ?? 5,
        shiftHours: _shiftHours,
      );

      widget.onDoctorAdded(newDoctor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 520,
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
                    Row(
                      children: [
                        const GlassIconContainer(
                          icon: Icons.person_add_rounded,
                          color: AppTheme.primaryColor,
                          size: 42,
                          iconSize: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add New Doctor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? Colors.white12 : AppTheme.borderLight),
                const SizedBox(height: 16),

                // Form Body
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text(
                          'Doctor Full Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: 'e.g. Sarah Jenkins',
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter doctor name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Department & Initial Status Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Department',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: _department,
                                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                    decoration: GlassTextFieldTheme.getDecoration(
                                      context: context,
                                      hintText: 'Select department',
                                    ),
                                    items: _departments
                                        .map((d) => DropdownMenuItem(
                                              value: d,
                                              child: Text(d, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _department = val);
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
                                    'Initial Status',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<DoctorStatus>(
                                    isExpanded: true,
                                    initialValue: _status,
                                    dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                    decoration: GlassTextFieldTheme.getDecoration(
                                      context: context,
                                      hintText: 'Select status',
                                    ),
                                    items: [
                                      DropdownMenuItem(value: DoctorStatus.available, child: Text('Available', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                                      DropdownMenuItem(value: DoctorStatus.inSurgery, child: Text('In Surgery', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                                      DropdownMenuItem(value: DoctorStatus.busy, child: Text('Busy', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                                      DropdownMenuItem(value: DoctorStatus.offDuty, child: Text('Off Duty', style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary))),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _status = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Shift Roster Hours
                        Text(
                          'Shift Schedule Roster',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _shifts[0],
                          dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                          decoration: GlassTextFieldTheme.getDecoration(
                            context: context,
                            hintText: 'Select shift',
                          ),
                          items: _shifts
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s, style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _shiftHours = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email & Phone Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Official Email',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                    decoration: GlassTextFieldTheme.getDecoration(
                                      context: context,
                                      hintText: 'sarah@healthify.org',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                    ),
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
                                    'Phone Number',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _phoneController,
                                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                                    decoration: GlassTextFieldTheme.getDecoration(
                                      context: context,
                                      hintText: '+1 (555) 234-5678',
                                      prefixIcon: const Icon(Icons.phone_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? Colors.white12 : AppTheme.borderLight),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassSecondaryButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    GlassPrimaryButton(
                      onPressed: _submitForm,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Register Doctor'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}