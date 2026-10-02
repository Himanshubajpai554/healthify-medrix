import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';
import '../../models/patient_profile_models.dart';

class PatientProfileHeader extends StatelessWidget {
  final PatientProfileFullModel profileData;
  final VoidCallback onStartConsultation;
  final VoidCallback onAddNote;
  final VoidCallback onCreatePrescription;
  final VoidCallback onViewReports;
  final Function(String) onActionSelected;

  const PatientProfileHeader({
    super.key,
    required this.profileData,
    required this.onStartConsultation,
    required this.onAddNote,
    required this.onCreatePrescription,
    required this.onViewReports,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final patient = profileData.patient;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      children: [
        // Main Identity Header Card
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Avatar
                  Stack(
                    children: [
                      Container(
                        width: isDesktop ? 76 : 64,
                        height: isDesktop ? 76 : 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryTeal, width: 2.5),
                          image: DecorationImage(
                            image: NetworkImage(patient.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),

                  // Patient Identity Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            Text(
                              patient.name,
                              style: TextStyle(
                                fontSize: isDesktop ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.fingerprint_rounded, size: 13, color: AppTheme.primaryTeal),
                                  const SizedBox(width: 4),
                                  Text(
                                    patient.id,
                                    style: const TextStyle(
                                      color: AppTheme.primaryTeal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(patient.careStatus),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Demographic Pills
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          children: [
                            _buildInfoChip(Icons.cake_outlined, '${patient.age} yrs'),
                            _buildInfoChip(
                              patient.gender.toLowerCase() == 'male' ? Icons.male_rounded : Icons.female_rounded,
                              patient.gender,
                            ),
                            _buildInfoChip(Icons.water_drop_outlined, 'Blood: ${patient.bloodGroup}', isHighlighted: true),
                            _buildInfoChip(Icons.phone_outlined, patient.phone),
                            _buildInfoChip(Icons.domain_rounded, patient.department),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Desktop Action Bar
                  if (isDesktop)
                    Row(
                      children: [
                        GlassPrimaryButton(
                          onPressed: onStartConsultation,
                          child: const Row(
                            children: [
                              Icon(Icons.play_circle_fill_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Start Consultation', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GlassSecondaryButton(
                          onPressed: onAddNote,
                          child: const Row(
                            children: [
                              Icon(Icons.post_add_rounded, size: 18, color: AppTheme.textPrimary),
                              SizedBox(width: 6),
                              Text('Add Note'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GlassSecondaryButton(
                          onPressed: onCreatePrescription,
                          child: const Row(
                            children: [
                              Icon(Icons.medication_liquid_rounded, size: 18, color: AppTheme.textPrimary),
                              SizedBox(width: 6),
                              Text('Prescription'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        PopupMenuButton<String>(
                          onSelected: onActionSelected,
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: const Icon(Icons.more_vert_rounded, color: AppTheme.textPrimary, size: 20),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'reports',
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primaryTeal),
                                  SizedBox(width: 10),
                                  Text('View Reports'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'schedule',
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.accentColor),
                                  SizedBox(width: 10),
                                  Text('Schedule Appointment'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'documents',
                              child: Row(
                                children: [
                                  Icon(Icons.folder_open_rounded, size: 18, color: Color(0xFF6366F1)),
                                  SizedBox(width: 10),
                                  Text('View Documents'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),

              // Mobile/Tablet Action Row
              if (!isDesktop) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GlassPrimaryButton(
                        onPressed: onStartConsultation,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Start Consultation', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassSecondaryButton(
                        onPressed: onAddNote,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.post_add_rounded, size: 16, color: AppTheme.textPrimary),
                            SizedBox(width: 4),
                            Text('Add Note', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassSecondaryButton(
                        onPressed: onCreatePrescription,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medication_rounded, size: 16, color: AppTheme.textPrimary),
                            SizedBox(width: 4),
                            Text('Prescription', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassSecondaryButton(
                        onPressed: onViewReports,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 16, color: AppTheme.textPrimary),
                            SizedBox(width: 4),
                            Text('Reports', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Patient Info Grid / Row
        LayoutBuilder(
          builder: (context, constraints) {
            final colCount = constraints.maxWidth >= 1100 ? 6 : (constraints.maxWidth >= 700 ? 3 : 2);
            final cards = [
              _buildQuickCard('Blood Group', patient.bloodGroup, Icons.water_drop_rounded, const Color(0xFFEF4444)),
              _buildQuickCard('Last Visit', patient.lastVisitDate, Icons.calendar_today_rounded, AppTheme.primaryTeal),
              _buildQuickCard('Next Appointment', patient.nextAppointmentText ?? 'Not Scheduled', Icons.event_available_rounded, AppTheme.accentColor),
              _buildQuickCard('Current Doctor', patient.lastVisitDoctor, Icons.medical_services_rounded, const Color(0xFF6366F1)),
              _buildQuickCard('Active Prescriptions', '${profileData.prescriptions.where((p) => p.isActive).length} Active', Icons.medication_rounded, const Color(0xFF10B981)),
              _buildQuickCard('Follow-up Status', patient.followUpStatus ?? 'None', Icons.update_rounded, const Color(0xFFF59E0B)),
            ];

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: colCount,
              childAspectRatio: constraints.maxWidth >= 1100 ? 2.4 : 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: cards,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool isHighlighted = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isHighlighted ? const Color(0xFFEF4444) : AppTheme.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isHighlighted ? const Color(0xFFEF4444) : AppTheme.textSecondary,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PatientCareStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case PatientCareStatus.active:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'Active';
        break;
      case PatientCareStatus.followUpDue:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'Follow-up Due';
        break;
      case PatientCareStatus.admitted:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'Admitted';
        break;
      case PatientCareStatus.emergency:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Emergency';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppTheme.textSecondary;
        label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildQuickCard(String title, String value, IconData icon, Color iconColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
