import 'package:flutter/material.dart';
import '../../main.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/doctor_profile_models.dart';
import '../notifications/widgets/notification_preferences_modal.dart';
import '../services/doctor_notification_service.dart';
import '../services/doctor_profile_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/account_management_section.dart';
import 'widgets/availability_schedule_section.dart';
import 'widgets/consultation_settings_section.dart';
import 'widgets/general_preferences_section.dart';
import 'widgets/help_support_section.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/privacy_settings_section.dart';
import 'widgets/professional_info_section.dart';
import 'widgets/profile_settings_header.dart';
import 'widgets/security_settings_section.dart';
import 'widgets/settings_nav_sidebar.dart';

class DoctorProfileSettingsScreen extends StatefulWidget {
  final bool embedInDashboard;
  const DoctorProfileSettingsScreen({
    super.key,
    this.embedInDashboard = false,
  });

  @override
  State<DoctorProfileSettingsScreen> createState() =>
      _DoctorProfileSettingsScreenState();
}

class _DoctorProfileSettingsScreenState
    extends State<DoctorProfileSettingsScreen> {
  final DoctorProfileService _profileService = DoctorProfileService();
  final DoctorNotificationService _notificationService = DoctorNotificationService();

  int _selectedNavIndex = 10; // Settings index
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;

  ProfileSettingsTab _selectedSettingsTab = ProfileSettingsTab.personalInfo;

  late DoctorProfileModel _profile;
  late ProfessionalInfoModel _professionalInfo;
  late List<HospitalAffiliationModel> _hospitalAffiliations;
  late List<DayScheduleModel> _weeklySchedule;
  late List<AvailabilityExceptionModel> _exceptions;
  late ConsultationSettingsModel _consultationSettings;
  late DoctorPrivacySettingsModel _privacySettings;
  late DoctorSecurityModel _securityInfo;
  late List<DoctorSecuritySessionModel> _sessions;
  late List<DoctorLoginActivityModel> _loginActivity;
  late DoctorPreferencesModel _preferences;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _profile = _profileService.getProfile();
    _professionalInfo = _profileService.getProfessionalInfo();
    _hospitalAffiliations = _profileService.getHospitalAffiliations();
    _weeklySchedule = _profileService.getWeeklySchedule();
    _exceptions = _profileService.getAvailabilityExceptions();
    _consultationSettings = _profileService.getConsultationSettings();
    _privacySettings = _profileService.getPrivacySettings();
    _securityInfo = _profileService.getSecurityInfo();
    _sessions = _profileService.getActiveSessions();
    _loginActivity = _profileService.getLoginActivity();
    _preferences = _profileService.getPreferences();
    _availabilityStatus = _profile.availabilityStatus;
  }

  void _onNavItemSelected(int index) {
    if (index == _selectedNavIndex) return;

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/doctor-appointments');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/doctor-patients');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/doctor-patient-profile');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/doctor-reports');
        break;
      case 5:
        Navigator.of(context).pushReplacementNamed('/doctor-prescriptions');
        break;
      case 6:
        Navigator.of(context).pushReplacementNamed('/doctor-emergency-cases');
        break;
      case 7:
        Navigator.of(context).pushReplacementNamed('/doctor-patient-followups');
        break;
      case 8:
        Navigator.of(context).pushReplacementNamed('/doctor-analytics');
        break;
      case 9:
        Navigator.of(context).pushReplacementNamed('/doctor-notifications');
        break;
      case 10:
        // Already on Settings
        break;
      case 11:
        Navigator.of(context).pushReplacementNamed('/doctor-help');
        break;
      default:
        break;
    }
  }

  void _openPhotoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = HealthifyGlassTheme.isDarkMode(ctx);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: HealthifyGlassTheme.primaryTeal),
                title: const Text('Take Photo via Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uploading photo from camera...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: HealthifyGlassTheme.primaryTeal),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uploading photo from gallery...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile photo removed.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    if (widget.embedInDashboard) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSettingsHeader(
              profile: _profile,
              professionalInfo: _professionalInfo,
            ),
            const SizedBox(height: 16),
            _buildActiveSettingsContent(),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark
              ? HealthifyGlassTheme.darkBackground
              : HealthifyGlassTheme.lightBackground,
        ),
        child: Row(
          children: [
            // Sidebar Navigation
            DoctorSidebar(
              selectedNavIndex: _selectedNavIndex,
              onNavItemSelected: _onNavItemSelected,
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
              availabilityStatus: _availabilityStatus,
              onLogout: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              onRoleSwitcherTap: () {},
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Navigation Header
                  DoctorHeader(
                    doctorName: _profile.fullName,
                    title: 'Profile & Settings',
                    subtitle: 'Credentials, OPD Schedule & Preferences',
                    availabilityStatus: _availabilityStatus,
                    onAvailabilityChanged: (status) {
                      setState(() {
                        _availabilityStatus = status;
                        _profile = _profile.copyWith(availabilityStatus: status);
                      });
                    },
                    onNotificationTap: () {
                      Navigator.of(context).pushNamed('/doctor-notifications');
                    },
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {
                      themeNotifier.value = themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                    unreadNotificationsCount: _notificationService.getUnreadCount(),
                  ),

                  // Workspace Body
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 1000;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Page Header with Profile Summary Badge
                              ProfileSettingsHeader(
                                profile: _profile,
                                professionalInfo: _professionalInfo,
                              ),
                              const SizedBox(height: 16),

                              // 2. Main Content: Sidebar + Active Settings Section
                              if (isDesktop) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Settings Navigation Sidebar
                                    SizedBox(
                                      width: 260,
                                      child: SettingsNavSidebar(
                                        selectedTab: _selectedSettingsTab,
                                        onTabSelected: (tab) {
                                          setState(() {
                                            _selectedSettingsTab = tab;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Active Settings Content Panel
                                    Expanded(
                                      child: _buildActiveSettingsContent(),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Mobile/Tablet: Horizontal Scrollable Tabs
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: ProfileSettingsTab.values.map((tab) {
                                      final isSel = _selectedSettingsTab == tab;

                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Text(tab.label),
                                          selected: isSel,
                                          selectedColor: HealthifyGlassTheme.primaryTeal,
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() {
                                                _selectedSettingsTab = tab;
                                              });
                                            }
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActiveSettingsContent(),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSettingsContent() {
    switch (_selectedSettingsTab) {
      case ProfileSettingsTab.personalInfo:
        return PersonalInfoSection(
          profile: _profile,
          onSaveProfile: (updated) async {
            await _profileService.updatePersonalInformation(updated);
            setState(() {
              _profile = updated;
            });
          },
          onChangePhotoTap: _openPhotoModal,
        );

      case ProfileSettingsTab.professionalInfo:
        return ProfessionalInfoSection(
          professionalInfo: _professionalInfo,
          hospitalAffiliations: _hospitalAffiliations,
        );

      case ProfileSettingsTab.availabilitySchedule:
        return AvailabilityScheduleSection(
          currentStatus: _availabilityStatus,
          onStatusChanged: (status) {
            setState(() {
              _availabilityStatus = status;
              _profile = _profile.copyWith(availabilityStatus: status);
            });
          },
          weeklySchedule: _weeklySchedule,
          onSaveSchedule: (newSchedule) async {
            await _profileService.updateWeeklySchedule(newSchedule);
            setState(() {
              _weeklySchedule = newSchedule;
            });
          },
          exceptions: _exceptions,
          onAddException: (item) async {
            await _profileService.addAvailabilityException(item);
            setState(() {
              _exceptions = _profileService.getAvailabilityExceptions();
            });
          },
          onRemoveException: (id) async {
            await _profileService.removeAvailabilityException(id);
            setState(() {
              _exceptions = _profileService.getAvailabilityExceptions();
            });
          },
        );

      case ProfileSettingsTab.consultationSettings:
        return ConsultationSettingsSection(
          settings: _consultationSettings,
          onSaveSettings: (updated) async {
            await _profileService.updateConsultationSettings(updated);
            setState(() {
              _consultationSettings = updated;
            });
          },
        );

      case ProfileSettingsTab.notifications:
        return _buildNotificationPreferencesView();

      case ProfileSettingsTab.privacy:
        return PrivacySettingsSection(
          privacySettings: _privacySettings,
          onSavePrivacySettings: (updated) async {
            await _profileService.updatePrivacySettings(updated);
            setState(() {
              _privacySettings = updated;
            });
          },
        );

      case ProfileSettingsTab.security:
        return SecuritySettingsSection(
          securityInfo: _securityInfo,
          sessions: _sessions,
          loginActivity: _loginActivity,
          onChangePassword: (curr, next) async {
            return await _profileService.changePassword(
              currentPassword: curr,
              newPassword: next,
            );
          },
          onSignOutSession: (sessionId) async {
            await _profileService.signOutSession(sessionId);
            setState(() {
              _sessions = _profileService.getActiveSessions();
            });
          },
          onSignOutOtherSessions: () async {
            await _profileService.signOutAllOtherSessions();
            setState(() {
              _sessions = _profileService.getActiveSessions();
            });
          },
        );

      case ProfileSettingsTab.preferences:
        return GeneralPreferencesSection(
          preferences: _preferences,
          onSavePreferences: (updated) async {
            await _profileService.updatePreferences(updated);
            setState(() {
              _preferences = updated;
            });
          },
        );

      case ProfileSettingsTab.helpSupport:
        return const HelpSupportSection();

      case ProfileSettingsTab.account:
        return AccountManagementSection(
          doctorId: _profile.id,
          hospitalName: 'Medrix City Hospital',
          onSignOut: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        );
    }
  }

  Widget _buildNotificationPreferencesView() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.notifications_rounded,
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
                      'Notification Channels & Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Configure workspace alert triggers and delivery preferences.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              GlassPrimaryButton(
                height: 38,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) {
                      return NotificationPreferencesModal(
                        preferences: _notificationService.getPreferences(),
                        onSavePreferences: (updatedPrefs) {
                          for (final pref in updatedPrefs) {
                            _notificationService.updatePreference(pref);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification preferences saved.'),
                              backgroundColor: HealthifyGlassTheme.primaryTeal,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Configure Notifications', style: TextStyle(fontSize: 12.5, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          Text(
            'Active Alert Channels:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 10),
          _buildChannelStatusTile('In-App Workspace Alerts', 'Enabled (Real-time header & badge alerts)', true, isDark),
          const SizedBox(height: 8),
          _buildChannelStatusTile('Mobile Push Notifications', 'Coming Soon (Enabled for Emergency & Lab Alerts)', false, isDark),
          const SizedBox(height: 8),
          _buildChannelStatusTile('Email Digest & Direct Summaries', 'Coming Soon (Enabled for Hospital Protocol Notices)', false, isDark),
        ],
      ),
    );
  }

  Widget _buildChannelStatusTile(String title, String subtitle, bool isEnabled, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 20,
            color: isEnabled ? const Color(0xFF10B981) : Colors.amber,
          ),
          const SizedBox(width: 12),
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
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
