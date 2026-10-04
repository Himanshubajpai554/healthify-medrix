import 'dart:async';
import 'dart:ui';

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
  final bool embedInDashboard;

  const DoctorNotificationsScreen({super.key, this.embedInDashboard = false});

  @override
  State<DoctorNotificationsScreen> createState() =>
      _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  // ==========================================================================
  // SERVICES
  // ==========================================================================

  final DoctorNotificationService _notificationService =
      DoctorNotificationService();

  // ==========================================================================
  // NAVIGATION / UI STATE
  // ==========================================================================

  int _selectedNavIndex = 9;
  bool _isSidebarExpanded = true;

  DoctorAvailability _availabilityStatus = DoctorAvailability.available;

  NotificationCategory _selectedCategory = NotificationCategory.all;

  String _searchQuery = '';

  DoctorNotificationFullModel? _selectedNotification;

  StreamSubscription<List<DoctorNotificationFullModel>>? _streamSubscription;

  // ==========================================================================
  // HEALTHIFY DESIGN SYSTEM
  // ==========================================================================

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  static const Color _backgroundLight = Color(0xFFF3FAF9);
  static const Color _backgroundDark = Color(0xFF061817);

  Color _background(bool isDark) {
    return isDark ? _backgroundDark : _backgroundLight;
  }

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _primaryColor(bool isDark) {
    return isDark ? _primaryDark : _primary;
  }

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _streamSubscription = _notificationService.notificationsStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

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
        // Already on Notifications.
        break;

      case 10:
        Navigator.of(context).pushReplacementNamed('/doctor-settings');
        break;

      default:
        break;
    }
  }

  // ==========================================================================
  // NOTIFICATION ACTIONS
  // ==========================================================================

  void _handlePerformAction(DoctorNotificationFullModel notification) {
    _notificationService.markNotificationRead(notification.id);
    final messenger = ScaffoldMessenger.of(context);

    if (notification.targetRoute != null &&
        notification.targetRoute!.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Navigating to '
            '${notification.actionLabel ?? 'Workflow Target'}...',
          ),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      if (mounted) {
        Navigator.of(context).pushNamed(notification.targetRoute!);
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(notification.fullDescription),
          backgroundColor: _primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ==========================================================================
  // PREFERENCES
  // ==========================================================================

  void _openPreferencesModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NotificationPreferencesModal(
          preferences: _notificationService.getPreferences(),
          onSavePreferences: (updatedPrefs) {
            for (final pref in updatedPrefs) {
              _notificationService.updatePreference(pref);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification preferences saved successfully.'),
                  backgroundColor: _primary,
                ),
              );
            }
          },
        );
      },
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final notifications = _notificationService.getNotifications(
      category: _selectedCategory,
      searchQuery: _searchQuery,
    );

    final unreadCount = _notificationService.getUnreadCount();

    // ------------------------------------------------------------------------
    // EMBEDDED DASHBOARD MODE
    // ------------------------------------------------------------------------

    if (widget.embedInDashboard) {
      return _buildEmbeddedView(
        context: context,
        isDark: isDark,
        notifications: notifications,
        unreadCount: unreadCount,
      );
    }

    // ------------------------------------------------------------------------
    // FULL SCREEN MODE
    // ------------------------------------------------------------------------

    return Scaffold(
      backgroundColor: _background(isDark),
      body: Stack(
        children: [
          // Ambient background.
          Positioned.fill(child: _buildAmbientBackground(isDark)),

          Row(
            children: [
              // ================================================================
              // SIDEBAR
              // ================================================================
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

              // ================================================================
              // MAIN AREA
              // ================================================================
              Expanded(
                child: Column(
                  children: [
                    // ----------------------------------------------------------
                    // HEADER
                    // ----------------------------------------------------------
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
                        themeNotifier.value =
                            themeNotifier.value == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      },
                      unreadNotificationsCount: unreadCount,
                    ),

                    // ----------------------------------------------------------
                    // WORKSPACE
                    // ----------------------------------------------------------
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildWorkspace(
                            context: context,
                            constraints: constraints,
                            isDark: isDark,
                            notifications: notifications,
                            unreadCount: unreadCount,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EMBEDDED VIEW
  // ==========================================================================

  Widget _buildEmbeddedView({
    required BuildContext context,
    required bool isDark,
    required List<DoctorNotificationFullModel> notifications,
    required int unreadCount,
  }) {
    return Container(
      color: _background(isDark),
      child: Stack(
        children: [
          Positioned.fill(child: _buildAmbientBackground(isDark)),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildNotificationWorkspaceContent(
              context: context,
              isDark: isDark,
              notifications: notifications,
              unreadCount: unreadCount,
              embedded: true,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MAIN WORKSPACE
  // ==========================================================================

  Widget _buildWorkspace({
    required BuildContext context,
    required BoxConstraints constraints,
    required bool isDark,
    required List<DoctorNotificationFullModel> notifications,
    required int unreadCount,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        constraints.maxWidth >= 1200 ? 28 : 20,
        20,
        constraints.maxWidth >= 1200 ? 28 : 20,
        32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: _buildNotificationWorkspaceContent(
            context: context,
            isDark: isDark,
            notifications: notifications,
            unreadCount: unreadCount,
            embedded: false,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WORKSPACE CONTENT
  // ==========================================================================

  Widget _buildNotificationWorkspaceContent({
    required BuildContext context,
    required bool isDark,
    required List<DoctorNotificationFullModel> notifications,
    required int unreadCount,
    required bool embedded,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isTablet =
            constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================================
            // PAGE INTRO
            // ================================================================
            _buildPageIntro(
              context: context,
              isDark: isDark,
              unreadCount: unreadCount,
              isDesktop: isDesktop,
            ),

            const SizedBox(height: 18),

            // ================================================================
            // SUMMARY
            // ================================================================
            _buildGlassSection(
              isDark: isDark,
              padding: EdgeInsets.zero,
              child: NotificationsSummaryCards(
                unreadCount: unreadCount,
                todayCount: _notificationService.getCategoryCount(
                  NotificationCategory.all,
                ),
                emergencyCount: _notificationService.getCategoryCount(
                  NotificationCategory.emergency,
                ),
                appointmentsCount: _notificationService.getCategoryCount(
                  NotificationCategory.appointments,
                ),
                selectedCategory: _selectedCategory,
                onSelectCategory: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================================================================
            // FILTERS
            // ================================================================
            _buildGlassSection(
              isDark: isDark,
              child: NotificationsFilterToolbar(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
                getCategoryCount: (cat) =>
                    _notificationService.getCategoryCount(cat),
              ),
            ),

            const SizedBox(height: 16),

            // ================================================================
            // MAIN NOTIFICATION WORKSPACE
            // ================================================================
            if (isDesktop && _selectedNotification != null)
              _buildDesktopNotificationSplit(
                context: context,
                isDark: isDark,
                notifications: notifications,
              )
            else
              _buildNotificationListArea(
                context: context,
                isDark: isDark,
                notifications: notifications,
                isTablet: isTablet,
              ),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // PAGE INTRO
  // ==========================================================================

  Widget _buildPageIntro({
    required BuildContext context,
    required bool isDark,
    required int unreadCount,
    required bool isDesktop,
  }) {
    return _buildGlassSection(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: NotificationsHeader(
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
    );
  }

  // ==========================================================================
  // DESKTOP SPLIT VIEW
  // ==========================================================================

  Widget _buildDesktopNotificationSplit({
    required BuildContext context,
    required bool isDark,
    required List<DoctorNotificationFullModel> notifications,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==============================================================
        // LIST
        // ==============================================================
        Expanded(
          flex: 3,
          child: _buildGlassSection(
            isDark: isDark,
            padding: const EdgeInsets.all(8),
            child: GroupedNotificationsList(
              notifications: notifications,
              selectedNotificationId: _selectedNotification?.id,
              onSelectNotification: (item) {
                setState(() {
                  _selectedNotification = item;
                });

                _notificationService.markNotificationRead(item.id);
              },
              onMarkRead: (id) {
                _notificationService.markNotificationRead(id);

                setState(() {});
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
        ),

        const SizedBox(width: 16),

        // ==============================================================
        // DETAIL
        // ==============================================================
        Expanded(
          flex: 2,
          child: _buildGlassSection(
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: NotificationDetailDrawer(
              notification: _selectedNotification!,
              onClose: () {
                setState(() {
                  _selectedNotification = null;
                });
              },
              onMarkReadToggle: () {
                setState(() {
                  _notificationService.markNotificationRead(
                    _selectedNotification!.id,
                  );
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
        ),
      ],
    );
  }

  // ==========================================================================
  // LIST AREA
  // ==========================================================================

  Widget _buildNotificationListArea({
    required BuildContext context,
    required bool isDark,
    required List<DoctorNotificationFullModel> notifications,
    required bool isTablet,
  }) {
    return _buildGlassSection(
      isDark: isDark,
      padding: const EdgeInsets.all(8),
      child: GroupedNotificationsList(
        notifications: notifications,
        selectedNotificationId: _selectedNotification?.id,
        onSelectNotification: (item) {
          setState(() {
            _selectedNotification = item;
          });

          if (isTablet) {
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
    );
  }

  // ==========================================================================
  // GLASS SECTION
  // ==========================================================================

  Widget _buildGlassSection({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(isDark), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(22),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // AMBIENT BACKGROUND
  // ==========================================================================

  Widget _buildAmbientBackground(bool isDark) {
    final primary = _primaryColor(isDark);

    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: _background(isDark)),

          Positioned(
            top: -140,
            right: -100,
            child: _buildGlow(
              color: primary,
              size: 360,
              opacity: isDark ? 0.09 : 0.075,
            ),
          ),

          Positioned(
            top: 380,
            left: -180,
            child: _buildGlow(
              color: const Color(0xFF6366F1),
              size: 360,
              opacity: isDark ? 0.045 : 0.035,
            ),
          ),

          Positioned(
            bottom: -160,
            right: 160,
            child: _buildGlow(
              color: primary,
              size: 320,
              opacity: isDark ? 0.055 : 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow({
    required Color color,
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size * 0.55,
            spreadRadius: size * 0.10,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MOBILE DETAIL SHEET
  // ==========================================================================

  void _openMobileDetailBottomSheet(
    BuildContext context,
    DoctorNotificationFullModel item,
  ) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.60 : 0.35),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.84,
          maxChildSize: 0.96,
          minChildSize: 0.52,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0B2422).withValues(alpha: 0.97)
                    : const Color(0xFFF8FCFB).withValues(alpha: 0.97),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(color: _border(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    children: [
                      // ------------------------------------------------------
                      // HANDLE
                      // ------------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: NotificationDetailDrawer(
                            notification: item,
                            onClose: () => Navigator.of(context).pop(),
                            onMarkReadToggle: () {
                              setState(() {
                                _notificationService.markNotificationRead(
                                  item.id,
                                );
                              });

                              Navigator.of(context).pop();
                            },
                            onDismiss: () {
                              setState(() {
                                _notificationService.dismissNotification(
                                  item.id,
                                );
                              });

                              Navigator.of(context).pop();
                            },
                            onPerformAction: () {
                              Navigator.of(context).pop();

                              _handlePerformAction(item);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
