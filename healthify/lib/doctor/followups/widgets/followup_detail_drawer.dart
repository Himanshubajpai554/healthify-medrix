import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class FollowUpDetailDrawer extends StatefulWidget {
  final DoctorFollowUpFullModel followUp;
  final VoidCallback onClose;
  final VoidCallback onOpenPatient;
  final VoidCallback onReschedule;
  final VoidCallback onMarkCompleted;
  final VoidCallback onCancelFollowUp;
  final VoidCallback onViewConsultation;
  final VoidCallback onViewReports;
  final VoidCallback onViewPrescriptions;
  final VoidCallback onScheduleAppointment;
  final Function(FollowUpNoteType type, String content) onAddNote;

  const FollowUpDetailDrawer({
    super.key,
    required this.followUp,
    required this.onClose,
    required this.onOpenPatient,
    required this.onReschedule,
    required this.onMarkCompleted,
    required this.onCancelFollowUp,
    required this.onViewConsultation,
    required this.onViewReports,
    required this.onViewPrescriptions,
    required this.onScheduleAppointment,
    required this.onAddNote,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  State<FollowUpDetailDrawer> createState() => _FollowUpDetailDrawerState();
}

class _FollowUpDetailDrawerState extends State<FollowUpDetailDrawer> {
  FollowUpNoteType _noteType = FollowUpNoteType.internal;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitNote() {
    final text = _noteController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddNote(_noteType, text);
      _noteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final fu = widget.followUp;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Follow-up Detail',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: fu.status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: fu.status.color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              fu.status.label,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fu.status.color),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'ID: ${fu.id} • Date: ${FollowUpDetailDrawer.formatDate(fu.followUpDate)} at ${fu.followUpTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Drawer Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Action Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      GlassPrimaryButton(
                        onPressed: widget.onOpenPatient,
                        height: 38,
                        child: const Row(
                          children: [
                            Icon(Icons.person_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Open Patient'),
                          ],
                        ),
                      ),
                      GlassSecondaryButton(
                        onPressed: widget.onReschedule,
                        height: 38,
                        child: const Row(
                          children: [
                            Icon(Icons.update_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Reschedule'),
                          ],
                        ),
                      ),
                      if (fu.status != FollowUpStatus.completed)
                        GlassSecondaryButton(
                          onPressed: widget.onMarkCompleted,
                          height: 38,
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Mark Completed'),
                            ],
                          ),
                        ),
                      if (fu.status != FollowUpStatus.cancelled)
                        TextButton(
                          onPressed: widget.onCancelFollowUp,
                          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1. Patient Context Card
                  _buildPatientContextCard(isDark),
                  const SizedBox(height: 16),

                  // 2. Follow-up Info & Original Reason
                  _buildFollowUpInfoCard(isDark),
                  const SizedBox(height: 16),

                  // 3. Controlled AI Summary Card
                  _buildAISummaryCard(isDark),
                  const SizedBox(height: 16),

                  // 4. Previous Consultation Summary Card
                  _buildPreviousConsultationCard(isDark),
                  const SizedBox(height: 16),

                  // 5. Upcoming Appointment Card
                  _buildUpcomingAppointmentCard(isDark),
                  const SizedBox(height: 16),

                  // 6. Follow-up History & Reschedule History
                  _buildHistoryTimelineCard(isDark),
                  const SizedBox(height: 16),

                  // 7. Clinical Notes Editor & Log
                  _buildNotesSection(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientContextCard(bool isDark) {
    final fu = widget.followUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Context',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling patient phone: ${fu.phone}')),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF0D9488)),
                    const SizedBox(width: 4),
                    Text(
                      'Contact Patient',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fu.patientName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
          Text(
            'ID: ${fu.patientId} • Age: ${fu.patientAge} • Gender: ${fu.patientGender} • Blood: ${fu.bloodGroup}',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
          ),
          if (fu.allergies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  'Allergies: ${fu.allergies.join(", ")}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Quick navigation links
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _quickLinkChip('Profile', Icons.person_outline_rounded, widget.onOpenPatient),
              _quickLinkChip('Medical History', Icons.folder_shared_rounded, widget.onOpenPatient),
              _quickLinkChip('Consultation', Icons.medical_services_outlined, widget.onViewConsultation),
              _quickLinkChip('Reports', Icons.assignment_outlined, widget.onViewReports),
              _quickLinkChip('Prescriptions', Icons.medication_outlined, widget.onViewPrescriptions),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickLinkChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF0D9488)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpInfoCard(bool isDark) {
    final fu = widget.followUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Follow-up Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 10),
          _infoRow('Follow-up Date', '${FollowUpDetailDrawer.formatDate(fu.followUpDate)} at ${fu.followUpTime}', isDark),
          _infoRow('Department', fu.department, isDark),
          _infoRow('Assigned Doctor', fu.doctorName, isDark),
          _infoRow('Created Date', '${FollowUpDetailDrawer.formatDate(fu.createdDate)} by ${fu.createdBy}', isDark),
          if (fu.previousConsultation != null)
            _infoRow('Related Consultation', '${fu.previousConsultation!.id} (${FollowUpDetailDrawer.formatDate(fu.previousConsultation!.date)})', isDark),
          const SizedBox(height: 8),
          Text('Original Follow-up Reason:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(fu.reason, style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard(bool isDark) {
    final fu = widget.followUp;
    final summaryText = fu.aiSummary ?? 'Patient has had 3 recorded follow-up visits during the last 6 months. The latest scheduled follow-up is ${FollowUpDetailDrawer.formatDate(fu.followUpDate)}.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.purple.shade900.withValues(alpha: 0.15) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.purple.shade700 : const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: isDark ? Colors.purple.shade300 : Colors.purple.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Follow-up Summary',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.purple.shade200 : Colors.purple.shade900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('Assistive Only', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summaryText,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.purple.shade100 : const Color(0xFF581C87)),
          ),
          const SizedBox(height: 8),
          Text(
            'Disclaimer: AI-generated summary — verify against original patient records. AI does not make clinical decisions.',
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: isDark ? Colors.purple.shade300 : Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousConsultationCard(bool isDark) {
    final fu = widget.followUp;
    if (fu.previousConsultation == null) return const SizedBox();

    final pc = fu.previousConsultation!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Previous Consultation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              GlassSecondaryButton(
                onPressed: widget.onViewConsultation,
                height: 30,
                child: const Text('View Consultation', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Date: ${FollowUpDetailDrawer.formatDate(pc.date)} • ${pc.doctorName} (${pc.department})', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
          const SizedBox(height: 6),
          Text('Clinical Notes Summary:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569))),
          Text(pc.clinicalNotesSummary, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(bool isDark) {
    final fu = widget.followUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Appointment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
              if (fu.upcomingAppointment != null)
                GlassSecondaryButton(
                  onPressed: widget.onReschedule,
                  height: 30,
                  child: const Text('Reschedule', style: TextStyle(fontSize: 11)),
                )
              else
                GlassPrimaryButton(
                  onPressed: widget.onScheduleAppointment,
                  height: 30,
                  child: const Text('Schedule Appointment', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (fu.upcomingAppointment != null) ...[
            Text(
              'Date: ${FollowUpDetailDrawer.formatDate(fu.upcomingAppointment!.appointmentDate)} at ${fu.upcomingAppointment!.timeSlot}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            Text(
              'Type: ${fu.upcomingAppointment!.type} • Status: ${fu.upcomingAppointment!.status}',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ] else ...[
            Text('No appointment scheduled.', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF64748B))),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTimelineCard(bool isDark) {
    final fu = widget.followUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Follow-up History & Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fu.timeline.length,
            itemBuilder: (context, index) {
              final item = fu.timeline[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF0D9488)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${FollowUpDetailDrawer.formatDate(item.timestamp)} • ${item.actor}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                          ),
                          Text(item.action, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          if (item.optionalNote != null)
                            Text(item.optionalNote!, style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDark) {
    final fu = widget.followUp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical Follow-up Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 10),
          DropdownButtonFormField<FollowUpNoteType>(
            initialValue: _noteType,
            decoration: const InputDecoration(labelText: 'Note Visibility'),
            items: FollowUpNoteType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _noteType = val);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Add a clinical note...'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GlassSecondaryButton(
              onPressed: _submitNote,
              height: 34,
              child: const Text('Add Note', style: TextStyle(fontSize: 12)),
            ),
          ),
          if (fu.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...fu.notes.map((n) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n.author, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(n.noteType.label, style: const TextStyle(fontSize: 10, color: Color(0xFF0D9488))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(n.content, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}
