import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class WhatIfSimulatorWidget extends StatefulWidget {
  const WhatIfSimulatorWidget({super.key});

  @override
  State<WhatIfSimulatorWidget> createState() => _WhatIfSimulatorWidgetState();
}

class _WhatIfSimulatorWidgetState extends State<WhatIfSimulatorWidget> {
  double _additionalPatients = 10;
  double _doctorAbsence = 2;
  bool _isSimulationActive = false;

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    // Dynamic simulated outcomes
    final baseOccupancy = 84.0;
    final simulatedOccupancy = (baseOccupancy + (_additionalPatients * 0.6)).clamp(0.0, 100.0);

    final baseWaitTime = 14;
    final simulatedWaitTime = (baseWaitTime + (_additionalPatients * 1.5) + (_doctorAbsence * 4)).toInt();

    final isSevere = simulatedOccupancy > 90 || simulatedWaitTime > 30;

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              GlassIconContainer(
                icon: Icons.alt_route_rounded,
                color: _isSimulationActive
                    ? (isSevere ? const Color(0xFFE11D48) : AppTheme.primaryColor)
                    : (isDark ? Colors.white60 : AppTheme.textSecondary),
                size: 38,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'What-If Hospital Scenario Simulator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isSimulationActive
                                ? AppTheme.primaryColor
                                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.textMuted.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isSimulationActive ? 'SIMULATING' : 'IDLE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _isSimulationActive ? Colors.white : (isDark ? Colors.white70 : AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Simulate emergency patient surges or staff shortages to test hospital capacity response.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Sliders Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPatientSlider(context)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildStaffSlider(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPatientSlider(context),
                        const SizedBox(height: 12),
                        _buildStaffSlider(context),
                      ],
                    );
            },
          ),

          const SizedBox(height: 18),

          // Predicted Impact Results Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSevere
                  ? (isDark ? const Color(0xFF4C0519).withValues(alpha: 0.5) : const Color(0xFFFFF1F2))
                  : HealthifyGlassTheme.getGlassSurface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSevere
                    ? const Color(0xFFE11D48).withValues(alpha: 0.4)
                    : HealthifyGlassTheme.getGlassBorder(isDark),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSevere ? Icons.warning_amber_rounded : Icons.analytics_outlined,
                          color: isSevere ? const Color(0xFFE11D48) : AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Simulated Impact Prediction',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSevere
                                ? (isDark ? const Color(0xFFFDA4AF) : const Color(0xFF9F1239))
                                : (isDark ? Colors.white : AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    if (_isSimulationActive)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _additionalPatients = 10;
                            _doctorAbsence = 2;
                            _isSimulationActive = false;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Reset', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metrics Comparison Cards
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildMetricBox(
                      context,
                      title: 'Bed Occupancy',
                      original: '84%',
                      simulated: '${simulatedOccupancy.toStringAsFixed(1)}%',
                      isDanger: simulatedOccupancy > 88,
                    ),
                    _buildMetricBox(
                      context,
                      title: 'Est. ER Wait Time',
                      original: '14 min',
                      simulated: '$simulatedWaitTime min',
                      isDanger: simulatedWaitTime > 25,
                    ),
                    _buildMetricBox(
                      context,
                      title: 'Staff Load Index',
                      original: '72%',
                      simulated: '${(72 + (_additionalPatients * 1.2) + (_doctorAbsence * 5)).clamp(0, 100).toInt()}%',
                      isDanger: (72 + (_additionalPatients * 1.2) + (_doctorAbsence * 5)) > 85,
                    ),
                  ],
                ),

                if (isSevere) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F2928) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDA4AF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Warning: Emergency intake capacity exceeded! Immediate bed reallocation & call-in doctors required.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFF9F1239),
                            ),
                          ),
                        ),
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

  Widget _buildPatientSlider(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Simulate Patient Surge (+ Patients)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+${_additionalPatients.toInt()} Patients',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ],
        ),
        Slider(
          value: _additionalPatients,
          min: 0,
          max: 40,
          divisions: 40,
          activeColor: AppTheme.primaryColor,
          label: '+${_additionalPatients.toInt()}',
          onChanged: (val) {
            setState(() {
              _additionalPatients = val;
              _isSimulationActive = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStaffSlider(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Simulate Staff Absence (- Doctors)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '-${_doctorAbsence.toInt()} Doctors',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
            ),
          ],
        ),
        Slider(
          value: _doctorAbsence,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: const Color(0xFFEF4444),
          label: '-${_doctorAbsence.toInt()}',
          onChanged: (val) {
            setState(() {
              _doctorAbsence = val;
              _isSimulationActive = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String original,
    required String simulated,
    required bool isDanger,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDanger ? const Color(0xFFFDA4AF) : HealthifyGlassTheme.getGlassBorder(isDark),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                original,
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                  color: isDark ? Colors.white38 : AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 12, color: isDark ? Colors.white38 : AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                simulated,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDanger ? const Color(0xFFE11D48) : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}