import 'package:flutter/material.dart';
import '../../core/data/mock/mock_ai_insight_repository.dart';
import '../../core/enums/domain_enums.dart';
import '../../core/models/ai_insight_model.dart';
import '../../core/services/ai_insight_service.dart';
import '../../core/widgets/medrix_empty_state.dart';
import '../../core/widgets/medrix_error_state.dart';
import '../../core/widgets/medrix_loading_state.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/responsive.dart';

class AIInsightsCenterScreen extends StatefulWidget {
  const AIInsightsCenterScreen({super.key});

  @override
  State<AIInsightsCenterScreen> createState() => _AIInsightsCenterScreenState();
}

class _AIInsightsCenterScreenState extends State<AIInsightsCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AIService _aiService;

  bool _isLoading = true;
  String? _errorMessage;

  List<AIInsight> _insights = [];
  List<AIModelMetadata> _models = [];
  List<DoctorWorkloadForecast> _doctorForecasts = [];
  List<BloodDemandForecast> _bloodForecasts = [];
  BedOccupancyForecast? _bedForecast;
  ICUCapacityForecast? _icuForecast;
  HospitalCapacityForecast? _hospitalForecast;
  List<QueueForecast> _queueForecasts = [];
  WhatIfSimulationResult? _simulationResult;

  AIInsight? _selectedInsight;
  int _simulatedIcuBeds = 4;

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
    _tabController = TabController(length: 4, vsync: this);
    _aiService = AIService(aiRepository: MockAIInsightRepository());
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
      final insights = await _aiService.getInsights();
      final models = await _aiService.getModelMetadata();
      final doctor = await _aiService.getDoctorAvailabilityForecast();
      final blood = await _aiService.getBloodDemandForecast();
      final bed = await _aiService.getBedOccupancyForecast();
      final icu = await _aiService.getICUCapacityForecast();
      final hospital = await _aiService.getHospitalCapacityForecast();
      final queue = await _aiService.getQueueForecast();
      final sim = await _aiService.simulateWhatIf(
        'Add Step-Down ICU Overflow Beds',
        {'addedICUBeds': _simulatedIcuBeds},
      );

      if (mounted) {
        setState(() {
          _insights = insights;
          _models = models;
          _doctorForecasts = doctor;
          _bloodForecasts = blood;
          _bedForecast = bed;
          _icuForecast = icu;
          _hospitalForecast = hospital;
          _queueForecasts = queue;
          _simulationResult = sim;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load AI/ML insights: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleInsightAction(AIInsight insight, RecommendationStatus status) async {
    try {
      await _aiService.reviewInsight(insight.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insight marked as ${status.name.toUpperCase()}'),
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
                    controller: _tabController,
                    indicatorColor: HealthifyGlassTheme.primaryTeal,
                    labelColor: HealthifyGlassTheme.primaryTeal,
                    unselectedLabelColor: HealthifyGlassTheme.getTextSecondary(isDark),
                    tabs: const [
                      Tab(icon: Icon(Icons.lightbulb_rounded), text: 'AI Insights & Alerts'),
                      Tab(icon: Icon(Icons.show_chart_rounded), text: 'Capacity & Demand Forecasts'),
                      Tab(icon: Icon(Icons.alt_route_rounded), text: 'What-If Operational Simulator'),
                      Tab(icon: Icon(Icons.memory_rounded), text: 'AI Models & Metadata'),
                    ],
                  ),
                  Expanded(
                    child: _isLoading
                        ? const MedrixLoadingState(message: 'Initializing AI/ML forecasting pipeline...')
                        : _errorMessage != null
                            ? MedrixErrorState(
                                errorMessage: _errorMessage!,
                                onRetry: _loadData,
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildInsightsTab(isDark, isDesktop),
                                  _buildForecastsTab(isDark, isDesktop),
                                  _buildSimulatorTab(isDark, isDesktop),
                                  _buildModelsTab(isDark, isDesktop),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedInsight != null) _buildInsightDetailDrawer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Row(
        children: [
          const GlassIconContainer(
            icon: Icons.psychology_rounded,
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
                  'AI & FORECASTING INSIGHT CENTER',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 15,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
                Text(
                  'Predictive Operational Analytics, Capacity Forecasters & What-If Simulations',
                  style: TextStyle(
                    fontSize: 12,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.purple, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_models.where((m) => m.status == AIModelStatus.active).length} Models Active',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: AI INSIGHTS & ALERTS
  // ---------------------------------------------------------------------------
  Widget _buildInsightsTab(bool isDark, bool isDesktop) {
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
              Icon(Icons.shield_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI ADVISORY PRINCIPLE: Predictions represent machine learning operational forecasts. AI does NOT execute autonomous clinical decisions or automatic resource mutations. Review and confirm action.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _insights.isEmpty
              ? const MedrixEmptyState(
                  title: 'No AI Insights Currently Active',
                  description: 'All hospital capacity metrics are operating within normal baseline parameters.',
                  icon: Icons.lightbulb_outline_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _insights.length,
                  itemBuilder: (context, index) {
                    final ins = _insights[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _buildSeverityIcon(ins.severity),
                        title: Row(
                          children: [
                            Expanded(child: Text(ins.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            _buildSeverityBadge(ins.severity),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(ins.summary),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('${(ins.confidence * 100).toStringAsFixed(0)}% model confidence', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal)),
                                const SizedBox(width: 12),
                                Text(ins.isExpired ? 'Forecast expired' : 'Expires in ${ins.expiresAt.difference(DateTime.now()).inHours}h', style: TextStyle(fontSize: 11, color: ins.isExpired ? Colors.red : Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onPressed: () => setState(() => _selectedInsight = ins),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSeverityIcon(AIInsightSeverity severity) {
    switch (severity) {
      case AIInsightSeverity.critical:
        return const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32);
      case AIInsightSeverity.high:
        return const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 32);
      case AIInsightSeverity.medium:
        return const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 32);
      default:
        return const Icon(Icons.lightbulb_outline_rounded, color: Colors.teal, size: 32);
    }
  }

  Widget _buildSeverityBadge(AIInsightSeverity severity) {
    Color bg;
    switch (severity) {
      case AIInsightSeverity.critical:
        bg = Colors.redAccent;
        break;
      case AIInsightSeverity.high:
        bg = Colors.orange;
        break;
      case AIInsightSeverity.medium:
        bg = Colors.blue;
        break;
      default:
        bg = Colors.teal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(severity.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: CAPACITY & DEMAND FORECASTS
  // ---------------------------------------------------------------------------
  Widget _buildForecastsTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForecastCard(
            isDark,
            title: 'Hospital Capacity & Pressure Forecast',
            subtitle: 'Predicted 24h bed, ICU, doctor, and nursing load',
            icon: Icons.local_hospital_rounded,
            child: _hospitalForecast != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Capacity Pressure: ${_hospitalForecast!.overallCapacityPressure.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                          const SizedBox(width: 8),
                          Text('${(_hospitalForecast!.confidence * 100).toStringAsFixed(0)}% model confidence', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Bed Occupancy: ${_hospitalForecast!.predictedBedOccupancy}/${_hospitalForecast!.bedCapacity} beds'),
                      Text('ICU Occupancy: ${_hospitalForecast!.predictedICUOccupancy}/${_hospitalForecast!.icuCapacity} beds'),
                      Text('Doctor Workload: ${_hospitalForecast!.predictedDoctorLoad}/${_hospitalForecast!.doctorCapacity} doctors on shift'),
                    ],
                  )
                : const Text('Forecast data unavailable.'),
          ),
          const SizedBox(height: 16),
          _buildForecastCard(
            isDark,
            title: 'Ward & ICU Bed Occupancy Forecast',
            subtitle: 'Real-time projected occupancy and available beds',
            icon: Icons.single_bed_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_bedForecast != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Ward Beds: ${_bedForecast!.predictedOccupancy} occupied, ${_bedForecast!.predictedAvailableBeds} available (${(_bedForecast!.confidence * 100).toStringAsFixed(0)}% confidence)',
                      style: TextStyle(fontWeight: FontWeight.w500, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                    ),
                  ),
                if (_icuForecast != null)
                  Text(
                    'ICU Beds: ${_icuForecast!.predictedOccupancy} occupied, ${_icuForecast!.predictedAvailableBeds} available (${(_icuForecast!.confidence * 100).toStringAsFixed(0)}% confidence)',
                    style: TextStyle(fontWeight: FontWeight.w500, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildForecastCard(
            isDark,
            title: 'Emergency & OPD Wait-Time Forecast',
            subtitle: 'Predicted queue depth and wait times by department',
            icon: Icons.queue_rounded,
            child: Column(
              children: _queueForecasts.map((q) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(q.departmentName, style: TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark))),
                  subtitle: Text('Queue Depth: ${q.predictedQueue} patients • Wait Time: ${q.predictedWaitMinutes} mins', style: TextStyle(color: HealthifyGlassTheme.getTextSecondary(isDark))),
                  trailing: Text('${(q.confidence * 100).toStringAsFixed(0)}% confidence', style: const TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildForecastCard(
            isDark,
            title: 'Blood Stock Demand Forecast',
            subtitle: '3-Day depletion forecast and shortage risk by blood group',
            icon: Icons.bloodtype_rounded,
            child: Column(
              children: _bloodForecasts.map((b) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Blood Group ${b.bloodGroup} (${b.component})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Current: ${b.currentInventory} u • Predicted Demand: ${b.expectedDemand} u • Projected Stock: ${b.projectedInventory} u'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: b.shortageRisk == 'High' ? Colors.redAccent : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Risk: ${b.shortageRisk}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildForecastCard(
            isDark,
            title: 'Doctor Workload & Availability Forecast',
            subtitle: 'Expected appointments & emergency cases for next shift',
            icon: Icons.badge_rounded,
            child: Column(
              children: _doctorForecasts.map((d) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Expected Appointments: ${d.expectedAppointments} • ER Cases: ${d.expectedEmergencyLoad}'),
                  trailing: Text('Workload: ${d.expectedWorkload}', style: const TextStyle(fontWeight: FontWeight.bold, color: HealthifyGlassTheme.primaryTeal)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(bool isDark, {required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: HealthifyGlassTheme.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HealthifyGlassTheme.getTextPrimary(isDark)),
                ),
              ),
            ],
          ),
          Text(subtitle, style: TextStyle(fontSize: 11, color: HealthifyGlassTheme.getTextSecondary(isDark))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: WHAT-IF OPERATIONAL SIMULATOR
  // ---------------------------------------------------------------------------
  Widget _buildSimulatorTab(bool isDark, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.science_rounded, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'OPERATIONAL WHAT-IF SIMULATOR: Simulate resource capacity changes and observe predicted load balancing effects. Simulation does NOT mutate actual hospital database records.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _glassDecoration(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Simulation Scenario: Add Step-Down ICU Overflow Beds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Additional ICU Beds: '),
                    Expanded(
                      child: Slider(
                        value: _simulatedIcuBeds.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '+$_simulatedIcuBeds Beds',
                        onChanged: (val) {
                          setState(() => _simulatedIcuBeds = val.round());
                          _loadData();
                        },
                      ),
                    ),
                    Text('+$_simulatedIcuBeds Beds', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_simulationResult != null) ...[
                  const Text('Simulated Impact Result:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Metric: ${_simulationResult!.currentMetric}'),
                        Text('Simulated Metric: ${_simulationResult!.simulatedMetric}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Projected Change: ${_simulationResult!.projectedChange}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        Text('Simulation Confidence: ${(_simulationResult!.confidence * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: AI MODELS & METADATA
  // ---------------------------------------------------------------------------
  Widget _buildModelsTab(bool isDark, bool isDesktop) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _models.length,
      itemBuilder: (context, index) {
        final m = _models[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.memory_rounded, color: HealthifyGlassTheme.primaryTeal),
            title: Text('${m.modelName} (${m.version})', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ID: ${m.modelId} • Horizon: ${m.predictionHorizon}\nTraining Range: ${m.trainingDataRange}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
              child: Text(m.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DETAIL DRAWER
  // ---------------------------------------------------------------------------
  Widget _buildInsightDetailDrawer(bool isDark) {
    final ins = _selectedInsight!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: screenWidth < 500 ? screenWidth * 0.9 : 450,
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
                  Expanded(child: Text('AI Insight: ${ins.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedInsight = null)),
                ],
              ),
              const Divider(),
              Text(ins.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(ins.summary),
              const SizedBox(height: 16),
              const Text('Recommendation:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(ins.recommendation, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              if (ins.explanation != null) ...[
                const Text('Model Explanation & Contributing Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(ins.explanation!.summary),
                const SizedBox(height: 6),
                ...ins.explanation!.factors.map((f) => Text('• $f', style: const TextStyle(fontSize: 12))),
                const SizedBox(height: 8),
                Text('Limitations: ${ins.explanation!.limitations}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleInsightAction(ins, RecommendationStatus.rejected),
                      child: const Text('Reject Insight'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: HealthifyGlassTheme.primaryTeal),
                      onPressed: () => _handleInsightAction(ins, RecommendationStatus.accepted),
                      child: const Text('Confirm Action', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
