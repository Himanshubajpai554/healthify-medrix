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

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  @override
  void initState() {
    super.initState();
    _localPrefs = widget.preferences.map((p) => p.copyWith()).toList();
  }

  Color _primaryColor(bool isDark) {
    return isDark ? _primaryDark : _primary;
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark);
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.58)
        : HealthifyGlassTheme.getTextSecondary(isDark);
  }

  Color _mutedText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.38)
        : HealthifyGlassTheme.getTextMuted(isDark);
  }

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.68);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.82);
  }

  void _updatePreference(
    NotificationPreferencesModel pref,
    NotificationPreferencesModel updated,
  ) {
    final index = _localPrefs.indexOf(pref);

    if (index == -1) return;

    setState(() {
      _localPrefs[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final primary = _primaryColor(isDark);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // HEADER
              // ============================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GlassIconContainer(
                    icon: Icons.tune_rounded,
                    size: 46,
                    iconSize: 22,
                    color: primary,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification Preferences',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: _primaryText(isDark),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Configure channels and alert categories for your workspace.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: _secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  _buildCloseButton(context, isDark: isDark),
                ],
              ),

              const SizedBox(height: 18),

              // ============================================================
              // HEADER DIVIDER
              // ============================================================
              Container(height: 1, color: _border(isDark)),

              const SizedBox(height: 16),

              // ============================================================
              // PREFERENCES
              // ============================================================
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _localPrefs.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pref = _localPrefs[index];

                      return _buildPreferenceCategory(pref, isDark);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============================================================
              // FOOTER DIVIDER
              // ============================================================
              Container(height: 1, color: _border(isDark)),

              const SizedBox(height: 16),

              // ============================================================
              // ACTIONS
              // ============================================================
              _buildBottomActions(context, isDark: isDark, primary: primary),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CLOSE BUTTON
  // ==========================================================================

  Widget _buildCloseButton(BuildContext context, {required bool isDark}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _border(isDark), width: 0.8),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 19,
            color: _secondaryText(isDark),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CATEGORY CARD
  // ==========================================================================

  Widget _buildPreferenceCategory(
    NotificationPreferencesModel pref,
    bool isDark,
  ) {
    final categoryColor = pref.category.color;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border(isDark), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // CATEGORY HEADER
          // ---------------------------------------------------------------
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: isDark ? 0.14 : 0.09),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: categoryColor.withValues(
                      alpha: isDark ? 0.18 : 0.14,
                    ),
                  ),
                ),
                child: Icon(pref.category.icon, size: 18, color: categoryColor),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  pref.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(isDark),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ---------------------------------------------------------------
          // CHANNEL OPTIONS
          // ---------------------------------------------------------------
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              if (isNarrow) {
                return Column(
                  children: [
                    _buildToggleOption(
                      label: 'In-App Alert',
                      subtitle: 'Workspace badge',
                      value: pref.inAppEnabled,
                      icon: Icons.notifications_active_outlined,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(inAppEnabled: value),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildToggleOption(
                      label: 'Push (Mobile)',
                      subtitle: 'Device push',
                      value: pref.pushEnabled,
                      icon: Icons.phone_android_rounded,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(pushEnabled: value),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    _buildToggleOption(
                      label: 'Email',
                      subtitle: 'Daily digest',
                      value: pref.emailEnabled,
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(emailEnabled: value),
                        );
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildToggleOption(
                      label: 'In-App Alert',
                      subtitle: 'Workspace badge',
                      value: pref.inAppEnabled,
                      icon: Icons.notifications_active_outlined,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(inAppEnabled: value),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildToggleOption(
                      label: 'Push (Mobile)',
                      subtitle: 'Device push',
                      value: pref.pushEnabled,
                      icon: Icons.phone_android_rounded,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(pushEnabled: value),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildToggleOption(
                      label: 'Email',
                      subtitle: 'Daily digest',
                      value: pref.emailEnabled,
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      onChanged: (value) {
                        _updatePreference(
                          pref,
                          pref.copyWith(emailEnabled: value),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOGGLE OPTION
  // ==========================================================================

  Widget _buildToggleOption({
    required String label,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    final primary = _primaryColor(isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: value
            ? primary.withValues(alpha: isDark ? 0.075 : 0.055)
            : _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? primary.withValues(alpha: isDark ? 0.28 : 0.20)
              : _border(isDark),
          width: value ? 1 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // ---------------------------------------------------------------
          // ICON
          // ---------------------------------------------------------------
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: value
                  ? primary.withValues(alpha: isDark ? 0.14 : 0.09)
                  : _surface(isDark),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 15,
              color: value ? primary : _mutedText(isDark),
            ),
          ),

          const SizedBox(width: 8),

          // ---------------------------------------------------------------
          // LABELS
          // ---------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.2, color: _mutedText(isDark)),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // ---------------------------------------------------------------
          // SWITCH
          // ---------------------------------------------------------------
          Transform.scale(
            scale: 0.72,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: primary,
              activeThumbColor: Colors.white,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.10),
              inactiveThumbColor: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTTOM ACTIONS
  // ==========================================================================

  Widget _buildBottomActions(
    BuildContext context, {
    required bool isDark,
    required Color primary,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 390;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCancelButton(context, isDark: isDark),

              const SizedBox(height: 8),

              _buildSaveButton(context, primary: primary),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildCancelButton(context, isDark: isDark),

            const SizedBox(width: 10),

            _buildSaveButton(context, primary: primary),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // CANCEL BUTTON
  // ==========================================================================

  Widget _buildCancelButton(BuildContext context, {required bool isDark}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border(isDark), width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _secondaryText(isDark),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SAVE BUTTON
  // ==========================================================================

  Widget _buildSaveButton(BuildContext context, {required Color primary}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onSavePreferences(_localPrefs);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, size: 16, color: Colors.white),
              SizedBox(width: 7),
              Text(
                'Save Preferences',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
