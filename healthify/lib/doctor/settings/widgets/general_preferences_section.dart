import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';

class GeneralPreferencesSection extends StatefulWidget {
  final DoctorPreferencesModel preferences;
  final ValueChanged<DoctorPreferencesModel> onSavePreferences;

  const GeneralPreferencesSection({
    super.key,
    required this.preferences,
    required this.onSavePreferences,
  });

  @override
  State<GeneralPreferencesSection> createState() =>
      _GeneralPreferencesSectionState();
}

class _GeneralPreferencesSectionState
    extends State<GeneralPreferencesSection> {
  late DoctorPreferencesModel _local;

  @override
  void initState() {
    super.initState();
    _local = widget.preferences.copyWith();
  }

  void _handleSave() {
    widget.onSavePreferences(_local);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('General preferences saved successfully.'),
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
                icon: Icons.tune_rounded,
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
                      'General Workspace Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Customize locale, date/time display formats, and default workspace views.',
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

          // Grid Options
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 650;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownTile(
                          label: 'Workspace Language',
                          value: _local.language,
                          options: ['English', 'Hindi', 'Marathi'],
                          onChanged: (val) {
                            if (val != null) setState(() => _local = _local.copyWith(language: val));
                          },
                          isDark: isDark,
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (isDesktop)
                        Expanded(
                          child: _buildDropdownTile(
                            label: 'Date Format',
                            value: _local.dateFormat,
                            options: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                            onChanged: (val) {
                              if (val != null) setState(() => _local = _local.copyWith(dateFormat: val));
                            },
                            isDark: isDark,
                          ),
                        ),
                    ],
                  ),
                  if (!isDesktop) const SizedBox(height: 12),
                  if (!isDesktop)
                    _buildDropdownTile(
                      label: 'Date Format',
                      value: _local.dateFormat,
                      options: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                      onChanged: (val) {
                        if (val != null) setState(() => _local = _local.copyWith(dateFormat: val));
                      },
                      isDark: isDark,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownTile(
                          label: 'Time Format',
                          value: _local.timeFormat,
                          options: ['12-hour', '24-hour'],
                          onChanged: (val) {
                            if (val != null) setState(() => _local = _local.copyWith(timeFormat: val));
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownTile(
                          label: 'Timezone',
                          value: _local.timezone,
                          options: ['Asia/Kolkata (GMT+5:30)', 'UTC', 'America/New_York (EST)'],
                          onChanged: (val) {
                            if (val != null) setState(() => _local = _local.copyWith(timezone: val));
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownTile(
                    label: 'Default Workspace Landing Page',
                    value: _local.defaultLandingPage,
                    options: ['/doctor-dashboard', '/doctor-appointments', '/doctor-patients'],
                    onChanged: (val) {
                      if (val != null) setState(() => _local = _local.copyWith(defaultLandingPage: val));
                    },
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Appearance Option
          Text(
            'APPEARANCE & THEME PREFERENCE',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdownTile(
            label: 'Application Theme',
            value: _local.theme,
            options: ['Light', 'Dark', 'System'],
            onChanged: (val) {
              if (val != null) setState(() => _local = _local.copyWith(theme: val));
            },
            isDark: isDark,
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
                    Text('Save Preferences', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isDark,
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
        DropdownButtonFormField<String>(
          initialValue: value,
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
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
