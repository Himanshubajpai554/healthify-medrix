import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';

class HospitalProfileScreen extends StatefulWidget {
  const HospitalProfileScreen({super.key});

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  UiState<HospitalProfile> _uiState = UiState.initial();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _uiState = UiState.loading());
    try {
      final repository = RepositoryScope.of(context).hospitalRepository;
      final profile = await repository.getHospitalProfile();
      if (mounted) {
        setState(() => _uiState = UiState.success(profile));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uiState = UiState.error('Failed to load profile: $e'));
      }
    }
  }

  Color _getVerificationColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const Color(0xFF10B981);
      case VerificationStatus.pending:
        return const Color(0xFFF59E0B);
      case VerificationStatus.rejected:
        return const Color(0xFFEF4444);
      case VerificationStatus.unverified:
        return const Color(0xFF6B7280);
    }
  }

  String _getVerificationText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified Hospital';
      case VerificationStatus.pending:
        return 'Verification Pending';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
      case VerificationStatus.unverified:
        return 'Unverified Hospital';
    }
  }

  void _showEditProfileDialog(HospitalProfile profile) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.receptionPhone);
    final helplineController = TextEditingController(text: profile.emergencyHelpline);
    final addressController = TextEditingController(text: profile.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Hospital Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Hospital Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Reception Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: helplineController,
                  decoration: const InputDecoration(labelText: 'Emergency Helpline'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlassPrimaryButton(
            height: 42,
            onPressed: () async {
              Navigator.pop(context);
              final updated = profile.copyWith(
                name: nameController.text,
                email: emailController.text,
                receptionPhone: phoneController.text,
                emergencyHelpline: helplineController.text,
                address: addressController.text,
              );
              final messenger = ScaffoldMessenger.of(context);
              final repo = RepositoryScope.of(context).hospitalRepository;
              await repo.updateHospitalProfile(updated);
              _loadProfile();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Hospital profile updated successfully!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _submitVerificationRequest(HospitalProfile profile) async {
    await RepositoryScope.of(context).hospitalRepository.submitVerification({'submittedAt': DateTime.now()});
    _loadProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification documents submitted for review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    if (_uiState.isLoading) {
      return const MedrixLoadingState(message: 'Loading hospital profile...');
    }

    if (_uiState.isError) {
      return MedrixErrorState(
        errorMessage: _uiState.errorMessage ?? 'Error loading hospital profile',
        onRetry: _loadProfile,
      );
    }

    final profile = _uiState.data;
    if (profile == null) {
      return const MedrixEmptyState(
        title: 'No Profile Found',
        description: 'Hospital profile details are currently unavailable.',
        icon: Icons.domain_disabled_rounded,
      );
    }

    final statusColor = _getVerificationColor(profile.verificationStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Profile & Verification',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Legal identity, operational capacity, and verification status',
                    style: TextStyle(
                      fontSize: 13,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(profile),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                  ),
                  if (profile.verificationStatus != VerificationStatus.verified)
                    ElevatedButton.icon(
                      onPressed: () => _submitVerificationRequest(profile),
                      icon: const Icon(Icons.verified_user_outlined, size: 18),
                      label: const Text('Submit Verification'),
                      style: ElevatedButton.styleFrom(backgroundColor: statusColor),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Verification Callout Banner
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                GlassIconContainer(
                  icon: profile.verificationStatus == VerificationStatus.verified
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  color: statusColor,
                  size: 48,
                  iconSize: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Text(
                            _getVerificationText(profile.verificationStatus),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              profile.registrationLicenseId,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.verificationNotes,
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
          ),

          const SizedBox(height: 20),

          // Details Grid (Identity, Contact, Capacity, Operations)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: _buildInfoCard(
                      isDark: isDark,
                      title: 'Legal Identity',
                      icon: Icons.badge_outlined,
                      items: [
                        _infoRow('Legal Name', profile.legalName, isDark),
                        _infoRow('Display Name', profile.displayName, isDark),
                        _infoRow('Hospital Type', profile.hospitalType, isDark),
                        _infoRow('Establishment Date', profile.establishmentDate, isDark),
                        _infoRow('Tax ID', profile.taxId, isDark),
                        _infoRow('Accreditation', profile.accreditationInfo, isDark),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: _buildInfoCard(
                      isDark: isDark,
                      title: 'Contact & Location',
                      icon: Icons.location_on_outlined,
                      items: [
                        _infoRow('Email', profile.email, isDark),
                        _infoRow('Emergency Hotline', profile.emergencyHelpline, isDark),
                        _infoRow('Reception Phone', profile.receptionPhone, isDark),
                        _infoRow('Website', profile.website, isDark),
                        _infoRow('Address', '${profile.address}, ${profile.city}, ${profile.state}, ${profile.country}', isDark),
                        _infoRow('Coordinates', '${profile.latitude}, ${profile.longitude}', isDark),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: _buildInfoCard(
                      isDark: isDark,
                      title: 'Hospital Capacity',
                      icon: Icons.king_bed_outlined,
                      items: [
                        _infoRow('Total Beds', '${profile.totalBeds} Beds', isDark),
                        _infoRow('ICU Beds', '${profile.icuBeds} Beds', isDark),
                        _infoRow('Operating Theatres', '${profile.operatingTheatres} Suites', isDark),
                        _infoRow('Emergency Capacity', '${profile.emergencyCapacity} Bays', isDark),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth,
                    child: _buildInfoCard(
                      isDark: isDark,
                      title: 'Operational Parameters',
                      icon: Icons.medical_services_outlined,
                      items: [
                        _infoRow('24/7 Emergency', profile.has247Emergency ? 'Active' : 'Inactive', isDark),
                        _infoRow('Trauma Designation', profile.traumaLevel, isDark),
                        _infoRow('Ambulance Fleet', profile.hasAmbulance ? 'Available' : 'None', isDark),
                        _infoRow('OPD Hours', profile.opdTimings, isDark),
                        _infoRow('Status', profile.operatingStatus, isDark),
                      ],
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

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIconContainer(
                icon: icon,
                size: 36,
                iconSize: 18,
                color: HealthifyGlassTheme.primaryTeal,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
