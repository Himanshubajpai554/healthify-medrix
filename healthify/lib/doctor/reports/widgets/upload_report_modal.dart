import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/reports_models.dart';

class UploadReportModal extends StatefulWidget {
  final Function(DoctorReportFullModel newReport) onUploadComplete;

  const UploadReportModal({
    super.key,
    required this.onUploadComplete,
  });

  @override
  State<UploadReportModal> createState() => _UploadReportModalState();
}

class _UploadReportModalState extends State<UploadReportModal> {
  final _formKey = GlobalKey<FormState>();

  String _selectedPatientName = 'Rahul Sharma';
  String _selectedPatientId = 'MED-PAT-10482';
  int _patientAge = 42;
  String _patientGender = 'Male';

  final _titleController = TextEditingController();
  final _departmentController = TextEditingController(text: 'Radiology');
  final _requestedByController = TextEditingController(text: 'Dr. Sarah Jenkins');
  final _performedByController = TextEditingController(text: 'Central Diagnostic Lab');
  final _facilityController = TextEditingController(text: 'Medrix Diagnostic Wing B');
  final _findingsController = TextEditingController();

  ReportCategory _selectedCategory = ReportCategory.radiology;
  ReportModality _selectedModality = ReportModality.pdf;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;

  final List<Map<String, dynamic>> _mockPatients = [
    {'name': 'Rahul Sharma', 'id': 'MED-PAT-10482', 'age': 42, 'gender': 'Male'},
    {'name': 'Priya Patel', 'id': 'MED-PAT-10391', 'age': 38, 'gender': 'Female'},
    {'name': 'Amit Verma', 'id': 'MED-PAT-10519', 'age': 56, 'gender': 'Male'},
    {'name': 'Ananya Sen', 'id': 'MED-PAT-10220', 'age': 29, 'gender': 'Female'},
    {'name': 'Vikram Malhotra', 'id': 'MED-PAT-10115', 'age': 61, 'gender': 'Male'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _requestedByController.dispose();
    _performedByController.dispose();
    _facilityController.dispose();
    _findingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.upload_file_rounded,
                        size: 40,
                        iconSize: 22,
                        color: HealthifyGlassTheme.primaryTeal,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Medical Report',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Attach diagnostic lab or imaging document to patient record.',
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
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Selection Dropdown
                    Text(
                      'Select Patient',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPatientId,
                          isExpanded: true,
                          dropdownColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
                          items: _mockPatients.map((p) {
                            return DropdownMenuItem<String>(
                              value: p['id'] as String,
                              child: Text(
                                '${p['name']} (${p['id']}) • ${p['age']}y / ${p['gender']}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final p = _mockPatients.firstWhere((element) => element['id'] == val);
                              setState(() {
                                _selectedPatientId = p['id'] as String;
                                _selectedPatientName = p['name'] as String;
                                _patientAge = p['age'] as int;
                                _patientGender = p['gender'] as String;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Report Title
                    Text(
                      'Report Title',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter report title' : null,
                      decoration: InputDecoration(
                        hintText: 'e.g. High-Resolution Chest CT Scan, Fasting Blood Glucose',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category & Modality Selection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ReportCategory>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    dropdownColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
                                    items: ReportCategory.values.where((c) => c != ReportCategory.all).map((c) {
                                      return DropdownMenuItem<ReportCategory>(
                                        value: c,
                                        child: Text(c.label, style: const TextStyle(fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCategory = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modality / File Type',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<ReportModality>(
                                    value: _selectedModality,
                                    isExpanded: true,
                                    dropdownColor: isDark ? HealthifyGlassTheme.darkBackground : Colors.white,
                                    items: ReportModality.values.map((m) {
                                      return DropdownMenuItem<ReportModality>(
                                        value: m,
                                        child: Text(m.label, style: const TextStyle(fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedModality = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Department & Facility
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _departmentController,
                            decoration: InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _facilityController,
                            decoration: InputDecoration(
                              labelText: 'Diagnostic Facility',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Findings summary
                    TextFormField(
                      controller: _findingsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Initial Findings & Observations',
                        hintText: 'Enter clinical observations or summary of test results...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // File picker simulation
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFileName = 'MED_REPORT_${DateTime.now().millisecondsSinceEpoch}.pdf';
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFileName != null ? Icons.task_rounded : Icons.cloud_upload_rounded,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedFileName ?? 'Click to attach PDF, DICOM, or High-Res Image file',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isUploading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: HealthifyGlassTheme.getGlassBorder(isDark),
                        color: HealthifyGlassTheme.primaryTeal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploading & indexing report file... (${(_uploadProgress * 100).toInt()}%)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        GlassPrimaryButton(
                          onPressed: _startUploadProcess,
                          height: 44,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Submit & Index Report', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startUploadProcess() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFileName == null) {
      setState(() {
        _selectedFileName = 'SCAN_${DateTime.now().millisecondsSinceEpoch}.pdf';
      });
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.2;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _uploadProgress = 0.6);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _uploadProgress = 1.0);

    final newReport = DoctorReportFullModel(
      id: 'REP-20261001-${(100 + (DateTime.now().millisecond % 899)).toString()}',
      title: _titleController.text.trim(),
      patientId: _selectedPatientId,
      patientName: _selectedPatientName,
      patientAge: _patientAge,
      patientGender: _patientGender,
      category: _selectedCategory,
      status: ReportStatus.newReport,
      modality: _selectedModality,
      uploadedDate: DateTime.now(),
      uploadedBy: 'Dr. Sarah Jenkins',
      requestedBy: _requestedByController.text.trim(),
      performedBy: _performedByController.text.trim(),
      department: _departmentController.text.trim(),
      facility: _facilityController.text.trim(),
      summaryAiText: 'Automated initial indexing complete. Findings pending doctor review.',
      findingsText: _findingsController.text.trim().isEmpty
          ? 'Diagnostic investigation completed. Report pending detailed radiologist / pathologist verification.'
          : _findingsController.text.trim(),
      impressionText: 'Pending clinical evaluation.',
      recommendationText: 'Follow up with attending physician.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-NEW',
          timestamp: DateTime.now(),
          action: 'Uploaded',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Uploaded file $_selectedFileName',
        ),
      ],
    );

    widget.onUploadComplete(newReport);
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
