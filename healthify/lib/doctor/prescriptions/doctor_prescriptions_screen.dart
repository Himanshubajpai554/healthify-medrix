import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/prescription_models.dart';
import '../services/doctor_prescription_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/cancel_prescription_dialog.dart';
import 'widgets/create_prescription_modal.dart';
import 'widgets/prescription_detail_drawer.dart';
import 'widgets/prescription_print_modal.dart';
import 'widgets/prescriptions_filter_toolbar.dart';
import 'widgets/prescriptions_header.dart';
import 'widgets/prescriptions_summary_cards.dart';
import 'widgets/prescriptions_table_view.dart';

class DoctorPrescriptionsScreen extends StatefulWidget {
  final bool embedInDashboard;
  const DoctorPrescriptionsScreen({
    super.key,
    this.embedInDashboard = false,
  });

  @override
  State<DoctorPrescriptionsScreen> createState() => _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState extends State<DoctorPrescriptionsScreen> {
  final DoctorPrescriptionService _prescriptionService = DoctorPrescriptionService();

  List<DoctorPrescriptionFullModel> _allPrescriptions = [];
  bool _isLoading = true;
  bool _isSidebarExpanded = true;

  // Filter & Search states
  String _searchQuery = '';
  PrescriptionStatus? _selectedStatus;
  String? _selectedDepartment;
  String? _selectedPatientId;
  PrescriptionSortOption _selectedSort = PrescriptionSortOption.newest;

  // Selection state
  DoctorPrescriptionFullModel? _selectedPrescription;
  PatientMedicationHistoryModel? _patientMedicationHistory;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    final list = await _prescriptionService.getPrescriptions();
    if (mounted) {
      setState(() {
        _allPrescriptions = list;
        _isLoading = false;
        if (_selectedPrescription != null) {
          try {
            _selectedPrescription = list.firstWhere((p) => p.id == _selectedPrescription!.id);
          } catch (_) {}
        }
      });
      if (_selectedPrescription != null) {
        _loadPatientHistory(_selectedPrescription!.patientId);
      }
    }
  }

  Future<void> _loadPatientHistory(String patientId) async {
    final history = await _prescriptionService.getPatientMedicationHistory(patientId);
    if (mounted) {
      setState(() => _patientMedicationHistory = history);
    }
  }

  List<DoctorPrescriptionFullModel> get _filteredPrescriptions {
    var result = List<DoctorPrescriptionFullModel>.from(_allPrescriptions);

    // Status Filter
    if (_selectedStatus != null) {
      result = result.where((p) => p.status == _selectedStatus).toList();
    }

    // Department Filter
    if (_selectedDepartment != null) {
      result = result.where((p) => p.department == _selectedDepartment).toList();
    }

    // Patient Filter
    if (_selectedPatientId != null) {
      result = result.where((p) => p.patientId == _selectedPatientId).toList();
    }

    // Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        final matchesMed = p.medicines.any((m) => m.medicineName.toLowerCase().contains(q));
        return p.id.toLowerCase().contains(q) ||
            p.patientName.toLowerCase().contains(q) ||
            p.patientId.toLowerCase().contains(q) ||
            p.department.toLowerCase().contains(q) ||
            matchesMed;
      }).toList();
    }

    // Sort
    switch (_selectedSort) {
      case PrescriptionSortOption.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case PrescriptionSortOption.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case PrescriptionSortOption.patientName:
        result.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
    }

    return result;
  }

  List<String> get _availableDepartments {
    return _allPrescriptions.map((p) => p.department).toSet().toList();
  }

  List<Map<String, String>> get _availablePatients {
    final map = <String, String>{};
    for (final p in _allPrescriptions) {
      map[p.patientId] = p.patientName;
    }
    return map.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    final today = DateTime.now();
    final metrics = <String, int>{
      'total': _allPrescriptions.length,
      'createdToday': _allPrescriptions.where((p) => p.date.year == today.year && p.date.month == today.month && p.date.day == today.day).length,
      'active': _allPrescriptions.where((p) => p.status == PrescriptionStatus.active).length,
      'drafts': _allPrescriptions.where((p) => p.status == PrescriptionStatus.draft).length,
    };

    if (widget.embedInDashboard) {
      if (isDesktop) {
        return _buildDesktopLayout(context, isDark, metrics);
      }
      return _buildMobileTabletLayout(context, isDark, metrics, isMobile);
    }

    return Scaffold(
      backgroundColor: isDark ? HealthifyGlassTheme.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Row(
          children: [
            // Desktop Sidebar
            if (isDesktop)
              DoctorSidebar(
                selectedNavIndex: 5, // Index 5 is Prescriptions
                onNavItemSelected: (index) => _navigateToIndex(context, index),
                isExpanded: _isSidebarExpanded,
                onToggleExpand: () {
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                },
                availabilityStatus: DoctorAvailability.available,
                onLogout: () => Navigator.pushReplacementNamed(context, '/portal-select'),
                onRoleSwitcherTap: () => Navigator.pushReplacementNamed(context, '/portal-select'),
              ),

            // Main Content Body
            Expanded(
              child: Column(
                children: [
                  // Doctor Header Top Navigation
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Prescription Workspace',
                    subtitle: 'Rx Generation & Order History',
                    availabilityStatus: DoctorAvailability.available,
                    onAvailabilityChanged: (_) {},
                    onNotificationTap: () {},
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {},
                    unreadNotificationsCount: 3,
                  ),

                  // Prescriptions Workspace Content
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
    final filtered = _filteredPrescriptions;
    final isDrawerOpen = _selectedPrescription != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Reports Area (Left / Full width)
        Expanded(
          flex: isDrawerOpen ? 3 : 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                PrescriptionsHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onClearSearch: () => setState(() => _searchQuery = ''),
                  onCreatePrescriptionPressed: () => _openCreateModal(context),
                  onRefreshPressed: _loadPrescriptions,
                ),
                const SizedBox(height: 20),

                // Summary Cards
                PrescriptionsSummaryCards(
                  totalCount: metrics['total'] ?? 0,
                  createdTodayCount: metrics['createdToday'] ?? 0,
                  activeCount: metrics['active'] ?? 0,
                  draftsCount: metrics['drafts'] ?? 0,
                  selectedStatusFilter: _selectedStatus,
                  onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
                ),
                const SizedBox(height: 20),

                // Filter Toolbar
                PrescriptionsFilterToolbar(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  selectedDepartment: _selectedDepartment,
                  onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
                  availableDepartments: _availableDepartments,
                  selectedPatientId: _selectedPatientId,
                  onPatientChanged: (pid) => setState(() => _selectedPatientId = pid),
                  availablePatients: _availablePatients,
                  selectedSort: _selectedSort,
                  onSortChanged: (sort) => setState(() => _selectedSort = sort),
                  onResetFilters: _resetFilters,
                ),
                const SizedBox(height: 20),

                // Prescriptions Data Table
                PrescriptionsTableView(
                  prescriptions: filtered,
                  selectedPrescriptionId: _selectedPrescription?.id,
                  onSelectPrescription: (rx) {
                    setState(() => _selectedPrescription = rx);
                    _loadPatientHistory(rx.patientId);
                  },
                  onEditPrescription: (rx) => _openCreateModal(context, existingDraft: rx),
                  onDuplicatePrescription: (rx) => _handleDuplicate(context, rx),
                  onCancelPrescription: (rx) => _openCancelDialog(context, rx),
                ),
              ],
            ),
          ),
        ),

        // Right Side Detail Drawer
        if (isDrawerOpen)
          SizedBox(
            width: 540,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                    width: 1.2,
                  ),
                ),
              ),
              child: PrescriptionDetailDrawer(
                prescription: _selectedPrescription!,
                medicationHistory: _patientMedicationHistory,
                onClose: () => setState(() => _selectedPrescription = null),
                onPrint: () => _openPrintModal(context, _selectedPrescription!),
                onDownload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading PDF for ${_selectedPrescription!.id}...')),
                  );
                },
                onDuplicate: () => _handleDuplicate(context, _selectedPrescription!),
                onCancelPrescription: () => _openCancelDialog(context, _selectedPrescription!),
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
    final filtered = _filteredPrescriptions;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PrescriptionsHeader(
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onClearSearch: () => setState(() => _searchQuery = ''),
            onCreatePrescriptionPressed: () => _openCreateModal(context),
            onRefreshPressed: _loadPrescriptions,
          ),
          const SizedBox(height: 16),

          // Summary Cards
          PrescriptionsSummaryCards(
            totalCount: metrics['total'] ?? 0,
            createdTodayCount: metrics['createdToday'] ?? 0,
            activeCount: metrics['active'] ?? 0,
            draftsCount: metrics['drafts'] ?? 0,
            selectedStatusFilter: _selectedStatus,
            onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
          ),
          const SizedBox(height: 16),

          // Filter Toolbar
          PrescriptionsFilterToolbar(
            selectedStatus: _selectedStatus,
            onStatusChanged: (st) => setState(() => _selectedStatus = st),
            selectedDepartment: _selectedDepartment,
            onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
            availableDepartments: _availableDepartments,
            selectedPatientId: _selectedPatientId,
            onPatientChanged: (pid) => setState(() => _selectedPatientId = pid),
            availablePatients: _availablePatients,
            selectedSort: _selectedSort,
            onSortChanged: (sort) => setState(() => _selectedSort = sort),
            onResetFilters: _resetFilters,
          ),
          const SizedBox(height: 16),

          // Cards View
          PrescriptionsTableView(
            prescriptions: filtered,
            selectedPrescriptionId: _selectedPrescription?.id,
            onSelectPrescription: (rx) {
              setState(() => _selectedPrescription = rx);
              _loadPatientHistory(rx.patientId);
              _showMobileDetailBottomSheet(context, rx);
            },
            onEditPrescription: (rx) => _openCreateModal(context, existingDraft: rx),
            onDuplicatePrescription: (rx) => _handleDuplicate(context, rx),
            onCancelPrescription: (rx) => _openCancelDialog(context, rx),
          ),
        ],
      ),
    );
  }

  void _showMobileDetailBottomSheet(BuildContext context, DoctorPrescriptionFullModel rx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: PrescriptionDetailDrawer(
              prescription: rx,
              medicationHistory: _patientMedicationHistory,
              onClose: () => Navigator.pop(context),
              onPrint: () {
                Navigator.pop(context);
                _openPrintModal(context, rx);
              },
              onDownload: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading PDF for ${rx.id}...')),
                );
              },
              onDuplicate: () {
                Navigator.pop(context);
                _handleDuplicate(context, rx);
              },
              onCancelPrescription: () {
                Navigator.pop(context);
                _openCancelDialog(context, rx);
              },
            ),
          ),
        );
      },
    );
  }

  void _openCreateModal(BuildContext context, {DoctorPrescriptionFullModel? existingDraft}) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreatePrescriptionModal(
          existingDraft: existingDraft,
          onSaveComplete: (rx, isDraft) async {
            if (isDraft) {
              if (existingDraft != null) {
                await _prescriptionService.updatePrescriptionDraft(rx);
              } else {
                await _prescriptionService.createPrescriptionDraft(rx);
              }
            } else {
              if (existingDraft != null) {
                await _prescriptionService.updatePrescriptionDraft(rx);
                await _prescriptionService.activatePrescription(rx.id);
              } else {
                final created = await _prescriptionService.createPrescriptionDraft(rx);
                await _prescriptionService.activatePrescription(created.id);
              }
            }
            await _loadPrescriptions();
            if (!mounted) return;
            setState(() => _selectedPrescription = rx);
            messenger.showSnackBar(
              SnackBar(content: Text(isDraft ? 'Prescription ${rx.id} saved as draft.' : 'Prescription ${rx.id} activated successfully.')),
            );
          },
        );
      },
    );
  }

  void _handleDuplicate(BuildContext context, DoctorPrescriptionFullModel rx) async {
    final messenger = ScaffoldMessenger.of(context);
    final duplicate = await _prescriptionService.duplicatePrescription(
      sourcePrescriptionId: rx.id,
      doctorName: 'Dr. Sarah Jenkins',
    );
    await _loadPrescriptions();
    if (!mounted) return;
    setState(() => _selectedPrescription = duplicate);
    messenger.showSnackBar(
      SnackBar(content: Text('Duplicated ${rx.id} as new draft ${duplicate.id}.')),
    );
  }

  void _openCancelDialog(BuildContext context, DoctorPrescriptionFullModel rx) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CancelPrescriptionDialog(
          prescription: rx,
          onConfirmCancel: (reason) async {
            await _prescriptionService.cancelPrescription(
              prescriptionId: rx.id,
              reason: reason,
              doctorName: 'Dr. Sarah Jenkins',
            );
            await _loadPrescriptions();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Prescription ${rx.id} cancelled.')),
            );
          },
        );
      },
    );
  }

  void _openPrintModal(BuildContext context, DoctorPrescriptionFullModel rx) {
    showDialog(
      context: context,
      builder: (context) {
        return PrescriptionPrintModal(prescription: rx);
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedDepartment = null;
      _selectedPatientId = null;
      _selectedSort = PrescriptionSortOption.newest;
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
        // Already on Prescriptions
        break;
      default:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
    }
  }
}
