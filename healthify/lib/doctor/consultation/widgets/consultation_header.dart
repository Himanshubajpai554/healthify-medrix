import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/consultation_models.dart';

class ConsultationHeader extends StatelessWidget {
  final ConsultationFullModel consultation;
  final AutosaveState autosaveState;
  final VoidCallback onSaveDraft;
  final VoidCallback onPause;
  final VoidCallback onCompleteConsultation;

  const ConsultationHeader({
    super.key,
    required this.consultation,
    required this.autosaveState,
    required this.onSaveDraft,
    required this.onPause,
    required this.onCompleteConsultation,
  });

  @override
  Widget build(BuildContext context) {
    final patient = consultation.patient;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Avatar & Badge
              Stack(
                children: [
                  Container(
                    width: isDesktop ? 60 : 50,
                    height: isDesktop ? 60 : 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryTeal, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(patient.avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Identity Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          patient.name,
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            patient.id,
                            style: const TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        _buildStatusBadge(consultation.status),
                        _buildAutosaveIndicator(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _buildHeaderMeta(Icons.cake_outlined, 'Age: ${patient.age} yrs'),
                        _buildHeaderMeta(
                          patient.gender.toLowerCase() == 'male' ? Icons.male_rounded : Icons.female_rounded,
                          patient.gender,
                        ),
                        _buildHeaderMeta(Icons.water_drop_outlined, 'Blood: ${patient.bloodGroup}', isHighlight: true),
                        _buildHeaderMeta(Icons.calendar_month_rounded, '04 Oct 2026, 10:30 AM'),
                        _buildHeaderMeta(Icons.domain_rounded, 'Cardiology (Follow-up)'),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons Row (Desktop)
              if (isDesktop)
                Row(
                  children: [
                    GlassSecondaryButton(
                      onPressed: onSaveDraft,
                      child: const Row(
                        children: [
                          Icon(Icons.save_outlined, size: 16, color: AppTheme.textPrimary),
                          SizedBox(width: 6),
                          Text('Save Draft'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassSecondaryButton(
                      onPressed: onPause,
                      child: const Row(
                        children: [
                          Icon(Icons.pause_circle_outline_rounded, size: 16, color: AppTheme.textPrimary),
                          SizedBox(width: 6),
                          Text('Pause'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassPrimaryButton(
                      onPressed: onCompleteConsultation,
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Complete Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Action Row for Mobile / Tablet
          if (!isDesktop) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: onSaveDraft,
                    child: const Text('Save Draft', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GlassSecondaryButton(
                    onPressed: onPause,
                    child: const Text('Pause', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: GlassPrimaryButton(
                    onPressed: onCompleteConsultation,
                    child: const Text('Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderMeta(IconData icon, String label, {bool isHighlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: isHighlight ? const Color(0xFFEF4444) : AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isHighlight ? const Color(0xFFEF4444) : AppTheme.textSecondary,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ConsultationStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case ConsultationStatus.inConsultation:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = 'In Consultation';
        break;
      case ConsultationStatus.draft:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'Consultation Draft';
        break;
      case ConsultationStatus.completed:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        label = 'Completed';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppTheme.textSecondary;
        label = 'In Consultation';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildAutosaveIndicator() {
    String text;
    IconData icon;
    Color color;

    switch (autosaveState) {
      case AutosaveState.saving:
        text = 'Saving...';
        icon = Icons.sync_rounded;
        color = AppTheme.accentColor;
        break;
      case AutosaveState.saved:
        text = consultation.lastSavedAt;
        icon = Icons.cloud_done_rounded;
        color = const Color(0xFF10B981);
        break;
      case AutosaveState.failed:
        text = 'Save failed';
        icon = Icons.cloud_off_rounded;
        color = const Color(0xFFEF4444);
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
