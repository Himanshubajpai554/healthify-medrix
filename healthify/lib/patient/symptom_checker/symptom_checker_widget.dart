import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './symptom_checker_service.dart';
import '../appointments/book_appointment_modal.dart';
import '../emergency/emergency_hospitals_modal.dart';

class SymptomCheckerWidget extends StatefulWidget {
  final Function(String)? onBookingSuccess;

  const SymptomCheckerWidget({super.key, this.onBookingSuccess});

  @override
  State<SymptomCheckerWidget> createState() => _SymptomCheckerWidgetState();
}

class _SymptomCheckerWidgetState extends State<SymptomCheckerWidget> {
  final _textController = TextEditingController();
  SymptomAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  final List<String> _sampleSymptoms = const [
    'Chest tightness and rapid heart rate',
    'Severe headache, dizziness and blurred vision',
    'Shortness of breath and wheezing',
    'Severe knee pain and joint swelling',
    'Child high fever and vomiting',
  ];

  Color _surface(bool dark) => dark
      ? Colors.white.withValues(alpha: .045)
      : Colors.white.withValues(alpha: .72);
  Color _surfaceStrong(bool dark) => dark
      ? Colors.white.withValues(alpha: .075)
      : Colors.white.withValues(alpha: .90);
  Color _border(bool dark) => dark
      ? Colors.white.withValues(alpha: .085)
      : Colors.white.withValues(alpha: .88);
  Color _primaryText(bool dark) => dark ? Colors.white : AppTheme.textPrimary;
  Color _secondaryText(bool dark) =>
      dark ? Colors.white.withValues(alpha: .55) : AppTheme.textSecondary;

  Widget _glassCard({
    required bool dark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double radius = 22,
    Color? accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _surface(dark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: accent != null
                  ? accent.withValues(alpha: dark ? .22 : .18)
                  : _border(dark),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .17 : .035),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              if (accent != null)
                BoxShadow(
                  color: accent.withValues(alpha: dark ? .055 : .035),
                  blurRadius: 22,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _background({required bool dark, required Widget child}) => Stack(
    children: [
      Positioned(
        top: -100,
        right: -80,
        child: IgnorePointer(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: dark ? .065 : .055),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -120,
        left: -90,
        child: IgnorePointer(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withValues(alpha: dark ? .035 : .025),
            ),
          ),
        ),
      ),
      child,
    ],
  );

  void _runAnalysis([String? customText]) {
    final query = customText ?? _textController.text;
    if (query.trim().isEmpty) return;
    if (customText != null) _textController.text = customText;
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final result = SymptomCheckerService.analyzeHealthConcern(query);
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _background(
      dark: dark,
      child: _glassCard(
        dark: dark,
        radius: 24,
        accent: _primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: dark ? .13 : .10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: dark ? .16 : .10),
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.purple,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Health Concern & Triage Analyzer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryText(dark),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Enter symptoms to find relevant department, doctors & emergency advice',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _secondaryText(dark),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: TextField(
                  controller: _textController,
                  maxLines: 2,
                  style: TextStyle(color: _primaryText(dark), fontSize: 14),
                  cursorColor: _primary,
                  decoration: InputDecoration(
                    hintText:
                        'Describe how you feel (e.g. "I have chest tightness and pressure on my left arm")...',
                    hintStyle: TextStyle(
                      color: _secondaryText(dark),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _primary,
                    ),
                    filled: true,
                    fillColor: _surfaceStrong(dark),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: _border(dark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: _border(dark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: _primary.withValues(alpha: dark ? .55 : .40),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _sampleSymptoms
                  .map(
                    (symptom) => ActionChip(
                      label: Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _primaryText(dark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: _surfaceStrong(dark),
                      side: BorderSide(color: _border(dark)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      onPressed: () => _runAnalysis(symptom),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : () => _runAnalysis(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withValues(alpha: .55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 19),
                label: Text(
                  _isAnalyzing
                      ? 'Analyzing Symptoms...'
                      : 'Analyze Health Concern & Match Doctor',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (_analysisResult != null) ...[
              const SizedBox(height: 20),
              _buildAnalysisResultCard(context, _analysisResult!, dark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard(
    BuildContext context,
    SymptomAnalysisResult result,
    bool dark,
  ) {
    Color urgencyColor;
    String urgencyLabel;
    IconData urgencyIcon;
    switch (result.urgency) {
      case UrgencyLevel.emergency:
        urgencyColor = Colors.red;
        urgencyLabel = 'CRITICAL EMERGENCY';
        urgencyIcon = Icons.warning_amber_rounded;
        break;
      case UrgencyLevel.urgent:
        urgencyColor = Colors.orange;
        urgencyLabel = 'HIGH URGENCY';
        urgencyIcon = Icons.error_outline_rounded;
        break;
      case UrgencyLevel.routine:
        urgencyColor = _primary;
        urgencyLabel = 'ROUTINE CONSULTATION';
        urgencyIcon = Icons.info_outline_rounded;
        break;
    }

    return _glassCard(
      dark: dark,
      padding: const EdgeInsets.all(16),
      radius: 20,
      accent: urgencyColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgencyIcon, color: urgencyColor, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    urgencyLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: dark ? .13 : .10),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: dark ? .18 : .12),
                    ),
                  ),
                  child: Text(
                    'Dept: ${result.recommendedDepartment}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dark
                          ? const Color(0xFFD8B4FE)
                          : Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.advice,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: result.urgency == UrgencyLevel.emergency
                  ? (dark ? const Color(0xFFFF8A8A) : Colors.red.shade900)
                  : _primaryText(dark),
            ),
          ),
          if (result.urgency == UrgencyLevel.emergency) ...[
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => EmergencyHospitalsModal.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.local_hospital_rounded, size: 18),
                label: const Text(
                  'View Emergency Hospitals & Free ICU Beds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(height: 1, color: _border(dark)),
          const SizedBox(height: 12),
          Text(
            'Recommended Specialist Doctors (${result.recommendedDepartment}):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: _primaryText(dark),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: result.suggestedDoctors
                .take(2)
                .map(
                  (doc) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: _surfaceStrong(dark),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _border(dark)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: dark ? .14 : .10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primary.withValues(
                                alpha: dark ? .20 : .14,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: _primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: _primaryText(dark),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${doc.specialty} • ${doc.hospitalName}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _secondaryText(dark),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => BookAppointmentModal.show(
                            context,
                            doctor: doc,
                            onSuccess: widget.onBookingSuccess,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
