import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientsTableView extends StatelessWidget {
  final List<PatientModel> patients;
  final ValueChanged<PatientModel> onViewPatientProfile;
  final ValueChanged<PatientModel> onStartConsultation;
  final ValueChanged<PatientModel> onWritePrescription;
  final ValueChanged<PatientModel> onAddClinicalNote;
  final ValueChanged<PatientModel> onScheduleFollowUp;

  const PatientsTableView({
    super.key,
    required this.patients,
    required this.onViewPatientProfile,
    required this.onStartConsultation,
    required this.onWritePrescription,
    required this.onAddClinicalNote,
    required this.onScheduleFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (!isDesktop) {
      return _buildMobileCardList(context, isDark);
    }

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Table Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildHeaderCell('PATIENT', flex: 3, isDark: isDark),
                _buildHeaderCell('AGE & GENDER', flex: 2, isDark: isDark),
                _buildHeaderCell('LAST VISIT', flex: 2, isDark: isDark),
                _buildHeaderCell('NEXT APPOINTMENT', flex: 3, isDark: isDark),
                _buildHeaderCell('CARE STATUS', flex: 2, isDark: isDark),
                _buildHeaderCell('FOLLOW-UP', flex: 2, isDark: isDark),
                _buildHeaderCell('ACTIONS', flex: 2, alignRight: true, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (context, index) => const Divider(height: 12, thickness: 0.8),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return _buildTableRow(context, patient, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {required int flex, required bool isDark, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: HealthifyGlassTheme.getTextMuted(isDark),
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, PatientModel patient, bool isDark) {
    return InkWell(
      onTap: () => onViewPatientProfile(patient),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Patient Avatar & Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    backgroundImage: NetworkImage(patient.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          patient.mrn,
                          style: TextStyle(
                            fontSize: 11.5,
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

            // Age & Gender
            Expanded(
              flex: 2,
              child: Text(
                '${patient.age} yrs • ${patient.gender}',
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ),

            // Last Visit
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.lastVisitDate,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  Text(
                    patient.lastVisitDoctor,
                    style: TextStyle(
                      fontSize: 11,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Next Appointment
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.nextAppointmentText ?? 'None Scheduled',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: patient.nextAppointmentText != null
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getTextMuted(isDark),
                    ),
                  ),
                  Text(
                    patient.department,
                    style: TextStyle(
                      fontSize: 11,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Care Status Badge
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCareStatusBadge(patient.careStatus),
              ),
            ),

            // Follow-up Status
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: patient.followUpStatus == 'Due'
                      ? Colors.amber.withValues(alpha: 0.18)
                      : HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  patient.followUpStatus ?? 'Scheduled',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: patient.followUpStatus == 'Due' ? Colors.amber.shade900 : HealthifyGlassTheme.primaryTeal,
                  ),
                ),
              ),
            ),

            // Action Popup Menu
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'view_profile':
                          onViewPatientProfile(patient);
                          break;
                        case 'start_consult':
                          onStartConsultation(patient);
                          break;
                        case 'write_prescription':
                          onWritePrescription(patient);
                          break;
                        case 'add_note':
                          onAddClinicalNote(patient);
                          break;
                        case 'schedule_followup':
                          onScheduleFollowUp(patient);
                          break;
                      }
                    },
                    icon: Icon(Icons.more_vert_rounded, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'view_profile', child: Text('View Patient File')),
                      PopupMenuItem(value: 'start_consult', child: Text('Start Consultation')),
                      PopupMenuItem(value: 'write_prescription', child: Text('Write E-Prescription')),
                      PopupMenuItem(value: 'add_note', child: Text('Add Clinical Note')),
                      PopupMenuItem(value: 'schedule_followup', child: Text('Schedule Follow-up')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: patients.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final patient = patients[index];

        return GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          onTap: () => onViewPatientProfile(patient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCareStatusBadge(patient.careStatus),
                  Text(
                    'Last: ${patient.lastVisitDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    backgroundImage: NetworkImage(patient.avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '${patient.age} yrs • ${patient.gender} • ${patient.mrn}',
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
              const SizedBox(height: 10),

              Text(
                'Concern: ${patient.primaryConcern}',
                style: TextStyle(
                  fontSize: 12.5,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onStartConsultation(patient),
                    icon: const Icon(Icons.video_call_rounded, size: 14),
                    label: const Text('Consult'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => onViewPatientProfile(patient),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text('View File'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCareStatusBadge(PatientCareStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case PatientCareStatus.active:
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        label = 'Active';
        break;
      case PatientCareStatus.newPatient:
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade700;
        label = 'New Patient';
        break;
      case PatientCareStatus.followUpDue:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade900;
        label = 'Follow-up Due';
        break;
      case PatientCareStatus.admitted:
        bg = Colors.purple.withValues(alpha: 0.15);
        fg = Colors.purple.shade700;
        label = 'Admitted';
        break;
      case PatientCareStatus.emergency:
        bg = Colors.redAccent.withValues(alpha: 0.15);
        fg = Colors.redAccent;
        label = 'Emergency';
        break;
      case PatientCareStatus.discharged:
        bg = Colors.teal.withValues(alpha: 0.15);
        fg = Colors.teal.shade700;
        label = 'Discharged';
        break;
      case PatientCareStatus.inactive:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey.shade700;
        label = 'Inactive';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
