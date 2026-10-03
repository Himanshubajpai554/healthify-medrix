import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class TicketDetailDrawer extends StatefulWidget {
  final SupportTicketModel ticket;
  final VoidCallback onClose;
  final Function(String messageText) onSendReply;

  const TicketDetailDrawer({
    super.key,
    required this.ticket,
    required this.onClose,
    required this.onSendReply,
  });

  @override
  State<TicketDetailDrawer> createState() => _TicketDetailDrawerState();
}

class _TicketDetailDrawerState extends State<TicketDetailDrawer> {
  final _replyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _replyCtrl.text.trim();
    if (text.isNotEmpty) {
      setState(() => _isSending = true);
      await widget.onSendReply(text);
      _replyCtrl.clear();
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              GlassIconContainer(
                icon: Icons.confirmation_number_rounded,
                size: 44,
                iconSize: 22,
                color: widget.ticket.status.color,
                borderRadius: 12,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.ticket.id,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.ticket.status.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.ticket.status.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.ticket.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.ticket.subject,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: widget.onClose,
                tooltip: 'Close Ticket',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Threaded Conversation Messages
          Text(
            'CONVERSATION HISTORY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.ticket.messages.length,
            itemBuilder: (context, idx) {
              final msg = widget.ticket.messages[idx];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: msg.isDoctor
                        ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.15 : 0.08)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: msg.isDoctor
                          ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)
                          : HealthifyGlassTheme.getGlassBorder(isDark),
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
                              msg.senderName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: msg.isDoctor
                                    ? HealthifyGlassTheme.primaryTeal
                                    : HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(msg.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.messageText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Reply Composer
          if (widget.ticket.status != SupportTicketStatus.closed) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 340;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _replyCtrl,
                        style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                        decoration: InputDecoration(
                          hintText: 'Type your reply message...',
                          hintStyle: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextMuted(isDark)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassPrimaryButton(
                        height: 40,
                        onPressed: _isSending ? null : _handleSend,
                        child: _isSending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text('Reply', style: TextStyle(fontSize: 12, color: Colors.white)),
                                ],
                              ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyCtrl,
                        style: TextStyle(fontSize: 13, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                        decoration: InputDecoration(
                          hintText: 'Type your reply message...',
                          hintStyle: TextStyle(fontSize: 12.5, color: HealthifyGlassTheme.getTextMuted(isDark)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassPrimaryButton(
                      height: 42,
                      onPressed: _isSending ? null : _handleSend,
                      child: _isSending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Row(
                              children: [
                                Icon(Icons.send_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Reply', style: TextStyle(fontSize: 12, color: Colors.white)),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
