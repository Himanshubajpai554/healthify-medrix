import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class SendFeedbackModal extends StatefulWidget {
  final Future<void> Function(String type, String message) onSubmitFeedback;

  const SendFeedbackModal({
    super.key,
    required this.onSubmitFeedback,
  });

  @override
  State<SendFeedbackModal> createState() => _SendFeedbackModalState();
}

class _SendFeedbackModalState extends State<SendFeedbackModal> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  String _selectedType = 'Suggestion';
  bool _isSubmitting = false;

  final types = ['Suggestion', 'Bug', 'Usability', 'Other'];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      await widget.onSubmitFeedback(_selectedType, _messageCtrl.text.trim());
      setState(() => _isSubmitting = false);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback! Your suggestion helps improve Medrix.'),
            backgroundColor: HealthifyGlassTheme.primaryTeal,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.rate_review_rounded,
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
                            'Send Feedback',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Share suggestions or usability ideas with the product team.',
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

                Text(
                  'Feedback Type',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                  ),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),

                Text(
                  'Feedback Message',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 4,
                  style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    hintText: 'Share your feedback, feature idea, or workflow suggestion...',
                    hintStyle: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextMuted(isDark)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Feedback message required' : null,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassSecondaryButton(
                      height: 40,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    GlassPrimaryButton(
                      height: 40,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Row(
                              children: [
                                Icon(Icons.send_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 5),
                                Text('Submit Feedback', style: TextStyle(fontSize: 13, color: Colors.white)),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
