import 'package:flutter/material.dart';
import '../../core/data/mock/mock_analytics_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/analytics_model.dart';
import '../../core/queries/domain_queries.dart';
import '../../core/services/analytics_service.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class OperationalAnalyticsScreen extends StatefulWidget {
  const OperationalAnalyticsScreen({super.key});

  @override
  State<OperationalAnalyticsScreen> createState() => _OperationalAnalyticsScreenState();
}

class _OperationalAnalyticsScreenState extends State<OperationalAnalyticsScreen> {
  late AnalyticsService _analyticsService;

  bool _isLoading = true;
  String? _errorMessage;

  HospitalOperationalKpis? _kpis;
  List<BedOccupancyMetric> _bedMetrics = [];
  List<ICUUtilizationMetric> _icuMetrics = [];
  List<OPDSlotEfficiencyMetric> _opdMetrics = [];
  List<AverageLengthOfStayMetric> _losMetrics = [];
  List<EmergencyThroughputMetric> _erMetrics = [];
  List<BloodStockMetric> _bloodMetrics = [];
  List<EquipmentDowntimeMetric> _equipmentMetrics = [];
  List<NoShowMetric> _noShowMetrics = [];

  String _selectedDateRange = '7 Days';
  AnalyticsGranularity _selectedGranularity = AnalyticsGranularity.day;

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
    _analyticsService = AnalyticsService(analyticsRepository: MockAnalyticsRepository());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = AnalyticsQuery(granularity: _selectedGranularity);
      final kpis = await _analyticsService.getHospitalKpis(query: query);
      final bed = await _analyticsService.getBedOccupancy(query: query);
      final icu = await _analyticsService.getICUUtilization(query: query);
      final opd = await _analyticsService.getOPDSlotEfficiency(query: query);
      final los = await _analyticsService.getAverageLengthOfStay(query: query);
      final er = await _analyticsService.getEmergencyThroughput(query: query);
      final blood = await _analyticsService.getBloodStockMetrics(query: query);
      final equipment = await _analyticsService.getEquipmentDowntime(query: query);
      final noShow = await _analyticsService.getNoShowRate(query: query);

      if (mounted) {
        setState(() {
          _kpis = kpis;
          _bedMetrics = bed;
          _icuMetrics = icu;
          _opdMetrics = opd;
          _losMetrics = los;
          _erMetrics = er;
          _bloodMetrics = blood;
          _equipmentMetrics = equipment;
          _noShowMetrics = noShow;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load operational analytics: $e';
          _isLoading = false;
        });
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
                  Expanded(
                    child: _isLoading
                        ? const MedrixLoadingState(message: 'Loading hospital operational analytics & trends...')
                        : _errorMessage != null
                            ? MedrixErrorState(
                                errorMessage: _errorMessage!,
                                onRetry: _loadData,
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildKpiGrid(isDark, isDesktop),
                                    const SizedBox(height: 24),
                                    _buildChartSection(
                                      isDark,
                                      title: 'Bed & ICU Utilization Velocity',
                                      subtitle: 'Daily bed occupancy rate (%) vs ICU capacity pressure',
                                      child: _buildBedTrendBar(isDark),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartSection(
                                      isDark,
                                      title: 'ICU Critical Pressure Trend',
                                      subtitle: 'Occupied vs available ICU critical care beds',
                                      child: _buildIcuTrendBar(isDark),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartSection(
                                      isDark,
                                      title: 'OPD Slot Efficiency & No-Show Rate',
                                      subtitle: 'Completed OPD slots vs patient no-show percentage',
                                      child: _buildOpdTrendBar(isDark),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartSection(
                                      isDark,
                                      title: 'Emergency Room Triage Throughput',
                                      subtitle: 'Average minutes from triage registration to doctor consultation',
                                      child: _buildErThroughputBar(isDark),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartSection(
                                      isDark,
                                      title: 'Blood Bank Depletion Velocity & Inventory',
                                      subtitle: 'Units issued vs ending stock velocity by group',
                                      child: _buildBloodStockList(isDark),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildChartSection(
                                      isDark,
                                      title: 'Equipment Downtime & Maintenance Ratio',
                                      subtitle: 'Equipment operational downtime hours vs available hours',
                                      child: _buildEquipmentDowntimeBar(isDark),
                                    ),
                                  ],
                                ),
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
    final granularityDropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsGranularity>(
          value: _selectedGranularity,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedGranularity = val);
              _loadData();
            }
          },
          items: AnalyticsGranularity.values.map((g) => DropdownMenuItem(value: g, child: Text(g.name.toUpperCase()))).toList(),
        ),
      ),
    );

    final dateRangeDropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDateRange,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedDateRange = val);
              _loadData();
            }
          },
          items: const [
            DropdownMenuItem(value: 'Today', child: Text('Today')),
            DropdownMenuItem(value: '7 Days', child: Text('Last 7 Days')),
            DropdownMenuItem(value: '30 Days', child: Text('Last 30 Days')),
            DropdownMenuItem(value: '90 Days', child: Text('Last 90 Days')),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: isDesktop
          ? Row(
              children: [
                const GlassIconContainer(
                  icon: Icons.analytics_rounded,
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
                        'HOSPITAL OPERATIONAL ANALYTICS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Real-Time KPI Metrics, Throughput Velocity & Historical Trends',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                granularityDropdown,
                const SizedBox(width: 8),
                dateRangeDropdown,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.analytics_rounded,
                      size: 40,
                      iconSize: 22,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPERATIONAL ANALYTICS',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Real-Time KPI Metrics & Trends',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    granularityDropdown,
                    dateRangeDropdown,
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildKpiGrid(bool isDark, bool isDesktop) {
    if (_kpis == null) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      childAspectRatio: isDesktop ? 1.8 : 0.95,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _kpiCard('Bed Occupancy Rate', '${_kpis!.bedOccupancyRate}%', _kpis!.bedOccupancyChange, Icons.king_bed_rounded, Colors.blue, isDark),
        _kpiCard('ICU Utilization', '${_kpis!.icuUtilizationRate}%', _kpis!.icuChange, Icons.local_hospital_rounded, Colors.redAccent, isDark),
        _kpiCard('OPD Slot Efficiency', '${_kpis!.opdSlotEfficiency}%', _kpis!.opdChange, Icons.event_available_rounded, Colors.teal, isDark),
        _kpiCard('Avg Length of Stay', '${_kpis!.averageLengthOfStay} d (${_losMetrics.isEmpty ? '4.2' : _losMetrics.last.averageDays.toStringAsFixed(1)})', _kpis!.lengthOfStayChange, Icons.timer_rounded, Colors.purple, isDark),
        _kpiCard('ER Triage-to-Doctor', '${_kpis!.erTriageToDoctorMinutes} min', _kpis!.erTimeChange, Icons.emergency_rounded, Colors.orange, isDark),
        _kpiCard('Blood Stock Depletion', '${_kpis!.bloodStockDepletionVelocity} u/d', _kpis!.bloodVelocityChange, Icons.bloodtype_rounded, Colors.red, isDark),
        _kpiCard('Equipment Downtime', '${_kpis!.equipmentDowntimeRatio}%', _kpis!.downtimeChange, Icons.build_rounded, Colors.amber, isDark),
        _kpiCard('No-Show Rate', '${_kpis!.noShowRate}% (${_noShowMetrics.isEmpty ? '6.8' : _noShowMetrics.last.noShowRate.toStringAsFixed(1)}%)', _kpis!.noShowChange, Icons.person_off_rounded, Colors.deepOrange, isDark),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String change, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: change.contains('-') ? Colors.green.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(change, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: change.contains('-') ? Colors.green : Colors.blue)),
              ),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          Text(title, style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark))),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isDark, {required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
          Text(subtitle, style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBedTrendBar(bool isDark) {
    return SizedBox(
      height: 120,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _bedMetrics.map((m) {
            final h = ((m.occupancyRate / 100) * 50).clamp(6.0, 50.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${m.occupancyRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: h,
                    decoration: BoxDecoration(
                      color: HealthifyGlassTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIcuTrendBar(bool isDark) {
    return SizedBox(
      height: 120,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _icuMetrics.map((m) {
            final h = ((m.utilizationRate / 100) * 50).clamp(6.0, 50.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${m.utilizationRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOpdTrendBar(bool isDark) {
    return SizedBox(
      height: 120,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _opdMetrics.map((m) {
            final h = ((m.utilizationRate / 100) * 50).clamp(6.0, 50.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${m.utilizationRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErThroughputBar(bool isDark) {
    return SizedBox(
      height: 120,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _erMetrics.map((m) {
            final h = ((m.averageTriageToDoctorMinutes / 20) * 50).clamp(6.0, 50.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${m.averageTriageToDoctorMinutes.toStringAsFixed(1)}m', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBloodStockList(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _bloodMetrics.map((b) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${b.bloodGroup}: ${b.endingUnits} units (Issued: ${b.unitsIssued})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.redAccent),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentDowntimeBar(bool isDark) {
    return SizedBox(
      height: 100,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _equipmentMetrics.map((m) {
            final h = ((m.downtimeRatio / 5) * 50).clamp(6.0, 50.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${m.downtimeRatio.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(m.date.day.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
