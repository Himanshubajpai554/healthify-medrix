import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';

class NotificationPreferencesModal extends StatefulWidget {
  final List<NotificationPreferencesModel> preferences;
  final ValueChanged<List<NotificationPreferencesModel>> onSavePreferences;

  const NotificationPreferencesModal({
    super.key,
    required this.preferences,
    required this.onSavePreferences,
  });

  @override
  State<NotificationPreferencesModal> createState() =>
      _NotificationPreferencesModalState();
}

class _NotificationPreferencesModalState
    extends State<NotificationPreferencesModal> {
  late List<NotificationPreferencesModel> _localPrefs;

  @override
  void initState() {
    super.initState();
    _localPrefs = widget.preferences.map((p) => p.copyWith()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Close
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.tune_rounded,
                    size: 44,
                    iconSize: 22,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Configure channels and alert categories for your workspace.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              // Category Preferences List
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _localPrefs.map((pref) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: HealthifyGlassTheme.getGlassBorder(isDark),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    pref.category.icon,
                                    size: 18,
                                    color: pref.category.color,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    pref.category.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildToggleOption(
                                      label: 'In-App Alert',
                                      subtitle: 'Workspace badge',
                                      value: pref.inAppEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          final idx = _localPrefs.indexOf(pref);
                                          _localPrefs[idx] = pref.copyWith(inAppEnabled: val);
                                        });
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildToggleOption(
                                      label: 'Push (Mobile)',
                                      subtitle: 'Device push',
                                      value: pref.pushEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          final idx = _localPrefs.indexOf(pref);
                                          _localPrefs[idx] = pref.copyWith(pushEnabled: val);
                                        });
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildToggleOption(
                                      label: 'Email',
                                      subtitle: 'Daily digest',
                                      value: pref.emailEnabled,
                                      onChanged: (val) {
                                        setState(() {
                                          final idx = _localPrefs.indexOf(pref);
                                          _localPrefs[idx] = pref.copyWith(emailEnabled: val);
                                        });
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassSecondaryButton(
                    height: 40,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  GlassPrimaryButton(
                    height: 40,
                    onPressed: () {
                      widget.onSavePreferences(_localPrefs);
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.save_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Save Preferences',
                          style: TextStyle(fontSize: 13, color: Colors.white),
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
    );
  }

  Widget _buildToggleOption({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: HealthifyGlassTheme.primaryTeal,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
