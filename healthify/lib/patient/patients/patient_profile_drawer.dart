import 'package:flutter/material.dart';
import './patient_model.dart';
import '../../theme/app_theme.dart';

class PatientProfileDrawer extends StatelessWidget {
  final PatientItem patient;
  final VoidCallback onClose;
  final ValueChanged<PatientStatus> onStatusChanged;
  final ValueChanged<String> onWardChanged;

  const PatientProfileDrawer({
    super.key,
    required this.patient,
    required this.onClose,
    required this.onStatusChanged,
    required this.onWardChanged,
  });

  Color _getStatusColor(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return const Color(0xFF3B82F6);
      case PatientStatus.icu:
        return const Color(0xFFEF4444);
      case PatientStatus.observation:
        return const Color(0xFFF59E0B);
      case PatientStatus.discharged:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return 'Admitted';
      case PatientStatus.icu:
        return 'ICU (Critical)';
      case PatientStatus.observation:
        return 'Observation';
      case PatientStatus.discharged:
        return 'Discharged';
      default:
        return status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(patient.status);
    final mrn = 'MRN-${10000 + (patient.id.hashCode.abs() % 89999)}';

    return Container(
      width: 440,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: patient.avatarGradientStart,
                      child: Text(
                        patient.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'ID: ${patient.id} • MRN: $mrn',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Drawer Body Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Blood Group Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 10),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(patient.status),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Blood Group: ${patient.bloodGroup}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Privacy & Access Banner (Frontend Access Control State)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, color: Color(0xFFB45309), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Administrative Access Mode: Identity, MRN & Vitals visible. Diagnostic clinical notes require physician authorization.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ward Location & Physician Info
                  _buildDetailTile(
                    icon: Icons.meeting_room_outlined,
                    label: 'Ward / Department',
                    value: patient.status == PatientStatus.discharged
                        ? 'N/A - Discharged'
                        : patient.ward,
                  ),
                  const SizedBox(height: 12),

                  _buildDetailTile(
                    icon: Icons.badge_outlined,
                    label: 'Attending Physician',
                    value: patient.doctorName,
                  ),
                  const SizedBox(height: 12),

                  _buildDetailTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Admission Date',
                    value: '${patient.admissionDate.day}/${patient.admissionDate.month}/${patient.admissionDate.year}',
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 14),

                  // Real-Time Vitals Summary Grid
                  const Text(
                    'Real-Time Patient Vitals',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: patient.vitals.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 14),

                  // Admission History Section
                  const Text(
                    'Admission History',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stay: ${_formatDate(patient.admissionDate)} - Present',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(patient.status),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ward: ${patient.ward} • Doctor: ${patient.doctorName}',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Footer Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Column(
              children: [
                if (patient.status != PatientStatus.discharged) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      onStatusChanged(PatientStatus.discharged);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Patient ${patient.name} discharged successfully')),
                      );
                      onClose();
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Discharge Patient'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing full medical record for ${patient.name}')),
                    );
                    onClose();
                  },
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('View Full Medical File'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}