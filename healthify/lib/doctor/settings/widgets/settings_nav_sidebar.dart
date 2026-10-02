import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

enum ProfileSettingsTab {
  personalInfo,
  professionalInfo,
  availabilitySchedule,
  consultationSettings,
  notifications,
  privacy,
  security,
  preferences,
  helpSupport,
  account,
}

extension ProfileSettingsTabExtension on ProfileSettingsTab {
  String get label {
    switch (this) {
      case ProfileSettingsTab.personalInfo:
        return 'Personal Info';
      case ProfileSettingsTab.professionalInfo:
        return 'Professional & Hospital';
      case ProfileSettingsTab.availabilitySchedule:
        return 'Availability & Schedule';
      case ProfileSettingsTab.consultationSettings:
        return 'Consultation Preferences';
      case ProfileSettingsTab.notifications:
        return 'Notifications';
      case ProfileSettingsTab.privacy:
        return 'Privacy';
      case ProfileSettingsTab.security:
        return 'Security & Sessions';
      case ProfileSettingsTab.preferences:
        return 'Preferences & Theme';
      case ProfileSettingsTab.helpSupport:
        return 'Help & Support';
      case ProfileSettingsTab.account:
        return 'Account Management';
    }
  }

  IconData get icon {
    switch (this) {
      case ProfileSettingsTab.personalInfo:
        return Icons.person_rounded;
      case ProfileSettingsTab.professionalInfo:
        return Icons.card_membership_rounded;
      case ProfileSettingsTab.availabilitySchedule:
        return Icons.calendar_month_rounded;
      case ProfileSettingsTab.consultationSettings:
        return Icons.medical_services_rounded;
      case ProfileSettingsTab.notifications:
        return Icons.notifications_rounded;
      case ProfileSettingsTab.privacy:
        return Icons.lock_person_rounded;
      case ProfileSettingsTab.security:
        return Icons.security_rounded;
      case ProfileSettingsTab.preferences:
        return Icons.tune_rounded;
      case ProfileSettingsTab.helpSupport:
        return Icons.help_outline_rounded;
      case ProfileSettingsTab.account:
        return Icons.manage_accounts_rounded;
    }
  }
}

class SettingsNavSidebar extends StatelessWidget {
  final ProfileSettingsTab selectedTab;
  final ValueChanged<ProfileSettingsTab> onTabSelected;

  const SettingsNavSidebar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 10),
            child: Text(
              'SETTINGS SECTIONS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: HealthifyGlassTheme.getTextMuted(isDark),
              ),
            ),
          ),
          ...ProfileSettingsTab.values.map((tab) {
            final isSelected = selectedTab == tab;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                onTap: () => onTabSelected(tab),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.22 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : HealthifyGlassTheme.primaryTeal)
                                : HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
