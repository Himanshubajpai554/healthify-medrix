import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class MySupportTicketsSection extends StatelessWidget {
  final List<SupportTicketModel> tickets;
  final ValueChanged<SupportTicketModel> onSelectTicket;

  const MySupportTicketsSection({
    super.key,
    required this.tickets,
    required this.onSelectTicket,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    if (tickets.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              GlassIconContainer(
                icon: Icons.confirmation_number_outlined,
                size: 50,
                iconSize: 24,
                color: HealthifyGlassTheme.getTextMuted(isDark),
              ),
              const SizedBox(height: 12),
              Text(
                'No Support Requests Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'When you log a technical issue or problem report, tickets will appear here.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.confirmation_number_rounded,
                size: 40,
                iconSize: 20,
                color: HealthifyGlassTheme.primaryTeal,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Support Requests & Tickets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Track progress and reply to IT support specialists.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          ...tickets.map((ticket) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ticket.id,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ticket.status.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ticket.status.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            ticket.status.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: ticket.status.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatRelativeTime(ticket.lastUpdated),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: HealthifyGlassTheme.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.subject,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${ticket.category} • Priority: ${ticket.priority.label} • ${ticket.messages.length} messages',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GlassSecondaryButton(
                          height: 34,
                          onPressed: () => onSelectTicket(ticket),
                          child: const Row(
                            children: [
                              Icon(Icons.forum_outlined, size: 14),
                              SizedBox(width: 5),
                              Text('View Ticket & Reply', style: TextStyle(fontSize: 11.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
