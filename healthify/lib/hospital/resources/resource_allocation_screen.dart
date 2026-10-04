import 'package:flutter/material.dart';
import '../../core/data/mock/mock_resource_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/resource_model.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/resource_service.dart';
import '../../core/widgets/medrix_empty_state.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class ResourceAllocationScreen extends StatefulWidget {
  const ResourceAllocationScreen({super.key});

  @override
  State<ResourceAllocationScreen> createState() => _ResourceAllocationScreenState();
}

class _ResourceAllocationScreenState extends State<ResourceAllocationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ResourceService _resourceService;

  bool _isLoading = true;
  String? _errorMessage;

  List<ResourceMatrixItem> _matrix = [];
  List<DepartmentCapacitySummary> _departmentSummaries = [];
  List<ResourceAllocationRequest> _requests = [];
  List<ResourceAllocationRecommendation> _recommendations = [];

  HospitalResourceType? _selectedResourceType;

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
    _tabController = TabController(length: 3, vsync: this);
    _resourceService = ResourceService(resourceRepository: MockResourceRepository());
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
      final matrix = await _resourceService.getResourceMatrix(
        query: ResourceQuery(resourceType: _selectedResourceType),
      );
      final dept = await _resourceService.getDepartmentCapacitySummaries();
      final reqs = await _resourceService.getAllocationRequests();
      final recs = await _resourceService.getRecommendations();

      if (mounted) {
        setState(() {
          _matrix = matrix;
          _departmentSummaries = dept;
          _requests = reqs;
          _recommendations = recs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load resource allocation data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRecommendationAction(ResourceAllocationRecommendation rec, RecommendationStatus status) async {
    try {
      await _resourceService.reviewRecommendation(rec.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recommendation updated to ${status.name.toUpperCase()}'),
            backgroundColor: status == RecommendationStatus.accepted ? Colors.teal : Colors.grey[800],
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
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
                    isScrollable: true,
                    controller: _tabController,
                    indicatorColor: HealthifyGlassTheme.primaryTeal,
                    labelColor: HealthifyGlassTheme.primaryTeal,
                    unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_view_rounded), text: 'Resource Matrix & Departments'),
                      Tab(icon: Icon(Icons.assignment_turned_in_rounded), text: 'Allocation Requests'),
                      Tab(icon: Icon(Icons.lightbulb_rounded), text: 'Human-in-Loop Insights'),
                    ],
                  ),
                  Expanded(
                    child: _isLoading
                        ? const MedrixLoadingState(message: 'Loading hospital resource capacity matrix...')
                        : _errorMessage != null
                            ? MedrixErrorState(
                                errorMessage: _errorMessage!,
                                onRetry: _loadData,
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildMatrixTab(isDark, isDesktop),
                                  _buildRequestsTab(isDark, isDesktop),
                                  _buildRecommendationsTab(isDark, isDesktop),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
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
                const GlassIconContainer(
                  icon: Icons.account_tree_rounded,
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
                        'HOSPITAL RESOURCE ALLOCATION',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Resource Matrix, Capacity & Allocation Insights',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _showCreateRequestModal,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text('Request Resource', style: TextStyle(color: Colors.white)),
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
          const GlassIconContainer(
            icon: Icons.account_tree_rounded,
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
                  'HOSPITAL RESOURCE ALLOCATION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  'Resource Matrix, Department Capacity Summaries & Allocation Insights',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: HealthifyGlassTheme.primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _showCreateRequestModal,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text('Request Resource', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: RESOURCE MATRIX & DEPARTMENT CAPACITY
  // ---------------------------------------------------------------------------
  Widget _buildMatrixTab(bool isDark, bool isDesktop) {
    final textPrimary = HealthifyGlassTheme.getTextPrimary(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hospital-Wide Capacity Matrix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 12),
          isDesktop ? _buildMatrixTable(isDark) : _buildMatrixCards(isDark),
          const SizedBox(height: 24),
          Text('Department Capacity Summaries', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 12),
          _buildDepartmentCards(isDark, isDesktop),
        ],
      ),
    );
  }

  Widget _buildMatrixTable(bool isDark) {
    final textPrimary = HealthifyGlassTheme.getTextPrimary(isDark);

    return Container(
      decoration: _glassDecoration(isDark),
      child: DataTable(
        columns: [
          DataColumn(label: Text('Resource Category', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Available', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Occupied', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Reserved', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Maintenance', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Utilization', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
        ],
        rows: _matrix.map((m) {
          return DataRow(
            cells: [
              DataCell(Text(m.resourceName, style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary))),
              DataCell(Text('${m.total}', style: TextStyle(color: textPrimary))),
              DataCell(Text('${m.available}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              DataCell(Text('${m.occupied}', style: TextStyle(color: textPrimary))),
              DataCell(Text('${m.reserved}', style: TextStyle(color: textPrimary))),
              DataCell(Text('${m.maintenance}', style: TextStyle(color: textPrimary))),
              DataCell(SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: m.utilizationPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          m.utilizationPercentage > 85 ? Colors.redAccent : HealthifyGlassTheme.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${m.utilizationPercentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              )),
              DataCell(_buildStatusBadge(m.status)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatrixCards(bool isDark) {
    return Column(
      children: _matrix.map((m) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            title: Text(m.resourceName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Utilization: ${m.utilizationPercentage.toStringAsFixed(1)}% • Available: ${m.available}/${m.total}'),
            trailing: _buildStatusBadge(m.status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _subMetric('Occupied', '${m.occupied}'),
                    _subMetric('Reserved', '${m.reserved}'),
                    _subMetric('Maintenance', '${m.maintenance}'),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _subMetric(String title, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatusBadge(ResourceAvailabilityStatus status) {
    Color color;
    switch (status) {
      case ResourceAvailabilityStatus.available:
        color = Colors.green;
        break;
      case ResourceAvailabilityStatus.partiallyAvailable:
        color = Colors.blue;
        break;
      case ResourceAvailabilityStatus.occupied:
        color = Colors.orange;
        break;
      case ResourceAvailabilityStatus.critical:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDepartmentCards(bool isDark, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        childAspectRatio: isDesktop ? 2.5 : 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _departmentSummaries.length,
      itemBuilder: (context, index) {
        final d = _departmentSummaries[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d.departmentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${d.utilization.toStringAsFixed(0)}% Utilized', style: const TextStyle(color: HealthifyGlassTheme.primaryTeal, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _deptMetric('Beds Avail', '${d.availableBeds}/${d.totalBeds}'),
                  _deptMetric('Doctors On Duty', '${d.availableDoctors}/${d.doctorCount}'),
                  _deptMetric('Staff On Duty', '${d.availableStaff}/${d.staffCount}'),
                  _deptMetric('ER Cases', '${d.emergencyCases}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deptMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ALLOCATION REQUESTS
  // ---------------------------------------------------------------------------
  Widget _buildRequestsTab(bool isDark, bool isDesktop) {
    if (_requests.isEmpty) {
      return const MedrixEmptyState(
        title: 'No Pending Allocation Requests',
        description: 'All hospital resource requests have been processed.',
        icon: Icons.assignment_turned_in_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final req = _requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: HealthifyGlassTheme.primaryTeal,
              child: Icon(Icons.local_hospital_rounded, color: Colors.white),
            ),
            title: Text('${req.quantity}x ${req.resourceType.name.toUpperCase()} — Priority: ${req.priority.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Requested By: ${req.requestedBy}\nReason: ${req.reason}\nTime: ${req.createdAt.toString().substring(0, 16)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (req.status == AllocationRequestStatus.pending) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                    onPressed: () async {
                      await _resourceService.updateAllocationRequestStatus(req.id, AllocationRequestStatus.approved);
                      _loadData();
                    },
                    tooltip: 'Approve Request',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                    onPressed: () async {
                      await _resourceService.updateAllocationRequestStatus(req.id, AllocationRequestStatus.rejected);
                      _loadData();
                    },
                    tooltip: 'Reject Request',
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: req.status == AllocationRequestStatus.approved ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(req.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: HUMAN-IN-LOOP RECOMMENDATIONS
  // ---------------------------------------------------------------------------
  Widget _buildRecommendationsTab(bool isDark, bool isDesktop) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'HUMAN-IN-THE-LOOP ALLOCATION PRINCIPLE: Recommendations represent mathematical load balancing insights. Autonomous clinical mutations are disabled. Review and confirm action.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _recommendations.isEmpty
              ? const MedrixEmptyState(
                  title: 'No Resource Insights',
                  description: 'Hospital resource capacity is currently balanced.',
                  icon: Icons.lightbulb_outline_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    final rec = _recommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Insight for ${rec.resourceType.name.toUpperCase()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: HealthifyGlassTheme.primaryTeal, borderRadius: BorderRadius.circular(8)),
                                  child: Text('${(rec.confidence * 100).toStringAsFixed(0)}% Confidence', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Current State: ${rec.currentStatus}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('Recommended Action: ${rec.recommendedAction}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Estimated Impact: ${rec.impact}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (rec.status == RecommendationStatus.newAction) ...[
                                  OutlinedButton(
                                    onPressed: () => _handleRecommendationAction(rec, RecommendationStatus.rejected),
                                    child: const Text('Reject Insight'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
                                    onPressed: () => _handleRecommendationAction(rec, RecommendationStatus.accepted),
                                    child: const Text('Confirm & Accept', style: TextStyle(color: Colors.white)),
                                  ),
                                ] else
                                  Text('Status: ${rec.status.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateRequestModal() {
    final qtyController = TextEditingController(text: '1');
    final reasonController = TextEditingController();
    HospitalResourceType selectedType = HospitalResourceType.bed;
    AllocationPriority selectedPriority = AllocationPriority.high;

    showDialog(
      context: context,
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, setModalState) => AlertDialog(
          title: const Text('Submit Resource Allocation Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<HospitalResourceType>(
                  isExpanded: true,
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Resource Category', border: OutlineInputBorder()),
                  items: HospitalResourceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity Requested', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AllocationPriority>(
                  isExpanded: true,
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority Level', border: OutlineInputBorder()),
                  items: AllocationPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedPriority = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Operational Reason', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(modalContext), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) return;
                final req = ResourceAllocationRequest(
                  id: 'REQ-2026-${DateTime.now().millisecondsSinceEpoch}',
                  hospitalId: 'HOSP-01',
                  resourceType: selectedType,
                  requestedBy: 'Current User',
                  departmentId: 'DEP-GEN-01',
                  quantity: int.tryParse(qtyController.text) ?? 1,
                  priority: selectedPriority,
                  reason: reasonController.text.trim(),
                  createdAt: DateTime.now(),
                );
                await _resourceService.createAllocationRequest(req);
                if (modalContext.mounted) Navigator.pop(modalContext);
                _loadData();
              },
              child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
