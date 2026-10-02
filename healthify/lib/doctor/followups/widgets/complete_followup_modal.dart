import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class CompleteFollowUpModal extends StatefulWidget {
  final DoctorFollowUpFullModel followUp;
  final Function(String completionNote) onCompleteConfirmed;

  const CompleteFollowUpModal({
    super.key,
    required this.followUp,
    required this.onCompleteConfirmed,
  });

  @override
  State<CompleteFollowUpModal> createState() => _CompleteFollowUpModalState();
}

class _CompleteFollowUpModalState extends State<CompleteFollowUpModal> {
  final _noteController = TextEditingController(text: 'Follow-up consultation completed.');

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onCompleteConfirmed(_noteController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.check_circle_outline_rounded,
                    size: 40,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Follow-up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'ID: ${widget.followUp.id} • ${widget.followUp.patientName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Mark this follow-up visit as completed? The original follow-up record will remain permanently preserved in patient history.',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
              const SizedBox(height: 16),

              Text('Completion Outcome Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'e.g. Patient fully recovered. Spirometry & vitals within normal parameters.',
                  hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassSecondaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    height: 40,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GlassPrimaryButton(
                    onPressed: _submit,
                    height: 40,
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Mark Completed'),
                      ],
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
}
