import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorModals {
  /// 1. Start Consultation Interactive Modal
  static void showStartConsultationModal({
    required BuildContext context,
    required DoctorAppointmentModel appointment,
    required VoidCallback onConsultationCompleted,
  }) {
    final patient = appointment.patient;
    final notesController = TextEditingController();
    final diagnosisController = TextEditingController(text: 'Mild Angina Pectoris / Suspected Ischemia');
    final prescriptionController = TextEditingController(text: 'Atorvastatin 20mg OD, Metoprolol 25mg BD');
    final labOrderController = TextEditingController(text: '12-Lead ECG, Lipid Profile');

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
                  children: [
                    const GlassIconContainer(
                      icon: Icons.video_call_rounded,
                      size: 42,
                      iconSize: 22,
                      color: HealthifyGlassTheme.primaryTeal,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Consultation Room',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Active OPD Session • Patient: ${patient.name} (${patient.mrn})',
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
                const SizedBox(height: 20),

                // Patient Summary Ribbon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: HealthifyGlassTheme.primaryTeal,
                        backgroundImage: NetworkImage(patient.avatarUrl),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: Text(patient.name[0], style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${patient.name} (${patient.age} yrs • ${patient.gender})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              'Chief Complaint: ${appointment.reasonForVisit}',
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
                ),
                const SizedBox(height: 18),

                // Clinical Vitals Section
                Text(
                  'Patient Vitals (Triage Log)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildVitalChip('BP', '142/90 mmHg', Icons.speed_rounded, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildVitalChip('Pulse', '78 bpm', Icons.favorite_rounded, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildVitalChip('SpO2', '98%', Icons.air_rounded, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildVitalChip('Temp', '98.6 °F', Icons.thermostat_rounded, isDark)),
                  ],
                ),
                const SizedBox(height: 18),

                // Diagnosis Input
                TextField(
                  controller: diagnosisController,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Primary Clinical Diagnosis',
                    labelText: 'Clinical Diagnosis',
                    prefixIcon: const Icon(Icons.medical_information_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                // Clinical Notes Input
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Enter clinical observations, examination findings, and advice...',
                    labelText: 'Doctor Clinical Notes',
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                // E-Prescription Input
                TextField(
                  controller: prescriptionController,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'e.g. Atorvastatin 20mg OD, Metoprolol 25mg BD',
                    labelText: 'E-Prescription (Rx)',
                    prefixIcon: const Icon(Icons.medication_rounded),
                  ),
                ),
                const SizedBox(height: 14),

                // Lab Test Orders
                TextField(
                  controller: labOrderController,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'e.g. Lipid Profile, 12-Lead ECG, Troponin-I',
                    labelText: 'Order Laboratory / Diagnostic Tests',
                    prefixIcon: const Icon(Icons.science_rounded),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: GlassSecondaryButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GlassPrimaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConsultationCompleted();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Consultation completed for ${patient.name}. Prescription sent to Pharmacy.'),
                              backgroundColor: HealthifyGlassTheme.primaryTeal,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Complete Consultation'),
                            ],
                          ),
                        ),
                      ),
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

  static Widget _buildVitalChip(String title, String val, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Interactive Review Report Modal
  static void showReviewReportModal({
    required BuildContext context,
    required PendingReportModel report,
    required ValueChanged<String> onReportReviewed,
  }) {
    final patient = report.patient;
    final notesController = TextEditingController(text: report.clinicalNotes ?? '');

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.assignment_rounded,
                      size: 42,
                      iconSize: 22,
                      color: Colors.amber,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review Report: ${report.reportType}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Patient: ${patient.name} (${patient.mrn}) • Date: ${report.date}',
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
                const SizedBox(height: 20),

                Text(
                  'Laboratory Findings & Values',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  child: Column(
                    children: report.labValues.entries.map((entry) {
                      final isElevated = entry.value.toLowerCase().contains('elevated');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isElevated ? Colors.redAccent : HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Add clinical remarks, follow-up advice or instructions...',
                    labelText: 'Doctor Clinical Review Notes',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GlassSecondaryButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GlassPrimaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onReportReviewed(notesController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${report.reportType} for ${patient.name} marked as reviewed.'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Mark Reviewed & Notify Patient'),
                          ],
                        ),
                      ),
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

  /// 3. Patient Profile Drawer / Modal
  static void showPatientProfileModal({
    required BuildContext context,
    required PatientModel patient,
  }) {
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      backgroundImage: NetworkImage(patient.avatarUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'MRN: ${patient.mrn} • ${patient.age} yrs • ${patient.gender} • Blood: ${patient.bloodGroup}',
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
                const SizedBox(height: 20),

                // Allergies & Chronic Conditions
                if (patient.allergies.isNotEmpty) ...[
                  Text(
                    'Known Allergies',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: patient.allergies.map((allergy) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          allergy,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                Text(
                  'Current Active Medications',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                ),
                const SizedBox(height: 6),
                Column(
                  children: patient.currentMedications.map((med) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.medication_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                          const SizedBox(width: 8),
                          Text(med, style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text(
                  'Recent Visit History',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Last Visit: ${patient.lastVisitDate} with ${patient.lastVisitDoctor}',
                          style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                GlassPrimaryButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Center(child: Text('Close Patient File')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 4. Practice Working Hours Configuration Modal
  static void showConfigureHoursModal({
    required BuildContext context,
    required DoctorAvailabilityConfig currentConfig,
    required ValueChanged<DoctorAvailabilityConfig> onSave,
  }) {
    final startController = TextEditingController(text: currentConfig.workingHoursStart);
    final endController = TextEditingController(text: currentConfig.workingHoursEnd);
    final breakStartController = TextEditingController(text: currentConfig.breakStart);
    final breakEndController = TextEditingController(text: currentConfig.breakEnd);

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure Today\'s Working Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '09:00 AM',
                        labelText: 'OPD Start',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '05:00 PM',
                        labelText: 'OPD End',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: breakStartController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '01:00 PM',
                        labelText: 'Break Start',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: breakEndController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '02:00 PM',
                        labelText: 'Break End',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GlassPrimaryButton(
                onPressed: () {
                  final newConfig = currentConfig.copyWith(
                    workingHoursStart: startController.text,
                    workingHoursEnd: endController.text,
                    breakStart: breakStartController.text,
                    breakEnd: breakEndController.text,
                  );
                  onSave(newConfig);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Working hours updated and synced with Patient App.'),
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Center(child: Text('Save Working Hours')),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 5. Reschedule Appointment Modal
  static void showRescheduleModal({
    required BuildContext context,
    required DoctorAppointmentModel appointment,
    required ValueChanged<String> onRescheduled,
  }) {
    String selectedSlot = 'Tomorrow, 10:00 AM';
    final availableSlots = [
      'Tomorrow, 10:00 AM',
      'Tomorrow, 02:30 PM',
      'Next Mon, 09:30 AM',
    ];

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reschedule Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rescheduling session for ${appointment.patient.name} (Originally ${appointment.appointmentTime})',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSlots.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: HealthifyGlassTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : HealthifyGlassTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedSlot = slot);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  GlassPrimaryButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRescheduled(selectedSlot);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Appointment for ${appointment.patient.name} rescheduled to $selectedSlot.'),
                          backgroundColor: HealthifyGlassTheme.primaryTeal,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Center(child: Text('Confirm Reschedule')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 6. Notifications Modal Pane
  static void showNotificationsPane({
    required BuildContext context,
    required List<DoctorNotificationModel> notifications,
    required VoidCallback onMarkAllRead,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  TextButton(
                    onPressed: onMarkAllRead,
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: GlassIconContainer(
                        icon: item.icon,
                        size: 38,
                        iconSize: 20,
                        color: item.iconColor,
                        borderRadius: 10,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      subtitle: Text(
                        '${item.message}\n${item.time}',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
