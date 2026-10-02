import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';

class ConsultationSettingsSection extends StatefulWidget {
  final ConsultationSettingsModel settings;
  final ValueChanged<ConsultationSettingsModel> onSaveSettings;

  const ConsultationSettingsSection({
    super.key,
    required this.settings,
    required this.onSaveSettings,
  });

  @override
  State<ConsultationSettingsSection> createState() =>
      _ConsultationSettingsSectionState();
}

class _ConsultationSettingsSectionState
    extends State<ConsultationSettingsSection> {
  late ConsultationSettingsModel _local;

  @override
  void initState() {
    super.initState();
    _local = widget.settings.copyWith();
  }

  void _handleSave() {
    widget.onSaveSettings(_local);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation preferences updated successfully.'),
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
                icon: Icons.medical_services_rounded,
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
                      'Consultation & Booking Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Configure default consultation duration, buffers, and appointment types.',
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

          // Duration & Buffer Selectors Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 650;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownTile(
                          label: 'Consultation Duration',
                          value: '${_local.consultationDurationMinutes} min',
                          options: ['15 min', '30 min', '45 min', '60 min'],
                          onChanged: (val) {
                            if (val != null) {
                              final mins = int.parse(val.split(' ')[0]);
                              setState(() {
                                _local = _local.copyWith(consultationDurationMinutes: mins);
                              });
                            }
                          },
                          isDark: isDark,
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (isDesktop)
                        Expanded(
                          child: _buildDropdownTile(
                            label: 'Appointment Buffer Time',
                            value: '${_local.appointmentBufferMinutes} min',
                            options: ['5 min', '10 min', '15 min'],
                            onChanged: (val) {
                              if (val != null) {
                                final mins = int.parse(val.split(' ')[0]);
                                setState(() {
                                  _local = _local.copyWith(appointmentBufferMinutes: mins);
                                });
                              }
                            },
                            isDark: isDark,
                          ),
                        ),
                    ],
                  ),
                  if (!isDesktop) const SizedBox(height: 12),
                  if (!isDesktop)
                    _buildDropdownTile(
                      label: 'Appointment Buffer Time',
                      value: '${_local.appointmentBufferMinutes} min',
                      options: ['5 min', '10 min', '15 min'],
                      onChanged: (val) {
                        if (val != null) {
                          final mins = int.parse(val.split(' ')[0]);
                          setState(() {
                            _local = _local.copyWith(appointmentBufferMinutes: mins);
                          });
                        }
                      },
                      isDark: isDark,
                    ),
                  const SizedBox(height: 12),
                  _buildDropdownTile(
                    label: 'Maximum Daily Appointments Limit',
                    value: '${_local.maxDailyAppointments} Patients / Day',
                    options: ['10 Patients / Day', '15 Patients / Day', '20 Patients / Day', '25 Patients / Day', '30 Patients / Day'],
                    onChanged: (val) {
                      if (val != null) {
                        final limit = int.parse(val.split(' ')[0]);
                        setState(() {
                          _local = _local.copyWith(maxDailyAppointments: limit);
                        });
                      }
                    },
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Toggles & Explanations
          Text(
            'APPOINTMENT RULES & PERMISSIONS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 12),

          _buildSwitchTile(
            title: 'Accept New Patients',
            description: 'Allows first-time patient registrations and bookings into your clinical queue.',
            value: _local.acceptNewPatients,
            onChanged: (val) => setState(() => _local = _local.copyWith(acceptNewPatients: val)),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Allow Follow-up Appointments',
            description: 'Allows existing patients to schedule follow-up reviews and post-consultation check-ups.',
            value: _local.allowFollowUpAppointments,
            onChanged: (val) => setState(() => _local = _local.copyWith(allowFollowUpAppointments: val)),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Allow Emergency Assignments',
            description: 'Allows authorized hospital staff to assign emergency cases directly to your ER queue.',
            value: _local.allowEmergencyAssignments,
            onChanged: (val) => setState(() => _local = _local.copyWith(allowEmergencyAssignments: val)),
            isDark: isDark,
            isImportant: true,
          ),
          const SizedBox(height: 10),
          _buildSwitchTile(
            title: 'Allow Online Consultations',
            description: 'Enables telehealth video and remote clinical consultations.',
            value: _local.allowOnlineConsultations,
            onChanged: (val) => setState(() => _local = _local.copyWith(allowOnlineConsultations: val)),
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

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    bool isImportant = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImportant
              ? Colors.redAccent.withValues(alpha: 0.3)
              : HealthifyGlassTheme.getGlassBorder(isDark),
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
