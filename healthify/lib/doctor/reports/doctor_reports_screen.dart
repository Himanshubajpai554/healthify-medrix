import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/reports_models.dart';
import '../services/doctor_reports_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/attach_report_modal.dart';
import 'widgets/report_detail_drawer.dart';
import 'widgets/reports_filter_toolbar.dart';
import 'widgets/reports_header.dart';
import 'widgets/reports_summary_cards.dart';
import 'widgets/reports_table_view.dart';
import 'widgets/upload_report_modal.dart';

class DoctorReportsScreen extends StatefulWidget {
  final bool embedInDashboard;
  const DoctorReportsScreen({
    super.key,
    this.embedInDashboard = false,
  });

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  final DoctorReportsService _reportsService = DoctorReportsService();

  List<DoctorReportFullModel> _allReports = [];
  bool _isLoading = true;
  bool _isSidebarExpanded = true;

  // Filter & Search states
  String _searchQuery = '';
  ReportCategory _selectedCategory = ReportCategory.all;
  ReportStatus? _selectedStatus;
  String? _selectedDepartment;
  ReportSortOption _selectedSort = ReportSortOption.newest;

  // Drawer / Selection state
  DoctorReportFullModel? _selectedReport;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await _reportsService.getReports();
    if (mounted) {
      setState(() {
        _allReports = reports;
        _isLoading = false;
        // Keep selected report refreshed if open
        if (_selectedReport != null) {
          try {
            _selectedReport = reports.firstWhere((r) => r.id == _selectedReport!.id);
          } catch (_) {}
        }
      });
    }
  }

  List<DoctorReportFullModel> get _filteredReports {
    var result = List<DoctorReportFullModel>.from(_allReports);

    // Category Filter
    if (_selectedCategory != ReportCategory.all) {
      result = result.where((r) => r.category == _selectedCategory).toList();
    }

    // Status Filter
    if (_selectedStatus != null) {
      result = result.where((r) => r.status == _selectedStatus).toList();
    }

    // Department Filter
    if (_selectedDepartment != null) {
      result = result.where((r) => r.department == _selectedDepartment).toList();
    }

    // Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.id.toLowerCase().contains(q) ||
            r.patientName.toLowerCase().contains(q) ||
            r.patientId.toLowerCase().contains(q) ||
            r.department.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    switch (_selectedSort) {
      case ReportSortOption.newest:
        result.sort((a, b) => b.uploadedDate.compareTo(a.uploadedDate));
        break;
      case ReportSortOption.oldest:
        result.sort((a, b) => a.uploadedDate.compareTo(b.uploadedDate));
        break;
      case ReportSortOption.patientName:
        result.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
      case ReportSortOption.pendingFirst:
        result.sort((a, b) {
          if (a.status == ReportStatus.pendingReview && b.status != ReportStatus.pendingReview) {
            return -1;
          }
          if (b.status == ReportStatus.pendingReview && a.status != ReportStatus.pendingReview) {
            return 1;
          }
          return b.uploadedDate.compareTo(a.uploadedDate);
        });
        break;
    }

    return result;
  }

  List<String> get _availableDepartments {
    return _allReports.map((r) => r.department).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    final today = DateTime.now();
    final metrics = <String, int>{
      'total': _allReports.length,
      'pending': _allReports.where((report) => report.status == ReportStatus.pendingReview).length,
      'reviewedToday': _allReports.where((report) => report.reviewedDate != null && report.reviewedDate!.year == today.year && report.reviewedDate!.month == today.month && report.reviewedDate!.day == today.day).length,
      'newReports': _allReports.where((report) => report.status == ReportStatus.newReport).length,
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
            // Desktop Left Sidebar
            if (isDesktop)
              DoctorSidebar(
                selectedNavIndex: 4, // Index 4 is Reports
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
                  // Doctor Top Navigation Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Patient Medical Reports',
                    subtitle: 'Document & Lab Review Workspace',
                    availabilityStatus: DoctorAvailability.available,
                    onAvailabilityChanged: (_) {},
                    onNotificationTap: () {},
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {},
                    unreadNotificationsCount: 3,
                  ),

                  // Reports Workspace Content
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
    final filtered = _filteredReports;
    final isDrawerOpen = _selectedReport != null;

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
                ReportsHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onClearSearch: () => setState(() => _searchQuery = ''),
                  onUploadPressed: () => _openUploadModal(context),
                  onRefreshPressed: _loadReports,
                ),
                const SizedBox(height: 20),

                // Metrics Summary Cards
                ReportsSummaryCards(
                  totalCount: metrics['total'] ?? 0,
                  pendingCount: metrics['pending'] ?? 0,
                  reviewedTodayCount: metrics['reviewedToday'] ?? 0,
                  newCount: metrics['newReports'] ?? 0,
                  selectedStatusFilter: _selectedStatus,
                  onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
                ),
                const SizedBox(height: 20),

                // Filter & Sort Toolbar
                ReportsFilterToolbar(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
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

                // Reports Table View
                ReportsTableView(
                  reports: filtered,
                  selectedReportId: _selectedReport?.id,
                  onSelectReport: (r) => setState(() => _selectedReport = r),
                  onAttachReport: (r) => _openAttachModal(context, r),
                ),
              ],
            ),
          ),
        ),

        // Desktop Right Side Detail Drawer
        if (isDrawerOpen)
          SizedBox(
            width: 520,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                    width: 1.2,
                  ),
                ),
              ),
              child: ReportDetailDrawer(
                report: _selectedReport!,
                allPatientReports: _allReports,
                onClose: () => setState(() => _selectedReport = null),
                onSwitchReport: (r) => setState(() => _selectedReport = r),
                onMarkReviewed: _handleMarkReviewed,
                onSaveNote: _handleSaveNote,
                onAttachToConsultation: () => _openAttachModal(context, _selectedReport!),
                onDownloadReportFile: _downloadReportFile,
                onTogglePatientSharing: _togglePatientSharing,
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
    final filtered = _filteredReports;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ReportsHeader(
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onClearSearch: () => setState(() => _searchQuery = ''),
            onUploadPressed: () => _openUploadModal(context),
            onRefreshPressed: _loadReports,
          ),
          const SizedBox(height: 16),

          // Metrics Summary Cards
          ReportsSummaryCards(
            totalCount: metrics['total'] ?? 0,
            pendingCount: metrics['pending'] ?? 0,
            reviewedTodayCount: metrics['reviewedToday'] ?? 0,
            newCount: metrics['newReports'] ?? 0,
            selectedStatusFilter: _selectedStatus,
            onStatusFilterSelected: (st) => setState(() => _selectedStatus = st),
          ),
          const SizedBox(height: 16),

          // Filter Toolbar
          ReportsFilterToolbar(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
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

          // Reports Table / Cards View
          ReportsTableView(
            reports: filtered,
            selectedReportId: _selectedReport?.id,
            onSelectReport: (r) {
              setState(() => _selectedReport = r);
              _showMobileDetailBottomSheet(context, r);
            },
            onAttachReport: (r) => _openAttachModal(context, r),
          ),
        ],
      ),
    );
  }

  void _showMobileDetailBottomSheet(BuildContext context, DoctorReportFullModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: ReportDetailDrawer(
              report: report,
              allPatientReports: _allReports,
              onClose: () => Navigator.pop(context),
              onSwitchReport: (r) {
                Navigator.pop(context);
                setState(() => _selectedReport = r);
                _showMobileDetailBottomSheet(context, r);
              },
              onMarkReviewed: (id, note) {
                _handleMarkReviewed(id, note);
                Navigator.pop(context);
              },
              onSaveNote: _handleSaveNote,
              onAttachToConsultation: () {
                Navigator.pop(context);
                _openAttachModal(context, report);
              },
              onDownloadReportFile: _downloadReportFile,
              onTogglePatientSharing: _togglePatientSharing,
            ),
          ),
        );
      },
    );
  }

  void _handleMarkReviewed(String reportId, String reviewNote) async {
    await _reportsService.markAsReviewed(
      reportId: reportId,
      reviewNotes: reviewNote,
      doctorName: 'Dr. Sarah Jenkins',
    );
    await _loadReports();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report $reportId marked as reviewed.')),
      );
    }
  }

  Future<void> _downloadReportFile(String reportId) async {
    try {
      final file = await _reportsService.downloadReportFile(reportId);
      await FilePicker.saveFile(
        fileName: file.fileName,
        bytes: file.bytes,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download report file: $error')),
      );
    }
  }

  Future<void> _togglePatientSharing(String reportId, bool isShared) async {
    try {
      await _reportsService.setPatientSharing(
        reportId: reportId,
        isShared: isShared,
      );
      await _loadReports();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isShared
              ? 'Reviewed report released to the linked patient account.'
              : 'Patient access to this report was revoked.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update patient sharing: $error')),
      );
    }
  }

  void _handleSaveNote(String reportId, String noteText, bool isPrivate) async {
    await _reportsService.addDoctorNote(
      reportId: reportId,
      noteText: noteText,
      isPrivate: isPrivate,
    );
    await _loadReports();
  }

  void _openUploadModal(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return UploadReportModal(
          onUploadComplete: (newReport, file) async {
            await _reportsService.uploadReport(newReport, file);
            await _loadReports();
            if (!mounted) return;
            setState(() => _selectedReport = newReport);
            messenger.showSnackBar(
              SnackBar(content: Text('Report ${newReport.id} indexed successfully.')),
            );
          },
        );
      },
    );
  }

  void _openAttachModal(BuildContext context, DoctorReportFullModel report) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AttachReportModal(
          report: report,
          onAttachConfirmed: (consultationId) async {
            await _reportsService.attachToConsultation(
              reportId: report.id,
              consultationId: consultationId,
              doctorName: 'Dr. Sarah Jenkins',
            );
            await _loadReports();
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Report ${report.id} attached to consultation $consultationId.')),
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = ReportCategory.all;
      _selectedStatus = null;
      _selectedDepartment = null;
      _selectedSort = ReportSortOption.newest;
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
        // Already on Reports
        break;
      case 5:
        // Prescriptions / Consultation
        Navigator.pushReplacementNamed(context, '/doctor-consultation');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
    }
  }
}
