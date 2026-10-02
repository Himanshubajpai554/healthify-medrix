import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/emergency_models.dart';
import '../services/doctor_emergency_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/create_emergency_case_modal.dart';
import 'widgets/emergency_case_detail_drawer.dart';
import 'widgets/emergency_filter_toolbar.dart';
import 'widgets/emergency_header.dart';
import 'widgets/emergency_summary_cards.dart';
import 'widgets/emergency_table_view.dart';
import 'widgets/resolve_emergency_case_modal.dart';
import 'widgets/transfer_emergency_case_modal.dart';
import 'widgets/update_emergency_status_modal.dart';

class DoctorEmergencyCasesScreen extends StatefulWidget {
  const DoctorEmergencyCasesScreen({super.key});

  @override
  State<DoctorEmergencyCasesScreen> createState() => _DoctorEmergencyCasesScreenState();
}

class _DoctorEmergencyCasesScreenState extends State<DoctorEmergencyCasesScreen> {
  final DoctorEmergencyService _emergencyService = DoctorEmergencyService();

  List<DoctorEmergencyCaseFullModel> _allCases = [];
  bool _isLoading = true;
  bool _isSidebarExpanded = true;

  // Filter & Search state
  String _searchQuery = '';
  String _activeSummaryFilter = 'all'; // 'all', 'active', 'critical', 'waiting', 'inTreatment', 'resolvedToday'
  EmergencyCaseStatus? _selectedStatus;
  EmergencyOperationalPriority? _selectedPriority;
  String? _selectedDepartment;
  String? _selectedDoctor;

  // Drawer / Selection state
  DoctorEmergencyCaseFullModel? _selectedCase;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    final cases = await _emergencyService.getEmergencyCases();
    if (mounted) {
      setState(() {
        _allCases = cases;
        _isLoading = false;
        if (_selectedCase != null) {
          try {
            _selectedCase = cases.firstWhere((c) => c.id == _selectedCase!.id);
          } catch (_) {
            _selectedCase = cases.isNotEmpty ? cases.first : null;
          }
        }
      });
    }
  }

  List<DoctorEmergencyCaseFullModel> get _filteredCases {
    var result = List<DoctorEmergencyCaseFullModel>.from(_allCases);

    // Summary Card Filter
    switch (_activeSummaryFilter) {
      case 'active':
        result = result.where((c) => c.status != EmergencyCaseStatus.resolved && c.status != EmergencyCaseStatus.cancelled).toList();
        break;
      case 'critical':
        result = result.where((c) => c.priority == EmergencyOperationalPriority.immediate && c.status != EmergencyCaseStatus.resolved).toList();
        break;
      case 'waiting':
        result = result.where((c) => c.status == EmergencyCaseStatus.waiting).toList();
        break;
      case 'inTreatment':
        result = result.where((c) => c.status == EmergencyCaseStatus.inTreatment).toList();
        break;
      case 'resolvedToday':
        result = result.where((c) => c.status == EmergencyCaseStatus.resolved).toList();
        break;
      case 'all':
      default:
        break;
    }

    // Status Filter
    if (_selectedStatus != null) {
      result = result.where((c) => c.status == _selectedStatus).toList();
    }

    // Priority Filter
    if (_selectedPriority != null) {
      result = result.where((c) => c.priority == _selectedPriority).toList();
    }

    // Department Filter
    if (_selectedDepartment != null) {
      result = result.where((c) => c.department == _selectedDepartment).toList();
    }

    // Doctor Filter
    if (_selectedDoctor != null) {
      result = result.where((c) => c.assignedDoctor == _selectedDoctor).toList();
    }

    // Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.patientName.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q) ||
            c.patientId.toLowerCase().contains(q) ||
            c.emergencyReason.toLowerCase().contains(q) ||
            c.department.toLowerCase().contains(q) ||
            c.assignedDoctor.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  List<String> get _availableDepartments {
    return _allCases.map((c) => c.department).toSet().toList();
  }

  List<String> get _availableDoctors {
    return _allCases.map((c) => c.assignedDoctor).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    final metrics = _emergencyService.getSummaryMetrics();

    return Scaffold(
      backgroundColor: isDark ? HealthifyGlassTheme.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Row(
          children: [
            // Desktop Left Sidebar
            if (isDesktop)
              DoctorSidebar(
                selectedNavIndex: 6, // Index 6 is Emergency Cases
                onNavItemSelected: (index) => _navigateToIndex(context, index),
                isExpanded: _isSidebarExpanded,
                onToggleExpand: () {
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                },
                availabilityStatus: DoctorAvailability.available,
                onLogout: () => Navigator.pushReplacementNamed(context, '/portal-select'),
                onRoleSwitcherTap: () => Navigator.pushReplacementNamed(context, '/portal-select'),
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Doctor Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Emergency Workspace',
                    subtitle: 'Real-Time Acute Triage & Critical Alerts',
                    availabilityStatus: DoctorAvailability.available,
                    onAvailabilityChanged: (_) {},
                    onNotificationTap: () {},
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {},
                    unreadNotificationsCount: 3,
                  ),

                  // Workspace Body
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          )
                        : isDesktop
                            ? _buildDesktopLayout(context, isDark, metrics)
                            : _buildMobileTabletLayout(context, isDark, metrics, isMobile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    bool isDark,
    Map<String, int> metrics,
  ) {
    final filtered = _filteredCases;
    final isDrawerOpen = _selectedCase != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Emergency Cases Workspace Table View
        Expanded(
          flex: isDrawerOpen ? 3 : 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workspace Header
                EmergencyHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onClearSearch: () => setState(() => _searchQuery = ''),
                  onNewEmergencyPressed: () => _openCreateCaseModal(context),
                  onRefreshPressed: _loadCases,
                ),
                const SizedBox(height: 20),

                // Operational Summary Metric Cards
                EmergencySummaryCards(
                  activeCount: metrics['active'] ?? 0,
                  criticalCount: metrics['critical'] ?? 0,
                  waitingCount: metrics['waiting'] ?? 0,
                  inTreatmentCount: metrics['inTreatment'] ?? 0,
                  resolvedTodayCount: metrics['resolvedToday'] ?? 0,
                  selectedStatusFilter: _selectedStatus,
                  onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
                ),
                const SizedBox(height: 20),

                // Filter & Search Toolbar
                EmergencyFilterToolbar(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                  selectedDepartment: _selectedDepartment,
                  onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
                  availableDepartments: _availableDepartments,
                  selectedDoctor: _selectedDoctor,
                  onDoctorChanged: (doc) => setState(() => _selectedDoctor = doc),
                  availableDoctors: _availableDoctors,
                  onResetFilters: _resetFilters,
                ),
                const SizedBox(height: 20),

                // Emergency Cases Table / Cards View
                EmergencyTableView(
                  cases: filtered,
                  selectedCaseId: _selectedCase?.id,
                  onSelectCase: (caseModel) {
                    setState(() => _selectedCase = caseModel);
                  },
                  onUpdateStatus: (caseModel) => _openUpdateStatusModal(context, caseModel),
                  onTransferCase: (caseModel) => _openTransferModal(context, caseModel),
                  onResolveCase: (caseModel) => _openResolveModal(context, caseModel),
                ),
              ],
            ),
          ),
        ),

        // Desktop Right Side Detail Drawer
        if (isDrawerOpen)
          SizedBox(
            width: 540,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: EmergencyCaseDetailDrawer(
                emergencyCase: _selectedCase!,
                onClose: () => setState(() => _selectedCase = null),
                onStartConsultation: () => _handleStartConsultation(_selectedCase!),
                onAddNotePressed: () {},
                onUpdateStatusPressed: () => _openUpdateStatusModal(context, _selectedCase!),
                onTransferPressed: () => _openTransferModal(context, _selectedCase!),
                onResolvePressed: () => _openResolveModal(context, _selectedCase!),
                onSaveObservations: (obs) => _handleAddObservation(_selectedCase!.id, obs),
                onSaveNote: (type, content, isPrivate) => _handleAddNote(_selectedCase!.id, type, content, isPrivate),
                onCreatePrescription: () => Navigator.pushNamed(context, '/doctor-prescriptions'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileTabletLayout(
    BuildContext context,
    bool isDark,
    Map<String, int> metrics,
    bool isMobile,
  ) {
    final filtered = _filteredCases;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmergencyHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onClearSearch: () => setState(() => _searchQuery = ''),
                  onNewEmergencyPressed: () => _openCreateCaseModal(context),
                  onRefreshPressed: _loadCases,
                ),
                const SizedBox(height: 16),

                EmergencySummaryCards(
                  activeCount: metrics['active'] ?? 0,
                  criticalCount: metrics['critical'] ?? 0,
                  waitingCount: metrics['waiting'] ?? 0,
                  inTreatmentCount: metrics['inTreatment'] ?? 0,
                  resolvedTodayCount: metrics['resolvedToday'] ?? 0,
                  selectedStatusFilter: _selectedStatus,
                  onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
                ),
                const SizedBox(height: 16),

                EmergencyFilterToolbar(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  selectedPriority: _selectedPriority,
                  onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                  selectedDepartment: _selectedDepartment,
                  onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
                  availableDepartments: _availableDepartments,
                  selectedDoctor: _selectedDoctor,
                  onDoctorChanged: (doc) => setState(() => _selectedDoctor = doc),
                  availableDoctors: _availableDoctors,
                  onResetFilters: _resetFilters,
                ),
                const SizedBox(height: 16),

                EmergencyTableView(
                  cases: filtered,
                  selectedCaseId: _selectedCase?.id,
                  onSelectCase: (caseModel) => _openMobileDetailBottomSheet(context, caseModel),
                  onUpdateStatus: (caseModel) => _openUpdateStatusModal(context, caseModel),
                  onTransferCase: (caseModel) => _openTransferModal(context, caseModel),
                  onResolveCase: (caseModel) => _openResolveModal(context, caseModel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openMobileDetailBottomSheet(BuildContext context, DoctorEmergencyCaseFullModel caseModel) {
    setState(() => _selectedCase = caseModel);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.isDarkMode(context)
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: EmergencyCaseDetailDrawer(
              emergencyCase: caseModel,
              onClose: () => Navigator.of(bContext).pop(),
              onStartConsultation: () {
                Navigator.of(bContext).pop();
                _handleStartConsultation(caseModel);
              },
              onAddNotePressed: () {},
              onUpdateStatusPressed: () {
                Navigator.of(bContext).pop();
                _openUpdateStatusModal(context, caseModel);
              },
              onTransferPressed: () {
                Navigator.of(bContext).pop();
                _openTransferModal(context, caseModel);
              },
              onResolvePressed: () {
                Navigator.of(bContext).pop();
                _openResolveModal(context, caseModel);
              },
              onSaveObservations: (obs) => _handleAddObservation(caseModel.id, obs),
              onSaveNote: (type, content, isPrivate) => _handleAddNote(caseModel.id, type, content, isPrivate),
              onCreatePrescription: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-prescriptions');
              },
            ),
          ),
        );
      },
    );
  }

  void _openCreateCaseModal(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreateEmergencyCaseModal(
          onCreateSubmitted: (newCase) async {
            await _emergencyService.createEmergencyCase(newCase);
            await _loadCases();
            if (!mounted) return;
            setState(() => _selectedCase = newCase);
            messenger.showSnackBar(
              SnackBar(content: Text('Emergency Case ${newCase.id} registered successfully.')),
            );
          },
        );
      },
    );
  }

  void _openUpdateStatusModal(BuildContext context, DoctorEmergencyCaseFullModel caseModel) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return UpdateEmergencyStatusModal(
          emergencyCase: caseModel,
          onStatusUpdated: (newStatus, reason) async {
            await _emergencyService.updateEmergencyStatus(
              caseId: caseModel.id,
              newStatus: newStatus,
              reason: reason,
              actor: 'Dr. Sarah Jenkins',
            );
            await _loadCases();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Case ${caseModel.id} status updated to ${newStatus.label}.')),
            );
          },
        );
      },
    );
  }

  void _openTransferModal(BuildContext context, DoctorEmergencyCaseFullModel caseModel) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return TransferEmergencyCaseModal(
          emergencyCase: caseModel,
          onTransferConfirmed: (transferInfo) async {
            await _emergencyService.transferEmergencyCase(
              caseId: caseModel.id,
              transferInfo: transferInfo,
            );
            await _loadCases();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Case ${caseModel.id} transferred to ${transferInfo.transferredToDepartment}.')),
            );
          },
        );
      },
    );
  }

  void _openResolveModal(BuildContext context, DoctorEmergencyCaseFullModel caseModel) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ResolveEmergencyCaseModal(
          emergencyCase: caseModel,
          onResolveConfirmed: (resolutionInfo) async {
            await _emergencyService.resolveEmergencyCase(
              caseId: caseModel.id,
              resolutionInfo: resolutionInfo,
            );
            await _loadCases();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Case ${caseModel.id} resolved (${resolutionInfo.disposition.label}).')),
            );
          },
        );
      },
    );
  }

  Future<void> _handleStartConsultation(DoctorEmergencyCaseFullModel caseModel) async {
    final consultationId = 'CON-EMR-${1000 + DateTime.now().millisecond}';
    await _emergencyService.startEmergencyConsultation(
      caseId: caseModel.id,
      consultationId: consultationId,
      doctorName: 'Dr. Sarah Jenkins',
    );
    await _loadCases();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emergency consultation $consultationId started.')),
    );
    Navigator.pushNamed(context, '/doctor-consultation');
  }

  Future<void> _handleAddNote(
    String caseId,
    EmergencyNoteType type,
    String content,
    bool isPrivate,
  ) async {
    final note = EmergencyNoteModel(
      id: 'NOTE-${DateTime.now().millisecondsSinceEpoch}',
      noteType: type,
      content: content,
      isInternalPrivate: isPrivate,
      author: 'Dr. Sarah Jenkins',
      createdAt: DateTime.now(),
    );
    await _emergencyService.addEmergencyNote(caseId: caseId, note: note);
    await _loadCases();
  }

  Future<void> _handleAddObservation(String caseId, EmergencyObservationsModel obs) async {
    await _emergencyService.addEmergencyObservation(caseId: caseId, obs: obs);
    await _loadCases();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _activeSummaryFilter = 'all';
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedDepartment = null;
      _selectedDoctor = null;
    });
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-appointments');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-patients');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-patient-profile');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/doctor-reports');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/doctor-prescriptions');
        break;
      case 6:
        // Already on Emergency Cases
        break;
      case 7:
        Navigator.pushReplacementNamed(context, '/doctor-consultation');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
    }
  }
}
