import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';

class PrivacySettingsSection extends StatefulWidget {
  final DoctorPrivacySettingsModel privacySettings;
  final ValueChanged<DoctorPrivacySettingsModel> onSavePrivacySettings;

  const PrivacySettingsSection({
    super.key,
    required this.privacySettings,
    required this.onSavePrivacySettings,
  });

  @override
  State<PrivacySettingsSection> createState() => _PrivacySettingsSectionState();
}

class _PrivacySettingsSectionState extends State<PrivacySettingsSection> {
  late DoctorPrivacySettingsModel _local;

  @override
  void initState() {
    super.initState();
    _local = widget.privacySettings.copyWith();
  }

  void _handleSave() {
    widget.onSavePrivacySettings(_local);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings saved successfully.'),
        backgroundColor: HealthifyGlassTheme.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.lock_person_rounded,
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
                      'Privacy & Profile Visibility',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Control how your professional information is visible across channels.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 20),

          // Profile Visibility Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Profile Visibility Scope',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _local.profileVisibility,
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
                  DropdownMenuItem(value: 'Hospital Staff', child: Text('Hospital Staff Only (Recommended)')),
                  DropdownMenuItem(value: 'Patients', child: Text('Verified Hospital Patients')),
                  DropdownMenuItem(value: 'Public', child: Text('Public Directory')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _local = _local.copyWith(profileVisibility: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'DATA EXPOSURE PREFERENCES',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 12),

          _buildSwitchTile(
            title: 'Show Direct Phone Number',
            description: 'Displays phone number on patient consultation receipts.',
            value: _local.showPhoneNumber,
            onChanged: (val) => setState(() => _local = _local.copyWith(showPhoneNumber: val)),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Show Email Address',
            description: 'Displays professional email address on hospital clinical directory.',
            value: _local.showEmail,
            onChanged: (val) => setState(() => _local = _local.copyWith(showEmail: val)),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Show Qualifications & Certification Badges',
            description: 'Displays degrees and verification status on patient booking cards.',
            value: _local.showQualifications,
            onChanged: (val) => setState(() => _local = _local.copyWith(showQualifications: val)),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Show Consultation Availability Status',
            description: 'Shows real-time availability status indicator to hospital triage staff.',
            value: _local.showConsultationAvailability,
            onChanged: (val) => setState(() => _local = _local.copyWith(showConsultationAvailability: val)),
            isDark: isDark,
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 16,
                  color: HealthifyGlassTheme.getTextMuted(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Privacy settings control default visibility in patient apps but never override backend role authorization or hospital security policies.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: HealthifyGlassTheme.getTextMuted(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                    Text('Save Privacy Settings', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: HealthifyGlassTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}
