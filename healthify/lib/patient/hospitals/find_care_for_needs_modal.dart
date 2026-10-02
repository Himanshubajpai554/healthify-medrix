import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import '../symptom_checker/symptom_checker_service.dart';

class FindCareForNeedsModal extends StatefulWidget {
  final Function(String department, List<NearbyHospital> matchingHospitals)? onCareMatched;

  const FindCareForNeedsModal({super.key, this.onCareMatched});

  static void show(
    BuildContext context, {
    Function(String department, List<NearbyHospital> matchingHospitals)? onCareMatched,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => FindCareForNeedsModal(onCareMatched: onCareMatched),
    );
  }

  @override
  State<FindCareForNeedsModal> createState() => _FindCareForNeedsModalState();
}

class _FindCareForNeedsModalState extends State<FindCareForNeedsModal> {
  final _needController = TextEditingController();
  SymptomAnalysisResult? _result;
  bool _isMatching = false;

  final List<String> _quickNeeds = [
    'Breathing Problem / Oxygen Needed',
    'Trauma & Emergency Care',
    'Cardiac & Heart ICU Bed',
    'Child ER & Pediatric Ward',
    'Brain & Stroke Care Unit',
    'Orthopedic Fracture / Surgery',
  ];

  @override
  void dispose() {
    _needController.dispose();
    super.dispose();
  }

  void _matchCareNeed(String needText) {
    if (needText.trim().isEmpty) return;
    setState(() {
      _isMatching = true;
      _needController.text = needText;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final res = SymptomCheckerService.analyzeHealthConcern(needText);
      setState(() {
        _result = res;
        _isMatching = false;
      });
    });
  }

  void _applyMatchingHospitals() {
    if (_result != null && widget.onCareMatched != null) {
      widget.onCareMatched!(_result!.recommendedDepartment, _result!.recommendedHospitals);
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
                    color: Colors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.manage_search_rounded, color: Colors.teal, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Find Hospital Care for Your Need',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Find hospitals with specific ICU, ER or diagnostic capabilities',
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
              'What specific care do you require?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Input Field
            TextField(
              controller: _needController,
              onSubmitted: (val) => _matchCareNeed(val),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary, fontSize: 14),
              cursorColor: const Color(0xFF0D9488),
              decoration: InputDecoration(
                hintText: 'e.g., ICU bed for breathing problem, Cath Lab...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary,
                  fontSize: 13,
                ),

                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D9488)),
                  onPressed: () => _matchCareNeed(_needController.text),
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
            const Text('Common Care Needs:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
            const SizedBox(height: 8),

            // Quick need chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickNeeds.map((need) {
                return ChoiceChip(
                  label: Text(need),
                  selected: _needController.text == need,
                  selectedColor: Colors.teal.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _needController.text == need ? Colors.teal : AppTheme.textPrimary,
                    fontWeight: _needController.text == need ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) _matchCareNeed(need);
                  },
                );
              }).toList(),
            ),

            if (_isMatching) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 12),
                    Text('Matching hospitals with required capabilities...', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],

            // Analysis & Matching Result
            if (_result != null && !_isMatching) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_rounded, color: Colors.teal, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Recommended Care Department:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal,
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
                    // Non-Diagnostic Care Navigation Disclaimer
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is healthcare care-navigation assistance based on reported facility capabilities and not a medical diagnosis.',
                              style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _applyMatchingHospitals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.domain_rounded),
                        label: Text(
                          'View Equipped Hospitals (${_result!.recommendedHospitals.length})',
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