import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class FollowUpTableView extends StatelessWidget {
  final List<DoctorFollowUpFullModel> followUps;
  final ValueChanged<DoctorFollowUpFullModel> onSelectFollowUp;
  final ValueChanged<DoctorFollowUpFullModel> onOpenPatient;
  final ValueChanged<DoctorFollowUpFullModel> onReschedule;
  final ValueChanged<DoctorFollowUpFullModel> onMoreActions;
  final String? selectedFollowUpId;

  const FollowUpTableView({
    super.key,
    required this.followUps,
    required this.onSelectFollowUp,
    required this.onOpenPatient,
    required this.onReschedule,
    required this.onMoreActions,
    this.selectedFollowUpId,
  });

  static String formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    if (followUps.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 56,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 16),
              Text(
                'No follow-ups found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try adjusting your search query or filter criteria.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return _buildMobileCardList(context, isDark);
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerCell('Patient', isDark)),
                Expanded(flex: 2, child: _headerCell('Follow-up Date', isDark)),
                Expanded(flex: 3, child: _headerCell('Reason', isDark)),
                Expanded(flex: 2, child: _headerCell('Last Visit', isDark)),
                Expanded(flex: 2, child: _headerCell('Department', isDark)),
                Expanded(flex: 2, child: _headerCell('Status', isDark)),
                Expanded(flex: 2, child: _headerCell('Doctor', isDark)),
                SizedBox(width: 140, child: _headerCell('Actions', isDark, alignRight: true)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: followUps.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = followUps[index];
              final isSelected = item.id == selectedFollowUpId;

              return InkWell(
                onTap: () => onSelectFollowUp(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: isSelected
                      ? const Color(0xFF0D9488).withValues(alpha: 0.12)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      // Patient
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.patientName,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              item.patientId,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Follow-up Date
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(item.followUpDate),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              item.followUpTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reason
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      // Last Visit
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.previousConsultation != null
                              ? formatDate(item.previousConsultation!.date)
                              : 'None',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      // Department
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.department,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      // Status
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.status.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: item.status.color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            item.status.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.status.color,
                            ),
                          ),
                        ),
                      ),
                      // Doctor
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.doctorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      // Actions
                      SizedBox(
                        width: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => onSelectFollowUp(item),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.person_outline_rounded, size: 18),
                              onPressed: () => onOpenPatient(item),
                              tooltip: 'Open Patient',
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded, size: 18),
                              onPressed: () => onMoreActions(item),
                              tooltip: 'More Actions',
                            ),
                          ],
                        ),
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

  Widget _buildMobileCardList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: followUps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = followUps[index];
        final isSelected = item.id == selectedFollowUpId;

        return InkWell(
          onTap: () => onSelectFollowUp(item),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0D9488).withValues(alpha: 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: item.status.color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        item.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 14, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Follow-up: ${formatDate(item.followUpDate)} at ${item.followUpTime}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.history_rounded, size: 14, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Last Visit: ${item.previousConsultation != null ? formatDate(item.previousConsultation!.date) : "None"} • ${item.department}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: ${item.reason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: GlassSecondaryButton(
                        onPressed: () => onOpenPatient(item),
                        height: 34,
                        child: const Text('Open Patient', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: GlassPrimaryButton(
                        onPressed: () => onSelectFollowUp(item),
                        height: 34,
                        child: const Text('View Details', style: TextStyle(fontSize: 11)),
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

  Widget _headerCell(String label, bool isDark, {bool alignRight = false}) {
    return Text(
      label,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: isDark ? Colors.white60 : const Color(0xFF64748B),
      ),
    );
  }
}
