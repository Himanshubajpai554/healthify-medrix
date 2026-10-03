import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/followup_models.dart';
import '../services/doctor_followup_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/cancel_followup_modal.dart';
import 'widgets/complete_followup_modal.dart';
import 'widgets/create_followup_modal.dart';
import 'widgets/followup_calendar_view.dart';
import 'widgets/followup_detail_drawer.dart';
import 'widgets/followup_filter_toolbar.dart';
import 'widgets/followup_header.dart';
import 'widgets/followup_summary_cards.dart';
import 'widgets/followup_table_view.dart';
import 'widgets/overdue_followups_section.dart';
import 'widgets/reschedule_followup_modal.dart';
import 'widgets/todays_followups_section.dart';

class DoctorFollowUpsScreen extends StatefulWidget {
  final bool embedInDashboard;
  const DoctorFollowUpsScreen({
    super.key,
    this.embedInDashboard = false,
  });

  @override
  State<DoctorFollowUpsScreen> createState() => _DoctorFollowUpsScreenState();
}

class _DoctorFollowUpsScreenState extends State<DoctorFollowUpsScreen> {
  final DoctorFollowUpService _followUpService = DoctorFollowUpService();

  List<DoctorFollowUpFullModel> _allFollowUps = [];
  bool _isLoading = true;
  bool _isSidebarExpanded = true;
  bool _isCalendarView = false;

  // Search & Filter state
  String _searchQuery = '';
  FollowUpStatus? _selectedStatus;
  String? _selectedDepartment;
  FollowUpSortOption _selectedSort = FollowUpSortOption.soonest;

  // Selected Detail state
  DoctorFollowUpFullModel? _selectedFollowUp;

  @override
  void initState() {
    super.initState();
    _loadFollowUps();
  }

  Future<void> _loadFollowUps() async {
    setState(() => _isLoading = true);
    final list = await _followUpService.getFollowUps();
    if (mounted) {
      setState(() {
        _allFollowUps = list;
        _isLoading = false;
        if (_selectedFollowUp != null) {
          try {
            _selectedFollowUp = list.firstWhere((f) => f.id == _selectedFollowUp!.id);
          } catch (_) {
            _selectedFollowUp = list.isNotEmpty ? list.first : null;
          }
        }
      });
    }
  }

  List<DoctorFollowUpFullModel> get _filteredFollowUps {
    var result = List<DoctorFollowUpFullModel>.from(_allFollowUps);

    // Status Filter
    if (_selectedStatus != null) {
      result = result.where((f) => f.status == _selectedStatus).toList();
    }

    // Department Filter
    if (_selectedDepartment != null && _selectedDepartment != 'All') {
      result = result.where((f) => f.department == _selectedDepartment).toList();
    }

    // Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((f) {
        return f.patientName.toLowerCase().contains(q) ||
            f.patientId.toLowerCase().contains(q) ||
            f.id.toLowerCase().contains(q) ||
            f.phone.contains(q) ||
            f.reason.toLowerCase().contains(q) ||
            f.department.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    switch (_selectedSort) {
      case FollowUpSortOption.soonest:
        result.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
        break;
      case FollowUpSortOption.latest:
        result.sort((a, b) => b.followUpDate.compareTo(a.followUpDate));
        break;
      case FollowUpSortOption.patientName:
        result.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
    }

    return result;
  }

  List<DoctorFollowUpFullModel> get _todaysFollowUps {
    final now = DateTime.now();
    return _allFollowUps.where((f) {
      return f.status == FollowUpStatus.dueToday ||
          (f.followUpDate.year == now.year && f.followUpDate.month == now.month && f.followUpDate.day == now.day);
    }).toList();
  }

  List<DoctorFollowUpFullModel> get _overdueFollowUps {
    return _allFollowUps.where((f) => f.status == FollowUpStatus.overdue).toList();
  }

  List<String> get _availableDepartments {
    return _allFollowUps.map((f) => f.department).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    final metrics = _followUpService.getSummaryMetrics();

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
            // Desktop Left Sidebar
            if (isDesktop)
              DoctorSidebar(
                selectedNavIndex: 7, // Index 7 is Patient Follow-ups
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
                  // Doctor Top Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Patient Follow-ups',
                    subtitle: 'Schedule & Post-Care Management',
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
    final filtered = _filteredFollowUps;
    final isDrawerOpen = _selectedFollowUp != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Follow-ups Table View (Left Column)
        Expanded(
          flex: isDrawerOpen ? 3 : 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workspace Header
                FollowUpHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onClearSearch: () => setState(() => _searchQuery = ''),
                  onSchedulePressed: () => _openCreateModal(context),
                  onRefreshPressed: _loadFollowUps,
                  isCalendarView: _isCalendarView,
                  onToggleCalendarView: (val) => setState(() => _isCalendarView = val),
                ),
                const SizedBox(height: 20),

                // Operational Summary Cards
                FollowUpSummaryCards(
                  dueTodayCount: metrics['dueToday'] ?? 0,
                  upcomingCount: metrics['upcoming'] ?? 0,
                  overdueCount: metrics['overdue'] ?? 0,
                  completedThisWeekCount: metrics['completedThisWeek'] ?? 0,
                  selectedStatusFilter: _selectedStatus,
                  onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
                ),
                const SizedBox(height: 20),

                // Prominent Today's Follow-ups Section
                if (!_isCalendarView && _todaysFollowUps.isNotEmpty) ...[
                  TodaysFollowUpsSection(
                    todaysFollowUps: _todaysFollowUps,
                    onOpenFollowUp: (item) => setState(() => _selectedFollowUp = item),
                  ),
                  const SizedBox(height: 20),
                ],

                // Dedicated Overdue Follow-ups Section
                if (!_isCalendarView && _overdueFollowUps.isNotEmpty) ...[
                  OverdueFollowUpsSection(
                    overdueFollowUps: _overdueFollowUps,
                    onOpenPatient: (_) => Navigator.pushNamed(context, '/doctor-patient-profile'),
                    onReschedule: (item) => _openRescheduleModal(context, item),
                  ),
                  const SizedBox(height: 20),
                ],

                // Filter & Sort Toolbar
                FollowUpFilterToolbar(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (st) => setState(() => _selectedStatus = st),
                  selectedDepartment: _selectedDepartment,
                  onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
                  availableDepartments: _availableDepartments,
                  selectedSort: _selectedSort,
                  onSortChanged: (sort) => setState(() => _selectedSort = sort),
                  onResetFilters: _resetFilters,
                ),
                const SizedBox(height: 20),

                // Follow-ups Table View or Calendar View
                if (_isCalendarView)
                  FollowUpCalendarView(
                    followUps: filtered,
                    onSelectFollowUp: (item) => setState(() => _selectedFollowUp = item),
                  )
                else
                  FollowUpTableView(
                    followUps: filtered,
                    selectedFollowUpId: _selectedFollowUp?.id,
                    onSelectFollowUp: (item) => setState(() => _selectedFollowUp = item),
                    onOpenPatient: (_) => Navigator.pushNamed(context, '/doctor-patient-profile'),
                    onReschedule: (item) => _openRescheduleModal(context, item),
                    onMoreActions: (item) => _showMoreActionsMenu(context, item),
                  ),
              ],
            ),
          ),
        ),

        // Desktop Right Side Contextual Detail Drawer
        if (isDrawerOpen)
          SizedBox(
            width: 520,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: FollowUpDetailDrawer(
                followUp: _selectedFollowUp!,
                onClose: () => setState(() => _selectedFollowUp = null),
                onOpenPatient: () => Navigator.pushNamed(context, '/doctor-patient-profile'),
                onReschedule: () => _openRescheduleModal(context, _selectedFollowUp!),
                onMarkCompleted: () => _openCompleteModal(context, _selectedFollowUp!),
                onCancelFollowUp: () => _openCancelModal(context, _selectedFollowUp!),
                onViewConsultation: () => Navigator.pushNamed(context, '/doctor-consultation'),
                onViewReports: () => Navigator.pushNamed(context, '/doctor-reports'),
                onViewPrescriptions: () => Navigator.pushNamed(context, '/doctor-prescriptions'),
                onScheduleAppointment: () => Navigator.pushNamed(context, '/doctor-appointments'),
                onAddNote: (type, content) => _handleAddNote(_selectedFollowUp!.id, type, content),
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
    final filtered = _filteredFollowUps;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FollowUpHeader(
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onClearSearch: () => setState(() => _searchQuery = ''),
            onSchedulePressed: () => _openCreateModal(context),
            onRefreshPressed: _loadFollowUps,
            isCalendarView: _isCalendarView,
            onToggleCalendarView: (val) => setState(() => _isCalendarView = val),
          ),
          const SizedBox(height: 16),

          FollowUpSummaryCards(
            dueTodayCount: metrics['dueToday'] ?? 0,
            upcomingCount: metrics['upcoming'] ?? 0,
            overdueCount: metrics['overdue'] ?? 0,
            completedThisWeekCount: metrics['completedThisWeek'] ?? 0,
            selectedStatusFilter: _selectedStatus,
            onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
          ),
          const SizedBox(height: 16),

          if (!_isCalendarView && _todaysFollowUps.isNotEmpty) ...[
            TodaysFollowUpsSection(
              todaysFollowUps: _todaysFollowUps,
              onOpenFollowUp: (item) => _openMobileDetailBottomSheet(context, item),
            ),
            const SizedBox(height: 16),
          ],

          if (!_isCalendarView && _overdueFollowUps.isNotEmpty) ...[
            OverdueFollowUpsSection(
              overdueFollowUps: _overdueFollowUps,
              onOpenPatient: (_) => Navigator.pushNamed(context, '/doctor-patient-profile'),
              onReschedule: (item) => _openRescheduleModal(context, item),
            ),
            const SizedBox(height: 16),
          ],

          FollowUpFilterToolbar(
            selectedStatus: _selectedStatus,
            onStatusChanged: (st) => setState(() => _selectedStatus = st),
            selectedDepartment: _selectedDepartment,
            onDepartmentChanged: (dept) => setState(() => _selectedDepartment = dept),
            availableDepartments: _availableDepartments,
            selectedSort: _selectedSort,
            onSortChanged: (sort) => setState(() => _selectedSort = sort),
            onResetFilters: _resetFilters,
          ),
          const SizedBox(height: 16),

          if (_isCalendarView)
            FollowUpCalendarView(
              followUps: filtered,
              onSelectFollowUp: (item) => _openMobileDetailBottomSheet(context, item),
            )
          else
            FollowUpTableView(
              followUps: filtered,
              selectedFollowUpId: _selectedFollowUp?.id,
              onSelectFollowUp: (item) => _openMobileDetailBottomSheet(context, item),
              onOpenPatient: (_) => Navigator.pushNamed(context, '/doctor-patient-profile'),
              onReschedule: (item) => _openRescheduleModal(context, item),
              onMoreActions: (item) => _showMoreActionsMenu(context, item),
            ),
        ],
      ),
    );
  }

  void _openMobileDetailBottomSheet(BuildContext context, DoctorFollowUpFullModel item) {
    setState(() => _selectedFollowUp = item);
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
            child: FollowUpDetailDrawer(
              followUp: item,
              onClose: () => Navigator.of(bContext).pop(),
              onOpenPatient: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-patient-profile');
              },
              onReschedule: () {
                Navigator.of(bContext).pop();
                _openRescheduleModal(context, item);
              },
              onMarkCompleted: () {
                Navigator.of(bContext).pop();
                _openCompleteModal(context, item);
              },
              onCancelFollowUp: () {
                Navigator.of(bContext).pop();
                _openCancelModal(context, item);
              },
              onViewConsultation: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-consultation');
              },
              onViewReports: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-reports');
              },
              onViewPrescriptions: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-prescriptions');
              },
              onScheduleAppointment: () {
                Navigator.of(bContext).pop();
                Navigator.pushNamed(context, '/doctor-appointments');
              },
              onAddNote: (type, content) => _handleAddNote(item.id, type, content),
            ),
          ),
        );
      },
    );
  }

  void _openCreateModal(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreateFollowUpModal(
          onCreateSubmitted: (newFollowUp) async {
            await _followUpService.createFollowUp(newFollowUp);
            await _loadFollowUps();
            if (!mounted) return;
            setState(() => _selectedFollowUp = newFollowUp);
            messenger.showSnackBar(
              SnackBar(content: Text('Follow-up ${newFollowUp.id} scheduled successfully.')),
            );
          },
        );
      },
    );
  }

  void _openRescheduleModal(BuildContext context, DoctorFollowUpFullModel item) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return RescheduleFollowUpModal(
          followUp: item,
          onRescheduleConfirmed: (newDate, newTimeSlot, reason) async {
            await _followUpService.rescheduleFollowUp(
              id: item.id,
              newDate: newDate,
              newTimeSlot: newTimeSlot,
              reason: reason,
              changedBy: 'Dr. Sarah Jenkins',
            );
            await _loadFollowUps();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Follow-up ${item.id} rescheduled.')),
            );
          },
        );
      },
    );
  }

  void _openCompleteModal(BuildContext context, DoctorFollowUpFullModel item) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CompleteFollowUpModal(
          followUp: item,
          onCompleteConfirmed: (completionNote) async {
            await _followUpService.completeFollowUp(
              id: item.id,
              completionNote: completionNote,
              completedBy: 'Dr. Sarah Jenkins',
            );
            await _loadFollowUps();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Follow-up ${item.id} marked as completed.')),
            );
          },
        );
      },
    );
  }

  void _openCancelModal(BuildContext context, DoctorFollowUpFullModel item) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CancelFollowUpModal(
          followUp: item,
          onCancelConfirmed: (cancellationReason) async {
            await _followUpService.cancelFollowUp(
              id: item.id,
              reason: cancellationReason,
              cancelledBy: 'Dr. Sarah Jenkins',
            );
            await _loadFollowUps();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Follow-up ${item.id} cancelled.')),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAddNote(String id, FollowUpNoteType type, String content) async {
    final note = FollowUpNoteModel(
      id: 'FN-${DateTime.now().millisecondsSinceEpoch}',
      noteType: type,
      content: content,
      author: 'Dr. Sarah Jenkins',
      createdAt: DateTime.now(),
    );
    await _followUpService.addFollowUpNote(id: id, note: note);
    await _loadFollowUps();
  }

  void _showMoreActionsMenu(BuildContext context, DoctorFollowUpFullModel item) {
    showModalBottomSheet(
      context: context,
      builder: (bContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: const Text('Open Patient Profile'),
                onTap: () {
                  Navigator.pop(bContext);
                  Navigator.pushNamed(context, '/doctor-patient-profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.update_rounded),
                title: const Text('Reschedule Follow-up'),
                onTap: () {
                  Navigator.pop(bContext);
                  _openRescheduleModal(context, item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('Mark Completed'),
                onTap: () {
                  Navigator.pop(bContext);
                  _openCompleteModal(context, item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                title: const Text('Cancel Follow-up', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(bContext);
                  _openCancelModal(context, item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedDepartment = null;
      _selectedSort = FollowUpSortOption.soonest;
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
        Navigator.pushReplacementNamed(context, '/doctor-emergency');
        break;
      case 7:
        // Already on Patient Follow-ups
        break;
      default:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
    }
  }
}
