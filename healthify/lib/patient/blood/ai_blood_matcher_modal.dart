import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './blood_discovery_service.dart';
import './blood_request_modal.dart';

class AIBloodMatcherModal extends StatefulWidget {
  final String initialBloodGroup;

  const AIBloodMatcherModal({
    super.key,
    this.initialBloodGroup = 'O+',
  });

  static void show(BuildContext context, {String initialBloodGroup = 'O+'}) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => AIBloodMatcherModal(initialBloodGroup: initialBloodGroup),
    );
  }

  @override
  State<AIBloodMatcherModal> createState() => _AIBloodMatcherModalState();
}

class _AIBloodMatcherModalState extends State<AIBloodMatcherModal> {
  late String _bloodGroup;
  late String _component;
  late int _units;
  late String _urgency;
  bool _isSearching = false;
  List<Map<String, dynamic>>? _matchResults;

  final List<String> _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _components = ['PRBC', 'Platelets', 'SDP', 'FFP', 'Whole Blood'];

  @override
  void initState() {
    super.initState();
    _bloodGroup = widget.initialBloodGroup;
    _component = 'PRBC';
    _units = 2;
    _urgency = 'Urgent';
    _runAIMatch();
  }

  void _runAIMatch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final matches = BloodDiscoveryService.findBestAIMatches(
          bloodGroup: _bloodGroup,
          componentType: _component,
          unitsNeeded: _units,
          urgencyLevel: _urgency,
        );
        setState(() {
          _matchResults = matches;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: const [
              Icon(Icons.psychology_rounded, color: Colors.purple, size: 26),
              SizedBox(width: 10),
              Text(
                'AI Blood Availability Matcher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Smart matching based on live component stock, distance, 24/7 service, and freshness.',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
          ),
          const Divider(height: 24),

          // Control row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _bloodGroup,
                  decoration: InputDecoration(
                    labelText: 'Group',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _bloodGroup = val);
                      _runAIMatch();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _component,
                  decoration: InputDecoration(
                    labelText: 'Component',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _components.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _component = val);
                      _runAIMatch();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _units,
                  decoration: InputDecoration(
                    labelText: 'Units',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: List.generate(8, (i) => i + 1)
                      .map((u) => DropdownMenuItem(value: u, child: Text('$u Units')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _units = val);
                      _runAIMatch();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _isSearching
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.purple),
                        SizedBox(height: 14),
                        Text(
                          'Matching blood bank databases...',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : (_matchResults == null || _matchResults!.isEmpty)
                    ? const Center(
                        child: Text(
                          'No matching blood banks found for this criteria.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _matchResults!.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _matchResults![index];
                          final bank = item['bank'] as BloodBankData;
                          final score = (item['score'] as double).round();
                          final totalUnits = item['totalUnits'] as int;
                          final componentCount = item['componentCount'] as int;
                          final hasFull = item['hasFullRequirement'] as bool;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCardColor : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: hasFull
                                    ? Colors.purple.withValues(alpha: 0.5)
                                    : AppTheme.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bank.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$score% MATCH',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${bank.distance} (${bank.travelTime}) • ${bank.type}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$_bloodGroup Stock: $totalUnits Units',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$_component: $componentCount Units',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Calling ${bank.phone}...')),
                                        );
                                      },
                                      icon: const Icon(Icons.phone_outlined, size: 14),
                                      label: const Text('Call Bank', style: TextStyle(fontSize: 11.5)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        BloodRequestModal.show(
                                          context,
                                          initialBloodGroup: _bloodGroup,
                                          initialHospital: bank.name,
                                        );
                                      },
                                      icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                                      label: const Text('Request', style: TextStyle(fontSize: 11.5, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}