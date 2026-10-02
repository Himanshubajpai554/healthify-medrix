import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class ContactSupportModal extends StatefulWidget {
  final Future<String> Function({
    required String subject,
    required String category,
    required SupportTicketPriority priority,
    required String description,
    required List<String> attachments,
  }) onSubmitTicket;

  const ContactSupportModal({
    super.key,
    required this.onSubmitTicket,
  });

  @override
  State<ContactSupportModal> createState() => _ContactSupportModalState();
}

class _ContactSupportModalState extends State<ContactSupportModal> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'Technical Issue';
  SupportTicketPriority _selectedPriority = SupportTicketPriority.normal;
  final List<String> _attachments = [];
  bool _isReviewMode = false;
  bool _isSubmitting = false;

  final categories = [
    'Technical Issue',
    'Account',
    'Appointments',
    'Patient Records',
    'Reports',
    'Prescriptions',
    'Emergency Workflow',
    'Notifications',
    'Other',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleAddMockAttachment() {
    setState(() {
      _attachments.add('screenshot_log_${DateTime.now().millisecondsSinceEpoch % 1000}.png (1.2 MB)');
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final ticketId = await widget.onSubmitTicket(
      subject: _subjectCtrl.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      description: _descCtrl.text.trim(),
      attachments: List.from(_attachments),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = HealthifyGlassTheme.isDarkMode(ctx);

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                SizedBox(width: 10),
                Text('Support Request Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your support request has been logged successfully.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('Ticket ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      SelectableText(
                        ticketId,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Medrix IT support specialists will review your ticket and respond in My Support Requests.'),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.support_agent_rounded,
                    size: 44,
                    iconSize: 22,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isReviewMode ? 'Review Support Request' : 'Contact Support / Report Problem',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          _isReviewMode ? 'Verify details before submitting ticket.' : 'Log a ticket with hospital IT and platform support.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              // Form or Review View
              Flexible(
                child: SingleChildScrollView(
                  child: !_isReviewMode ? _buildForm(isDark) : _buildReviewView(isDark),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isReviewMode)
                    GlassSecondaryButton(
                      height: 40,
                      onPressed: () => setState(() => _isReviewMode = false),
                      child: const Text('Edit Details', style: TextStyle(fontSize: 13)),
                    )
                  else
                    GlassSecondaryButton(
                      height: 40,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                    ),
                  const SizedBox(width: 10),
                  GlassPrimaryButton(
                    height: 40,
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_isReviewMode) {
                              _handleSubmit();
                            } else {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() => _isReviewMode = true);
                              }
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isReviewMode ? 'Submit Ticket' : 'Review & Proceed',
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy Notice Alert
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, size: 18, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Privacy Reminder: Do not include unnecessary patient medical records or PHI in ticket descriptions.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Issue Category & Priority Dropdowns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Category',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: _buildInputDeco(isDark),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
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
                      'Support Priority',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<SupportTicketPriority>(
                      initialValue: _selectedPriority,
                      decoration: _buildInputDeco(isDark),
                      items: SupportTicketPriority.values
                          .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subject Field
          Text(
            'Subject Summary',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _subjectCtrl,
            style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
            decoration: _buildInputDeco(isDark, hint: 'e.g. Reports page not loading DICOM study'),
            validator: (val) => val == null || val.isEmpty ? 'Subject required' : null,
          ),
          const SizedBox(height: 12),

          // Description Field
          Text(
            'Detailed Description',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descCtrl,
            maxLines: 4,
            style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
            decoration: _buildInputDeco(isDark, hint: 'Describe the issue or error encountered...'),
            validator: (val) => val == null || val.isEmpty ? 'Description required' : null,
          ),
          const SizedBox(height: 14),

          // File Attachments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attachments (Screenshots / Logs)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
              ),
              TextButton.icon(
                onPressed: _handleAddMockAttachment,
                icon: const Icon(Icons.attach_file_rounded, size: 14),
                label: const Text('Attach File', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 6),
            ..._attachments.map((file) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(file, style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () => setState(() => _attachments.remove(file)),
                      ),
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

  Widget _buildReviewView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewRow('Category:', _selectedCategory, isDark),
        _buildReviewRow('Priority:', _selectedPriority.label, isDark),
        _buildReviewRow('Subject:', _subjectCtrl.text, isDark),
        const SizedBox(height: 8),
        Text('Description:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
          ),
          child: Text(_descCtrl.text, style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark))),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Attachments: ${_attachments.length} files attached', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark))),
        ],
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextSecondary(isDark))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDeco(bool isDark, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
    );
  }
}
