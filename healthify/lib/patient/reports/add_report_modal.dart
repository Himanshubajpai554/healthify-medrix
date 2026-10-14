import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

/// Modal for patients to upload an external medical report.
///
/// **Live mode** (patientPortalRepository != null):
///   1. User fills report details and picks a file via file_picker.
///   2. On submit: a metadata record is saved to [patientReports] via
///      [saveMyPatientRecord] (isExternalUploaded = true).
///   3. File bytes are then uploaded via [uploadPatientReportFile], which
///      stores them in Serverpod private storage and updates the metadata
///      record with a [fileReference] block.
///
/// **Demo mode** (no server): shows a [DEMO] labelled mock entry.
class AddReportModal extends StatefulWidget {
  final Function(MedicalReport newReport) onReportAdded;

  const AddReportModal({super.key, required this.onReportAdded});

  static void show(
    BuildContext context, {
    required Function(MedicalReport newReport) onReportAdded,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => AddReportModal(onReportAdded: onReportAdded),
    );
  }

  @override
  State<AddReportModal> createState() => _AddReportModalState();
}

class _AddReportModalState extends State<AddReportModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();

  String _selectedCategory = 'Lab Reports';
  DateTime _selectedDate = DateTime.now();

  // Picked file state
  Uint8List? _pickedBytes;
  String _pickedFileName = '';
  String _pickedMimeType = '';
  String _pickedSourceLabel = '';

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadError = '';

  final List<String> _categories = [
    'Lab Reports',
    'Prescriptions',
    'Imaging',
    'Doctor Notes',
    'Discharge Summary',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _hospitalController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    _applyPickResult(result, 'PDF Document');
  }

  Future<void> _pickFromGallery() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    _applyPickResult(result, 'Gallery Image');
  }

  Future<void> _pickFromCamera() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    _applyPickResult(result, 'Camera Photo');
  }

  void _applyPickResult(FilePickerResult? result, String sourceLabel) {
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      setState(() => _uploadError = 'Could not read file bytes. Please try again.');
      return;
    }
    final ext = (file.extension ?? 'pdf').toLowerCase();
    final mime = switch (ext) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'application/octet-stream',
    };
    setState(() {
      _pickedBytes = file.bytes;
      _pickedFileName = file.name;
      _pickedMimeType = mime;
      _pickedSourceLabel = sourceLabel;
      _uploadError = '';
    });
  }

  // ── Submission ────────────────────────────────────────────────────────────

  Future<void> _submitUpload() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_pickedBytes == null) {
      setState(
        () => _uploadError = 'Please select a document or photo file to attach.',
      );
      return;
    }

    final repo = RepositoryContainer.instance.patientPortalRepository;
    final isLive = repo != null;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.05;
      _uploadError = '';
    });

    try {
      final recordKey =
          'REP-${DateTime.now().millisecondsSinceEpoch}';
      final title = _titleController.text.trim();
      final hospitalName =
          _hospitalController.text.trim().isEmpty
              ? 'External Lab / Clinic'
              : _hospitalController.text.trim();
      final doctorName =
          _doctorController.text.trim().isEmpty
              ? 'Self-Uploaded'
              : _doctorController.text.trim();
      final fileExt =
          _pickedFileName.contains('.') ? _pickedFileName.split('.').last.toUpperCase() : 'PDF';
      final fileSizeKb = (_pickedBytes!.lengthInBytes / 1024).toStringAsFixed(1);

      MedicalReport newReport;

      if (isLive) {
        // Step 1: save metadata record
        setState(() => _uploadProgress = 0.2);
        final now = DateTime.now().toUtc();
        await repo.save('patientReports', recordKey, {
          'id': recordKey,
          'title': title,
          'category': _selectedCategory,
          'hospitalName': hospitalName,
          'doctorName': doctorName,
          'date': _selectedDate.toIso8601String(),
          'fileFormat': fileExt,
          'isExternalUploaded': true,
          'hasAttachedFile': false,
          'summary':
              'User-uploaded external medical record ($_pickedSourceLabel). Encrypted in Healthify vault.',
        });

        // Step 2: upload file bytes
        setState(() => _uploadProgress = 0.5);
        await repo.uploadReportFile(
          recordKey: recordKey,
          fileName: _pickedFileName,
          mimeType: _pickedMimeType,
          bytes: _pickedBytes!,
        );
        setState(() => _uploadProgress = 1.0);

        newReport = MedicalReport(
          id: recordKey,
          title: title,
          category: _selectedCategory,
          hospitalName: hospitalName,
          doctorName: doctorName,
          date: _selectedDate,
          summary:
              'User-uploaded external medical record ($_pickedSourceLabel). Encrypted in Healthify vault.',
          fileFormat: fileExt,
          fileSize: '$fileSizeKb KB',
          isExternalUploaded: true,
          accessLogs: [
            ReportAccessLog(
              viewerName: 'Patient (You)',
              viewerRole: 'Owner',
              timestamp: now,
              action: 'Uploaded Record',
            ),
          ],
        );
      } else {
        // Demo mode: no server calls, label clearly as [DEMO]
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() => _uploadProgress = 1.0);
        newReport = MedicalReport(
          id: recordKey,
          title: '[DEMO] $title',
          category: _selectedCategory,
          hospitalName: hospitalName,
          doctorName: doctorName,
          date: _selectedDate,
          summary: '[DEMO] Demo-mode upload — no server connection.',
          fileFormat: fileExt,
          fileSize: '$fileSizeKb KB',
          isExternalUploaded: true,
          accessLogs: [
            ReportAccessLog(
              viewerName: 'Patient (You)',
              viewerRole: 'Owner',
              timestamp: DateTime.now(),
              action: '[DEMO] Simulated Upload',
            ),
          ],
        );
      }

      if (!mounted) return;
      widget.onReportAdded(newReport);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLive
                ? '✓ Medical report uploaded & encrypted successfully!'
                : '✓ [DEMO] Report added locally (no server).',
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadError = 'Upload failed: ${e.toString()}';
      });
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLive = RepositoryContainer.instance.patientPortalRepository != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal handle & title bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Add External Report',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Upload PDFs or photos of your previous medical records',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
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

              // Offline banner
              if (!isLive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '[DEMO] Not connected to server — report will be added locally only.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // File source picker
              const Text(
                '1. Select Document Source',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Upload PDF',
                      color: Colors.red,
                      isSelected: _pickedSourceLabel == 'PDF Document',
                      onTap: _pickPdf,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take Photo',
                      color: Colors.teal,
                      isSelected: _pickedSourceLabel == 'Camera Photo',
                      onTap: _pickFromCamera,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'From Gallery',
                      color: Colors.blue,
                      isSelected: _pickedSourceLabel == 'Gallery Image',
                      onTap: _pickFromGallery,
                    ),
                  ),
                ],
              ),

              // Picked file indicator
              if (_pickedBytes != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.teal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pickedFileName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(_pickedBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error
              if (_uploadError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _uploadError,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                '2. Report Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              TextFormField(
                controller: _titleController,
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter report title'
                            : null,
                decoration: InputDecoration(
                  labelText: 'Report Title *',
                  hintText: 'e.g., Blood Test CBC, Thyroid Panel, Chest X-Ray',
                  prefixIcon: const Icon(Icons.title_rounded, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: InputDecoration(
                  labelText: 'Report Category *',
                  prefixIcon: const Icon(
                    Icons.category_rounded,
                    color: Colors.teal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Hospital & Doctor
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hospitalController,
                      decoration: InputDecoration(
                        labelText: 'Hospital / Clinic',
                        hintText: 'City Care Clinic',
                        prefixIcon: const Icon(
                          Icons.domain_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _doctorController,
                      decoration: InputDecoration(
                        labelText: 'Doctor Name',
                        hintText: 'Dr. Sharma',
                        prefixIcon: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.teal,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date of Report',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Upload progress
              if (_isUploading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Encrypting & Uploading…',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.teal.withValues(alpha: 0.15),
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _submitUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    _isUploading ? 'Uploading Record…' : 'Upload & Save Report',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}