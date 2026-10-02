import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';

class PersonalInfoSection extends StatefulWidget {
  final DoctorProfileModel profile;
  final ValueChanged<DoctorProfileModel> onSaveProfile;
  final VoidCallback onChangePhotoTap;

  const PersonalInfoSection({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.onChangePhotoTap,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _dobCtrl = TextEditingController(text: widget.profile.dateOfBirth);
    _addressCtrl = TextEditingController(text: widget.profile.address);
    _cityCtrl = TextEditingController(text: widget.profile.city);
    _stateCtrl = TextEditingController(text: widget.profile.state);
    _countryCtrl = TextEditingController(text: widget.profile.country);
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.profile.copyWith(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        dateOfBirth: _dobCtrl.text.trim(),
        gender: _selectedGender,
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
      );

      widget.onSaveProfile(updated);
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated successfully.'),
          backgroundColor: HealthifyGlassTheme.primaryTeal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header & Action
            Row(
              children: [
                const GlassIconContainer(
                  icon: Icons.person_outline_rounded,
                  size: 40,
                  iconSize: 20,
                  color: HealthifyGlassTheme.primaryTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Manage your demographic details and contact information.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  GlassSecondaryButton(
                    height: 38,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 15),
                        SizedBox(width: 6),
                        Text('Edit Profile', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  )
                else
                  GlassSecondaryButton(
                    height: 38,
                    onPressed: () {
                      _initControllers();
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 20),

            // Profile Avatar Photo Card
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  child: Text(
                    widget.profile.fullName.isNotEmpty ? widget.profile.fullName[0] : 'D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Doctor ID: ${widget.profile.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassSecondaryButton(
                      height: 32,
                      onPressed: widget.onChangePhotoTap,
                      child: const Row(
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 14),
                          SizedBox(width: 5),
                          Text('Change Photo', style: TextStyle(fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 650;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Full Name',
                            controller: _nameCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        if (isDesktop) const SizedBox(width: 16),
                        if (isDesktop)
                          Expanded(
                            child: _buildFormField(
                              label: 'Email Address',
                              controller: _emailCtrl,
                              isEditing: _isEditing,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Required';
                                if (!val.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                          ),
                      ],
                    ),
                    if (!isDesktop) const SizedBox(height: 12),
                    if (!isDesktop)
                      _buildFormField(
                        label: 'Email Address',
                        controller: _emailCtrl,
                        isEditing: _isEditing,
                        isDark: isDark,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (!val.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'Phone Number',
                            controller: _phoneCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            label: 'Date of Birth',
                            controller: _dobCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderSelector(isDark: isDark),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            label: 'City',
                            controller: _cityCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      label: 'Clinic / Residential Address',
                      controller: _addressCtrl,
                      isEditing: _isEditing,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            label: 'State / Province',
                            controller: _stateCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            label: 'Country',
                            controller: _countryCtrl,
                            isEditing: _isEditing,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassPrimaryButton(
                    height: 42,
                    onPressed: _handleSave,
                    child: const Row(
                      children: [
                        Icon(Icons.save_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Save Changes', style: TextStyle(fontSize: 13, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: HealthifyGlassTheme.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        if (isEditing)
          TextFormField(
            controller: controller,
            validator: validator,
            style: TextStyle(
              fontSize: 13,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: HealthifyGlassTheme.primaryTeal,
                  width: 1.5,
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Text(
              controller.text.isNotEmpty ? controller.text : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderSelector({required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: HealthifyGlassTheme.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        if (_isEditing)
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            style: TextStyle(
              fontSize: 13,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedGender = val);
            },
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Text(
              _selectedGender,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
      ],
    );
  }
}
