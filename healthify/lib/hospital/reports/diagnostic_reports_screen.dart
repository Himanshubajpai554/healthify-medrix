import 'package:flutter/material.dart';
import '../../core/data/mock/mock_prescription_repository.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/data/mock/mock_report_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/prescription_model.dart';
import '../../core/models/report_model.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/prescription_service.dart';
import '../../core/services/report_service.dart';
import '../../core/widgets/medrix_empty_state.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class DiagnosticReportsScreen extends StatefulWidget {
  final UserRole initialRole;

  const DiagnosticReportsScreen({
    super.key,
    this.initialRole = UserRole.hospitalAdmin,
  });

  @override
  State<DiagnosticReportsScreen> createState() => _DiagnosticReportsScreenState();
}

class _DiagnosticReportsScreenState extends State<DiagnosticReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReportService _reportService;
  late PrescriptionService _prescriptionService;

  late UserRole _currentRole;
  bool _isLoading = true;
  String? _errorMessage;

  // Search and Filter State
  String _reportSearch = '';
  ReportType? _selectedReportType;
  ReportVerificationStatus? _selectedVerificationStatus;
  bool _criticalOnly = false;
  final bool? _releasedFilter = null;

  String _prescriptionSearch = '';
  final PrescriptionStatus? _selectedPrescriptionStatus = null;
  final PharmacyFulfillmentStatus? _selectedFulfillmentStatus = null;

  List<DiagnosticReport> _reports = [];
  List<PrescriptionIndex> _prescriptions = [];
  List<DocumentActivity> _activities = [];

  DiagnosticReport? _selectedReport;
  PrescriptionIndex? _selectedPrescription;

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
    _currentRole = widget.initialRole;
    _tabController = TabController(length: 3, vsync: this);
    _reportService = ReportService(reportRepository: RepositoryContainer.instance.reportRepository);
    _prescriptionService = PrescriptionService(prescriptionRepository: RepositoryContainer.instance.prescriptionRepository);
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
      final reports = await _reportService.getReports(
        query: ReportQuery(
          searchQuery: _reportSearch.isEmpty ? null : _reportSearch,
          reportType: _selectedReportType,
          verificationStatus: _selectedVerificationStatus,
          isCritical: _criticalOnly ? true : null,
          releasedToPatient: _releasedFilter,
        ),
      );

      final prescriptions = await _prescriptionService.getPrescriptions(
        query: PrescriptionQuery(
          searchQuery: _prescriptionSearch.isEmpty ? null : _prescriptionSearch,
          status: _selectedPrescriptionStatus,
          fulfillmentStatus: _selectedFulfillmentStatus,
        ),
      );

      final activities = <DocumentActivity>[];
      for (var r in reports) {
        final acts = await _reportService.getReportActivity(r.id);
        activities.addAll(acts);
      }

      if (mounted) {
        setState(() {
          _reports = reports;
          _prescriptions = prescriptions;
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load clinical document repositories: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Verification Workflows
  Future<void> _verifyReport(DiagnosticReport report) async {
    if (!PermissionService.hasPermission(_currentRole, Permission.verifyReport)) {
      _showPermissionDeniedDialog('Only authorized medical doctors can verify diagnostic reports.');
      return;
    }

    try {
      await _reportService.verifyReport(report.id, 'DOC1');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report successfully verified by Dr. Sarah Connor'),
            backgroundColor: HealthifyGlassTheme.primaryTeal,
          ),
        );
      }
      _loadData();
      if (_selectedReport?.id == report.id) {
        final updated = await _reportService.getReportById(report.id);
        if (mounted) {
          setState(() => _selectedReport = updated);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Verification failed: $e');
    }
  }

  Future<void> _rejectReport(DiagnosticReport report) async {
    if (!PermissionService.hasPermission(_currentRole, Permission.rejectReport)) {
      _showPermissionDeniedDialog('Only authorized medical doctors can reject diagnostic reports.');
      return;
    }

    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Diagnostic Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide reason for return/correction request:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Insufficient sample, unreadable imaging trace',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        await _reportService.rejectReport(report.id, 'DOC1', reasonController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report rejected and sent for correction.'),
              backgroundColor: Colors.deepOrange,
            ),
          );
        }
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Rejection failed: $e');
      }
    }
  }

  Future<void> _releaseReport(DiagnosticReport report) async {
    if (!PermissionService.hasPermission(_currentRole, Permission.releaseReport)) {
      _showPermissionDeniedDialog('Only authorized clinical staff can release reports to the patient portal.');
      return;
    }

    try {
      await _reportService.releaseReportToPatient(report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report released to patient mobile application.'),
            backgroundColor: HealthifyGlassTheme.primaryTeal,
          ),
        );
      }
      _loadData();
      if (_selectedReport?.id == report.id) {
        final updated = await _reportService.getReportById(report.id);
        if (mounted) {
          setState(() => _selectedReport = updated);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Release failed: $e');
    }
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Clinical Authorization Required'),
          ],
        ),
        content: Text(
          '$message\n\nCurrent Active Role: ${_currentRole.name.toUpperCase()}\n\nHospital Administrative users cannot alter or sign clinical records.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      body: Stack(
        children: [
          AnimatedPulseBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark, isDesktop),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: HealthifyGlassTheme.primaryTeal,
                    labelColor: HealthifyGlassTheme.primaryTeal,
                    unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
                    tabs: const [
                      Tab(icon: Icon(Icons.folder_shared_rounded), text: 'Diagnostic Reports'),
                      Tab(icon: Icon(Icons.medication_rounded), text: 'Prescription Index'),
                      Tab(icon: Icon(Icons.history_rounded), text: 'Document Activity Trail'),
                    ],
                  ),
                Expanded(
                  child: _isLoading
                      ? const MedrixLoadingState(message: 'Loading clinical document repository...')
                      : _errorMessage != null
                          ? MedrixErrorState(
                              errorMessage: _errorMessage!,
                              onRetry: _loadData,
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildReportsTab(isDark, isDesktop),
                                _buildPrescriptionsTab(isDark, isDesktop),
                                _buildActivityTab(isDark),
                              ],
                            ),
                ),
                ],
              ),
            ),
          ),
          if (_selectedReport != null) _buildReportDetailsDrawer(isDark),
          if (_selectedPrescription != null) _buildPrescriptionDetailsDrawer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: isDesktop
          ? Row(
              children: [
                const GlassIconContainer(
                  icon: Icons.description_rounded,
                  size: 44,
                  iconSize: 24,
                  color: HealthifyGlassTheme.primaryTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CLINICAL DOCUMENT MANAGEMENT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Diagnostic Report Repository & Immutable Prescription Index',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: _currentRole,
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                      onChanged: (role) {
                        if (role != null) {
                          setState(() => _currentRole = role);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: UserRole.hospitalAdmin, child: Text('Role: Hospital Admin (Metadata Only)')),
                        DropdownMenuItem(value: UserRole.doctor, child: Text('Role: Doctor (Clinical Access)')),
                        DropdownMenuItem(value: UserRole.nurse, child: Text('Role: Nurse')),
                        DropdownMenuItem(value: UserRole.labTechnician, child: Text('Role: Lab Technician')),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.description_rounded,
                      size: 40,
                      iconSize: 20,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLINICAL DOCUMENT MANAGEMENT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Diagnostic Report Repository',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      isExpanded: true,
                      value: _currentRole,
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                      onChanged: (role) {
                        if (role != null) {
                          setState(() => _currentRole = role);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: UserRole.hospitalAdmin, child: Text('Role: Hospital Admin', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: UserRole.doctor, child: Text('Role: Doctor', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: UserRole.nurse, child: Text('Role: Nurse', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: UserRole.labTechnician, child: Text('Role: Lab Tech', overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: DIAGNOSTIC REPORTS DIRECTORY
  // ---------------------------------------------------------------------------
  Widget _buildReportsTab(bool isDark, bool isDesktop) {
    return Column(
      children: [
        _buildReportMetricsBar(isDark),
        _buildReportFilterBar(isDark),
        Expanded(
          child: _reports.isEmpty
              ? const MedrixEmptyState(
                  title: 'No Diagnostic Reports Found',
                  description: 'No report records match the selected query and filters.',
                  icon: Icons.folder_open_rounded,
                )
              : isDesktop
                  ? _buildReportDataTable(isDark)
                  : _buildReportCardList(isDark),
        ),
      ],
    );
  }

  Widget _buildReportMetricsBar(bool isDark) {
    final pendingCount = _reports.where((r) => r.verificationStatus == ReportVerificationStatus.uploaded || r.verificationStatus == ReportVerificationStatus.underReview).length;
    final criticalCount = _reports.where((r) => r.isCritical).length;
    final releasedCount = _reports.where((r) => r.releasedToPatient).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 160, child: _buildMetricCard('Total Reports', '${_reports.length}', Icons.description_outlined, Colors.blue, isDark)),
          const SizedBox(width: 10),
          SizedBox(width: 160, child: _buildMetricCard('Pending Review', '$pendingCount', Icons.hourglass_top_rounded, Colors.orange, isDark)),
          const SizedBox(width: 10),
          SizedBox(width: 160, child: _buildMetricCard('Critical Alerts', '$criticalCount', Icons.warning_amber_rounded, Colors.redAccent, isDark)),
          const SizedBox(width: 10),
          SizedBox(width: 160, child: _buildMetricCard('Released to Patient', '$releasedCount', Icons.check_circle_outline_rounded, Colors.teal, isDark)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(isDark),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportFilterBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Report ID, Patient MRN, Doctor, Title...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (val) {
                _reportSearch = val;
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 10),
          FilterChip(
            label: const Text('Critical Only'),
            selected: _criticalOnly,
            selectedColor: Colors.redAccent.withValues(alpha: 0.3),
            onSelected: (val) {
              setState(() => _criticalOnly = val);
              _loadData();
            },
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: HealthifyGlassTheme.primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showUploadReportModal,
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
            label: const Text('Upload Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDataTable(bool isDark) {
    final textPrimary = HealthifyGlassTheme.getTextPrimary(isDark);
    final textSecondary = HealthifyGlassTheme.getTextSecondary(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: _glassDecoration(isDark),
        child: DataTable(
          columns: [
            DataColumn(label: Text('Report ID', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Patient / MRN', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Type & Title', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Ordering Doctor', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Critical', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Patient Release', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          ],
          rows: _reports.map((report) {
            return DataRow(
              cells: [
                DataCell(Text(report.id, style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
                DataCell(Text(report.patientName, style: TextStyle(color: textPrimary))),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                    Text(report.reportType.name.toUpperCase(), style: TextStyle(fontSize: 10, color: textSecondary)),
                  ],
                )),
                DataCell(Text(report.doctorName, style: TextStyle(color: textPrimary))),
                DataCell(_buildVerificationBadge(report.verificationStatus)),
                DataCell(report.isCritical
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                        child: const Text('CRITICAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    : const Text('-')),
                DataCell(Text(report.releasedToPatient ? 'Released' : 'Pending', style: TextStyle(color: report.releasedToPatient ? Colors.teal : textSecondary))),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_rounded, size: 20),
                      onPressed: () => setState(() => _selectedReport = report),
                      tooltip: 'View Report Details',
                    ),
                    if (report.verificationStatus != ReportVerificationStatus.verified &&
                        report.verificationStatus != ReportVerificationStatus.released)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
                        onPressed: () => _verifyReport(report),
                        tooltip: 'Verify Report (Doctor Only)',
                      ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportCardList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final r = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              r.isCritical ? Icons.warning_amber_rounded : Icons.description_rounded,
              color: r.isCritical ? Colors.redAccent : HealthifyGlassTheme.primaryTeal,
            ),
            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${r.id} • ${r.patientName} • ${r.doctorName}'),
            trailing: _buildVerificationBadge(r.verificationStatus),
            onTap: () => setState(() => _selectedReport = r),
          ),
        );
      },
    );
  }

  Widget _buildVerificationBadge(ReportVerificationStatus status) {
    Color bg;
    Color fg = Colors.white;
    switch (status) {
      case ReportVerificationStatus.uploaded:
        bg = Colors.blue;
        break;
      case ReportVerificationStatus.underReview:
        bg = Colors.orange;
        break;
      case ReportVerificationStatus.verified:
        bg = Colors.teal;
        break;
      case ReportVerificationStatus.rejected:
        bg = Colors.redAccent;
        break;
      case ReportVerificationStatus.released:
        bg = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: PRESCRIPTION INDEX DIRECTORY
  // ---------------------------------------------------------------------------
  Widget _buildPrescriptionsTab(bool isDark, bool isDesktop) {
    final isAdmin = _currentRole == UserRole.hospitalAdmin;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by Prescription ID, Reference, Patient, Doctor...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (val) {
              _prescriptionSearch = val;
              _loadData();
            },
          ),
        ),
        if (isAdmin)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'IMMUTABLE PRESCRIPTION INDEX NOTICE: Hospital Administrative users have read-only metadata access to signed prescriptions. Signed clinical content cannot be edited.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _prescriptions.isEmpty
              ? const MedrixEmptyState(
                  title: 'No Prescription Index Records',
                  description: 'No prescription records match your criteria.',
                  icon: Icons.medication_liquid_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    final p = _prescriptions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_rounded, color: HealthifyGlassTheme.primaryTeal),
                        title: Text('Ref: ${p.prescriptionReference} (${p.id})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Patient: ${p.patientId} • Doctor: ${p.doctorId} • Signed: ${p.signedAt.toString().split(' ')[0]}'),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: p.status == PrescriptionStatus.signed ? Colors.blue : Colors.teal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(p.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 4),
                            Text('Fulfillment: ${p.pharmacyFulfillmentStatus.name}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        onTap: () => setState(() => _selectedPrescription = p),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: DOCUMENT ACTIVITY TIMELINE
  // ---------------------------------------------------------------------------
  Widget _buildActivityTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final act = _activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.2),
              child: Icon(_getActivityIcon(act.action), color: HealthifyGlassTheme.primaryTeal, size: 20),
            ),
            title: Text('${act.documentType} ${act.documentId} — ${act.action.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Actor: ${act.actorName}\nTime: ${act.timestamp.toString().substring(0, 16)}\nNotes: ${act.notes ?? '-'}'),
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(DocumentActivityAction action) {
    switch (action) {
      case DocumentActivityAction.uploaded:
        return Icons.cloud_upload_rounded;
      case DocumentActivityAction.viewed:
        return Icons.visibility_rounded;
      case DocumentActivityAction.reviewed:
        return Icons.rate_review_rounded;
      case DocumentActivityAction.verified:
        return Icons.verified_user_rounded;
      case DocumentActivityAction.rejected:
        return Icons.cancel_rounded;
      case DocumentActivityAction.released:
        return Icons.send_rounded;
      case DocumentActivityAction.downloaded:
        return Icons.download_rounded;
    }
  }

  // ---------------------------------------------------------------------------
  // DRAWERS & MODALS
  // ---------------------------------------------------------------------------
  Widget _buildReportDetailsDrawer(bool isDark) {
    final r = _selectedReport!;
    final canSeeClinical = PermissionService.hasPermission(_currentRole, Permission.viewClinicalDetails);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 450,
        height: double.infinity,
        decoration: _glassDecoration(isDark),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report Details: ${r.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedReport = null)),
                ],
              ),
              const Divider(),
              _detailRow('Title:', r.title),
              _detailRow('Patient:', r.patientName),
              _detailRow('Ordering Doctor:', r.doctorName),
              _detailRow('Department:', r.departmentId),
              _detailRow('Type:', r.reportType.name.toUpperCase()),
              _detailRow('Verification Status:', r.verificationStatus.name.toUpperCase()),
              _detailRow('Critical Alert:', r.isCritical ? 'YES (CRITICAL)' : 'NO'),
              _detailRow('Patient Release Status:', r.releasedToPatient ? 'RELEASED' : 'PENDING RELEASE'),
              const SizedBox(height: 16),
              const Text('File Reference:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (r.fileReference != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file_rounded, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${r.fileReference!.fileName} (${(r.fileReference!.size / 1024).toStringAsFixed(1)} KB)', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                )
              else
                const Text('No file reference attached.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('Clinical Findings & Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (canSeeClinical)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Text(r.summary.isNotEmpty ? r.summary : 'No summary provided.'),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('CLINICAL DETAILS RESTRICTED: Hospital Admin does not have authorization to view diagnostic clinical conclusions.')),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (_currentRole == UserRole.doctor) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal, minimumSize: const Size(double.infinity, 44)),
                  onPressed: () => _verifyReport(r),
                  icon: const Icon(Icons.verified_user_rounded, color: Colors.white),
                  label: const Text('Verify Diagnostic Report', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 44)),
                  onPressed: () => _rejectReport(r),
                  icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                  label: const Text('Reject / Return for Correction', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 44)),
                  onPressed: () => _releaseReport(r),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text('Release to Patient App', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionDetailsDrawer(bool isDark) {
    final p = _selectedPrescription!;
    final canSeeClinical = PermissionService.hasPermission(_currentRole, Permission.viewClinicalDetails);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 450,
        height: double.infinity,
        decoration: _glassDecoration(isDark),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prescription Details: ${p.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedPrescription = null)),
                ],
              ),
              const Divider(),
              _detailRow('Reference Number:', p.prescriptionReference),
              _detailRow('Patient ID:', p.patientId),
              _detailRow('Doctor ID:', p.doctorId),
              _detailRow('Signed Date:', p.signedAt.toString().substring(0, 16)),
              _detailRow('Status:', p.status.name.toUpperCase()),
              _detailRow('Fulfillment Status:', p.pharmacyFulfillmentStatus.name.toUpperCase()),
              const SizedBox(height: 16),
              const Text('Prescribed Medications:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (canSeeClinical)
                ...p.medications.map((m) => Card(
                      child: ListTile(
                        title: Text(m.medicationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${m.dosage} • ${m.frequency} • ${m.durationDays} days\nInstructions: ${m.instructions}'),
                      ),
                    ))
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('CLINICAL DETAILS RESTRICTED: Prescription drug details and dosages are visible only to treating physicians and pharmacists.')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showUploadReportModal() {
    final titleController = TextEditingController();
    final patientController = TextEditingController(text: 'P101');
    final doctorController = TextEditingController(text: 'DOC1');
    ReportType selectedType = ReportType.laboratory;
    bool isCritical = false;

    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => AlertDialog(
          title: const Text('Upload Diagnostic Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Report Title (e.g. Brain MRI T2 weighted)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(labelText: 'Patient ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(labelText: 'Ordering Doctor ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReportType>(
                  isExpanded: true,
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Report Type', border: OutlineInputBorder()),
                  items: ReportType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Mark as Critical Report Alert'),
                  value: isCritical,
                  onChanged: (val) => setModalState(() => isCritical = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(modalContext), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final newReport = DiagnosticReport(
                  id: 'REP-2026-00${_reports.length + 1}',
                  hospitalId: 'HOSP-01',
                  patientId: patientController.text.trim(),
                  orderingDoctorId: doctorController.text.trim(),
                  title: titleController.text.trim(),
                  reportType: selectedType,
                  isCritical: isCritical,
                  uploadedAt: DateTime.now(),
                  fileReference: DocumentReference(
                    id: 'REF-${DateTime.now().millisecondsSinceEpoch}',
                    fileName: '${titleController.text.trim().replaceAll(' ', '_').toLowerCase()}.pdf',
                    mimeType: 'application/pdf',
                    size: 2048576,
                    storageKey: 'reports/2026/uploaded_doc.pdf',
                    createdAt: DateTime.now(),
                  ),
                  date: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await _reportService.uploadReport(newReport);
                if (modalContext.mounted) Navigator.pop(modalContext);
                _loadData();
              },
              child: const Text('Upload & File Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
