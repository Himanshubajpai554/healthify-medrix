import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/data/mock/mock_notification_repository.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/notification_model.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/healthify_empty_state.dart';
import '../../core/widgets/healthify_error_state.dart';
import '../../core/widgets/healthify_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class NotificationCenterScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const NotificationCenterScreen({super.key, this.onNavigateToTab});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final NotificationService _notificationService;

  bool _isLoading = true;
  String? _errorMessage;

  List<NotificationRecord> _notifications = [];
  List<OperationalAlert> _alerts = [];
  List<NotificationDispatch> _dispatches = [];
  List<NotificationRoutingRule> _routingRules = [];
  List<NotificationPreference> _preferences = [];

  String _filterCategory = 'All';
  String _searchQuery = '';
  NotificationRecord? _selectedNotification;
  DispatchChannel? _selectedDispatchChannel;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  Color _surfaceStrong(bool isDark) => isDark
      ? _primary.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);

  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.white.withValues(alpha: 0.88);

  Color _textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF17202A);

  Color _textSecondary(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF64748B);

  BoxDecoration _glassDecoration(
    bool isDark, {
    double radius = 20,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? _surface(isDark),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _border(isDark)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.075 : 0.025),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationService = NotificationService(
      notificationRepository: RepositoryContainer.instance.notificationRepository,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifs = await _notificationService.getNotifications(
        query: NotificationQuery(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      );
      final alerts = await _notificationService.getAlerts();
      final dispatches = await _notificationService.getDispatches();
      final routing = await _notificationService.getRoutingRules();
      final prefs = await _notificationService.getPreferences('DOC-1015');

      if (!mounted) return;

      setState(() {
        _notifications = notifs;
        _alerts = alerts;
        _dispatches = dispatches;
        _routingRules = routing;
        _preferences = prefs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load notifications: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<NotificationRecord> get _filteredNotifications {
    var list = _notifications;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where(
            (n) =>
                n.title.toLowerCase().contains(q) ||
                n.message.toLowerCase().contains(q) ||
                n.id.toLowerCase().contains(q) ||
                (n.sourceEntityId != null &&
                    n.sourceEntityId!.toLowerCase().contains(q)),
          )
          .toList();
    }

    switch (_filterCategory) {
      case 'Unread':
        return list.where((n) => n.isUnread).toList();
      case 'Critical':
        return list
            .where((n) => n.priority == NotificationPriority.critical)
            .toList();
      case 'Acknowledged':
        return list.where((n) => n.isAcknowledged).toList();
      case 'History':
        return list
            .where(
              (n) =>
                  n.isRead ||
                  n.status == NotificationStatus.dismissed ||
                  n.isExpired,
            )
            .toList();
      default:
        return list;
    }
  }

  Future<void> _handleMarkAsRead(String id) async {
    await _notificationService.markAsRead(id);
    await _loadData();
  }

  Future<void> _handleMarkAsUnread(String id) async {
    await _notificationService.markAsUnread(id);
    await _loadData();
  }

  Future<void> _handleAcknowledgeNotification(String id) async {
    await _notificationService.acknowledgeNotification(id);
    await _loadData();
  }

  Future<void> _handleDismissNotification(String id) async {
    try {
      await _notificationService.dismissNotification(id);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleAcknowledgeAlert(String id) async {
    await _notificationService.acknowledgeAlert(id);
    await _loadData();
  }

  Future<void> _handleResolveAlert(String id) async {
    await _notificationService.resolveAlert(id);
    await _loadData();
  }

  Future<void> _handleRetryDispatch(String id) async {
    await _notificationService.retryDispatch(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dispatch retry successful! Delivery confirmed.'),
      ),
    );
    await _loadData();
  }

  void _navigateToRelatedEntity(String? type, String? id) {
    if (widget.onNavigateToTab == null || type == null) return;

    switch (type) {
      case 'EmergencyCase':
        widget.onNavigateToTab!(9);
        break;
      case 'Bed':
        widget.onNavigateToTab!(7);
        break;
      case 'BloodUnit':
        widget.onNavigateToTab!(8);
        break;
      case 'DiagnosticReport':
        widget.onNavigateToTab!(10);
        break;
      case 'AIPrediction':
        widget.onNavigateToTab!(13);
        break;
      case 'Staff':
        widget.onNavigateToTab!(4);
        break;
      default:
        widget.onNavigateToTab!(0);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = Responsive.isDesktop(context) || size.width >= 1100;
    final isTablet = size.width >= 700 && size.width < 1100;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedPulseBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopHeader(
                    isDark: isDark,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    isMobile: isMobile,
                  ),
                  _buildTabBar(isDark: isDark, isMobile: isMobile),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const HealthifyLoadingState(
                            message:
                                'Loading notification & dispatch pipeline...',
                          )
                        : _errorMessage != null
                        ? HealthifyErrorState(
                            errorMessage: _errorMessage!,
                            onRetry: _loadData,
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildInboxTab(
                                isDark,
                                isDesktop,
                                isTablet,
                                isMobile,
                              ),
                              _buildAlertCenterTab(
                                isDark,
                                isDesktop,
                                isTablet,
                                isMobile,
                              ),
                              _buildDispatchCenterTab(
                                isDark,
                                isDesktop,
                                isTablet,
                                isMobile,
                              ),
                              _buildPreferencesTab(
                                isDark,
                                isDesktop,
                                isTablet,
                                isMobile,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedNotification != null && !isMobile)
            _buildDetailDrawer(isDark),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP HEADER
  // ---------------------------------------------------------------------------

  Widget _buildTopHeader({
    required bool isDark,
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    final criticalCount = _notifications
        .where((n) => n.priority == NotificationPriority.critical && n.isUnread)
        .length;
    final activeAlerts = _alerts.where((a) => a.isActive).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        isMobile ? 10 : 14,
        isMobile ? 12 : 16,
        8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 13 : 17),
            decoration: _glassDecoration(
              isDark,
              radius: 24,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.045)
                  : Colors.white.withValues(alpha: 0.76),
            ),
            child: isMobile
                ? _buildMobileHeaderContent(
                    isDark,
                    unreadCount,
                    criticalCount,
                    activeAlerts,
                  )
                : _buildWideHeaderContent(
                    isDark,
                    unreadCount,
                    criticalCount,
                    activeAlerts,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideHeaderContent(
    bool isDark,
    int unreadCount,
    int criticalCount,
    int activeAlerts,
  ) {
    return Row(
      children: [
        _buildHeaderIcon(isDark),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Notification & Dispatch Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: _textPrimary(isDark),
                    ),
                  ),
                  _buildSoftBadge('PHASE 11', _primary, isDark),
                  _buildLiveDotBadge('LIVE PIPELINE', isDark),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hospital communications, critical alert routing and delivery operations in one workspace.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _textSecondary(isDark),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        _buildHeaderMetric(
          icon: Icons.notifications_none_rounded,
          value: unreadCount.toString(),
          label: 'Unread',
          color: _primary,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        if (criticalCount > 0)
          _buildHeaderMetric(
            icon: Icons.warning_amber_rounded,
            value: criticalCount.toString(),
            label: 'Critical',
            color: Colors.redAccent,
            isDark: isDark,
          ),
        if (criticalCount > 0) const SizedBox(width: 8),
        _buildHeaderMetric(
          icon: Icons.shield_outlined,
          value: activeAlerts.toString(),
          label: 'Alerts',
          color: Colors.orange,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMobileHeaderContent(
    bool isDark,
    int unreadCount,
    int criticalCount,
    int activeAlerts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildHeaderIcon(isDark, size: 42),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Center',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Operational messaging & dispatch',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            _buildLiveDotBadge('LIVE', isDark),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCompactHeaderStat(
                value: unreadCount.toString(),
                label: 'Unread',
                color: _primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _buildCompactHeaderStat(
                value: criticalCount.toString(),
                label: 'Critical',
                color: Colors.redAccent,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _buildCompactHeaderStat(
                value: activeAlerts.toString(),
                label: 'Alerts',
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(bool isDark, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary.withValues(alpha: 0.92), _primaryDark],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: isDark ? 0.18 : 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.notifications_active_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }

  Widget _buildHeaderMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.055),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary(isDark),
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 9.5, color: _textSecondary(isDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeaderStat({
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.075 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 9.5, color: _textSecondary(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.11 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isDark ? Colors.white.withValues(alpha: 0.78) : color,
        ),
      ),
    );
  }

  Widget _buildLiveDotBadge(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: isDark ? 0.10 : 0.065),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB BAR
  // ---------------------------------------------------------------------------

  Widget _buildTabBar({required bool isDark, required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: _glassDecoration(
          isDark,
          radius: 17,
          color: isDark
              ? Colors.white.withValues(alpha: 0.035)
              : Colors.white.withValues(alpha: 0.62),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: _primary.withValues(alpha: 0.06),
            highlightColor: _primary.withValues(alpha: 0.04),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: isMobile,
            tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: _textSecondary(isDark),
            labelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 10),
            tabs: const [
              Tab(icon: Icon(Icons.inbox_rounded, size: 18), text: 'Inbox'),
              Tab(
                icon: Icon(Icons.warning_amber_rounded, size: 18),
                text: 'Alert Center',
              ),
              Tab(icon: Icon(Icons.send_rounded, size: 18), text: 'Dispatch'),
              Tab(
                icon: Icon(Icons.settings_suggest_rounded, size: 18),
                text: 'Routing & Prefs',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INBOX
  // ---------------------------------------------------------------------------

  Widget _buildInboxTab(
    bool isDark,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final items = _filteredNotifications;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            6,
            isMobile ? 12 : 16,
            22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInboxToolbar(isDark, isMobile),
              const SizedBox(height: 12),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 260,
                      child: _buildInboxSummaryRail(isDark, items),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildNotificationList(
                        isDark,
                        items,
                        isDesktop: true,
                      ),
                    ),
                  ],
                )
              else ...[
                _buildInboxSummaryRail(isDark, items, compact: true),
                const SizedBox(height: 12),
                _buildNotificationList(isDark, items, isDesktop: false),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInboxToolbar(bool isDark, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: _glassDecoration(isDark, radius: 20),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: _textPrimary(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: _primary,
                decoration: InputDecoration(
                  hintText: 'Search notifications, IDs, messages or sources...',
                  hintStyle: TextStyle(
                    color: _textSecondary(isDark),
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: _primary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: _textSecondary(isDark),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: _surfaceStrong(isDark),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _border(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _border(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _primary.withValues(alpha: isDark ? 0.55 : 0.40),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children:
                      [
                        'All',
                        'Unread',
                        'Critical',
                        'Acknowledged',
                        'History',
                      ].map((category) {
                        final selected = _filterCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            label: category,
                            selected: selected,
                            isDark: isDark,
                            color: category == 'Critical'
                                ? Colors.redAccent
                                : _primary,
                            onTap: () =>
                                setState(() => _filterCategory = category),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required bool isDark,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? color : _border(isDark)),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : _textPrimary(isDark),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 5),
                const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInboxSummaryRail(
    bool isDark,
    List<NotificationRecord> items, {
    bool compact = false,
  }) {
    final unread = _notifications.where((n) => n.isUnread).length;
    final critical = _notifications
        .where((n) => n.priority == NotificationPriority.critical)
        .length;
    final acknowledged = _notifications.where((n) => n.isAcknowledged).length;
    final historical = _notifications
        .where(
          (n) =>
              n.isRead ||
              n.status == NotificationStatus.dismissed ||
              n.isExpired,
        )
        .length;

    final children = [
      _buildSummaryStat(
        'Unread',
        unread,
        Icons.mark_email_unread_rounded,
        _primary,
        isDark,
      ),
      _buildSummaryStat(
        'Critical',
        critical,
        Icons.priority_high_rounded,
        Colors.redAccent,
        isDark,
      ),
      _buildSummaryStat(
        'Acknowledged',
        acknowledged,
        Icons.task_alt_rounded,
        Colors.green,
        isDark,
      ),
      _buildSummaryStat(
        'History',
        historical,
        Icons.history_rounded,
        Colors.blue,
        isDark,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: _glassDecoration(isDark, radius: 20),
      child: compact
          ? Row(
              children: List.generate(
                children.length,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == children.length - 1 ? 0 : 7,
                    ),
                    child: children[index],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Inbox Overview',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...children.map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: child,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: isDark ? 0.065 : 0.045),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _primary.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: _primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unread and critical messages stay visible until they are explicitly handled.',
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.35,
                            color: _textSecondary(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryStat(
    String label,
    int value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.10 : 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary(isDark),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: _textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    bool isDark,
    List<NotificationRecord> items, {
    required bool isDesktop,
  }) {
    if (items.isEmpty) {
      return const HealthifyEmptyState(
        title: 'No Notifications Found',
        description:
            'No notification records match the current filter or search criteria.',
        icon: Icons.notifications_off_rounded,
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: _glassDecoration(isDark, radius: 15),
          child: Row(
            children: [
              Icon(Icons.view_list_rounded, size: 17, color: _primary),
              const SizedBox(width: 7),
              Text(
                '${items.length} notification${items.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              Text(
                'Newest first',
                style: TextStyle(fontSize: 10, color: _textSecondary(isDark)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        ...items.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildNotificationCard(isDark, entry.value, entry.key),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    bool isDark,
    NotificationRecord item,
    int index,
  ) {
    final unread = item.isUnread;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1),
      duration: Duration(milliseconds: 240 + (index * 25)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openNotificationDetail(item),
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: unread
                      ? _primary.withValues(alpha: isDark ? 0.06 : 0.045)
                      : _surface(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: unread
                        ? _primary.withValues(alpha: isDark ? 0.18 : 0.13)
                        : _border(isDark),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: unread
                          ? _primary.withValues(alpha: isDark ? 0.07 : 0.035)
                          : Colors.black.withValues(
                              alpha: isDark ? 0.055 : 0.018,
                            ),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeIcon(item.type, item.priority, isDark),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (unread)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    right: 6,
                                  ),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: unread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: _textPrimary(isDark),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityBadge(item.priority, isDark),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: _textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 7,
                            runSpacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (item.sourceEntityType != null)
                                _buildMetaPill(
                                  Icons.link_rounded,
                                  '${item.sourceEntityType}: ${item.sourceEntityId}',
                                  _primary,
                                  isDark,
                                ),
                              _buildMetaPill(
                                Icons.schedule_rounded,
                                _formatTime(item.createdAt),
                                Colors.blueGrey,
                                isDark,
                              ),
                              if (item.isAcknowledged)
                                _buildMetaPill(
                                  Icons.verified_rounded,
                                  'Acknowledged',
                                  Colors.green,
                                  isDark,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildNotificationMenu(item, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(
    NotificationType type,
    NotificationPriority priority,
    bool isDark,
  ) {
    final data = _notificationVisual(type, priority);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: isDark ? 0.12 : 0.075),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: data.color.withValues(alpha: 0.15)),
      ),
      child: Icon(data.icon, color: data.color, size: 21),
    );
  }

  _NotificationVisual _notificationVisual(
    NotificationType type,
    NotificationPriority priority,
  ) {
    switch (type) {
      case NotificationType.newEmergencyArrival:
        return const _NotificationVisual(
          Icons.emergency_rounded,
          Colors.redAccent,
        );
      case NotificationType.icuVitalCritical:
      case NotificationType.icuCapacityWarning:
        return const _NotificationVisual(Icons.favorite_rounded, Colors.red);
      case NotificationType.bloodStockCritical:
        return const _NotificationVisual(Icons.bloodtype_rounded, Colors.red);
      case NotificationType.reportUploaded:
      case NotificationType.reportReleased:
        return const _NotificationVisual(
          Icons.description_rounded,
          Colors.blue,
        );
      case NotificationType.bedSanitizationCleared:
        return const _NotificationVisual(Icons.king_bed_rounded, Colors.green);
      case NotificationType.staffShiftReminder:
        return const _NotificationVisual(Icons.schedule_rounded, Colors.amber);
      case NotificationType.aiForecastAlert:
        return const _NotificationVisual(
          Icons.psychology_rounded,
          Colors.purpleAccent,
        );
      default:
        return _NotificationVisual(
          Icons.notifications_rounded,
          _priorityColor(priority),
        );
    }
  }

  Widget _buildPriorityBadge(NotificationPriority priority, bool isDark) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.075),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.35,
          color: color,
        ),
      ),
    );
  }

  Color _priorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Colors.redAccent;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      default:
        return _primary;
    }
  }

  Widget _buildMetaPill(IconData icon, String label, Color color, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.07 : 0.045),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: _textSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMenu(NotificationRecord item, bool isDark) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border(isDark)),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz_rounded,
          size: 18,
          color: _textSecondary(isDark),
        ),
        onSelected: (value) {
          if (value == 'read') _handleMarkAsRead(item.id);
          if (value == 'unread') _handleMarkAsUnread(item.id);
          if (value == 'ack') _handleAcknowledgeNotification(item.id);
          if (value == 'dismiss') _handleDismissNotification(item.id);
          if (value == 'detail') _openNotificationDetail(item);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'detail', child: Text('View Details')),
          if (item.isUnread)
            const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
          if (item.isRead)
            const PopupMenuItem(value: 'unread', child: Text('Mark as Unread')),
          if (!item.isAcknowledged &&
              (item.priority == NotificationPriority.critical ||
                  item.priority == NotificationPriority.high))
            const PopupMenuItem(value: 'ack', child: Text('Acknowledge')),
          if (item.priority != NotificationPriority.critical ||
              item.isAcknowledged)
            const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
        ],
      ),
    );
  }

  void _openNotificationDetail(NotificationRecord item) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.38),
        builder: (sheetContext) {
          final isDark = HealthifyGlassTheme.isDark(context);
          return _buildMobileNotificationSheet(sheetContext, item, isDark);
        },
      );
      return;
    }

    setState(() => _selectedNotification = item);
  }

  // ---------------------------------------------------------------------------
  // ALERT CENTER
  // ---------------------------------------------------------------------------

  Widget _buildAlertCenterTab(
    bool isDark,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final active = _alerts.where((a) => a.isActive).length;
    final acknowledged = _alerts.where((a) => a.isAcknowledged).length;
    final resolved = _alerts
        .where((a) => !a.isActive && !a.isAcknowledged)
        .length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        6,
        isMobile ? 12 : 16,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertHero(isDark, isMobile),
          const SizedBox(height: 12),
          _buildStatRow(
            isDark: isDark,
            isMobile: isMobile,
            stats: [
              _StatData(
                'Active',
                active.toString(),
                Icons.warning_rounded,
                Colors.redAccent,
              ),
              _StatData(
                'Acknowledged',
                acknowledged.toString(),
                Icons.verified_rounded,
                Colors.orange,
              ),
              _StatData(
                'Resolved',
                resolved.toString(),
                Icons.task_alt_rounded,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_alerts.isEmpty)
            const HealthifyEmptyState(
              title: 'No Operational Alerts',
              description:
                  'There are currently no operational alert records to review.',
              icon: Icons.shield_outlined,
            )
          else if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 235,
              ),
              itemCount: _alerts.length,
              itemBuilder: (context, index) =>
                  _buildAlertCard(_alerts[index], isDark, index),
            )
          else
            ..._alerts.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAlertCard(entry.value, isDark, entry.key),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertHero(bool isDark, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: isDark ? 0.055 : 0.035),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: isDark ? 0.10 : 0.07),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operational Alert Center',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review high-urgency hospital conditions and acknowledge or resolve them when the operational state is actually addressed.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: _textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(OperationalAlert alert, bool isDark, int index) {
    final accent = alert.isActive
        ? Colors.redAccent
        : alert.isAcknowledged
        ? Colors.orange
        : Colors.green;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.97, end: 1),
      duration: Duration(milliseconds: 260 + (index * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: alert.isActive
                    ? accent.withValues(alpha: 0.22)
                    : _border(isDark),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(
                    alpha: alert.isActive
                        ? isDark
                              ? 0.07
                              : 0.035
                        : isDark
                        ? 0.04
                        : 0.015,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPriorityBadge(alert.severity, isDark),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        alert.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(isDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    _buildStatusPill(
                      alert.status.name.toUpperCase(),
                      accent,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alert.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: _textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Source: ${alert.sourceEntityType} (${alert.sourceEntityId})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    if (alert.isActive)
                      _buildActionButton(
                        label: 'Acknowledge',
                        icon: Icons.check_rounded,
                        color: Colors.orange,
                        onPressed: () => _handleAcknowledgeAlert(alert.id),
                      ),
                    if (alert.isAcknowledged)
                      _buildActionButton(
                        label: 'Mark Resolved',
                        icon: Icons.done_all_rounded,
                        color: Colors.green,
                        onPressed: () => _handleResolveAlert(alert.id),
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

  // ---------------------------------------------------------------------------
  // DISPATCH
  // ---------------------------------------------------------------------------

  Widget _buildDispatchCenterTab(
    bool isDark,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final filtered = _dispatches
        .where(
          (d) =>
              _selectedDispatchChannel == null ||
              d.channel == _selectedDispatchChannel,
        )
        .toList();

    final delivered = _dispatches
        .where((d) => d.status == DispatchStatus.delivered)
        .length;
    final failed = _dispatches
        .where((d) => d.status == DispatchStatus.failed)
        .length;
    final pending = _dispatches.length - delivered - failed;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        6,
        isMobile ? 12 : 16,
        22,
      ),
      child: Column(
        children: [
          _buildDispatchHeader(isDark, isMobile),
          const SizedBox(height: 12),
          _buildStatRow(
            isDark: isDark,
            isMobile: isMobile,
            stats: [
              _StatData(
                'Delivered',
                delivered.toString(),
                Icons.check_circle_outline_rounded,
                Colors.green,
              ),
              _StatData(
                'Failed',
                failed.toString(),
                Icons.error_outline_rounded,
                Colors.redAccent,
              ),
              _StatData(
                'Pending',
                pending.toString(),
                Icons.schedule_rounded,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const HealthifyEmptyState(
              title: 'No Dispatch Records',
              description:
                  'There are no dispatch records for the selected channel.',
              icon: Icons.send_rounded,
            )
          else
            ...filtered.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _buildDispatchCard(
                  entry.value,
                  isDark,
                  entry.key,
                  isMobile,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDispatchHeader(bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassDecoration(isDark, radius: 20),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Delivery Channel Dispatches',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDispatchDropdown(isDark, true),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: _primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Channel Dispatches',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_dispatches.length} total delivery attempts across configured channels.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: _textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDispatchDropdown(isDark, false),
              ],
            ),
    );
  }

  Widget _buildDispatchDropdown(bool isDark, bool fullWidth) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DispatchChannel?>(
          value: _selectedDispatchChannel,
          hint: const Text('All Channels'),
          isDense: true,
          borderRadius: BorderRadius.circular(14),
          dropdownColor: isDark ? const Color(0xFF13202A) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: _textSecondary(isDark),
          ),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _textPrimary(isDark),
          ),
          items: [
            const DropdownMenuItem<DispatchChannel?>(
              value: null,
              child: Text('All Channels'),
            ),
            ...DispatchChannel.values.map(
              (channel) => DropdownMenuItem<DispatchChannel?>(
                value: channel,
                child: Text(channel.name.toUpperCase()),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedDispatchChannel = value);
          },
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }

  Widget _buildDispatchCard(
    NotificationDispatch dispatch,
    bool isDark,
    int index,
    bool isMobile,
  ) {
    final statusColor = dispatch.status == DispatchStatus.delivered
        ? Colors.green
        : dispatch.status == DispatchStatus.failed
        ? Colors.redAccent
        : Colors.blue;

    final channelIcon = dispatch.channel == DispatchChannel.inApp
        ? Icons.phonelink_setup_rounded
        : dispatch.channel == DispatchChannel.push
        ? Icons.notifications_active_rounded
        : dispatch.channel == DispatchChannel.email
        ? Icons.email_rounded
        : Icons.sms_rounded;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.97, end: 1),
      duration: Duration(milliseconds: 260 + (index * 25)),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: _glassDecoration(isDark, radius: 20),
            child: isMobile
                ? _buildMobileDispatchContent(
                    dispatch,
                    statusColor,
                    channelIcon,
                    isDark,
                  )
                : Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _primary.withValues(
                            alpha: isDark ? 0.10 : 0.07,
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(channelIcon, color: _primary, size: 20),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dispatch #${dispatch.id}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${dispatch.channel.name.toUpperCase()} • Recipient ${dispatch.recipientId}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: _textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dispatch.failureReason != null)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 230),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(
                              alpha: isDark ? 0.07 : 0.045,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            dispatch.failureReason!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 9),
                      _buildStatusPill(
                        dispatch.status.name.toUpperCase(),
                        statusColor,
                        isDark,
                      ),
                      if (dispatch.status == DispatchStatus.failed) ...[
                        const SizedBox(width: 5),
                        IconButton(
                          tooltip: 'Retry Dispatch',
                          onPressed: () => _handleRetryDispatch(dispatch.id),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.orange,
                            size: 19,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDispatchContent(
    NotificationDispatch dispatch,
    Color statusColor,
    IconData channelIcon,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(channelIcon, color: _primary, size: 20),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dispatch #${dispatch.id}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dispatch.channel.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusPill(
              dispatch.status.name.toUpperCase(),
              statusColor,
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildMetaPill(
          Icons.person_outline_rounded,
          'Recipient: ${dispatch.recipientId}',
          _primary,
          isDark,
        ),
        const SizedBox(height: 5),
        _buildMetaPill(
          Icons.notifications_none_rounded,
          'Notification: ${dispatch.notificationId}',
          Colors.blue,
          isDark,
        ),
        if (dispatch.failureReason != null) ...[
          const SizedBox(height: 7),
          Text(
            'Failure: ${dispatch.failureReason}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (dispatch.status == DispatchStatus.failed) ...[
          const SizedBox(height: 9),
          _buildActionButton(
            label: 'Retry Dispatch',
            icon: Icons.refresh_rounded,
            color: Colors.orange,
            onPressed: () => _handleRetryDispatch(dispatch.id),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PREFERENCES
  // ---------------------------------------------------------------------------

  Widget _buildPreferencesTab(
    bool isDark,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 16,
        6,
        isMobile ? 12 : 16,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreferencesHero(isDark, isMobile),
          const SizedBox(height: 12),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRoutingRulesPanel(isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildChannelPreferencesPanel(isDark)),
              ],
            )
          else ...[
            _buildRoutingRulesPanel(isDark),
            const SizedBox(height: 12),
            _buildChannelPreferencesPanel(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesHero(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: _glassDecoration(
        isDark,
        radius: 22,
        color: _primary.withValues(alpha: isDark ? 0.045 : 0.025),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.settings_suggest_rounded,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Routing & Notification Preferences',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Control how operational events are routed and which delivery channels are enabled.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.3,
                    color: _textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingRulesPanel(bool isDark) {
    return _buildGlassPanel(
      isDark,
      title: 'Routing Rules',
      icon: Icons.route_rounded,
      subtitle: '${_routingRules.length} configured notification routes',
      child: Column(
        children: _routingRules.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('No routing rules configured.'),
                ),
              ]
            : _routingRules.map((rule) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _surfaceStrong(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border(isDark)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: rule.enabled
                              ? _primary.withValues(
                                  alpha: isDark ? 0.10 : 0.065,
                                )
                              : Colors.grey.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          rule.enabled
                              ? Icons.alt_route_rounded
                              : Icons.pause_circle_outline_rounded,
                          size: 18,
                          color: rule.enabled
                              ? _primary
                              : _textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rule.notificationType.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${rule.recipientRole.name} • ${rule.channels.map((c) => c.name.toUpperCase()).join(', ')}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: _textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Switch.adaptive(
                        value: rule.enabled,
                        activeTrackColor: _primary,
                        onChanged: (value) {
                          final updated = rule.copyWith(enabled: value);
                          _notificationService.updateRoutingRule(updated);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildChannelPreferencesPanel(bool isDark) {
    return _buildGlassPanel(
      isDark,
      title: 'User Channel Preferences',
      icon: Icons.tune_rounded,
      subtitle: '${_preferences.length} notification preference records',
      child: Column(
        children: _preferences.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('No notification preferences configured.'),
                ),
              ]
            : _preferences.map((pref) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _surfaceStrong(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pref.notificationType.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _buildPreferencePill(
                            'In-App',
                            pref.inAppEnabled,
                            Icons.phonelink_setup_rounded,
                            isDark,
                          ),
                          _buildPreferencePill(
                            'Push',
                            pref.pushEnabled,
                            Icons.notifications_active_outlined,
                            isDark,
                          ),
                          _buildPreferencePill(
                            'Email',
                            pref.emailEnabled,
                            Icons.email_outlined,
                            isDark,
                          ),
                          _buildPreferencePill(
                            'SMS',
                            pref.smsEnabled,
                            Icons.sms_outlined,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildPreferencePill(
    String label,
    bool enabled,
    IconData icon,
    bool isDark,
  ) {
    final color = enabled ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: enabled ? 0.16 : 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ${enabled ? 'ON' : 'OFF'}',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: enabled ? color : _textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPanel(
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: _glassDecoration(isDark, radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: isDark ? 0.10 : 0.065),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: _primary, size: 19),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: _textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required bool isDark,
    required bool isMobile,
    required List<_StatData> stats,
  }) {
    return Row(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 9 : 12,
                vertical: isMobile ? 10 : 11,
              ),
              decoration: _glassDecoration(isDark, radius: 16),
              child: Row(
                children: [
                  Container(
                    width: isMobile ? 34 : 38,
                    height: isMobile ? 34 : 38,
                    decoration: BoxDecoration(
                      color: stat.color.withValues(
                        alpha: isDark ? 0.10 : 0.065,
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      stat.icon,
                      color: stat.color,
                      size: isMobile ? 17 : 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 17,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary(isDark),
                          ),
                        ),
                        Text(
                          stat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 9.5,
                            color: _textSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusPill(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.11 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DETAIL DRAWER
  // ---------------------------------------------------------------------------

  Widget _buildDetailDrawer(bool isDark) {
    final item = _selectedNotification!;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.34),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selectedNotification = null),
                child: Container(color: Colors.transparent),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.94, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset((1 - value) * 40, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 430,
                  margin: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: _glassDecoration(
                          isDark,
                          radius: 26,
                          color: isDark
                              ? const Color(0xFF0D171D).withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.95),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(
                                      alpha: isDark ? 0.10 : 0.065,
                                    ),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_rounded,
                                    color: _primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notification Detail',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: _textPrimary(isDark),
                                        ),
                                      ),
                                      Text(
                                        'Operational message record',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _textSecondary(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(
                                    () => _selectedNotification = null,
                                  ),
                                  icon: const Icon(Icons.close_rounded),
                                  color: _textSecondary(isDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                _buildPriorityBadge(item.priority, isDark),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    item.type.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _textSecondary(isDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.message,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: _textSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailSection(
                              'Operational Metadata',
                              Icons.info_outline_rounded,
                              isDark,
                              [
                                'ID: ${item.id}',
                                'Recipient ID: ${item.recipientId}',
                                'Role: ${item.recipientRole.name}',
                                'Created At: ${item.createdAt}',
                                if (item.readAt != null)
                                  'Read At: ${item.readAt}',
                                if (item.acknowledgedAt != null)
                                  'Acknowledged At: ${item.acknowledgedAt}',
                              ],
                            ),
                            const Spacer(),
                            if (item.sourceEntityType != null)
                              SizedBox(
                                width: double.infinity,
                                child: _buildActionButton(
                                  label: 'View Related Record',
                                  icon: Icons.open_in_new_rounded,
                                  color: _primary,
                                  onPressed: () {
                                    final type = item.sourceEntityType;
                                    final id = item.sourceEntityId;
                                    setState(
                                      () => _selectedNotification = null,
                                    );
                                    _navigateToRelatedEntity(type, id);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNotificationSheet(
    BuildContext sheetContext,
    NotificationRecord item,
    bool isDark,
  ) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.90,
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D171D).withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              border: Border.all(color: _border(isDark)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _textSecondary(isDark).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTypeIcon(item.type, item.priority, isDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Notification Detail',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary(isDark),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                        color: _textSecondary(isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPriorityBadge(item.priority, isDark),
                  const SizedBox(height: 11),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: _textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailSection(
                    'Operational Metadata',
                    Icons.info_outline_rounded,
                    isDark,
                    [
                      'ID: ${item.id}',
                      'Recipient ID: ${item.recipientId}',
                      'Role: ${item.recipientRole.name}',
                      'Created At: ${item.createdAt}',
                      if (item.readAt != null) 'Read At: ${item.readAt}',
                      if (item.acknowledgedAt != null)
                        'Acknowledged At: ${item.acknowledgedAt}',
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (item.sourceEntityType != null)
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(
                        label: 'View Related Record',
                        icon: Icons.open_in_new_rounded,
                        color: _primary,
                        onPressed: () {
                          final type = item.sourceEntityType;
                          final id = item.sourceEntityId;
                          Navigator.pop(sheetContext);
                          _navigateToRelatedEntity(type, id);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    bool isDark,
    List<String> lines,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.35,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.3,
                  color: _textSecondary(isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UTILITIES
  // ---------------------------------------------------------------------------

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _NotificationVisual {
  final IconData icon;
  final Color color;

  const _NotificationVisual(this.icon, this.color);
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatData(this.label, this.value, this.icon, this.color);
}
