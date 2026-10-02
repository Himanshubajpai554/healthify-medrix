import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './symptom_checker_service.dart';
import '../appointments/book_appointment_modal.dart';
import '../emergency/emergency_hospitals_modal.dart';

class SymptomCheckerWidget extends StatefulWidget {
  final Function(String)? onBookingSuccess;

  const SymptomCheckerWidget({
    super.key,
    this.onBookingSuccess,
  });

  @override
  State<SymptomCheckerWidget> createState() => _SymptomCheckerWidgetState();
}

class _SymptomCheckerWidgetState extends State<SymptomCheckerWidget> {
  final _textController = TextEditingController();
  SymptomAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;

  final List<String> _sampleSymptoms = const [
    'Chest tightness and rapid heart rate',
    'Severe headache, dizziness and blurred vision',
    'Shortness of breath and wheezing',
    'Severe knee pain and joint swelling',
    'Child high fever and vomiting',
  ];

  void _runAnalysis([String? customText]) {
    final query = customText ?? _textController.text;
    if (query.trim().isEmpty) return;

    if (customText != null) {
      _textController.text = customText;
    }

    setState(() {
      _isAnalyzing = true;
    });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Health Concern & Triage Analyzer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Enter symptoms to find relevant department, doctors & emergency advice',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input Area
            TextField(
              controller: _textController,
              maxLines: 2,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary, fontSize: 14),
              cursorColor: const Color(0xFF0D9488),
              decoration: InputDecoration(
                hintText: 'Describe how you feel (e.g. "I have chest tightness and pressure on my left arm")...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary,
                  fontSize: 13,
                ),

                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),

                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.075) : Colors.white.withValues(alpha: 0.90),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.085) : Colors.white.withValues(alpha: 0.88),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.085) : Colors.white.withValues(alpha: 0.88),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.55 : 0.40),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Quick Samples
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _sampleSymptoms.map((symptom) {
                return ActionChip(
                  label: Text(symptom, style: const TextStyle(fontSize: 11.5)),
                  backgroundColor: AppTheme.backgroundColor,
                  onPressed: () => _runAnalysis(symptom),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : () => _runAnalysis(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isAnalyzing ? 'Analyzing Symptoms...' : 'Analyze Health Concern & Match Doctor',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            // Analysis Result Display Card
            if (_analysisResult != null) ...[
              const SizedBox(height: 20),
              _buildAnalysisResultCard(context, _analysisResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard(BuildContext context, SymptomAnalysisResult result) {
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
        urgencyColor = Colors.teal;
        urgencyLabel = 'ROUTINE CONSULTATION';
        urgencyIcon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgencyIcon, color: urgencyColor, size: 22),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  urgencyLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Dept: ${result.recommendedDepartment}',
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            result.advice,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: result.urgency == UrgencyLevel.emergency ? Colors.red.shade900 : AppTheme.textPrimary,
            ),
          ),

          if (result.urgency == UrgencyLevel.emergency) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => EmergencyHospitalsModal.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                icon: const Icon(Icons.local_hospital_rounded),
                label: const Text('View Emergency Hospitals & Free ICU Beds'),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          Text(
            'Recommended Specialist Doctors (${result.recommendedDepartment}):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          const SizedBox(height: 10),

          Column(
            children: result.suggestedDoctors.take(2).map((doc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text('${doc.specialty} • ${doc.hospitalName}', style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        BookAppointmentModal.show(context, doctor: doc, onSuccess: widget.onBookingSuccess);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Book', style: TextStyle(fontSize: 12)),
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
}