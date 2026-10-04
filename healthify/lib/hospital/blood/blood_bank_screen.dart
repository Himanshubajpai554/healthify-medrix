import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/glass_components.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import './widgets/blood_trend_chart.dart';
import './widgets/add_blood_units_modal.dart';
import './widgets/record_donation_modal.dart';
import './widgets/create_blood_request_modal.dart';

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({super.key});

  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  UiState<List<BloodInventoryUnit>> _uiState = UiState.initial();
  bool _initialized = false;

  // Filtering state
  String _selectedBloodGroupFilter = 'All';
  String _selectedComponentFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  String _chartTrendFilter = '7D';

  // What-If Simulator State
  final String _simBloodGroup = 'O-';
  int _simEmergencyDemand = 5;
  int _simIncomingDonation = 5;

  // Patient App Visibility State (8 Blood Groups)
  final Map<String, String> _patientAppVisibility = {
    'O+': 'Available',
    'O-': 'Limited',
    'A+': 'Available',
    'A-': 'Limited',
    'B+': 'Available',
    'B-': 'Critical',
    'AB+': 'Available',
    'AB-': 'Limited',
  };

  // Inventory Units, Donations, Requests, Blood Summaries
  List<BloodInventoryUnit> _inventoryUnits = [];
  List<DonationRecordItem> _donations = [];
  List<BloodRequestItem> _requests = [];
  List<BloodGroupSummaryItem> _bloodGroups = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadBloodBankData();
    }
  }

  Future<void> _loadBloodBankData() async {
    if (!mounted) return;
    setState(() {
      _uiState = UiState.loading();
    });

    try {
      final bloodRepo = RepositoryScope.of(context).bloodRepository;
      final fetchedInventory = await bloodRepo.getInventoryUnits();
      final fetchedDonations = await bloodRepo.getDonationRecords();
      final fetchedRequests = await bloodRepo.getBloodRequests();
      final fetchedSummaries = await bloodRepo.getBloodSummaries();

      if (!mounted) return;
      setState(() {
        _inventoryUnits = fetchedInventory;
        _donations = fetchedDonations;
        _requests = fetchedRequests;
        _bloodGroups = fetchedSummaries;
        _uiState = fetchedInventory.isEmpty
            ? UiState.empty()
            : UiState.success(fetchedInventory);
      });
    } catch (e) {
      setState(() {
        _uiState = UiState.error(
          'Failed to load blood bank data: ${e.toString()}',
        );
      });
    }
  }

  void _openAddUnitsModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final messenger = ScaffoldMessenger.of(dialogContext);
        return AddBloodUnitsModal(
          onUnitAdded: (unit) async {
            final repo = RepositoryScope.of(context).bloodRepository;
            await repo.addInventoryUnit(unit);
            await _loadBloodBankData();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Blood unit ${unit.unitId} added to inventory'),
              ),
            );
          },
        );
      },
    );
  }

  void _openRecordDonationModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final messenger = ScaffoldMessenger.of(dialogContext);
        return RecordDonationModal(
          onDonationRecorded: (donation) async {
            final repo = RepositoryScope.of(context).bloodRepository;
            await repo.recordDonation(donation);
            await _loadBloodBankData();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Donation ${donation.donorId} recorded successfully',
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openCreateRequestModal() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final messenger = ScaffoldMessenger.of(dialogContext);
        return CreateBloodRequestModal(
          onRequestCreated: (request) async {
            final repo = RepositoryScope.of(context).bloodRepository;
            await repo.createBloodRequest(request);
            await _loadBloodBankData();
            messenger.showSnackBar(
              SnackBar(
                content: Text('Blood request ${request.requestId} created'),
              ),
            );
          },
        );
      },
    );
  }

  List<BloodInventoryUnit> get _filteredInventory {
    return _inventoryUnits.where((unit) {
      final matchesSearch =
          unit.unitId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          unit.bloodGroup.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          unit.component.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesGroup =
          _selectedBloodGroupFilter == 'All' ||
          unit.bloodGroup == _selectedBloodGroupFilter;
      final matchesComponent =
          _selectedComponentFilter == 'All' ||
          unit.component.toLowerCase() ==
              _selectedComponentFilter.toLowerCase();
      final matchesStatus =
          _selectedStatusFilter == 'All' ||
          unit.status.name.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesGroup && matchesComponent && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;
    final isDark = HealthifyGlassTheme.isDark(context);
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedPulseBackground(
            child: SizedBox(
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. PAGE HEADER & QUICK ACTIONS
                    _buildPageHeader(isMobile, textColor, secondaryTextColor),
                    const SizedBox(height: 24),

                    // QUICK ACTIONS BAR
                    _buildQuickActionsBar(isMobile),
                    const SizedBox(height: 24),

                    // 2. INVENTORY SUMMARY CARDS
                    _buildInventorySummaryCards(
                      isMobile,
                      isTablet,
                      textColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 24),

                    // 3. CRITICAL BLOOD ALERTS
                    _buildCriticalAlertsSection(textColor, secondaryTextColor),
                    const SizedBox(height: 24),

                    if (_uiState.isLoading)
                      const MedrixLoadingState(
                        message:
                            'Loading blood bank inventory & request data...',
                      )
                    else if (_uiState.isError)
                      MedrixErrorState(
                        errorMessage:
                            _uiState.errorMessage ?? 'Error loading blood bank',
                        onRetry: _loadBloodBankData,
                      )
                    else ...[
                      _buildBloodGroupOverview(
                        isMobile,
                        textColor,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 24),

                      // 5. INVENTORY STATUS DISTRIBUTION
                      _buildStatusDistributionCard(
                        isMobile,
                        textColor,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 24),

                      // 6. BLOOD INVENTORY TABLE
                      _buildBloodInventoryTable(
                        isMobile,
                        textColor,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 24),

                      // 7. EXPIRY MONITOR & BLOOD COMPONENTS
                      if (isMobile) ...[
                        _buildExpiryMonitorCard(textColor, secondaryTextColor),
                        const SizedBox(height: 24),
                        _buildBloodComponentsCard(
                          textColor,
                          secondaryTextColor,
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildExpiryMonitorCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildBloodComponentsCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 8. DONATION MANAGEMENT & BLOOD REQUESTS
                      if (isMobile) ...[
                        _buildDonationManagementCard(
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildBloodRequestsCard(textColor, secondaryTextColor),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildDonationManagementCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildBloodRequestsCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 9. BLOOD ALLOCATION FLOW
                      _buildAllocationWorkflowCard(
                        isMobile,
                        textColor,
                        secondaryTextColor,
                      ),
                      const SizedBox(height: 24),

                      // 10. AI DEMAND FORECAST & USAGE TREND CHART
                      if (isMobile) ...[
                        _buildAiDemandForecastCard(
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildUsageTrendCard(textColor, secondaryTextColor),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildAiDemandForecastCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildUsageTrendCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 11. POTENTIAL SHORTAGES & DONATION NEEDS
                      if (isMobile) ...[
                        _buildPotentialShortagesCard(
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildDonationNeedsCard(textColor, secondaryTextColor),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildPotentialShortagesCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildDonationNeedsCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 12. STORAGE OVERVIEW & WHAT-IF SIMULATOR
                      if (isMobile) ...[
                        _buildStorageOverviewCard(
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildWhatIfSimulatorCard(
                          textColor,
                          secondaryTextColor,
                        ),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildStorageOverviewCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildWhatIfSimulatorCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 13. PATIENT APP AVAILABILITY & RECENT ACTIVITY
                      if (isMobile) ...[
                        _buildPatientAppAvailabilityCard(
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildRecentActivityCard(textColor, secondaryTextColor),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildPatientAppAvailabilityCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: _buildRecentActivityCard(
                                textColor,
                                secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildPageHeader(
    bool isMobile,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blood Bank Operations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor blood inventory, availability, donations, and demand.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _buildLiveStatusBadge(),
                  _SafePrimaryButton(
                    onPressed: _openAddUnitsModal,
                    height: 42,
                    color: const Color(0xFFE11D48),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Add Units',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SafeSecondaryButton(
                    onPressed: _openRecordDonationModal,
                    height: 42,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volunteer_activism_outlined, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Record Donation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                      'Blood Bank Operations',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor blood inventory, availability, donations, and demand.',
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildLiveStatusBadge(),
                  const SizedBox(width: 12),
                  _SafePrimaryButton(
                    onPressed: _openAddUnitsModal,
                    height: 46,
                    color: const Color(0xFFE11D48),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Add Blood Units',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SafeSecondaryButton(
                    onPressed: _openRecordDonationModal,
                    height: 46,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volunteer_activism_outlined, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Record Donation',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
          SizedBox(width: 8),
          Text(
            'Live • Last updated 2 min ago',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsBar(bool isMobile) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _QuickActionButton(
          icon: Icons.add,
          label: '+ Add Blood Units',
          color: const Color(0xFFE11D48),
          onTap: _openAddUnitsModal,
        ),
        _QuickActionButton(
          icon: Icons.volunteer_activism_outlined,
          label: 'Record Donation',
          color: const Color(0xFF10B981),
          onTap: _openRecordDonationModal,
        ),
        _QuickActionButton(
          icon: Icons.add_alert_outlined,
          label: 'Create Blood Request',
          color: const Color(0xFFD97706),
          onTap: _openCreateRequestModal,
        ),
        _QuickActionButton(
          icon: Icons.swap_horiz_rounded,
          label: 'Allocate Units',
          color: AppTheme.primaryColor,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opened Blood Allocation Module')),
            );
          },
        ),
        _QuickActionButton(
          icon: Icons.warning_amber_rounded,
          label: 'View Expiring Units',
          color: const Color(0xFFF59E0B),
          onTap: () {
            setState(() => _selectedStatusFilter = 'expiringSoon');
          },
        ),
      ],
    );
  }

  Widget _buildInventorySummaryCards(
    bool isMobile,
    bool isTablet,
    Color textColor,
    Color secondaryTextColor,
  ) {
    int count = isMobile ? 2 : (isTablet ? 3 : 5);
    final cardsData = [
      {
        'title': 'Total Units',
        'count': '486',
        'icon': Icons.bloodtype_outlined,
        'color': AppTheme.primaryColor,
        'sub': 'Full bank stock',
      },
      {
        'title': 'Available',
        'count': '342',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF10B981),
        'sub': '↑ 12 units today',
      },
      {
        'title': 'Reserved',
        'count': '86',
        'icon': Icons.bookmark_border_rounded,
        'color': const Color(0xFF3B82F6),
        'sub': 'Allocated to cases',
      },
      {
        'title': 'Expiring Soon',
        'count': '18',
        'icon': Icons.access_time_rounded,
        'color': const Color(0xFFF59E0B),
        'sub': 'Within 7 days',
      },
      {
        'title': 'Critical Groups',
        'count': '2',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
        'sub': 'O- and B- low',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 0.85 : 1.4,
      ),
      itemCount: cardsData.length,
      itemBuilder: (context, index) {
        final card = cardsData[index];
        final color = card['color'] as Color;

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
                      card['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  GlassIconContainer(
                    icon: card['icon'] as IconData,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    card['count'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Text(
                card['sub'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCriticalAlertsSection(
    Color textColor,
    Color secondaryTextColor,
  ) {
    final alerts = [
      {
        'text':
            '⚠ O- stock is below minimum threshold (7 units available, 15 required).',
        'group': 'O-',
      },
      {
        'text':
            '⚠ B- stock may become critical within 48 hours based on surgical demand.',
        'group': 'B-',
      },
      {
        'text': '⚠ 18 blood units are expiring within the next 7 days.',
        'group': 'All',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Bank Critical Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: alerts.map((alt) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.zero,
              isStrong: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _selectedBloodGroupFilter = alt['group'] as String;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          alt['text'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBloodGroupOverview(
    bool isMobile,
    Color textColor,
    Color secondaryTextColor,
  ) {
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
                  'Blood Group Availability (Click card to filter table)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_selectedBloodGroupFilter != 'All')
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      setState(() => _selectedBloodGroupFilter = 'All'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      'Reset Filter',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 0.8 : 1.4,
            ),
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              final bg = _bloodGroups[index];
              final isSelected = _selectedBloodGroupFilter == bg.bloodGroup;
              final isCritical = bg.status == 'Critical';
              final color = isCritical
                  ? const Color(0xFFEF4444)
                  : (bg.status == 'Limited'
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981));

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(
                  () => _selectedBloodGroupFilter = isSelected
                      ? 'All'
                      : bg.bloodGroup,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              bg.bloodGroup,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          Icon(Icons.circle, color: color, size: 10),
                        ],
                      ),
                      Text(
                        'Avail: ${bg.available} units',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Reserved: ${bg.reserved} | Min: ${bg.minRequired}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: secondaryTextColor,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: bg.ratio.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
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

  Widget _buildStatusDistributionCard(
    bool isMobile,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Status Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: 342,
                    child: Container(color: const Color(0xFF10B981)),
                  ),
                  Expanded(
                    flex: 86,
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                  Expanded(
                    flex: 22,
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                color: const Color(0xFF10B981),
                label: 'Available (342)',
                textColor: secondaryTextColor,
              ),
              _buildLegendItem(
                color: const Color(0xFF3B82F6),
                label: 'Reserved (86)',
                textColor: secondaryTextColor,
              ),
              _buildLegendItem(
                color: const Color(0xFFF59E0B),
                label: 'Quarantine (22)',
                textColor: secondaryTextColor,
              ),
              _buildLegendItem(
                color: const Color(0xFF6B7280),
                label: 'Expired (6)',
                textColor: secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }

  Widget _buildBloodInventoryTable(
    bool isMobile,
    Color textColor,
    Color secondaryTextColor,
  ) {
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
                  'Blood Inventory Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Showing ${_filteredInventory.length} unit(s)',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 220,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: textColor),
                  decoration: GlassTextFieldTheme.getDecoration(
                    context: context,
                    hintText: 'Search unit ID or group...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),
              _buildSafeFilterDropdown(
                label: 'Group: $_selectedBloodGroupFilter',
                value: _selectedBloodGroupFilter,
                options: const [
                  'All',
                  'A+',
                  'A-',
                  'B+',
                  'B-',
                  'AB+',
                  'AB-',
                  'O+',
                  'O-',
                ],
                onChanged: (value) =>
                    setState(() => _selectedBloodGroupFilter = value),
                textColor: textColor,
              ),
              _buildSafeFilterDropdown(
                label: 'Comp: $_selectedComponentFilter',
                value: _selectedComponentFilter,
                options: const [
                  'All',
                  'Whole Blood',
                  'RBC',
                  'Fresh Frozen Plasma',
                  'Platelets',
                ],
                onChanged: (value) =>
                    setState(() => _selectedComponentFilter = value),
                textColor: textColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _filteredInventory.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No blood units match the active search/filter criteria.',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                )
              : (isMobile
                    ? Column(
                        children: _filteredInventory.map((unit) {
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE11D48,
                                  ).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unit.bloodGroup,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${unit.unitId} (${unit.component})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                '${unit.storageLocation} • Expiry: ${unit.expiryDate.day}/${unit.expiryDate.month}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: secondaryTextColor),
                              ),
                              trailing: Text(
                                unit.status.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.white.withValues(alpha: 0.05),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Blood Group',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Unit ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Component',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Quantity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Expiry Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Storage Unit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                          rows: _filteredInventory.map((unit) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    unit.bloodGroup,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE11D48),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    unit.unitId,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    unit.component,
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${unit.quantityUnits} Unit',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${unit.expiryDate.day}/${unit.expiryDate.month}/${unit.expiryDate.year}',
                                    style: TextStyle(color: secondaryTextColor),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      unit.status.name,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    unit.storageLocation,
                                    style: TextStyle(color: secondaryTextColor),
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

  Widget _buildSafeFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required Color textColor,
  }) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF102422) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                label.startsWith('Group')
                    ? 'Select Blood Group'
                    : 'Select Component',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      final selected = option == value;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(dialogContext).pop(option),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryColor.withValues(alpha: 0.12)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.black.withValues(alpha: 0.025)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.08)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label.startsWith('Group')
                                      ? 'Group: $option'
                                      : 'Comp: $option',
                                  style: TextStyle(
                                    color: selected
                                        ? AppTheme.primaryColor
                                        : textColor,
                                    fontSize: 12.5,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );

        if (selected != null && mounted) {
          onChanged(selected);
        }
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryMonitorCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expiry Monitor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track expiring units across timeline horizons',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildExpiryStat(
                  'Today',
                  '2 units',
                  const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpiryStat(
                  'Next 3D',
                  '6 units',
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExpiryStat(
                  'Next 7D',
                  '18 units',
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SafePrimaryButton(
            onPressed: () =>
                setState(() => _selectedStatusFilter = 'expiringSoon'),
            height: 42,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'View Expiring Units',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryStat(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodComponentsCard(Color textColor, Color secondaryTextColor) {
    final components = [
      {'name': 'Whole Blood', 'avail': 140, 'reserved': 32, 'exp': 5},
      {'name': 'Red Blood Cells', 'avail': 182, 'reserved': 42, 'exp': 9},
      {'name': 'Platelets', 'avail': 54, 'reserved': 18, 'exp': 6},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Components Tracker',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: components.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comp['name'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Avail: ${comp['avail']} | Res: ${comp['reserved']}',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
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

  Widget _buildDonationManagementCard(
    Color textColor,
    Color secondaryTextColor,
  ) {
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
                  'Recent Blood Donations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              _SafePrimaryButton(
                onPressed: _openRecordDonationModal,
                height: 36,
                color: const Color(0xFF10B981),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Record',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.05),
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Donor ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Group',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Screening',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
              rows: _donations.map((d) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        d.donorId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        d.bloodGroup,
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        d.donationType,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                    DataCell(
                      Text(
                        d.screeningStatus,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodRequestsCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Department Blood Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _SafePrimaryButton(
                onPressed: _openCreateRequestModal,
                height: 36,
                color: const Color(0xFFD97706),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'New Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // IMPORTANT:
          // Give the request list a finite layout on mobile.
          if (_requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No blood requests available.',
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
              ),
            )
          else
            ..._requests.map((req) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthifyGlassTheme.getGlassSurface(
                      HealthifyGlassTheme.isDark(context),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: HealthifyGlassTheme.getGlassBorder(
                        HealthifyGlassTheme.isDark(context),
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${req.requestId} (${req.bloodGroup}) — ${req.requiredUnits} Units',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Dept: ${req.department} • Priority: ${req.priority.name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      _SafeSecondaryButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Allocated units for ${req.requestId}',
                              ),
                            ),
                          );
                        },
                        height: 32,
                        child: const Text(
                          'Allocate',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAllocationWorkflowCard(
    bool isMobile,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final steps = [
      'Request',
      'Compatibility',
      'Available Stock',
      'Reserved',
      'Allocated',
      'Issued',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Allocation & Release Workflow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: steps.map((st) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  st,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDemandForecastCard(Color textColor, Color secondaryTextColor) {
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
                  'AI Blood Demand Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AI Forecast',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Predicted Next 7 Days: O- Demand may exceed inventory (+18 units projected).',
            style: TextStyle(fontSize: 12.5, height: 1.4, color: textColor),
          ),
          const SizedBox(height: 12),
          const Text(
            'Prediction Confidence: 89%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTrendCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(
                'Blood Usage & Demand Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: ['24H', '7D', '30D', '90D'].map((t) {
                  return _SafeSelectionChip(
                    label: t,
                    isSelected: _chartTrendFilter == t,
                    onTap: () => setState(() => _chartTrendFilter = t),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BloodUsageTrendChart(filter: _chartTrendFilter),
        ],
      ),
    );
  }

  Widget _buildPotentialShortagesCard(
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Potential Blood Shortages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'O- Shortage: Current stock 7, Predicted demand 18 (Deficit: 11 units)',
            style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationNeedsCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Donation Needs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _SafePrimaryButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donation campaign draft generated'),
                ),
              );
            },
            height: 42,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Create Donation Campaign',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageOverviewCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Unit Capacity Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Refrigerator A: 78% | Refrigerator B: 64% | Freezer A: 52%',
            style: TextStyle(fontSize: 12.5, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIfSimulatorCard(Color textColor, Color secondaryTextColor) {
    int current = 7;
    int projected = current + _simIncomingDonation - _simEmergencyDemand;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What-If Blood Simulator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Simulated Stock ($_simBloodGroup): $projected units',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: secondaryTextColor,
                    ),
                    onPressed: () => setState(() => _simEmergencyDemand++),
                  ),
                  Text(
                    'Demand: $_simEmergencyDemand',
                    style: TextStyle(color: textColor),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () => setState(() => _simIncomingDonation++),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAppAvailabilityCard(
    Color textColor,
    Color secondaryTextColor,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient App Availability Governance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Control public patient mobile app blood availability statuses',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _patientAppVisibility.entries.map((entry) {
              final isAvail = entry.value == 'Available';
              final isCrit = entry.value == 'Critical';
              final color = isCrit
                  ? const Color(0xFFEF4444)
                  : (isAvail
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B));

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.circle, color: color, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IMPORTANT: Donor identity, patient identity, unit IDs, and internal storage locations are strictly hidden from the public patient app.',
                    style: TextStyle(fontSize: 11.5, color: textColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _SafePrimaryButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient App availability settings updated.'),
                ),
              );
            },
            height: 44,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security_rounded, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Show Availability to Patients',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(Color textColor, Color secondaryTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity Logs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '2m ago: O- unit reserved for Emergency',
            style: TextStyle(fontSize: 12.5, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _SafePrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final Color color;
  final bool isLoading;

  const _SafePrimaryButton({
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = 15,
    this.color = AppTheme.primaryColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

class _SafeSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;

  const _SafeSecondaryButton({
    required this.onPressed,
    required this.child,
    this.height = 50,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _SafeSelectionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _SafeSelectionChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor = HealthifyGlassTheme.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : HealthifyGlassTheme.getGlassSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : HealthifyGlassTheme.getGlassBorder(isDark),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? activeColor
                    : HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : HealthifyGlassTheme.getTextSecondary(isDark),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SafePrimaryButton(
      onPressed: onTap,
      height: 40,
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
