import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import '../symptom_checker/symptom_checker_service.dart';

class FindByConcernModal extends StatefulWidget {
  final Function(String department, List<DoctorSearchResult> doctors)? onDepartmentSelected;

  const FindByConcernModal({super.key, this.onDepartmentSelected});

  static void show(
    BuildContext context, {
    Function(String department, List<DoctorSearchResult> doctors)? onDepartmentSelected,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => FindByConcernModal(onDepartmentSelected: onDepartmentSelected),
    );
  }

  @override
  State<FindByConcernModal> createState() => _FindByConcernModalState();
}

class _FindByConcernModalState extends State<FindByConcernModal> {
  final _concernController = TextEditingController();
  SymptomAnalysisResult? _result;
  bool _isAnalyzing = false;

  final List<String> _quickConcerns = [
    'Headache & Dizziness',
    'Joint Pain & Stiffness',
    'Skin Rash or Problem',
    'Breathing Difficulty or Cough',
    'Stomach Pain & Indigestion',
    'Child Health & Fever',
    'Chest Discomfort',
    'General Health Checkup',
  ];

  @override
  void dispose() {
    _concernController.dispose();
    super.dispose();
  }

  void _analyzeConcern(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _concernController.text = text;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final res = SymptomCheckerService.analyzeHealthConcern(text);
      setState(() {
        _result = res;
        _isAnalyzing = false;
      });
    });
  }

  void _applySuggestedSpecialty() {
    if (_result != null && widget.onDepartmentSelected != null) {
      widget.onDepartmentSelected!(_result!.recommendedDepartment, _result!.suggestedDoctors);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Find Doctor by Health Concern',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Describe your symptom to find the right medical specialty',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'What are you looking for help with?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Input Field
            TextField(
              controller: _concernController,
              onSubmitted: (val) => _analyzeConcern(val),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary, fontSize: 14),
              cursorColor: const Color(0xFF0D9488),
              decoration: InputDecoration(
                hintText: 'Describe symptom (e.g. knee pain, persistent cough)...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary,
                  fontSize: 13,
                ),

                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D9488)),
                  onPressed: () => _analyzeConcern(_concernController.text),
                ),

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

            const SizedBox(height: 16),

            // Quick concern chips
            const Text('Common Health Concerns:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickConcerns.map((concern) {
                return ChoiceChip(
                  label: Text(concern),
                  selected: _concernController.text == concern,
                  selectedColor: Colors.indigo.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _concernController.text == concern ? Colors.indigo : AppTheme.textPrimary,
                    fontWeight: _concernController.text == concern ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) _analyzeConcern(concern);
                  },
                );
              }).toList(),
            ),

            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(color: Colors.indigo),
                    SizedBox(height: 12),
                    Text('Identifying appropriate medical department...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],

            // Analysis Result Box
            if (_result != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_rounded, color: Colors.indigo, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Suggested Specialty:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _result!.recommendedDepartment.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result!.advice,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    // Mandatory Medical Responsibility Disclaimer
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.privacy_tip_outlined, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is a suggested specialty recommendation and not a medical diagnosis. Always consult a qualified physician for clinical evaluation.',
                              style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _applySuggestedSpecialty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.people_rounded),
                        label: Text(
                          'View ${_result!.recommendedDepartment} Doctors (${_result!.suggestedDoctors.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}