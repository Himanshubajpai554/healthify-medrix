import 'package:flutter/material.dart';
import '../../main.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/doctor_help_models.dart';
import '../services/doctor_help_service.dart';
import '../services/doctor_notification_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/common_topics_grid.dart';
import 'widgets/contact_support_modal.dart';
import 'widgets/faq_accordion_section.dart';
import 'widgets/help_article_detail_drawer.dart';
import 'widgets/help_header.dart';
import 'widgets/hospital_admin_contact_card.dart';
import 'widgets/my_support_tickets_section.dart';
import 'widgets/quick_help_actions.dart';
import 'widgets/send_feedback_modal.dart';
import 'widgets/system_status_widget.dart';
import 'widgets/ticket_detail_drawer.dart';
import 'widgets/troubleshooting_section.dart';

class DoctorHelpSupportScreen extends StatefulWidget {
  const DoctorHelpSupportScreen({super.key});

  @override
  State<DoctorHelpSupportScreen> createState() =>
      _DoctorHelpSupportScreenState();
}

class _DoctorHelpSupportScreenState extends State<DoctorHelpSupportScreen> {
  final DoctorHelpService _helpService = DoctorHelpService();
  final DoctorNotificationService _notificationService = DoctorNotificationService();

  int _selectedNavIndex = 11; // Help & Support index
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;

  String _searchQuery = '';
  HelpArticleCategory? _selectedCategory;
  HelpArticleModel? _selectedArticle;
  SupportTicketModel? _selectedTicket;

  @override
  void initState() {
    super.initState();
  }

  void _onNavItemSelected(int index) {
    if (index == _selectedNavIndex) return;

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/doctor-appointments');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/doctor-patients');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/doctor-patient-profile');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/doctor-reports');
        break;
      case 5:
        Navigator.of(context).pushReplacementNamed('/doctor-prescriptions');
        break;
      case 6:
        Navigator.of(context).pushReplacementNamed('/doctor-emergency-cases');
        break;
      case 7:
        Navigator.of(context).pushReplacementNamed('/doctor-patient-followups');
        break;
      case 8:
        Navigator.of(context).pushReplacementNamed('/doctor-analytics');
        break;
      case 9:
        Navigator.of(context).pushReplacementNamed('/doctor-notifications');
        break;
      case 10:
        Navigator.of(context).pushReplacementNamed('/doctor-settings');
        break;
      case 11:
        // Already on Help & Support
        break;
      default:
        break;
    }
  }

  void _openContactSupportModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return ContactSupportModal(
          onSubmitTicket: ({
            required subject,
            required category,
            required priority,
            required description,
            required attachments,
          }) async {
            final ticketId = await _helpService.createSupportTicket(
              subject: subject,
              category: category,
              priority: priority,
              description: description,
              attachments: attachments,
            );
            setState(() {});
            return ticketId;
          },
        );
      },
    );
  }

  void _openFeedbackModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return SendFeedbackModal(
          onSubmitFeedback: (type, msg) async {
            await _helpService.submitFeedback(type, msg);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final articles = _helpService.getHelpArticles(
      searchQuery: _searchQuery,
      category: _selectedCategory,
    );
    final tickets = _helpService.getDoctorTickets();
    final adminContact = _helpService.getHospitalAdminContact();
    final systemServices = _helpService.getSystemStatus();
    final troubleshootingGuides = _helpService.getTroubleshootingGuides();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark
              ? HealthifyGlassTheme.darkBackground
              : HealthifyGlassTheme.lightBackground,
        ),
        child: Row(
          children: [
            // Sidebar Navigation
            DoctorSidebar(
              selectedNavIndex: _selectedNavIndex,
              onNavItemSelected: _onNavItemSelected,
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
              availabilityStatus: _availabilityStatus,
              onLogout: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              onRoleSwitcherTap: () {},
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Navigation Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Help & Support Workspace',
                    subtitle: 'Guides, Tickets & Admin Contact',
                    availabilityStatus: _availabilityStatus,
                    onAvailabilityChanged: (status) {
                      setState(() {
                        _availabilityStatus = status;
                      });
                    },
                    onNotificationTap: () {
                      Navigator.of(context).pushNamed('/doctor-notifications');
                    },
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {
                      themeNotifier.value = themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                    unreadNotificationsCount: _notificationService.getUnreadCount(),
                  ),

                  // Workspace Body
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 1000;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Page Header & Primary Search
                              HelpHeader(
                                searchQuery: _searchQuery,
                                onSearchChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // 2. Quick Help Actions Grid
                              QuickHelpActions(
                                onSearchCenterTap: () {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                },
                                onContactSupportTap: _openContactSupportModal,
                                onReportProblemTap: _openContactSupportModal,
                                onContactAdminTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Contacting Hospital Admin ${adminContact.adminName}...'),
                                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // 3. Browse Help Topics Filter Bar
                              CommonTopicsGrid(
                                selectedCategory: _selectedCategory,
                                onCategorySelected: (cat) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // 4. Main Section: FAQ Accordions + Opened Article/Ticket Drawer
                              if (isDesktop && (_selectedArticle != null || _selectedTicket != null)) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: FaqAccordionSection(
                                        articles: articles,
                                        onSelectArticle: (article) {
                                          setState(() {
                                            _selectedTicket = null;
                                            _selectedArticle = article;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: _selectedArticle != null
                                          ? HelpArticleDetailDrawer(
                                              article: _selectedArticle!,
                                              onClose: () {
                                                setState(() {
                                                  _selectedArticle = null;
                                                });
                                              },
                                              onRateHelpful: (helpful) {},
                                            )
                                          : TicketDetailDrawer(
                                              ticket: _selectedTicket!,
                                              onClose: () {
                                                setState(() {
                                                  _selectedTicket = null;
                                                });
                                              },
                                              onSendReply: (msg) async {
                                                await _helpService.replyToTicket(
                                                  _selectedTicket!.id,
                                                  msg,
                                                );
                                                setState(() {
                                                  _selectedTicket = _helpService
                                                      .getDoctorTickets()
                                                      .firstWhere((t) => t.id == _selectedTicket!.id);
                                                });
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                FaqAccordionSection(
                                  articles: articles,
                                  onSelectArticle: (article) {
                                    setState(() {
                                      _selectedTicket = null;
                                      _selectedArticle = article;
                                    });
                                    if (!isDesktop) {
                                      _openMobileArticleSheet(context, article);
                                    }
                                  },
                                ),
                              ],

                              const SizedBox(height: 16),

                              // 5. My Support Requests & Tickets Section
                              MySupportTicketsSection(
                                tickets: tickets,
                                onSelectTicket: (ticket) {
                                  setState(() {
                                    _selectedArticle = null;
                                    _selectedTicket = ticket;
                                  });
                                  if (!isDesktop) {
                                    _openMobileTicketSheet(context, ticket);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // 6. Hospital Administrator Contact Card
                              HospitalAdminContactCard(contact: adminContact),
                              const SizedBox(height: 16),

                              // 7. System Health Status Grid
                              SystemStatusWidget(services: systemServices),
                              const SizedBox(height: 16),

                              // 8. Troubleshooting Cards
                              TroubleshootingSection(
                                guides: troubleshootingGuides,
                                onContactSupportTap: _openContactSupportModal,
                              ),
                              const SizedBox(height: 16),

                              // 9. Quick Links & Send Feedback Banner
                              _buildFeedbackAndLinksCard(isDark),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackAndLinksCard(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const GlassIconContainer(
            icon: Icons.feedback_outlined,
            size: 40,
            iconSize: 20,
            color: HealthifyGlassTheme.primaryTeal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have Feedback or Feature Suggestions?',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  'Help us improve clinical workflows by sharing your feedback with our product team.',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GlassPrimaryButton(
            height: 38,
            onPressed: _openFeedbackModal,
            child: const Row(
              children: [
                Icon(Icons.rate_review_rounded, size: 15, color: Colors.white),
                SizedBox(width: 5),
                Text('Send Feedback', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openMobileArticleSheet(BuildContext context, HelpArticleModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: HelpArticleDetailDrawer(
                  article: article,
                  onClose: () => Navigator.pop(context),
                  onRateHelpful: (h) {},
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMobileTicketSheet(BuildContext context, SupportTicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TicketDetailDrawer(
                  ticket: ticket,
                  onClose: () => Navigator.pop(context),
                  onSendReply: (msg) async {
                    final nav = Navigator.of(context);
                    await _helpService.replyToTicket(ticket.id, msg);
                    if (mounted) setState(() {});
                    nav.pop();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
