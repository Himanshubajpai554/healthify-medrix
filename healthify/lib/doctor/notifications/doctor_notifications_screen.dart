import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/notification_models.dart';
import '../services/doctor_notification_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/grouped_notifications_list.dart';
import 'widgets/notification_detail_drawer.dart';
import 'widgets/notification_preferences_modal.dart';
import 'widgets/notifications_filter_toolbar.dart';
import 'widgets/notifications_header.dart';
import 'widgets/notifications_summary_cards.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  final DoctorNotificationService _notificationService =
      DoctorNotificationService();

  int _selectedNavIndex = 9; // Notifications index
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;

  NotificationCategory _selectedCategory = NotificationCategory.all;
  String _searchQuery = '';
  DoctorNotificationFullModel? _selectedNotification;

  StreamSubscription<List<DoctorNotificationFullModel>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _notificationService.notificationsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
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
        // Already on Notifications
        break;
      case 10:
        Navigator.of(context).pushReplacementNamed('/doctor-settings');
        break;
      default:
        break;
    }
  }

  void _handlePerformAction(DoctorNotificationFullModel notification) {
    // Automatically mark as read when action is taken
    _notificationService.markNotificationRead(notification.id);

    if (notification.targetRoute != null && notification.targetRoute!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Navigating to ${notification.actionLabel ?? 'Workflow Target'}...',
          ),
          backgroundColor: HealthifyGlassTheme.primaryTeal,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushNamed(notification.targetRoute!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notification.fullDescription),
          backgroundColor: HealthifyGlassTheme.primaryTeal,
        ),
      );
    }
  }

  void _openPreferencesModal() {
    showDialog(
      context: context,
      builder: (context) {
        return NotificationPreferencesModal(
          preferences: _notificationService.getPreferences(),
          onSavePreferences: (updatedPrefs) {
            for (final pref in updatedPrefs) {
              _notificationService.updatePreference(pref);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification preferences saved successfully.'),
                backgroundColor: HealthifyGlassTheme.primaryTeal,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final notifications = _notificationService.getNotifications(
      category: _selectedCategory,
      searchQuery: _searchQuery,
    );
    final unreadCount = _notificationService.getUnreadCount();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark
              ? HealthifyGlassTheme.darkBackground
              : HealthifyGlassTheme.lightBackground,
        ),
        child: Row(
          children: [
            // Sidebar
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
                  // Doctor Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Notification Center',
                    subtitle: 'Actionable Alerts & Clinical Updates',
                    availabilityStatus: _availabilityStatus,
                    onAvailabilityChanged: (status) {
                      setState(() {
                        _availabilityStatus = status;
                      });
                    },
                    onNotificationTap: () {},
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {
                      themeNotifier.value = themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                    unreadNotificationsCount: unreadCount,
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
                              // 1. Page Header
                              NotificationsHeader(
                                unreadCount: unreadCount,
                                onMarkAllRead: () {
                                  setState(() {
                                    _notificationService.markAllNotificationsRead();
                                  });
                                },
                                onOpenPreferences: _openPreferencesModal,
                                searchQuery: _searchQuery,
                                onSearchChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // 2. Metric Summary Cards
                              NotificationsSummaryCards(
                                unreadCount: unreadCount,
                                todayCount: _notificationService.getCategoryCount(NotificationCategory.all),
                                emergencyCount: _notificationService.getCategoryCount(NotificationCategory.emergency),
                                appointmentsCount: _notificationService.getCategoryCount(NotificationCategory.appointments),
                                selectedCategory: _selectedCategory,
                                onSelectCategory: (cat) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // 3. Category Filter Toolbar
                              NotificationsFilterToolbar(
                                selectedCategory: _selectedCategory,
                                onCategorySelected: (cat) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                                getCategoryCount: (cat) => _notificationService.getCategoryCount(cat),
                              ),
                              const SizedBox(height: 16),

                              // 4. Main Content: List + Contextual Detail Drawer
                              if (isDesktop && _selectedNotification != null) ...[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: GroupedNotificationsList(
                                        notifications: notifications,
                                        selectedNotificationId: _selectedNotification?.id,
                                        onSelectNotification: (item) {
                                          setState(() {
                                            _selectedNotification = item;
                                          });
                                        },
                                        onMarkRead: (id) {
                                          setState(() {
                                            _notificationService.markNotificationRead(id);
                                          });
                                        },
                                        onDismiss: (id) {
                                          setState(() {
                                            if (_selectedNotification?.id == id) {
                                              _selectedNotification = null;
                                            }
                                            _notificationService.dismissNotification(id);
                                          });
                                        },
                                        onPerformAction: _handlePerformAction,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: NotificationDetailDrawer(
                                        notification: _selectedNotification!,
                                        onClose: () {
                                          setState(() {
                                            _selectedNotification = null;
                                          });
                                        },
                                        onMarkReadToggle: () {
                                          setState(() {
                                            _notificationService.markNotificationRead(_selectedNotification!.id);
                                          });
                                        },
                                        onDismiss: () {
                                          setState(() {
                                            final id = _selectedNotification!.id;
                                            _selectedNotification = null;
                                            _notificationService.dismissNotification(id);
                                          });
                                        },
                                        onPerformAction: () {
                                          _handlePerformAction(_selectedNotification!);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                GroupedNotificationsList(
                                  notifications: notifications,
                                  selectedNotificationId: _selectedNotification?.id,
                                  onSelectNotification: (item) {
                                    setState(() {
                                      _selectedNotification = item;
                                    });
                                    if (!isDesktop) {
                                      _openMobileDetailBottomSheet(context, item);
                                    }
                                  },
                                  onMarkRead: (id) {
                                    setState(() {
                                      _notificationService.markNotificationRead(id);
                                    });
                                  },
                                  onDismiss: (id) {
                                    setState(() {
                                      if (_selectedNotification?.id == id) {
                                        _selectedNotification = null;
                                      }
                                      _notificationService.dismissNotification(id);
                                    });
                                  },
                                  onPerformAction: _handlePerformAction,
                                ),
                              ],
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

  void _openMobileDetailBottomSheet(
    BuildContext context,
    DoctorNotificationFullModel item,
  ) {
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
                child: NotificationDetailDrawer(
                  notification: item,
                  onClose: () => Navigator.of(context).pop(),
                  onMarkReadToggle: () {
                    setState(() {
                      _notificationService.markNotificationRead(item.id);
                    });
                    Navigator.of(context).pop();
                  },
                  onDismiss: () {
                    setState(() {
                      _notificationService.dismissNotification(item.id);
                    });
                    Navigator.of(context).pop();
                  },
                  onPerformAction: () {
                    Navigator.of(context).pop();
                    _handlePerformAction(item);
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
