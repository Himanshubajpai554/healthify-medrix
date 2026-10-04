import 'package:flutter/material.dart';
import '../../core/data/mock/mock_audit_repository.dart';
import '../../core/data/mock/mock_security_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/audit_model.dart';
import '../../core/models/security_model.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/audit_service.dart';
import '../../core/services/security_service.dart';
import '../../core/widgets/access_denied_widget.dart';
import '../../core/widgets/medrix_empty_state.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class SecurityGovernanceScreen extends StatefulWidget {
  final UserRole currentUserRole;
  final Function(int)? onNavigateToTab;

  const SecurityGovernanceScreen({
    super.key,
    this.currentUserRole = UserRole.hospitalAdmin,
    this.onNavigateToTab,
  });

  @override
  State<SecurityGovernanceScreen> createState() => _SecurityGovernanceScreenState();
}

class _SecurityGovernanceScreenState extends State<SecurityGovernanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AuditService _auditService;
  late SecurityService _securityService;

  bool _isLoading = true;
  String? _errorMessage;

  List<RoleDetailModel> _roles = [];
  List<UserAccessItem> _users = [];
  List<AuditLog> _auditLogs = [];
  List<SecurityEvent> _securityEvents = [];
  List<UserSessionInfo> _sessions = [];
  List<BreakGlassAccess> _breakGlassRequests = [];
  Map<String, dynamic> _auditSummary = {};

  UserRole _selectedMatrixRole = UserRole.doctor;
  List<RolePermission> _matrixPermissions = [];

  String _auditSearch = '';
  AuditActionType? _selectedActionFilter;
  AuditLog? _selectedAuditLog;

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
    _tabController = TabController(length: 5, vsync: this);
    _auditService = AuditService(auditRepository: MockAuditRepository());
    _securityService = SecurityService(securityRepository: MockSecurityRepository());
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
      final roles = await _securityService.getRoles();
      final users = await _securityService.getUsers();
      final auditRes = await _auditService.query(
        AuditLogQuery(
          search: _auditSearch.isNotEmpty ? _auditSearch : null,
          actionType: _selectedActionFilter,
        ),
      );
      final events = await _securityService.getSecurityEvents();
      final sessions = await _securityService.getActiveSessions();
      final breakGlass = await _securityService.getBreakGlassRequests();
      final summary = await _auditService.getSummary();
      final matrix = await _securityService.getRolePermissions(_selectedMatrixRole);

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _users = users;
        _auditLogs = auditRes.items;
        _securityEvents = events;
        _sessions = sessions;
        _breakGlassRequests = breakGlass;
        _auditSummary = summary;
        _matrixPermissions = matrix;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load security & audit data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMatrixForRole(UserRole role) async {
    final matrix = await _securityService.getRolePermissions(role);
    if (!mounted) return;
    setState(() {
      _selectedMatrixRole = role;
      _matrixPermissions = matrix;
    });
  }

  Future<void> _handleTerminateSession(String sessionId) async {
    await _securityService.terminateSession(sessionId);
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session terminated successfully.')),
    );
  }

  Future<void> _showBreakGlassDialog() async {
    final patientController = TextEditingController(text: 'PT-1001');
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Request Break-Glass Access',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EMERGENCY CLINICAL OVERRIDE: Emergency access bypasses standard role restrictions. Every access is time-bound, logged, and subject to mandatory administrative review.',
              style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: patientController,
              decoration: const InputDecoration(labelText: 'Patient ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Emergency Clinical Reason (Required)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _securityService.requestBreakGlass(
                'DOC-1015',
                patientController.text.trim(),
                reasonController.text.trim(),
              );
              await _loadData();
            },
            child: const Text('Grant Emergency Access'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    final isDesktop = Responsive.isDesktop(context);

    // Permission check for Security Screen
    if (!PermissionService.canView(widget.currentUserRole, 'security')) {
      return Scaffold(
        body: AccessDeniedWidget(
          title: 'Security & Governance Restricted',
          message: 'Your role (${widget.currentUserRole.name}) does not have permission to access Security & Governance.',
          onReturnToDashboard: () => widget.onNavigateToTab?.call(0),
        ),
      );
    }

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
                        ? const MedrixLoadingState(message: 'Loading security, governance & audit logs...')
                        : _errorMessage != null
                            ? MedrixErrorState(errorMessage: _errorMessage!, onRetry: _loadData)
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildDashboardTab(isDark, isDesktop),
                                  _buildRoleMatrixTab(isDark, isDesktop),
                                  _buildUsersTab(isDark, isDesktop),
                                  _buildAuditTab(isDark, isDesktop),
                                  _buildSessionsTab(isDark, isDesktop),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedAuditLog != null) _buildAuditDetailDrawer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final isDesktop = Responsive.isDesktop(context);
    if (!isDesktop) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: _glassDecoration(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.indigo, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'SECURITY, GOVERNANCE & AUDIT LOGGING',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                        child: const Text('PHASE 12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Role-Based Access Control, Permission Matrix, Audit Trail & Break-Glass Governance',
              style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.warning_amber_rounded, size: 16),
                label: const Text('Break-Glass Access'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: _showBreakGlassDialog,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security_rounded, color: Colors.indigo, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'SECURITY, GOVERNANCE & AUDIT LOGGING',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                      child: const Text('PHASE 12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  'Role-Based Access Control, Permission Matrix, Audit Trail & Break-Glass Governance',
                  style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('Break-Glass Access'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onPressed: _showBreakGlassDialog,
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.indigo,
        labelColor: Colors.indigo,
        unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_customize_rounded), text: 'Security Overview'),
          Tab(icon: Icon(Icons.grid_view_rounded), text: 'Role & Permission Matrix'),
          Tab(icon: Icon(Icons.admin_panel_settings_rounded), text: 'User Access Directory'),
          Tab(icon: Icon(Icons.history_rounded), text: 'Audit Log Trail'),
          Tab(icon: Icon(Icons.phonelink_lock_rounded), text: 'Sessions & Break-Glass'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: SECURITY DASHBOARD
  // ---------------------------------------------------------------------------
  Widget _buildDashboardTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildKpiCard(isDark, title: 'Audit Events Today', value: '${_auditSummary['todayLogs'] ?? 0}', icon: Icons.history_edu_rounded, color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(isDark, title: 'Permission Denials', value: '${_auditSummary['permissionDenials'] ?? 0}', icon: Icons.block_rounded, color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(isDark, title: 'Active Security Events', value: '${_securityEvents.where((e) => e.status == "Active").length}', icon: Icons.gpp_maybe_rounded, color: Colors.redAccent)),
                const SizedBox(width: 12),
                Expanded(child: _buildKpiCard(isDark, title: 'Break-Glass Overrides', value: '${_breakGlassRequests.length}', icon: Icons.lock_open_rounded, color: Colors.purple)),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildKpiCard(isDark, title: 'Audit Events Today', value: '${_auditSummary['todayLogs'] ?? 0}', icon: Icons.history_edu_rounded, color: Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKpiCard(isDark, title: 'Permission Denials', value: '${_auditSummary['permissionDenials'] ?? 0}', icon: Icons.block_rounded, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildKpiCard(isDark, title: 'Active Security Events', value: '${_securityEvents.where((e) => e.status == "Active").length}', icon: Icons.gpp_maybe_rounded, color: Colors.redAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKpiCard(isDark, title: 'Break-Glass Overrides', value: '${_breakGlassRequests.length}', icon: Icons.lock_open_rounded, color: Colors.purple)),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),
          Text('Recent Security Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._securityEvents.map((e) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  e.severity == SecurityEventSeverity.critical || e.severity == SecurityEventSeverity.high
                      ? Icons.warning_rounded
                      : Icons.info_rounded,
                  color: e.severity == SecurityEventSeverity.critical ? Colors.red : Colors.orange,
                ),
                title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Actor: ${e.actorId} • Status: ${e.status} • Time: ${e.timestamp}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(8)),
                  child: Text(e.severity.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKpiCard(bool isDark, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ROLE & PERMISSION MATRIX
  // ---------------------------------------------------------------------------
  Widget _buildRoleMatrixTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select User Role for Matrix Inspection:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _roles.map((r) {
                final isSel = r.role == _selectedMatrixRole;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r.roleName),
                    selected: isSel,
                    onSelected: (sel) => _loadMatrixForRole(r.role),
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(color: isSel ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Permission Matrix for ${_selectedMatrixRole.name.toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ..._matrixPermissions.map((mp) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(mp.allowed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: mp.allowed ? Colors.green : Colors.grey),
                      title: Text(mp.permission.name),
                      subtitle: Text('Category: ${mp.category}'),
                      trailing: Switch(
                        value: mp.allowed,
                        onChanged: (val) {
                          _securityService.updateRolePermission(_selectedMatrixRole, mp.permission, val);
                          _loadMatrixForRole(_selectedMatrixRole);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: USER ACCESS DIRECTORY
  // ---------------------------------------------------------------------------
  Widget _buildUsersTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Access Directory (${_users.length} Active Accounts)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 12),
          ..._users.map((u) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.indigo.withValues(alpha: 0.15), child: Text(u.userName[0], style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))),
                title: Text(u.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Email: ${u.email} • Dept: ${u.department}\n${u.permissionSummary}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text(u.role.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: AUDIT LOG DIRECTORY & DIFF VIEWER
  // ---------------------------------------------------------------------------
  Widget _buildAuditTab(bool isDark, bool isDesktop) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search audit logs by actor, action, target entity...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) {
              _auditSearch = val;
              _loadData();
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _auditLogs.isEmpty
              ? const MedrixEmptyState(
                  title: 'No Audit Logs Found',
                  description: 'No audit records match the current filter or search criteria.',
                  icon: Icons.history_toggle_off_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _auditLogs.length,
                  itemBuilder: (context, index) {
                    final item = _auditLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.status == 'DENIED' ? Icons.block_rounded : Icons.history_rounded,
                          color: item.status == 'DENIED' ? Colors.redAccent : Colors.indigo,
                        ),
                        title: Text('${item.actionType.name.toUpperCase()} • Target: ${item.targetEntityType} (${item.targetEntityId})'),
                        subtitle: Text('Actor: ${item.actorId} (${item.actorRole.name}) • IP: ${item.ipAddress ?? "192.168.1.x"} • Time: ${item.timestamp}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onPressed: () => setState(() => _selectedAuditLog = item),
                        ),
                        onTap: () => setState(() => _selectedAuditLog = item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 5: SESSIONS & BREAK-GLASS
  // ---------------------------------------------------------------------------
  Widget _buildSessionsTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Device Sessions (${_sessions.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._sessions.map((s) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.devices_rounded, color: Colors.indigo),
                title: Text('${s.device} (${s.userId})'),
                subtitle: Text('Location: ${s.locationSummary}\nLogin: ${s.loginTime} • Last Activity: ${s.lastActivity}'),
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 14),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: () => _handleTerminateSession(s.sessionId),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text('Emergency Break-Glass Requests Log (${_breakGlassRequests.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          const SizedBox(height: 8),
          ..._breakGlassRequests.map((bg) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.lock_open_rounded, color: Colors.redAccent),
                title: Text('Break-Glass Request #${bg.id} • Patient ${bg.patientId}'),
                subtitle: Text('User: ${bg.userId} • Reason: ${bg.reason}\nGranted: ${bg.grantedAt} • Expires: ${bg.expiresAt}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                  child: Text(bg.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUDIT DIFF DETAIL DRAWER
  // ---------------------------------------------------------------------------
  Widget _buildAuditDetailDrawer(bool isDark) {
    final item = _selectedAuditLog!;
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 440,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Audit Log Detail & State Diff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _selectedAuditLog = null),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text('Audit ID: ${item.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Action: ${item.action}'),
              Text('Actor: ${item.actorId} (${item.actorRole.name})'),
              Text('Target Entity: ${item.targetEntityType} (${item.targetEntityId})'),
              Text('Timestamp: ${item.timestamp}'),
              Text('IP Address: ${item.ipAddress ?? "192.168.1.x"}'),
              Text('User Agent: ${item.userAgent ?? "Medrix Client"}'),
              const SizedBox(height: 16),
              const Text('STATE CHANGE DIFF (PREVIOUS vs NEW)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PREVIOUS STATE:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                            Text(item.previousState != null ? item.previousState.toString() : 'None (Record Creation / Access)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NEW STATE:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                            Text(item.newState != null ? item.newState.toString() : 'None (Record Access / Deletion)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
