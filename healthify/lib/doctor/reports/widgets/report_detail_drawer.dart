import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/reports_models.dart';

class ReportDetailDrawer extends StatefulWidget {
  final DoctorReportFullModel report;
  final List<DoctorReportFullModel> allPatientReports;
  final VoidCallback onClose;
  final ValueChanged<DoctorReportFullModel> onSwitchReport;
  final Function(String reportId, String reviewNote) onMarkReviewed;
  final Function(String reportId, String noteText, bool isPrivate) onSaveNote;
  final VoidCallback onAttachToConsultation;

  const ReportDetailDrawer({
    super.key,
    required this.report,
    required this.allPatientReports,
    required this.onClose,
    required this.onSwitchReport,
    required this.onMarkReviewed,
    required this.onSaveNote,
    required this.onAttachToConsultation,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String formatDateTime(DateTime dt) => '${formatDate(dt)} • ${formatTime(dt)}';

  @override
  State<ReportDetailDrawer> createState() => _ReportDetailDrawerState();
}

class _ReportDetailDrawerState extends State<ReportDetailDrawer> {
  double _zoomLevel = 1.0;
  int _rotationDegree = 0;
  bool _isFullscreenPreview = false;

  // Notes state
  bool _isPrivateNote = true;
  late TextEditingController _notesController;
  late TextEditingController _reviewNoteController;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.report.doctorNotesPrivate,
    );
    _reviewNoteController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ReportDetailDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.id != widget.report.id) {
      _zoomLevel = 1.0;
      _rotationDegree = 0;
      _notesController.text = _isPrivateNote
          ? widget.report.doctorNotesPrivate
          : widget.report.doctorNotesPatientVisible;
      _reviewNoteController.clear();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reviewNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      color: isDark
          ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.98)
          : Colors.white.withValues(alpha: 0.98),
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(isDark),
          const Divider(height: 1),

          // Scrollable Detail Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Bar
                  _buildActionBar(isDark),
                  const SizedBox(height: 20),

                  // Information Grid Card
                  _buildInformationGrid(isDark),
                  const SizedBox(height: 20),

                  // Interactive Image / PDF Document Viewer
                  _buildDocumentViewer(isDark),
                  const SizedBox(height: 20),

                  // AI Summary Card with Mandatory Disclaimer
                  _buildAiSummaryCard(isDark),
                  const SizedBox(height: 20),

                  // Findings, Impression, Recommendations
                  _buildFindingsSection(isDark),
                  const SizedBox(height: 20),

                  // Review Workflow Section
                  _buildReviewWorkflowCard(isDark),
                  const SizedBox(height: 20),

                  // Clinical Doctor Notes Editor
                  _buildNotesEditorCard(isDark),
                  const SizedBox(height: 20),

                  // Patient Context & Recent Reports List
                  _buildPatientContextSection(isDark),
                  const SizedBox(height: 20),

                  // Audit History Timeline
                  _buildAuditHistorySection(isDark),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    final report = widget.report;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              report.modality.icon,
              size: 24,
              color: HealthifyGlassTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.id} • Patient: ${report.patientName} (${report.patientId})',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: widget.onClose,
            tooltip: 'Close Viewer',
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    final report = widget.report;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: [
        if (report.status == ReportStatus.pendingReview || report.status == ReportStatus.newReport)
          GlassPrimaryButton(
            onPressed: () => _showReviewDialog(context),
            height: 42,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 18),
                SizedBox(width: 6),
                Text('Mark as Reviewed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  'Reviewed by ${report.reviewDoctorName ?? "Doctor"}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

        GlassSecondaryButton(
          onPressed: widget.onAttachToConsultation,
          height: 42,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_rounded, size: 18),
              const SizedBox(width: 6),
              Text(
                report.attachedConsultationId != null ? 'Attached' : 'Attach to Consultation',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        GlassSecondaryButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading official PDF for ${report.id}...'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          height: 42,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, size: 18),
              SizedBox(width: 6),
              Text('Download PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationGrid(bool isDark) {
    final report = widget.report;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Clinical Meta & Facility Information',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildMetaItem('Department', report.department, isDark),
              _buildMetaItem('Modality', report.modality.label, isDark),
              _buildMetaItem('Requested By', report.requestedBy, isDark),
              _buildMetaItem('Performed By', report.performedBy, isDark),
              _buildMetaItem('Uploaded By', report.uploadedBy, isDark),
              _buildMetaItem('Facility', report.facility, isDark),
              _buildMetaItem(
                'Date Uploaded',
                ReportDetailDrawer.formatDateTime(report.uploadedDate),
                isDark,
              ),
              if (report.reviewedDate != null)
                _buildMetaItem(
                  'Date Reviewed',
                  ReportDetailDrawer.formatDateTime(report.reviewedDate!),
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value, bool isDark) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer(bool isDark) {
    final report = widget.report;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar for Interactive Document Viewer
          Row(
            children: [
              Icon(report.modality.icon, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diagnostic Preview (${report.modality.label})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ),
              // Controls
              IconButton(
                icon: const Icon(Icons.zoom_in_rounded, size: 20),
                onPressed: () {
                  setState(() => _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 3.0));
                },
                tooltip: 'Zoom In',
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out_rounded, size: 20),
                onPressed: () {
                  setState(() => _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 3.0));
                },
                tooltip: 'Zoom Out',
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _zoomLevel = 1.0;
                    _rotationDegree = 0;
                  });
                },
                tooltip: 'Reset View',
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right_rounded, size: 20),
                onPressed: () {
                  setState(() => _rotationDegree = (_rotationDegree + 90) % 360);
                },
                tooltip: 'Rotate 90°',
              ),
              IconButton(
                icon: Icon(
                  _isFullscreenPreview ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _isFullscreenPreview = !_isFullscreenPreview);
                },
                tooltip: 'Toggle Fullscreen',
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Render Area
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isFullscreenPreview ? 480 : 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated Radiological / Document Canvas
                  Transform.rotate(
                    angle: _rotationDegree * 3.14159 / 180,
                    child: Transform.scale(
                      scale: _zoomLevel,
                      child: _buildSimulatedCanvas(report),
                    ),
                  ),

                  // Overlay Details
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID: ${report.id} • ZOOM: ${(_zoomLevel * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'FACILITY: ${report.facility}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedCanvas(DoctorReportFullModel report) {
    if (report.modality == ReportModality.xray) {
      return Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_information_rounded, size: 90, color: Colors.blueGrey),
              SizedBox(height: 12),
              Text(
                'CHEST RADIOGRAPH (PA/LAT) - DICOM PREVIEW',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Patient: Rahul Sharma • Window: Lung Standard (W:1500 L:-600)',
                style: TextStyle(color: Colors.blueGrey, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    } else if (report.modality == ReportModality.mri || report.modality == ReportModality.ctScan) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.center_focus_strong_rounded, size: 90, color: Colors.teal.shade300),
              const SizedBox(height: 12),
              Text(
                '${report.modality.label.toUpperCase()} MULTI-AXIAL SLICES',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'High-Resolution 3D Volume Data • 480 Slices Indexed',
                style: TextStyle(color: Colors.teal, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    } else {
      // Lab / PDF Document preview
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MEDRIX CENTRAL LABORATORY',
                  style: TextStyle(
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'OFFICIAL REPORT',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black26),
            const SizedBox(height: 8),
            Text(
              report.title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              report.findingsText,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                height: 1.4,
              ),
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAiSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Clinical Report Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.report.summaryAiText,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          // Mandatory Disclaimer Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated summary of report content — verify against original report.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
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

  Widget _buildFindingsSection(bool isDark) {
    final report = widget.report;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Clinical Findings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.findingsText,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(
            'Impression',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report.impressionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report.recommendationText,
            style: TextStyle(
              fontSize: 13,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewWorkflowCard(bool isDark) {
    final report = widget.report;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                report.status == ReportStatus.reviewed
                    ? Icons.task_alt_rounded
                    : Icons.pending_actions_rounded,
                size: 20,
                color: report.status == ReportStatus.reviewed
                    ? const Color(0xFF10B981)
                    : Colors.amber,
              ),
              const SizedBox(width: 10),
              Text(
                'Clinical Review & Sign-Off Workflow',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (report.status == ReportStatus.reviewed) ...[
            Text(
              'Reviewed and signed off by ${report.reviewDoctorName ?? "Dr. Sarah Jenkins"} on ${report.reviewedDate != null ? ReportDetailDrawer.formatDateTime(report.reviewedDate!) : "Today"}.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
            if (report.reviewNotes != null && report.reviewNotes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Doctor Sign-off Note: ${report.reviewNotes}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ] else ...[
            Text(
              'Status: Pending Review. Add your clinical review note below to sign off on this diagnostic report.',
              style: TextStyle(
                fontSize: 13,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
            const SizedBox(height: 12),
            GlassPrimaryButton(
              onPressed: () => _showReviewDialog(context),
              height: 42,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rate_review_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Complete Review Sign-off', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesEditorCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 22, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Doctor Clinical Notes Editor',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Toggle Note Privacy
          Row(
            children: [
              ChoiceChip(
                label: const Text('Internal Note (Private)'),
                selected: _isPrivateNote,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _isPrivateNote = true;
                      _notesController.text = widget.report.doctorNotesPrivate;
                    });
                  }
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Patient-Visible Note'),
                selected: !_isPrivateNote,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _isPrivateNote = false;
                      _notesController.text = widget.report.doctorNotesPatientVisible;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 13.5,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              hintText: _isPrivateNote
                  ? 'Enter private internal doctor notes (only visible to medical staff)...'
                  : 'Enter notes visible to the patient on their Medrix Portal app...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: HealthifyGlassTheme.primaryTeal,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GlassPrimaryButton(
              onPressed: () async {
                setState(() => _isSavingNote = true);
                await widget.onSaveNote(
                  widget.report.id,
                  _notesController.text,
                  _isPrivateNote,
                );
                if (mounted) {
                  setState(() => _isSavingNote = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor note saved successfully.')),
                  );
                }
              },
              height: 40,
              isLoading: _isSavingNote,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Save Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientContextSection(bool isDark) {
    final report = widget.report;
    final patientOtherReports = widget.allPatientReports
        .where((r) => r.patientId == report.patientId && r.id != report.id)
        .toList();

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 22, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Patient Context & History (${report.patientName})',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Patient ID: ${report.patientId} • Age: ${report.patientAge} • Gender: ${report.patientGender}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Other Medical Reports for this Patient:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          if (patientOtherReports.isEmpty)
            Text(
              'No other diagnostic reports registered for this patient.',
              style: TextStyle(
                fontSize: 12,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patientOtherReports.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final other = patientOtherReports[idx];
                return InkWell(
                  onTap: () => widget.onSwitchReport(other),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: HealthifyGlassTheme.getGlassBorder(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(other.modality.icon, size: 18, color: HealthifyGlassTheme.primaryTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                other.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${other.id} • ${ReportDetailDrawer.formatDate(other.uploadedDate)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAuditHistorySection(bool isDark) {
    final history = widget.report.auditHistory;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Report Audit Trail & Access History',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isLast = index == history.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.action,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              ReportDetailDrawer.formatDateTime(item.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'By: ${item.performedBy} — ${item.details}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: 12),
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

  void _showReviewDialog(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
          title: Text(
            'Confirm Clinical Sign-off',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are marking report ${widget.report.id} as Reviewed.',
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reviewNoteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter mandatory review comments or recommendations...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            GlassPrimaryButton(
              onPressed: () {
                final note = _reviewNoteController.text.trim();
                widget.onMarkReviewed(
                  widget.report.id,
                  note.isEmpty ? 'Verified and signed off.' : note,
                );
                Navigator.pop(context);
              },
              height: 40,
              child: const Text('Sign Off Report', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
