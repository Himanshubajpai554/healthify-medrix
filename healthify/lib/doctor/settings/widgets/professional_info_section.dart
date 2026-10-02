import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_profile_models.dart';

class ProfessionalInfoSection extends StatelessWidget {
  final ProfessionalInfoModel professionalInfo;
  final List<HospitalAffiliationModel> hospitalAffiliations;

  const ProfessionalInfoSection({
    super.key,
    required this.professionalInfo,
    required this.hospitalAffiliations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: [
        // 1. Professional Credentials & Information
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.card_membership_rounded,
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
                          'Professional Credentials & Specialization',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Medical qualifications, specialization, and registration details.',
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

              // Info Fields Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 650;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStaticInfoTile('Doctor ID / Code', professionalInfo.doctorId, isDark),
                          ),
                          if (isDesktop) const SizedBox(width: 16),
                          if (isDesktop)
                            Expanded(
                              child: _buildStaticInfoTile('Specialization', professionalInfo.specialization, isDark),
                            ),
                        ],
                      ),
                      if (!isDesktop) const SizedBox(height: 12),
                      if (!isDesktop)
                        _buildStaticInfoTile('Specialization', professionalInfo.specialization, isDark),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStaticInfoTile('Department', professionalInfo.department, isDark),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStaticInfoTile('Medical Qualifications', professionalInfo.qualifications, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStaticInfoTile('Medical Council Reg. No.', professionalInfo.registrationNumber, isDark),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStaticInfoTile('Clinical Experience', professionalInfo.yearsOfExperience, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStaticInfoTile('Joining Date', professionalInfo.joiningDate, isDark),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStaticInfoTile('Languages Spoken', professionalInfo.languages, isDark),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Professional Verification Status Banner
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.verified_user_rounded,
                    size: 40,
                    iconSize: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Professional Verification Status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                  const SizedBox(width: 4),
                                  Text(
                                    professionalInfo.verificationStatus,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified by ${professionalInfo.verifiedBy} on ${professionalInfo.verificationDate}.',
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
              const SizedBox(height: 12),
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
                      Icons.shield_outlined,
                      size: 16,
                      color: HealthifyGlassTheme.getTextMuted(isDark),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Professional credentials require verification by the hospital/admin medical board. Self-verification is strictly prohibited to maintain medical safety compliance.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: HealthifyGlassTheme.getTextMuted(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Hospital Affiliations
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.local_hospital_rounded,
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
                          'Hospital Affiliations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Hospitals and healthcare centers where you practice.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassSecondaryButton(
                    height: 36,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital affiliation requests require approval by the target Hospital Administrator.'),
                          backgroundColor: HealthifyGlassTheme.primaryTeal,
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, size: 16),
                        SizedBox(width: 4),
                        Text('Add Hospital', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              ...hospitalAffiliations.map((aff) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: aff.isPrimary
                            ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4)
                            : HealthifyGlassTheme.getGlassBorder(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        const GlassIconContainer(
                          icon: Icons.domain_rounded,
                          size: 44,
                          iconSize: 22,
                          color: HealthifyGlassTheme.primaryTeal,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      aff.hospitalName,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                                      ),
                                    ),
                                  ),
                                  if (aff.isPrimary) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: HealthifyGlassTheme.primaryTeal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Primary Hospital',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${aff.role} • ${aff.department}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${aff.location} • Joined ${aff.joiningDate}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: HealthifyGlassTheme.getTextMuted(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassSecondaryButton(
                          height: 34,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening hospital profile for ${aff.hospitalName}...'),
                                backgroundColor: HealthifyGlassTheme.primaryTeal,
                              ),
                            );
                          },
                          child: const Text('View Hospital', style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticInfoTile(String label, String value, bool isDark) {
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
            value.isNotEmpty ? value : '—',
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
