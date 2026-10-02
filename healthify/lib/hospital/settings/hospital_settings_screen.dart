import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';

enum SettingsSaveState { idle, modified, saving, success, error }

class HospitalSettingsScreen extends StatefulWidget {
  const HospitalSettingsScreen({super.key});

  @override
  State<HospitalSettingsScreen> createState() => _HospitalSettingsScreenState();
}

class _HospitalSettingsScreenState extends State<HospitalSettingsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  SettingsSaveState _saveState = SettingsSaveState.idle;
  String? _statusMessage;

  // Local editable copies of models
  HospitalSettings? _hospitalSettings;
  OperationalSettings? _operationalSettings;
  EmergencySettings? _emergencySettings;
  BedManagementSettings? _bedSettings;
  BloodBankSettings? _bloodSettings;
  NotificationSystemSettings? _notificationSettings;
  AISettings? _aiSettings;
  SecuritySettings? _securitySettings;
  UserPreferences? _userPreferences;
  AppearanceSettings? _appearanceSettings;
  SystemInformation _systemInfo = const SystemInformation();
  List<ConfigurationChange> _configHistory = [];

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  final List<_SettingsCategoryDef> _categories = const [
    _SettingsCategoryDef(0, 'Hospital Identity', 'Legal name, contact & operating mode', Icons.domain_rounded),
    _SettingsCategoryDef(1, 'Operations & OPD', 'Appointment slots, buffers & walk-ins', Icons.access_time_filled_rounded),
    _SettingsCategoryDef(2, 'Emergency & Triage', '24/7 readiness & trauma center levels', Icons.emergency_rounded),
    _SettingsCategoryDef(3, 'Bed & ICU Capacity', 'Occupancy warning thresholds & alerts', Icons.single_bed_rounded),
    _SettingsCategoryDef(4, 'Blood Bank Config', 'Expiry warnings & critical stock limits', Icons.opacity_rounded),
    _SettingsCategoryDef(5, 'Notification System', 'Multi-channel alerts & retention', Icons.notifications_active_rounded),
    _SettingsCategoryDef(6, 'AI & Forecasting', 'ML insight toggles & confidence limits', Icons.auto_awesome_rounded),
    _SettingsCategoryDef(7, 'Security & Governance', 'Session timeouts & audit policies', Icons.shield_rounded),
    _SettingsCategoryDef(8, 'User Preferences', 'Language, landing page & compact mode', Icons.person_rounded),
    _SettingsCategoryDef(9, 'System & Swap Info', 'App version & backend swap readiness', Icons.info_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repoScope = RepositoryScope.of(context);

      final settingsService = SettingsService(
        settingsRepository: repoScope.settingsRepository,
        auditService: AuditService(auditRepository: repoScope.auditRepository),
        notificationService: NotificationService(notificationRepository: repoScope.notificationRepository),
      );

      final hospital = await settingsService.getHospitalSettings('HOSP-101');
      final operational = await settingsService.getOperationalSettings('HOSP-101');
      final emergency = await settingsService.getEmergencySettings('HOSP-101');
      final bed = await settingsService.getBedManagementSettings('HOSP-101');
      final blood = await settingsService.getBloodBankSettings('HOSP-101');
      final notification = await settingsService.getNotificationSystemSettings('HOSP-101');
      final ai = await settingsService.getAISettings('HOSP-101');
      final security = await settingsService.getSecuritySettings('HOSP-101');
      final pref = await settingsService.getUserPreferences('USR-001');
      final appearance = await settingsService.getAppearanceSettings('USR-001');
      final sysInfo = await settingsService.getSystemInformation();
      final history = await settingsService.getConfigurationHistory('HOSP-101');

      if (mounted) {
        setState(() {
          _hospitalSettings = hospital;
          _operationalSettings = operational;
          _emergencySettings = emergency;
          _bedSettings = bed;
          _bloodSettings = blood;
          _notificationSettings = notification;
          _aiSettings = ai;
          _securitySettings = security;
          _userPreferences = pref;
          _appearanceSettings = appearance;
          _systemInfo = sysInfo;
          _configHistory = history;
          _isLoading = false;
          _saveState = SettingsSaveState.idle;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load settings: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _markModified() {
    if (_saveState != SettingsSaveState.modified) {
      setState(() {
        _saveState = SettingsSaveState.modified;
      });
    }
  }

  Future<void> _saveCurrentSettings() async {
    if (_saveState == SettingsSaveState.saving) return;

    setState(() {
      _saveState = SettingsSaveState.saving;
      _statusMessage = 'Saving settings to local store...';
    });

    try {
      final repoScope = RepositoryScope.of(context);
      final settingsService = SettingsService(
        settingsRepository: repoScope.settingsRepository,
        auditService: AuditService(auditRepository: repoScope.auditRepository),
        notificationService: NotificationService(notificationRepository: repoScope.notificationRepository),
      );

      const currentUserId = 'ADM-001';
      const currentUserRole = UserRole.hospitalAdmin;

      // 1. Validate & Save Hospital Settings
      if (_hospitalSettings != null) {
        final res = await settingsService.updateHospitalSettings(
          _hospitalSettings!,
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 2. Validate & Save Operational Settings
      if (_operationalSettings != null) {
        final res = await settingsService.updateOperationalSettings(
          _operationalSettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 3. Validate & Save Emergency Settings
      if (_emergencySettings != null) {
        final res = await settingsService.updateEmergencySettings(
          _emergencySettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 4. Validate & Save Bed Settings
      if (_bedSettings != null) {
        final res = await settingsService.updateBedManagementSettings(
          _bedSettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 5. Validate & Save Blood Bank Settings
      if (_bloodSettings != null) {
        final res = await settingsService.updateBloodBankSettings(
          _bloodSettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 6. Validate & Save Notification Settings
      if (_notificationSettings != null) {
        final res = await settingsService.updateNotificationSystemSettings(
          _notificationSettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 7. Validate & Save AI Settings
      if (_aiSettings != null) {
        final res = await settingsService.updateAISettings(
          _aiSettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 8. Validate & Save Security Settings
      if (_securitySettings != null) {
        final res = await settingsService.updateSecuritySettings(
          _securitySettings!,
          hospitalId: 'HOSP-101',
          userId: currentUserId,
          role: currentUserRole,
        );
        if (!res.isValid) {
          _showValidationError(res.errors);
          return;
        }
      }

      // 9. Save User Preferences & Appearance
      if (_userPreferences != null) {
        await settingsService.updateUserPreferences(_userPreferences!);
      }
      if (_appearanceSettings != null) {
        await settingsService.updateAppearanceSettings(_appearanceSettings!, userId: currentUserId);
      }

      // Refresh history
      final history = await settingsService.getConfigurationHistory('HOSP-101');

      if (mounted) {
        setState(() {
          _configHistory = history;
          _saveState = SettingsSaveState.success;
          _statusMessage = 'All configurations updated and validated successfully!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Hospital configuration saved & audit logged!'),
              ],
            ),
            backgroundColor: HealthifyGlassTheme.primaryTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saveState = SettingsSaveState.error;
          _statusMessage = 'Failed to save configuration: $e';
        });
      }
    }
  }

  void _showValidationError(List<String> errors) {
    setState(() {
      _saveState = SettingsSaveState.error;
      _statusMessage = 'Validation failed';
    });

    showDialog(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text('Validation Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(e)),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showDangerousSettingWarning(String title, String warningText) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            warningText,
            style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            GlassPrimaryButton(
              height: 40,
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm Change'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (_isLoading) {
      return const MedrixLoadingState(message: 'Loading hospital settings & parameters...');
    }

    if (_errorMessage != null) {
      return MedrixErrorState(
        errorMessage: _errorMessage!,
        onRetry: _loadAllSettings,
      );
    }

    return Column(
      children: [
        // Top Header with Search & Global Save Indicator
        _buildTopHeader(isDark, isDesktop),

        // Main Body: Sidebar + Active Settings Category
        Expanded(
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: _buildSidebar(isDark),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _buildCategoryContent(isDark),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildMobileCategoryTabs(isDark),
                    Expanded(child: _buildCategoryContent(isDark)),
                  ],
                ),
        ),

        // Bottom Save Action Bar if modified
        if (_saveState == SettingsSaveState.modified ||
            _saveState == SettingsSaveState.saving ||
            _saveState == SettingsSaveState.success ||
            _saveState == SettingsSaveState.error)
          _buildSaveActionBar(isDark),
      ],
    );
  }

  Widget _buildTopHeader(bool isDark, bool isDesktop) {
    return GlassCard(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const GlassIconContainer(
            icon: Icons.settings_rounded,
            size: 40,
            iconSize: 22,
            color: HealthifyGlassTheme.primaryTeal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hospital Settings & System Configuration',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  'Manage operational parameters, security, AI policies & backend integration',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          SizedBox(
            width: isDesktop ? 260 : 160,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search settings...',
                hintStyle: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: HealthifyGlassTheme.getGlassSurface(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllSettings,
            tooltip: 'Reload Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    final filtered = _categories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      return cat.title.toLowerCase().contains(_searchQuery) ||
          cat.subtitle.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.05),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final cat = filtered[index];
          final isSelected = _selectedCategoryIndex == cat.id;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = cat.id;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    size: 20,
                    color: isSelected
                        ? HealthifyGlassTheme.primaryTeal
                        : HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          cat.subtitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileCategoryTabs(bool isDark) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : HealthifyGlassTheme.primaryTeal),
              label: Text(cat.title, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark))),
              selectedColor: HealthifyGlassTheme.primaryTeal,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategoryIndex = cat.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          switch (_selectedCategoryIndex) {
            0 => _buildHospitalIdentitySection(isDark),
            1 => _buildOperationalSection(isDark),
            2 => _buildEmergencySection(isDark),
            3 => _buildBedSection(isDark),
            4 => _buildBloodBankSection(isDark),
            5 => _buildNotificationSection(isDark),
            6 => _buildAISection(isDark),
            7 => _buildSecuritySection(isDark),
            8 => _buildUserPreferencesSection(isDark),
            9 => _buildSystemInfoSection(isDark),
            _ => const SizedBox(),
          },
        ],
      ),
    );
  }

  // --- Category 0: Hospital Identity & Operating Mode ---
  Widget _buildHospitalIdentitySection(bool isDark) {
    if (_hospitalSettings == null) return const SizedBox();
    final h = _hospitalSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Hospital Identity & Operating Mode', 'Official institution parameters, registration, & active emergency mode', Icons.domain_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operating Mode', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              const SizedBox(height: 6),
              Text(
                'Changing operating mode adjusts alert escalation, triage routing, and bed allocation priorities across Medrix.',
                style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: h.operatingMode,
                decoration: InputDecoration(

                  filled: true,
                  fillColor: HealthifyGlassTheme.getGlassSurface(isDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'Normal Operations', child: Text('Normal Operations')),
                  DropdownMenuItem(value: 'Emergency Surge Mode', child: Text('Emergency Surge Mode (High Capacity)')),
                  DropdownMenuItem(value: 'Maintenance Mode', child: Text('Maintenance Mode (Restricted Check-in)')),
                  DropdownMenuItem(value: 'Disaster Response Mode', child: Text('Disaster Response Mode (Mass Casualty Triage)')),
                ],
                onChanged: (val) async {
                  if (val != null && val != h.operatingMode) {
                    if (val.contains('Disaster') || val.contains('Surge')) {
                      final confirmed = await _showDangerousSettingWarning(
                        'Confirm High-Impact Operating Mode',
                        'Switching hospital mode to $val will trigger high-priority alerts across all staff dispatch terminals.',
                      );
                      if (!confirmed) return;
                    }
                    setState(() {
                      _hospitalSettings = h.copyWith(operatingMode: val);
                    });
                    _markModified();
                  }
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Display Name', h.displayName, isDark, (v) {
                      _hospitalSettings = h.copyWith(displayName: v);
                      _markModified();
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Legal Institution Name', h.legalName, isDark, (v) {
                      _hospitalSettings = h.copyWith(legalName: v);
                      _markModified();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Hospital Type / Specialty', h.hospitalType, isDark, (v) {
                      _hospitalSettings = h.copyWith(hospitalType: v);
                      _markModified();
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Medical License ID', h.licenseId, isDark, (v) {
                      _hospitalSettings = h.copyWith(licenseId: v);
                      _markModified();
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Contact Email', h.email, isDark, (v) {
                      _hospitalSettings = h.copyWith(email: v);
                      _markModified();
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Main Telephone', h.phone, isDark, (v) {
                      _hospitalSettings = h.copyWith(phone: v);
                      _markModified();
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('24/7 Emergency Helpline', h.emergencyHelpline, isDark, (v) {
                      _hospitalSettings = h.copyWith(emergencyHelpline: v);
                      _markModified();
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 1: Operational & OPD ---
  Widget _buildOperationalSection(bool isDark) {
    if (_operationalSettings == null) return const SizedBox();
    final op = _operationalSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Operations & OPD Configuration', 'Appointment scheduling parameters, queue displays, & walk-in rules', Icons.access_time_filled_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            children: [
              _buildSwitchTile(
                'Allow OPD Walk-In Patients',
                'Enable front desk to register un-scheduled walk-in patients into daily doctor queues',
                op.allowWalkIns,
                (v) {
                  setState(() => _operationalSettings = op.copyWith(allowWalkIns: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Allow Online Patient Self-Booking',
                'Allow registered patients to book appointments via Medrix mobile app',
                op.allowOnlineAppointments,
                (v) {
                  setState(() => _operationalSettings = op.copyWith(allowOnlineAppointments: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Enable Real-Time Waiting Room Queue Display',
                'Stream OPD queue numbers to lobby display screens and patient apps',
                op.queueDisplayEnabled,
                (v) {
                  setState(() => _operationalSettings = op.copyWith(queueDisplayEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField('Default Appointment Duration (mins)', op.defaultAppointmentDuration, isDark, (v) {
                      if (v != null) {
                        setState(() => _operationalSettings = op.copyWith(defaultAppointmentDuration: v));
                        _markModified();
                      }
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField('Buffer Between Appointments (mins)', op.appointmentBufferMinutes, isDark, (v) {
                      if (v != null) {
                        setState(() => _operationalSettings = op.copyWith(appointmentBufferMinutes: v));
                        _markModified();
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField('Max Advance Booking Window (days)', op.maxAdvanceBookingDays, isDark, (v) {
                      if (v != null) {
                        setState(() => _operationalSettings = op.copyWith(maxAdvanceBookingDays: v));
                        _markModified();
                      }
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField('No-Show Warning Threshold (missed visits)', op.noShowThreshold, isDark, (v) {
                      if (v != null) {
                        setState(() => _operationalSettings = op.copyWith(noShowThreshold: v));
                        _markModified();
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 2: Emergency & Triage ---
  Widget _buildEmergencySection(bool isDark) {
    if (_emergencySettings == null) return const SizedBox();
    final em = _emergencySettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Emergency & Triage Configuration', '24/7 emergency readiness, trauma center designation, & ambulance dispatch', Icons.emergency_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchTile(
                '24/7 Emergency Department Active',
                'Accept incoming emergency walk-ins and ambulance arrivals 24 hours a day',
                em.is24HourEmergency,
                (v) async {
                  if (!v) {
                    final confirm = await _showDangerousSettingWarning(
                      'Disable Emergency Department?',
                      'Disabling 24/7 emergency services will stop automatic ambulance intake routing.',
                    );
                    if (!confirm) return;
                  }
                  setState(() => _emergencySettings = em.copyWith(is24HourEmergency: v, emergencyServicesEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Manchester Emergency Triage System',
                'Require triage nurse grading (Level 1 Red to Level 5 Blue) for all arrivals',
                em.triageEnabled,
                (v) {
                  setState(() => _emergencySettings = em.copyWith(triageEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Ambulance Network Dispatch Synchronization',
                'Sync local emergency bay availability with regional ambulance dispatch systems',
                em.ambulanceServiceEnabled,
                (v) {
                  setState(() => _emergencySettings = em.copyWith(ambulanceServiceEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const SizedBox(height: 20),
              Text('Trauma Center Level Designation', style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: em.traumaLevel,
                decoration: InputDecoration(

                  filled: true,
                  fillColor: HealthifyGlassTheme.getGlassSurface(isDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'Level 1 Comprehensive Trauma Center', child: Text('Level 1 - Comprehensive Academic Trauma Center')),
                  DropdownMenuItem(value: 'Level 2 Major Trauma Center', child: Text('Level 2 - Major Trauma Center')),
                  DropdownMenuItem(value: 'Level 3 General Emergency Facility', child: Text('Level 3 - General Emergency Facility')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _emergencySettings = em.copyWith(traumaLevel: val));
                    _markModified();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 3: Bed & ICU Capacity ---
  Widget _buildBedSection(bool isDark) {
    if (_bedSettings == null) return const SizedBox();
    final bed = _bedSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Bed & ICU Management Settings', 'Sanitization protocols, occupancy warning thresholds, & auto-release rules', Icons.single_bed_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchTile(
                'Allow Inpatient Bed Reservations',
                'Permit advance bed reservation during pre-admission workflow',
                bed.allowReservations,
                (v) {
                  setState(() => _bedSettings = bed.copyWith(allowReservations: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Require Sanitation Clearance Before Assignment',
                'Beds must be marked as "Cleaned & Disinfected" by housekeeping prior to patient assignment',
                bed.sanitizationRequired,
                (v) {
                  setState(() => _bedSettings = bed.copyWith(sanitizationRequired: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Automated High Occupancy Alerts',
                'Trigger system notifications when ward or ICU capacity crosses warning limits',
                bed.occupancyAlerts,
                (v) {
                  setState(() => _bedSettings = bed.copyWith(occupancyAlerts: v));
                  _markModified();
                },
                isDark,
              ),
              const SizedBox(height: 20),
              _buildSliderTile(
                'General Ward Capacity Warning Threshold',
                'Current limit: ${(bed.capacityWarningThreshold * 100).toInt()}%',
                bed.capacityWarningThreshold,
                0.50,
                0.95,
                (v) {
                  setState(() => _bedSettings = bed.copyWith(capacityWarningThreshold: v));
                  _markModified();
                },
                isDark,
              ),
              const SizedBox(height: 12),
              _buildSliderTile(
                'ICU Critical Capacity Alert Threshold',
                'Current limit: ${(bed.icuCriticalThreshold * 100).toInt()}%',
                bed.icuCriticalThreshold,
                0.60,
                0.99,
                (v) {
                  setState(() => _bedSettings = bed.copyWith(icuCriticalThreshold: v));
                  _markModified();
                },
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 4: Blood Bank ---
  Widget _buildBloodBankSection(bool isDark) {
    if (_bloodSettings == null) return const SizedBox();
    final bl = _bloodSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Blood Bank & Transfusion Settings', 'Stock replenishment rules, quarantine validation, & unit expiration warnings', Icons.opacity_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            children: [
              _buildSwitchTile(
                'Enable Blood Unit Pre-Reservation',
                'Allow surgical teams to pre-reserve cross-matched units 24h prior to procedure',
                bl.reservationEnabled,
                (v) {
                  setState(() => _bloodSettings = bl.copyWith(reservationEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const Divider(),
              _buildSwitchTile(
                'Enforce Quarantine Protocol for New Donations',
                'Newly donated blood units remain in Quarantine status until lab testing passes',
                bl.quarantineEnabled,
                (v) {
                  setState(() => _bloodSettings = bl.copyWith(quarantineEnabled: v));
                  _markModified();
                },
                isDark,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField('Expiration Warning Advance Days', bl.expiryWarningDays, isDark, (v) {
                      if (v != null) {
                        setState(() => _bloodSettings = bl.copyWith(expiryWarningDays: v));
                        _markModified();
                      }
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField('Critical Group Minimum Units Threshold', bl.criticalStockThreshold, isDark, (v) {
                      if (v != null) {
                        setState(() => _bloodSettings = bl.copyWith(criticalStockThreshold: v));
                        _markModified();
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 5: Notification System ---
  Widget _buildNotificationSection(bool isDark) {
    if (_notificationSettings == null) return const SizedBox();
    final nt = _notificationSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notification & Dispatch Settings', 'Multi-channel delivery rules, emergency broadcasts, & retention periods', Icons.notifications_active_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            children: [
              _buildSwitchTile('In-App Header & Drawer Alerts', 'Deliver real-time toast and badge notifications within portal', nt.inAppEnabled, (v) {
                setState(() => _notificationSettings = nt.copyWith(inAppEnabled: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('Mobile Push Notifications', 'Dispatch high-priority push notifications to staff mobile devices', nt.pushEnabled, (v) {
                setState(() => _notificationSettings = nt.copyWith(pushEnabled: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('Emergency Critical Broadcasts', 'Override quiet hours for Code Red and ICU emergency broadcasts', nt.criticalAlertsEnabled, (v) {
                setState(() => _notificationSettings = nt.copyWith(criticalAlertsEnabled: v));
                _markModified();
              }, isDark),
              const SizedBox(height: 20),
              _buildNumberField('Notification Audit Log Retention (days)', nt.notificationRetentionDays, isDark, (v) {
                if (v != null) {
                  setState(() => _notificationSettings = nt.copyWith(notificationRetentionDays: v));
                  _markModified();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 6: AI & Forecasting ---
  Widget _buildAISection(bool isDark) {
    if (_aiSettings == null) return const SizedBox();
    final ai = _aiSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AI & Operational Analytics Controls', 'Clinical recommendation policies, forecasting models, & transparency settings', Icons.auto_awesome_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchTile('AI Resource Allocation Insights', 'Generate predictive recommendations for staff rosters and bed capacity', ai.aiInsightsEnabled, (v) {
                setState(() => _aiSettings = ai.copyWith(aiInsightsEnabled: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('ER Triage Assistive Recommendations', 'Suggest triage urgency scores based on vital signs & chief complaint', ai.emergencyRecommendationEnabled, (v) {
                setState(() => _aiSettings = ai.copyWith(emergencyRecommendationEnabled: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('Display Model Confidence & Limitations', 'Mandate displaying predictive confidence percentages and clinical disclaimers', ai.showForecastLimitations, (v) {
                setState(() => _aiSettings = ai.copyWith(showForecastLimitations: v));
                _markModified();
              }, isDark),
              const SizedBox(height: 20),
              _buildSliderTile(
                'Minimum Required Confidence Threshold for Display',
                'Current threshold: ${(ai.confidenceThreshold * 100).toInt()}%',
                ai.confidenceThreshold,
                0.60,
                0.95,
                (v) {
                  setState(() => _aiSettings = ai.copyWith(confidenceThreshold: v));
                  _markModified();
                },
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 7: Security & Governance ---
  Widget _buildSecuritySection(bool isDark) {
    if (_securitySettings == null) return const SizedBox();
    final sec = _securitySettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Security, Privacy & Audit Logging', 'Session expiry, break-glass access protocols, & audit trail retention', Icons.shield_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            children: [
              _buildSwitchTile('Enforce Detailed Audit Trail Logging', 'Log every clinical record access, edit, & patient lookup action', sec.auditLoggingEnabled, (v) {
                setState(() => _securitySettings = sec.copyWith(auditLoggingEnabled: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('Emergency Break-Glass Access Protocol', 'Allow authorized physicians emergency access to restricted records with mandatory audit', sec.breakGlassEnabled, (v) {
                setState(() => _securitySettings = sec.copyWith(breakGlassEnabled: v));
                _markModified();
              }, isDark),
              const SizedBox(height: 20),
              _buildNumberField('Inactivity Session Timeout (minutes)', sec.sessionTimeoutMinutes, isDark, (v) {
                if (v != null) {
                  setState(() => _securitySettings = sec.copyWith(sessionTimeoutMinutes: v));
                  _markModified();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 8: User Preferences ---
  Widget _buildUserPreferencesSection(bool isDark) {
    if (_userPreferences == null) return const SizedBox();
    final pref = _userPreferences!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('User Personalization & Display', 'Language, default start screen, sound, & motion preferences', Icons.person_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            children: [
              _buildSwitchTile('Compact Display Density Mode', 'Reduce padding and table margins for dense data viewing', pref.compactMode, (v) {
                setState(() => _userPreferences = pref.copyWith(compactMode: v));
                _markModified();
              }, isDark),
              const Divider(),
              _buildSwitchTile('In-App Notification Audio Tones', 'Play subtle acoustic feedback for high-priority alerts', pref.soundEnabled, (v) {
                setState(() => _userPreferences = pref.copyWith(soundEnabled: v));
                _markModified();
              }, isDark),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('System Locale / Language', pref.language, isDark, (v) {
                      _userPreferences = pref.copyWith(language: v);
                      _markModified();
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Default Portal Landing Page', pref.defaultLandingPage, isDark, (v) {
                      _userPreferences = pref.copyWith(defaultLandingPage: v);
                      _markModified();
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Category 9: System Info & Swap Contract ---
  Widget _buildSystemInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('System Architecture & Backend-Swap Readiness', 'Version metadata, contract stability verification, & audit history', Icons.info_outline_rounded, isDark),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: HealthifyGlassTheme.primaryTeal, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_systemInfo.appName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                        Text('${_systemInfo.appVersion} • ${_systemInfo.buildVersion}', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('BACKEND SWAP READY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildInfoRow('Architecture Status', _systemInfo.architectureVersion, isDark),
              _buildInfoRow('Current Mode', _systemInfo.environment, isDark),
              _buildInfoRow('Contract Interface', 'SettingsRepository (Fully Decoupled)', isDark),
              _buildInfoRow('Target Backend', 'Serverpod + PostgreSQL Client Ready', isDark),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Configuration Audit History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _configHistory.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _configHistory[index];
              return ListTile(
                leading: const Icon(Icons.history_rounded, color: HealthifyGlassTheme.primaryTeal),
                title: Text('${item.category}: ${item.setting}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                subtitle: Text('Changed from "${item.previousValue}" to "${item.newValue}" by ${item.changedBy}', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                trailing: Text('${item.changedAt.hour}:${item.changedAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark))),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Helper UI Widgets ---
  Widget _buildSectionHeader(String title, String subtitle, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: HealthifyGlassTheme.primaryTeal, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HealthifyGlassTheme.getTextPrimary(isDark))),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
      value: value,
      activeTrackColor: HealthifyGlassTheme.primaryTeal,
      onChanged: onChanged,

      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
            Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: HealthifyGlassTheme.primaryTeal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, bool isDark, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        filled: true,
        fillColor: HealthifyGlassTheme.getGlassSurface(isDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNumberField(String label, int value, bool isDark, ValueChanged<int?> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(int.tryParse(val)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        filled: true,
        fillColor: HealthifyGlassTheme.getGlassSurface(isDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
        ],
      ),
    );
  }

  Widget _buildSaveActionBar(bool isDark) {
    final isSaving = _saveState == SettingsSaveState.saving;
    final isSuccess = _saveState == SettingsSaveState.success;
    final isError = _saveState == SettingsSaveState.error;

    return GlassCard(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_rounded
                : isError
                    ? Icons.error_rounded
                    : Icons.edit_note_rounded,
            color: isSuccess
                ? Colors.green
                : isError
                    ? Colors.redAccent
                    : Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage ??
                  (isSuccess
                      ? 'Settings saved successfully'
                      : isError
                          ? 'Error saving settings'
                          : 'You have unsaved configuration changes'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: isSaving ? null : _loadAllSettings,
            child: const Text('Discard'),
          ),
          const SizedBox(width: 8),
          GlassPrimaryButton(
            height: 40,
            onPressed: isSaving ? null : _saveCurrentSettings,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Configuration'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCategoryDef {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsCategoryDef(this.id, this.title, this.subtitle, this.icon);
}
