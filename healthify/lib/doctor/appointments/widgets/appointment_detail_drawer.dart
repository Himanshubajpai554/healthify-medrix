import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentDetailDrawer {
  static void show({
    required BuildContext context,
    required DoctorAppointmentModel appointment,
    required VoidCallback onStartConsultation,
    required VoidCallback onViewPatient,
    required VoidCallback onReschedule,
    required VoidCallback onCancel,
  }) {
    final patient = appointment.patient;

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const GlassIconContainer(
                          icon: Icons.calendar_today_rounded,
                          size: 40,
                          iconSize: 20,
                          color: HealthifyGlassTheme.primaryTeal,
                          borderRadius: 12,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              'Appointment ID: ${appointment.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Patient Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: HealthifyGlassTheme.primaryTeal,
                        backgroundImage: NetworkImage(patient.avatarUrl),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              'Age: ${patient.age} yrs • Gender: ${patient.gender} • MRN: ${patient.mrn}',
                              style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                            Text(
                              'Phone: ${patient.phone} • Blood: ${patient.bloodGroup}',
                              style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Appointment Metadata Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Date & Time', '${appointment.appointmentTime} (Token ${appointment.tokenNumber})', isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Appointment Type', appointment.appointmentType, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Department', appointment.department, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Consultation Mode', appointment.consultationMode, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Reason for Visit', appointment.reasonForVisit, isDark),
                      const Divider(height: 16),
                      _buildDetailRow('Previous Visit Date', patient.lastVisitDate, isDark),
                      if (appointment.cancellationReason != null) ...[
                        const Divider(height: 16),
                        _buildDetailRow('Cancellation Reason', appointment.cancellationReason!, isDark, textColor: Colors.redAccent),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    GlassPrimaryButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onStartConsultation();
                      },
                      height: 44,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_call_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Start Consultation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    GlassSecondaryButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onViewPatient();
                      },
                      height: 44,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_shared_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('View Medical History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onReschedule();
                      },
                      icon: const Icon(Icons.schedule_rounded, size: 16),
                      label: const Text('Reschedule'),
                    ),
                    if (appointment.status != AppointmentStatus.completed && appointment.status != AppointmentStatus.cancelled)
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel();
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                        label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value, bool isDark, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor ?? HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
