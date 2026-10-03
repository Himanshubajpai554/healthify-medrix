import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/glass_components.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import './widgets/occupancy_chart.dart';
import './widgets/bed_details_drawer.dart';
import './widgets/add_bed_modal.dart';

class BedsIcuScreen extends StatefulWidget {
  const BedsIcuScreen({super.key});

  @override
  State<BedsIcuScreen> createState() => _BedsIcuScreenState();
}

class _BedsIcuScreenState extends State<BedsIcuScreen> {
  UiState<List<BedItem>> _uiState = UiState.initial();
  bool _initialized = false;

  // Filters & Selected State
  String _selectedWardFilter = 'All';
  int _selectedFloorFilter = 1;
  String _searchQuery = '';
  String _tableStatusFilter = 'All';
  String _tableTypeFilter = 'All';
  String _chartTrendFilter = '24H';
  
  // What-If Simulator State
  int _simulatedEmergencyPatients = 0;
  bool _simulateDischarges = false;

  // Selected Bed for Detail Drawer
  BedItem? _selectedBed;

  // Bed Data & Ward Capacities
  List<BedItem> _beds = [];
  List<WardCapacityItem> _wardsList = [];
  List<LiveActivityItem> _activities = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadBedData();
    }
  }

  Future<void> _loadBedData() async {
    if (!mounted) return;
    setState(() {
      _uiState = UiState.loading();
    });

    try {
      final bedRepo = RepositoryScope.of(context).bedRepository;
      final fetchedBeds = await bedRepo.getBeds();
      final fetchedWards = await bedRepo.getWardCapacities();
      final fetchedActivities = await bedRepo.getLiveActivities();

      if (!mounted) return;
      setState(() {
        _beds = fetchedBeds;
        _wardsList = fetchedWards;
        _activities = fetchedActivities;
        _uiState = fetchedBeds.isEmpty ? UiState.empty() : UiState.success(fetchedBeds);
      });
    } catch (e) {
      setState(() {
        _uiState = UiState.error('Failed to load bed management data: ${e.toString()}');
      });
    }
  }

  Color _getStatusColor(BedStatus status) {
    switch (status) {
      case BedStatus.available:
        return const Color(0xFF10B981);
      case BedStatus.occupied:
        return const Color(0xFFEF4444);
      case BedStatus.cleaning:
      case BedStatus.reserved:
        return const Color(0xFFF59E0B);
      case BedStatus.maintenance:
        return const Color(0xFF6B7280);
    }
  }

  void _openAddBedModal() {
    showDialog(
      context: context,
      builder: (context) => AddBedModal(
        onBedAdded: (newBed) {
          setState(() {
            _beds.insert(0, newBed);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bed ${newBed.id} added successfully')),
          );
        },
      ),
    );
  }

  // Filtered Bed List for Inventory Table
  List<BedItem> get _filteredTableBeds {
    return _beds.where((bed) {
      final matchesSearch = bed.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bed.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (bed.patientId != null && bed.patientId!.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      final matchesWard = _selectedWardFilter == 'All' || bed.type == _selectedWardFilter || bed.ward == _selectedWardFilter;
      final matchesStatus = _tableStatusFilter == 'All' || bed.status.name.toLowerCase() == _tableStatusFilter.toLowerCase();
      final matchesType = _tableTypeFilter == 'All' || bed.type.toLowerCase() == _tableTypeFilter.toLowerCase();

      return matchesSearch && matchesWard && matchesStatus && matchesType;
    }).toList();
  }

  // Calculated Simulated Occupancy
  double get _simulatedOccupancyPercentage {
    int baseOccupied = 198;
    int baseTotal = 250;
    int netOccupied = baseOccupied + _simulatedEmergencyPatients - (_simulateDischarges ? 5 : 0);
    if (netOccupied < 0) netOccupied = 0;
    return (netOccupied / baseTotal) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;
    final isDark = HealthifyGlassTheme.isDark(context);
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedPulseBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PAGE HEADER
                  _buildPageHeader(isMobile, textColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  if (_uiState.isLoading)
                    const MedrixLoadingState(message: 'Loading bed & ICU management data...')
                  else if (_uiState.isError)
                    MedrixErrorState(
                      errorMessage: _uiState.errorMessage ?? 'Error loading beds',
                      onRetry: _loadBedData,
                    )
                  else ...[
                    // 2. CAPACITY SUMMARY CARDS
                    _buildCapacitySummaryCards(isMobile, isTablet, textColor, secondaryTextColor),
                    const SizedBox(height: 24),

                  // 3. OVERALL HOSPITAL CAPACITY CARD
                  _buildOverallCapacityCard(isMobile, textColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // 4. WARD CAPACITY & LIVE ACTIVITY
                  if (isMobile) ...[
                    _buildWardCapacityCard(textColor, secondaryTextColor),
                    const SizedBox(height: 24),
                    _buildLiveActivityCard(textColor, secondaryTextColor),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildWardCapacityCard(textColor, secondaryTextColor)),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildLiveActivityCard(textColor, secondaryTextColor)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 5. INTERACTIVE BED MAP
                  _buildInteractiveBedMap(isMobile, textColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // 6. BED INVENTORY TABLE
                  _buildBedInventoryTable(isMobile, textColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // 7. CRITICAL EQUIPMENT & TURNAROUND ANALYTICS
                  if (isMobile) ...[
                    _buildCriticalEquipmentCard(textColor, secondaryTextColor),
                    const SizedBox(height: 24),
                    _buildBedTurnaroundCard(textColor, secondaryTextColor),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCriticalEquipmentCard(textColor, secondaryTextColor)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildBedTurnaroundCard(textColor, secondaryTextColor)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 8. OCCUPANCY TREND CHART
                  _buildOccupancyTrendCard(textColor, secondaryTextColor),
                  const SizedBox(height: 24),

                  // 9. AI CAPACITY FORECAST & WHAT-IF SIMULATOR
                  if (isMobile) ...[
                    _buildAiForecastCard(textColor, secondaryTextColor),
                    const SizedBox(height: 24),
                    _buildWhatIfSimulatorCard(textColor, secondaryTextColor),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAiForecastCard(textColor, secondaryTextColor)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildWhatIfSimulatorCard(textColor, secondaryTextColor)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 10. CAPACITY ALERTS & PATIENT APP GOVERNANCE
                  if (isMobile) ...[
                    _buildCapacityAlertsCard(textColor, secondaryTextColor),
                    const SizedBox(height: 24),
                    _buildPatientAppGovernanceCard(textColor, secondaryTextColor),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCapacityAlertsCard(textColor, secondaryTextColor)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildPatientAppGovernanceCard(textColor, secondaryTextColor)),
                      ],
                    ),
                  ],
                ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Slide Drawer Overlay for Selected Bed Details
        if (_selectedBed != null)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedBed = null),
                  child: Container(color: Colors.black45),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: BedDetailsDrawer(
                    bed: _selectedBed!,
                    onStatusChanged: (newStatus) {
                      setState(() {
                        _selectedBed!.status = newStatus;
                      });
                    },
                    onVisibilityToggled: (visible) {
                      setState(() {
                        _selectedBed!.isVisibleToPatientApp = visible;
                      });
                    },
                    onClose: () => setState(() => _selectedBed = null),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildPageHeader(bool isMobile, Color textColor, Color secondaryTextColor) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Beds & ICU Management',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor real-time bed capacity, ICU availability, and hospital occupancy.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildLiveStatusBadge(),
                  GlassPrimaryButton(
                    onPressed: _openAddBedModal,
                    height: 44,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text('+ Add Bed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beds & ICU Management',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor real-time bed capacity, ICU availability, and hospital occupancy.',
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildLiveStatusBadge(),
                  const SizedBox(width: 16),
                  GlassPrimaryButton(
                    onPressed: _openAddBedModal,
                    height: 46,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Add Bed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildLiveStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
          SizedBox(width: 8),
          Text(
            'Live • Last updated 2 min ago',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySummaryCards(bool isMobile, bool isTablet, Color textColor, Color secondaryTextColor) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 5);
    
    final cardsData = [
      {'title': 'Total Beds', 'count': '250', 'icon': Icons.king_bed_outlined, 'color': AppTheme.primaryColor, 'sub': '100% capacity'},
      {'title': 'Available', 'count': '42', 'icon': Icons.check_circle_outline, 'color': const Color(0xFF10B981), 'sub': '16.8% open'},
      {'title': 'Occupied', 'count': '198', 'icon': Icons.hotel_rounded, 'color': const Color(0xFFEF4444), 'sub': '79.2% filled'},
      {'title': 'Reserved', 'count': '10', 'icon': Icons.bookmark_border_rounded, 'color': const Color(0xFFF59E0B), 'sub': 'Pending admissions'},
      {'title': 'Maintenance', 'count': '4', 'icon': Icons.build_circle_outlined, 'color': const Color(0xFF6B7280), 'sub': 'Under repair'},
    ];

    final icuCardsData = [
      {'title': 'ICU Total', 'count': '30', 'icon': Icons.local_hospital_outlined, 'color': AppTheme.primaryColor, 'sub': 'Specialized care'},
      {'title': 'ICU Available', 'count': '4', 'icon': Icons.check_circle, 'color': const Color(0xFF10B981), 'sub': '13.3% open'},
      {'title': 'ICU Occupied', 'count': '26', 'icon': Icons.hotel, 'color': const Color(0xFFEF4444), 'sub': '86.7% occupied'},
      {'title': 'ICU Utilization', 'count': '87%', 'icon': Icons.speed_rounded, 'color': const Color(0xFFF59E0B), 'sub': 'High Utilization'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Hospital Metrics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.0 : 1.5,
          ),
          itemCount: cardsData.length,
          itemBuilder: (context, index) {
            final card = cardsData[index];
            return _buildStatCard(
              title: card['title'] as String,
              count: card['count'] as String,
              icon: card['icon'] as IconData,
              color: card['color'] as Color,
              subtitle: card['sub'] as String,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            );
          },
        ),
        const SizedBox(height: 20),

        Text(
          'ICU Critical Metrics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.0 : 1.5,
          ),
          itemCount: icuCardsData.length,
          itemBuilder: (context, index) {
            final card = icuCardsData[index];
            return _buildStatCard(
              title: card['title'] as String,
              count: card['count'] as String,
              icon: card['icon'] as IconData,
              color: card['color'] as Color,
              subtitle: card['sub'] as String,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
              ),
              const SizedBox(width: 4),
              GlassIconContainer(icon: icon, color: color, size: 16),
            ],
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                count,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCapacityCard(bool isMobile, Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Hospital Capacity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Operational capacity breakdown across all units',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'High Capacity',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '79%',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '198 / 250 beds occupied',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.792,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(color: const Color(0xFF10B981), label: 'Normal (<75%)', textColor: secondaryTextColor),
              _buildLegendItem(color: const Color(0xFFF59E0B), label: 'High (75-89%)', textColor: secondaryTextColor),
              _buildLegendItem(color: const Color(0xFFEF4444), label: 'Critical (≥90%)', textColor: secondaryTextColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hospital capacity is currently high. Monitor emergency arrivals closely.',
            style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: secondaryTextColor.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required Color textColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor),
        ),
      ],
    );
  }

  Widget _buildWardCapacityCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ward Capacity Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Click a ward to filter the bed map and inventory below',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 20),

          Column(
            children: _wardsList.map((ward) {
              final isSelected = _selectedWardFilter == ward.name;
              final color = ward.percentage >= 85
                  ? const Color(0xFFEF4444)
                  : (ward.percentage >= 70 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedWardFilter = isSelected ? 'All' : ward.name;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: color, size: 10),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ward.name,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ward.occupied} / ${ward.total}  (${ward.percentage.toInt()}%)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ward.occupied / ward.total,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActivityCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Live Capacity Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Showing all operational activity logs')),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            children: _activities.map((act) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassIconContainer(icon: act.icon, color: act.iconColor, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.description,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            act.timeAgo,
                            style: TextStyle(fontSize: 11, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveBedMap(bool isMobile, Color textColor, Color secondaryTextColor) {
    final mapBeds = _beds.where((bed) {
      final matchesFloor = bed.floor == _selectedFloorFilter;
      final matchesWard = _selectedWardFilter == 'All' || bed.type == _selectedWardFilter || bed.ward == _selectedWardFilter;
      return matchesFloor && matchesWard;
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Bed Map',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Click any bed chip to inspect details or change status',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Ward:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
              ...['All', 'ICU', 'General', 'Emergency', 'Private'].map((ward) {
                final isSelected = _selectedWardFilter == ward;
                return GlassSelectionChip(
                  label: ward,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedWardFilter = ward),
                );
              }),
              const SizedBox(width: 12),

              // Floor Selector Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [1, 2, 3].map((floor) {
                    final isSelected = _selectedFloorFilter == floor;
                    return InkWell(
                      onTap: () => setState(() => _selectedFloorFilter = floor),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Floor $floor',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : secondaryTextColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Map Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(color: const Color(0xFF10B981), label: '🟢 Available', textColor: secondaryTextColor),
              _buildLegendItem(color: const Color(0xFFEF4444), label: '🔴 Occupied', textColor: secondaryTextColor),
              _buildLegendItem(color: const Color(0xFFF59E0B), label: '🟡 Cleaning/Reserved', textColor: secondaryTextColor),
              _buildLegendItem(color: const Color(0xFF6B7280), label: '⚫ Maintenance', textColor: secondaryTextColor),
            ],
          ),
          const SizedBox(height: 20),

          // Beds Grid Map
          mapBeds.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('No beds found for the selected Ward and Floor criteria.', style: TextStyle(color: secondaryTextColor)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : (MediaQuery.of(context).size.width < 1100 ? 4 : 6),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: mapBeds.length,
                  itemBuilder: (context, index) {
                    final bed = mapBeds[index];
                    final color = _getStatusColor(bed.status);

                    return InkWell(
                      onTap: () => setState(() => _selectedBed = bed),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: color, size: 10),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    bed.id,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                  Text(
                                    bed.type,
                                    style: TextStyle(fontSize: 10.5, color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBedInventoryTable(bool isMobile, Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Bed Inventory & Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Total ${_filteredTableCount()} units',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Filter Controls
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 240,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: textColor),
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Search bed ID or patient...',
                    prefixIcon: Icon(Icons.search, size: 20, color: secondaryTextColor),
                  ),
                ),
              ),

              DropdownButton<String>(
                value: _tableStatusFilter,
                dropdownColor: HealthifyGlassTheme.isDark(context) ? const Color(0xFF0F766E) : Colors.white,
                style: TextStyle(color: textColor, fontSize: 13),
                underline: const SizedBox(),
                items: ['All', 'Available', 'Occupied', 'Cleaning', 'Reserved', 'Maintenance'].map((st) {
                  return DropdownMenuItem(value: st, child: Text('Status: $st', style: TextStyle(color: textColor, fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tableStatusFilter = val);
                },
              ),

              DropdownButton<String>(
                value: _tableTypeFilter,
                dropdownColor: HealthifyGlassTheme.isDark(context) ? const Color(0xFF0F766E) : Colors.white,
                style: TextStyle(color: textColor, fontSize: 13),
                underline: const SizedBox(),
                items: ['All', 'General', 'ICU', 'Emergency', 'Private', 'Pediatric', 'NICU'].map((tp) {
                  return DropdownMenuItem(value: tp, child: Text('Type: $tp', style: TextStyle(color: textColor, fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tableTypeFilter = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _filteredTableBeds.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text('No bed inventory records match the current filters.', style: TextStyle(color: secondaryTextColor)),
                )
              : (isMobile
                  ? Column(
                      children: _filteredTableBeds.map((bed) {
                        final color = _getStatusColor(bed.status);
                        return GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.circle, color: color, size: 12),
                            title: Text('${bed.id} (${bed.type})', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                            subtitle: Text('Floor ${bed.floor} • ${bed.status.name} • ${bed.lastUpdated}', style: TextStyle(color: secondaryTextColor)),
                            trailing: GlassSecondaryButton(
                              onPressed: () => setState(() => _selectedBed = bed),
                              height: 36,
                              child: const Text('Inspect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
                        columns: [
                          DataColumn(label: Text('Bed ID', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Type / Ward', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Floor', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Last Updated', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                        ],
                        rows: _filteredTableBeds.map((bed) {
                          final color = _getStatusColor(bed.status);
                          return DataRow(
                            cells: [
                              DataCell(Text(bed.id, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                              DataCell(Text(bed.type, style: TextStyle(color: secondaryTextColor))),
                              DataCell(Text('Floor ${bed.floor}', style: TextStyle(color: secondaryTextColor))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, color: color, size: 8),
                                      const SizedBox(width: 6),
                                      Text(
                                        bed.status.name[0].toUpperCase() + bed.status.name.substring(1),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(bed.equipment.isEmpty ? '—' : bed.equipment.join(', '), style: TextStyle(color: secondaryTextColor))),
                              DataCell(Text(bed.lastUpdated, style: TextStyle(color: secondaryTextColor))),
                              DataCell(
                                GlassSecondaryButton(
                                  onPressed: () => setState(() => _selectedBed = bed),
                                  height: 32,
                                  child: const Text('Inspect', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )),
        ],
      ),
    );
  }

  String _filteredTableCount() => _filteredTableBeds.length.toString();

  Widget _buildCriticalEquipmentCard(Color textColor, Color secondaryTextColor) {
    final equipmentList = [
      {'name': 'Ventilators', 'avail': 18, 'total': 20, 'icon': Icons.air_rounded},
      {'name': 'Oxygen Units', 'avail': 45, 'total': 50, 'icon': Icons.masks_outlined},
      {'name': 'Cardiac Monitors', 'avail': 28, 'total': 30, 'icon': Icons.monitor_heart_outlined},
      {'name': 'Infusion Pumps', 'avail': 38, 'total': 40, 'icon': Icons.medication_outlined},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Critical Equipment Availability',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Life-support equipment linked to ICU and Emergency units',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 20),

          Column(
            children: equipmentList.map((eq) {
              final avail = eq['avail'] as int;
              final total = eq['total'] as int;
              final ratio = avail / total;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    GlassIconContainer(icon: eq['icon'] as IconData, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(eq['name'] as String, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor))),
                              const SizedBox(width: 8),
                              Text('$avail / $total Ready', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBedTurnaroundCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bed Turnaround & Sanitation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Sanitation performance and queue analytics',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avg Turnaround', style: TextStyle(fontSize: 11.5, color: secondaryTextColor)),
                      const SizedBox(height: 4),
                      Text('18 min', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const Text('Target: <25 min', style: TextStyle(fontSize: 10.5, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cleaning Queue', style: TextStyle(fontSize: 11.5, color: secondaryTextColor)),
                      const SizedBox(height: 4),
                      const Text('6 beds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                      Text('4 staff assigned', style: TextStyle(fontSize: 10.5, color: secondaryTextColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GlassPrimaryButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispatched high-priority cleaning alert to housekeeping squad')),
              );
            },
            height: 44,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cleaning_services_rounded, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text('Dispatch Housekeeping Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyTrendCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Occupancy Trend Analytics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Historical occupancy rates over custom timeline filters',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Row(
                children: ['24H', '7D', '30D'].map((range) {
                  final isSelected = _chartTrendFilter == range;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GlassSelectionChip(
                      label: range,
                      isSelected: isSelected,
                      onTap: () => setState(() => _chartTrendFilter = range),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CustomPainter Line Chart Component
          OccupancyTrendChart(filter: _chartTrendFilter),
        ],
      ),
    );
  }

  Widget _buildAiForecastCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'AI Capacity Forecast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI Predictive',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Peak ICU Demand Forecast',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Peak ICU demand expected in next 6 hours (+3 admissions projected based on emergency department triage).',
                  style: TextStyle(fontSize: 12.5, color: textColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Recommended Action:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Prepare 2 General Ward beds for step-down ICU transfers to prevent critical bottleneck.',
            style: TextStyle(fontSize: 12.5, color: secondaryTextColor),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Confidence Rating:', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('87% High Precision', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIfSimulatorCard(Color textColor, Color secondaryTextColor) {
    final double simPercentage = _simulatedOccupancyPercentage;
    final isOverThreshold = simPercentage >= 90;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What-If Capacity Simulator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Simulate emergency surges or planned discharges',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 20),

          // Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Emergency Admissions:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: secondaryTextColor),
                    onPressed: () {
                      if (_simulatedEmergencyPatients > 0) {
                        setState(() => _simulatedEmergencyPatients--);
                      }
                    },
                  ),
                  Text('+$_simulatedEmergencyPatients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                    onPressed: () {
                      setState(() => _simulatedEmergencyPatients++);
                    },
                  ),
                ],
              ),
            ],
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Simulate 5 ICU Discharges', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            value: _simulateDischarges,
            activeTrackColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _simulateDischarges = val),
          ),
          const SizedBox(height: 12),

          // Output Indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOverThreshold
                  ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverThreshold ? const Color(0xFFEF4444).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Simulated Occupancy:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                Text(
                  '${simPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverThreshold ? const Color(0xFFEF4444) : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityAlertsCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Capacity Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Automated system notifications requiring staff attention',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 16),

          GlassCard(
            padding: EdgeInsets.zero,
            isStrong: true,
            child: ListTile(
              leading: const Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
              title: const Text('ICU Capacity Reached 87%', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
              subtitle: Text('Only 4 beds remain open. Consider holding elective admissions.', style: TextStyle(fontSize: 11.5, color: secondaryTextColor)),
              onTap: () {
                setState(() => _selectedWardFilter = 'ICU');
              },
            ),
          ),
          const SizedBox(height: 10),

          GlassCard(
            padding: EdgeInsets.zero,
            isStrong: true,
            child: ListTile(
              leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFFF59E0B)),
              title: const Text('General Ward Cleaning Delay (>25 min)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
              subtitle: Text('Bed G-102 cleaning duration exceeded benchmark time.', style: TextStyle(fontSize: 11.5, color: secondaryTextColor)),
              onTap: () {
                setState(() => _selectedWardFilter = 'General Ward');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAppGovernanceCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient App Visibility & Governance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Control public patient mobile app visibility for hospital emergency routing',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Only verified available beds are displayed to patients searching for emergency admission via the Medrix mobile app.',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GlassPrimaryButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient app visibility settings saved successfully')),
              );
            },
            height: 44,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_rounded, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text('Save Governance Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}