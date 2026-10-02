import 'package:flutter/material.dart';
import '../../core/data/mock/mock_notification_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/notification_model.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/medrix_empty_state.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class NotificationCenterScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const NotificationCenterScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NotificationService _notificationService;

  bool _isLoading = true;
  String? _errorMessage;

  List<NotificationRecord> _notifications = [];
  List<OperationalAlert> _alerts = [];
  List<NotificationDispatch> _dispatches = [];
  List<NotificationRoutingRule> _routingRules = [];
  List<NotificationPreference> _preferences = [];

  String _filterCategory = 'All'; // All, Unread, Critical, Acknowledged, History
  String _searchQuery = '';
  NotificationRecord? _selectedNotification;
  DispatchChannel? _selectedDispatchChannel;

  BoxDecoration _glassDecoration(bool isDark) {
    return BoxDecoration(
      color: HealthifyGlassTheme.getGlassSurface(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationService = NotificationService(notificationRepository: MockNotificationRepository());
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
        query: NotificationQuery(search: _searchQuery.isNotEmpty ? _searchQuery : null),
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
      list = list.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.message.toLowerCase().contains(q) ||
          n.id.toLowerCase().contains(q) ||
          (n.sourceEntityId != null && n.sourceEntityId!.toLowerCase().contains(q))).toList();
    }

    switch (_filterCategory) {
      case 'Unread':
        return list.where((n) => n.isUnread).toList();
      case 'Critical':
        return list.where((n) => n.priority == NotificationPriority.critical).toList();
      case 'Acknowledged':
        return list.where((n) => n.isAcknowledged).toList();
      case 'History':
        return list.where((n) => n.isRead || n.status == NotificationStatus.dismissed || n.isExpired).toList();
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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
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
      const SnackBar(content: Text('Dispatch retry successful! Delivery confirmed.')),
    );
    await _loadData();
  }

  void _navigateToRelatedEntity(String? type, String? id) {
    if (widget.onNavigateToTab == null || type == null) return;

    switch (type) {
      case 'EmergencyCase':
        widget.onNavigateToTab!(9); // Emergency & Triage tab index
        break;
      case 'Bed':
        widget.onNavigateToTab!(7); // Beds & ICU tab index
        break;
      case 'BloodUnit':
        widget.onNavigateToTab!(8); // Blood Bank tab index
        break;
      case 'DiagnosticReport':
        widget.onNavigateToTab!(10); // Clinical Documents tab index
        break;
      case 'AIPrediction':
        widget.onNavigateToTab!(13); // AI Center tab index
        break;
      case 'Staff':
        widget.onNavigateToTab!(4); // Staff tab index
        break;
      default:
        widget.onNavigateToTab!(0); // Overview
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPulseBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildTabBar(isDark),
                Expanded(
                  child: _isLoading
                      ? const MedrixLoadingState(message: 'Loading notification & dispatch pipeline...')
                      : _errorMessage != null
                          ? MedrixErrorState(errorMessage: _errorMessage!, onRetry: _loadData)
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildInboxTab(isDark, isDesktop),
                                _buildAlertCenterTab(isDark, isDesktop),
                                _buildDispatchCenterTab(isDark, isDesktop),
                                _buildPreferencesTab(isDark, isDesktop),
                              ],
                            ),
                ),
              ],
            ),
          ),
          ),
          if (_selectedNotification != null) _buildDetailDrawer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    final criticalCount = _notifications.where((n) => n.priority == NotificationPriority.critical && n.isUnread).length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: HealthifyGlassTheme.primaryTeal, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'NOTIFICATION & DISPATCH CENTER',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                      child: const Text('PHASE 11', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  'Hospital operational communications, critical alert routing, and dispatch pipeline',
                  style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                ),
              ],
            ),
          ),
          if (criticalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('$criticalCount Critical', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: HealthifyGlassTheme.primaryTeal, borderRadius: BorderRadius.circular(12)),
            child: Text('$unreadCount Unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _glassDecoration(isDark),
      child: TabBar(
        controller: _tabController,
        indicatorColor: HealthifyGlassTheme.primaryTeal,
        labelColor: HealthifyGlassTheme.primaryTeal,
        unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
        tabs: const [
          Tab(icon: Icon(Icons.inbox_rounded), text: 'Inbox & Center'),
          Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Alert Center'),
          Tab(icon: Icon(Icons.send_rounded), text: 'Dispatch Center'),
          Tab(icon: Icon(Icons.settings_suggest_rounded), text: 'Routing & Prefs'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: NOTIFICATION INBOX & CENTER
  // ---------------------------------------------------------------------------
  Widget _buildInboxTab(bool isDark, bool isDesktop) {
    final items = _filteredNotifications;

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search notifications by title, message, ID, or source...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['All', 'Unread', 'Critical', 'Acknowledged', 'History'].map((cat) {
              final isSel = _filterCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (sel) => setState(() => _filterCategory = cat),
                  selectedColor: HealthifyGlassTheme.primaryTeal,
                  labelStyle: TextStyle(color: isSel ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? const MedrixEmptyState(
                  title: 'No Notifications Found',
                  description: 'No notification records match the current filter or search criteria.',
                  icon: Icons.notifications_off_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: item.isUnread ? (isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.05)) : null,
                      child: ListTile(
                        leading: _buildTypeIcon(item.type, item.priority),
                        title: Row(
                          children: [
                            Expanded(child: Text(item.title, style: TextStyle(fontWeight: item.isUnread ? FontWeight.bold : FontWeight.normal))),
                            const SizedBox(width: 8),
                            _buildPriorityBadge(item.priority),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(item.message),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (item.sourceEntityType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                    child: Text('${item.sourceEntityType}: ${item.sourceEntityId}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                Text(
                                  _formatTime(item.createdAt),
                                  style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                                ),
                                const Spacer(),
                                if (item.isAcknowledged)
                                  const Text('Acknowledged', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'read') _handleMarkAsRead(item.id);
                            if (val == 'unread') _handleMarkAsUnread(item.id);
                            if (val == 'ack') _handleAcknowledgeNotification(item.id);
                            if (val == 'dismiss') _handleDismissNotification(item.id);
                            if (val == 'detail') setState(() => _selectedNotification = item);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'detail', child: Text('View Details')),
                            if (item.isUnread) const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
                            if (item.isRead) const PopupMenuItem(value: 'unread', child: Text('Mark as Unread')),
                            if (!item.isAcknowledged && (item.priority == NotificationPriority.critical || item.priority == NotificationPriority.high))
                              const PopupMenuItem(value: 'ack', child: Text('Acknowledge')),
                            if (item.priority != NotificationPriority.critical || item.isAcknowledged)
                              const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                          ],
                        ),
                        onTap: () => setState(() => _selectedNotification = item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTypeIcon(NotificationType type, NotificationPriority priority) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.newEmergencyArrival:
        icon = Icons.emergency_rounded;
        color = Colors.redAccent;
        break;
      case NotificationType.icuVitalCritical:
      case NotificationType.icuCapacityWarning:
        icon = Icons.favorite_rounded;
        color = Colors.red;
        break;
      case NotificationType.bloodStockCritical:
        icon = Icons.bloodtype_rounded;
        color = Colors.red;
        break;
      case NotificationType.reportUploaded:
      case NotificationType.reportReleased:
        icon = Icons.description_rounded;
        color = Colors.blue;
        break;
      case NotificationType.bedSanitizationCleared:
        icon = Icons.king_bed_rounded;
        color = Colors.green;
        break;
      case NotificationType.staffShiftReminder:
        icon = Icons.schedule_rounded;
        color = Colors.amber;
        break;
      case NotificationType.aiForecastAlert:
        icon = Icons.psychology_rounded;
        color = Colors.purpleAccent;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = HealthifyGlassTheme.primaryTeal;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority) {
    Color bg;
    switch (priority) {
      case NotificationPriority.critical:
        bg = Colors.red;
        break;
      case NotificationPriority.high:
        bg = Colors.orange;
        break;
      case NotificationPriority.medium:
        bg = Colors.blue;
        break;
      default:
        bg = Colors.teal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(priority.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ALERT CENTER & OPERATIONAL ALERTS
  // ---------------------------------------------------------------------------
  Widget _buildAlertCenterTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'OPERATIONAL ALERT CENTER: High-urgency hospital conditions requiring acknowledgement or operational resolution. Resolution must represent actual clinical/resource status changes.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Active Operational Alerts (${_alerts.where((a) => a.isActive).length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._alerts.map((alert) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildPriorityBadge(alert.severity),
                        const SizedBox(width: 8),
                        Expanded(child: Text(alert.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: alert.isActive ? Colors.redAccent : (alert.isAcknowledged ? Colors.orange : Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(alert.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(alert.description),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Source: ${alert.sourceEntityType} (${alert.sourceEntityId})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Spacer(),
                        if (alert.isActive)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Acknowledge'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            onPressed: () => _handleAcknowledgeAlert(alert.id),
                          ),
                        if (alert.isAcknowledged)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.done_all_rounded, size: 16),
                            label: const Text('Mark Resolved'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            onPressed: () => _handleResolveAlert(alert.id),
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

  // ---------------------------------------------------------------------------
  // TAB 3: DISPATCH CENTER
  // ---------------------------------------------------------------------------
  Widget _buildDispatchCenterTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Delivery Channel Dispatches (${_dispatches.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
              const Spacer(),
              DropdownButton<DispatchChannel?>(
                value: _selectedDispatchChannel,
                hint: const Text('Filter Channel'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Channels')),
                  ...DispatchChannel.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))),
                ],
                onChanged: (val) => setState(() => _selectedDispatchChannel = val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._dispatches
              .where((d) => _selectedDispatchChannel == null || d.channel == _selectedDispatchChannel)
              .map((dispatch) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  dispatch.channel == DispatchChannel.inApp
                      ? Icons.phonelink_setup_rounded
                      : dispatch.channel == DispatchChannel.push
                          ? Icons.notifications_active_rounded
                          : dispatch.channel == DispatchChannel.email
                              ? Icons.email_rounded
                              : Icons.sms_rounded,
                  color: HealthifyGlassTheme.primaryTeal,
                ),
                title: Text('Dispatch #${dispatch.id} • ${dispatch.channel.name.toUpperCase()}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recipient: ${dispatch.recipientId} • Notification: ${dispatch.notificationId}'),
                    if (dispatch.failureReason != null)
                      Text('Failure Reason: ${dispatch.failureReason}', style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dispatch.status == DispatchStatus.delivered
                            ? Colors.green
                            : dispatch.status == DispatchStatus.failed
                                ? Colors.redAccent
                                : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(dispatch.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    if (dispatch.status == DispatchStatus.failed) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.orange),
                        tooltip: 'Retry Dispatch',
                        onPressed: () => _handleRetryDispatch(dispatch.id),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: ROUTING RULES & PREFERENCES
  // ---------------------------------------------------------------------------
  Widget _buildPreferencesTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Routing Rules Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._routingRules.map((rule) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: SwitchListTile(
                title: Text(rule.notificationType.name),
                subtitle: Text('Mapped Role: ${rule.recipientRole.name} • Channels: ${rule.channels.map((c) => c.name.toUpperCase()).join(", ")}'),
                value: rule.enabled,
                onChanged: (val) {
                  final updated = rule.copyWith(enabled: val);
                  _notificationService.updateRoutingRule(updated);
                  _loadData();
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('User Notification Channel Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._preferences.map((pref) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pref.notificationType.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      children: [
                        Text('In-App: ${pref.inAppEnabled ? "ON" : "OFF"}', style: TextStyle(fontSize: 12, color: pref.inAppEnabled ? Colors.green : Colors.grey)),
                        Text('Push: ${pref.pushEnabled ? "ON" : "OFF"}', style: TextStyle(fontSize: 12, color: pref.pushEnabled ? Colors.green : Colors.grey)),
                        Text('Email: ${pref.emailEnabled ? "ON" : "OFF"}', style: TextStyle(fontSize: 12, color: pref.emailEnabled ? Colors.green : Colors.grey)),
                        Text('SMS: ${pref.smsEnabled ? "ON" : "OFF"}', style: TextStyle(fontSize: 12, color: pref.smsEnabled ? Colors.green : Colors.grey)),
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

  // ---------------------------------------------------------------------------
  // DETAIL DRAWER
  // ---------------------------------------------------------------------------
  Widget _buildDetailDrawer(bool isDark) {
    final item = _selectedNotification!;
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 420,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notification Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _selectedNotification = null),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPriorityBadge(item.priority),
                  const SizedBox(width: 8),
                  Text(item.type.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(item.message),
              const SizedBox(height: 16),
              const Text('OPERATIONAL METADATA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              Text('ID: ${item.id}'),
              Text('Recipient ID: ${item.recipientId} (${item.recipientRole.name})'),
              Text('Created At: ${item.createdAt}'),
              if (item.readAt != null) Text('Read At: ${item.readAt}'),
              if (item.acknowledgedAt != null) Text('Acknowledged At: ${item.acknowledgedAt}'),
              const Spacer(),
              if (item.sourceEntityType != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text('View Related Record (${item.sourceEntityType})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HealthifyGlassTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final type = item.sourceEntityType;
                      final id = item.sourceEntityId;
                      setState(() => _selectedNotification = null);
                      _navigateToRelatedEntity(type, id);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
