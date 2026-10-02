import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientProfileDrawer {
  static void show({
    required BuildContext context,
    required PatientModel patient,
    required VoidCallback onStartConsultation,
    required VoidCallback onWritePrescription,
    required VoidCallback onAddClinicalNote,
    required VoidCallback onScheduleFollowUp,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        return _PatientProfileContent(
          patient: patient,
          onStartConsultation: onStartConsultation,
          onWritePrescription: onWritePrescription,
          onAddClinicalNote: onAddClinicalNote,
          onScheduleFollowUp: onScheduleFollowUp,
        );
      },
    );
  }
}

class _PatientProfileContent extends StatefulWidget {
  final PatientModel patient;
  final VoidCallback onStartConsultation;
  final VoidCallback onWritePrescription;
  final VoidCallback onAddClinicalNote;
  final VoidCallback onScheduleFollowUp;

  const _PatientProfileContent({
    required this.patient,
    required this.onStartConsultation,
    required this.onWritePrescription,
    required this.onAddClinicalNote,
    required this.onScheduleFollowUp,
  });

  @override
  State<_PatientProfileContent> createState() => _PatientProfileContentState();
}

class _PatientProfileContentState extends State<_PatientProfileContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final patient = widget.patient;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, MRN & Close Button
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: HealthifyGlassTheme.primaryTeal,
                backgroundImage: NetworkImage(patient.avatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: Text(patient.name[0], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Actions Bar inside Profile Header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GlassPrimaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/doctor-patient-profile');
                  },
                  height: 38,
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Full Workspace', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onStartConsultation();
                  },
                  height: 38,
                  child: const Row(
                    children: [
                      Icon(Icons.video_call_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                      SizedBox(width: 6),
                      Text('Start Consult', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onWritePrescription();
                  },
                  height: 38,
                  child: const Row(
                    children: [
                      Icon(Icons.medication_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Write Rx', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onAddClinicalNote();
                  },
                  height: 38,
                  child: const Row(
                    children: [
                      Icon(Icons.note_add_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Add Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSecondaryButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onScheduleFollowUp();
                  },
                  height: 38,
                  child: const Row(
                    children: [
                      Icon(Icons.event_repeat_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Schedule Follow-up', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontally Scrollable 7 Tabs Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: HealthifyGlassTheme.primaryTeal,
            unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
            indicatorColor: HealthifyGlassTheme.primaryTeal,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Medical History'),
              Tab(text: 'Consultations'),
              Tab(text: 'Reports'),
              Tab(text: 'Prescriptions'),
              Tab(text: 'Clinical Notes'),
              Tab(text: 'Appointments'),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Body Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, isDark),
                _buildMedicalHistoryTab(isDark),
                _buildConsultationsTab(isDark),
                _buildReportsTab(isDark),
                _buildPrescriptionsTab(isDark),
                _buildNotesTab(isDark),
                _buildAppointmentsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. OVERVIEW TAB
  Widget _buildOverviewTab(BuildContext context, bool isDark) {
    final patient = widget.patient;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinical Alerts if any
          if (patient.clinicalAlerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Clinical Alerts Requirement',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...patient.clinicalAlerts.map((alert) => Text('• $alert', style: TextStyle(fontSize: 12, color: Colors.amber.shade900))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick Clinical Metric Overview Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat('Recent Visits', '4', isDark),
                _buildSummaryStat('Active Rx', '${patient.currentMedications.length}', isDark),
                _buildSummaryStat('Pending Reports', '1', isDark),
                _buildSummaryStat('Follow-ups', '1', isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Patient Summary Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: HealthifyGlassTheme.primaryTeal, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'AI Patient Synthesis Summary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('• 4 recorded consultations in Medrix EHR', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                Text('• Active medications: ${patient.currentMedications.join(", ")}', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                Text('• Last consultation: ${patient.lastVisitDate} by ${patient.lastVisitDoctor}', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                Text('• Follow-up scheduled: ${patient.nextAppointmentText ?? "Oct 05"}', style: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI-generated summary. Review original medical records before making clinical decisions.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String val, bool isDark) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: HealthifyGlassTheme.primaryTeal)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark))),
      ],
    );
  }

  // 2. MEDICAL HISTORY TIMELINE TAB
  Widget _buildMedicalHistoryTab(bool isDark) {
    final history = [
      {'date': 'Sep 28, 2026', 'type': 'Consultation', 'dept': 'Cardiology', 'doctor': 'Dr. Sarah Jenkins'},
      {'date': 'Sep 21, 2026', 'type': 'Blood Test / CBC', 'dept': 'Pathology Lab', 'doctor': 'Dr. Sarah Jenkins'},
      {'date': 'Sep 10, 2026', 'type': 'Follow-up Review', 'dept': 'Cardiology', 'doctor': 'Dr. Sarah Jenkins'},
      {'date': 'Aug 18, 2026', 'type': 'Initial OPD Consultation', 'dept': 'General Medicine', 'doctor': 'Dr. Rahul Verma'},
    ];

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timeline_rounded, color: HealthifyGlassTheme.primaryTeal, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['type']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    Text('${item['date']} • ${item['dept']} (${item['doctor']})', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('View Details'),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. CONSULTATIONS TAB
  Widget _buildConsultationsTab(bool isDark) {
    return ListView(
      children: [
        _buildConsultationCard('Sep 28, 2026', 'Post-ECG chest tightness review', 'Atorvastatin 20mg, Metoprolol 50mg prescribed', isDark),
        const SizedBox(height: 10),
        _buildConsultationCard('Sep 10, 2026', 'Routine Follow-up & Vitals check', 'Stable BP 138/88 mmHg. Continue current meds.', isDark),
      ],
    );
  }

  Widget _buildConsultationCard(String date, String reason, String notes, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HealthifyGlassTheme.primaryTeal)),
              const Text('Dr. Sarah Jenkins', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Reason: $reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 4),
          Text('Notes: $notes', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
        ],
      ),
    );
  }

  // 4. REPORTS TAB
  Widget _buildReportsTab(bool isDark) {
    return ListView(
      children: [
        _buildReportTile('CBC & Troponin-I Test', 'Sep 28, 2026', 'Urgent', true, isDark),
        const SizedBox(height: 10),
        _buildReportTile('12-Lead ECG Report', 'Sep 21, 2026', 'Normal', true, isDark),
        const SizedBox(height: 10),
        _buildReportTile('Lipid Profile Panel', 'Aug 18, 2026', 'Normal', true, isDark),
      ],
    );
  }

  Widget _buildReportTile(String name, String date, String status, bool reviewed, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_rounded, color: Colors.amber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                Text('$date • Status: $status', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
              ],
            ),
          ),
          OutlinedButton(onPressed: () {}, child: const Text('View Report')),
        ],
      ),
    );
  }

  // 5. PRESCRIPTIONS TAB
  Widget _buildPrescriptionsTab(bool isDark) {
    return ListView(
      children: widget.patient.currentMedications.map((med) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.medication_rounded, color: HealthifyGlassTheme.primaryTeal, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    Text('Active Prescription • Prescribed Sep 28', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 6. CLINICAL NOTES TAB
  Widget _buildNotesTab(bool isDark) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Internal Doctor Note', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ),
                  Text('Sep 28, 2026', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Patient reported mild exertional dyspnea. Troponin I slightly elevated. Re-evaluate in 5 days.',
                style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. APPOINTMENTS TAB
  Widget _buildAppointmentsTab(bool isDark) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.event_available_rounded, color: HealthifyGlassTheme.primaryTeal, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Oct 05, 2026 at 10:30 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                    Text('Follow-up Consultation • Cardiology', style: TextStyle(fontSize: 11.5, color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('Scheduled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
