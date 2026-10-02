import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';
import 'patient_ai_summary_card.dart';

class PatientOverviewTab extends StatelessWidget {
  final PatientProfileFullModel profileData;
  final VoidCallback onRefreshSummary;
  final VoidCallback onViewAllConsultations;
  final VoidCallback onViewAllReports;
  final VoidCallback onViewAllPrescriptions;

  const PatientOverviewTab({
    super.key,
    required this.profileData,
    required this.onRefreshSummary,
    required this.onViewAllConsultations,
    required this.onViewAllReports,
    required this.onViewAllPrescriptions,
  });

  @override
  Widget build(BuildContext context) {
    final patient = profileData.patient;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Patient Summary Card at top of overview
          PatientAISummaryCard(
            summary: profileData.summary,
            onRefreshSummary: onRefreshSummary,
          ),
          const SizedBox(height: 18),

          // Main 2-column or 1-column layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Clinical Context, Recent Consult, Reports)
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildClinicalContextCard(patient),
                          const SizedBox(height: 16),
                          _buildRecentConsultationCard(profileData),
                          const SizedBox(height: 16),
                          _buildRecentReportsCard(profileData),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Right Column (Vitals, Active Meds, Upcoming Appointment)
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildCurrentVitalsCard(profileData.currentVitals),
                          const SizedBox(height: 16),
                          _buildActiveMedicationsCard(profileData),
                          const SizedBox(height: 16),
                          _buildUpcomingAppointmentCard(profileData),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Mobile / Tablet single column
              return Column(
                children: [
                  _buildClinicalContextCard(patient),
                  const SizedBox(height: 16),
                  _buildCurrentVitalsCard(profileData.currentVitals),
                  const SizedBox(height: 16),
                  _buildRecentConsultationCard(profileData),
                  const SizedBox(height: 16),
                  _buildActiveMedicationsCard(profileData),
                  const SizedBox(height: 16),
                  _buildRecentReportsCard(profileData),
                  const SizedBox(height: 16),
                  _buildUpcomingAppointmentCard(profileData),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalContextCard(dynamic patient) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notes_rounded, color: AppTheme.primaryTeal, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Clinical Context',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 14),

          // Primary Concern
          const Text(
            'PRIMARY REASON FOR VISIT / CONCERN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            patient.primaryConcern,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Known Medical Conditions
          const Text(
            'KNOWN CHRONIC CONDITIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (patient.chronicConditions as List<String>).map((condition) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, size: 13, color: Color(0xFF0284C7)),
                    const SizedBox(width: 5),
                    Text(
                      condition,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Allergies
          const Text(
            'KNOWN ALLERGIES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (patient.allergies as List<String>).map((allergy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                    const SizedBox(width: 5),
                    Text(
                      allergy,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentVitalsCard(Map<String, String> vitals) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monitor_heart_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Current Vitals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 14),
          Column(
            children: vitals.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentConsultationCard(PatientProfileFullModel profileData) {
    if (profileData.consultations.isEmpty) return const SizedBox.shrink();
    final consult = profileData.consultations.first;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Latest Consultation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAllConsultations,
                child: const Text('View All', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${consult.date} at ${consult.time} • ${consult.doctorName}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Diagnosis: ${consult.diagnosis}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            consult.clinicalNotes,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMedicationsCard(PatientProfileFullModel profileData) {
    final activePrescriptions = profileData.prescriptions.where((p) => p.isActive).toList();
    if (activePrescriptions.isEmpty) return const SizedBox.shrink();
    final rx = activePrescriptions.first;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication_rounded, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Active Prescriptions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAllPrescriptions,
                child: const Text('Manage', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: rx.medications.map((med) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${med.drugName} ${med.dosage}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            '${med.frequency} • ${med.duration}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsCard(PatientProfileFullModel profileData) {
    final reports = profileData.reports.take(3).toList();

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFF59E0B), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Recent Reports',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAllReports,
                child: const Text('View All', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: reports.map((r) {
              final isAbnormal = r.status.toLowerCase().contains('abnormal') || r.status.toLowerCase().contains('elevated');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      r.category == ReportCategory.radiology
                          ? Icons.camera_rounded
                          : (r.category == ReportCategory.cardiology ? Icons.monitor_heart_rounded : Icons.science_rounded),
                      color: AppTheme.primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            '${r.date} • ${r.labName}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAbnormal ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAbnormal ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(PatientProfileFullModel profileData) {
    if (profileData.appointments.isEmpty) return const SizedBox.shrink();
    final apt = profileData.appointments.first;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppTheme.accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Next Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      profileData.patient.nextAppointmentText ?? 'Scheduled',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    Text(
                      apt.tokenNumber,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reason: ${apt.reasonForVisit}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
