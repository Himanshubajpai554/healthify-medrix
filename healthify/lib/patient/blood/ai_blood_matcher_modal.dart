import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './blood_discovery_service.dart';
import './blood_request_modal.dart';

class AIBloodMatcherModal extends StatefulWidget {
  final String initialBloodGroup;

  const AIBloodMatcherModal({super.key, this.initialBloodGroup = 'O+'});

  static void show(BuildContext context, {String initialBloodGroup = 'O+'}) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) =>
          AIBloodMatcherModal(initialBloodGroup: initialBloodGroup),
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

  final List<String> _groups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> _components = [
    'PRBC',
    'Platelets',
    'SDP',
    'FFP',
    'Whole Blood',
  ];

  // ─────────────────────────────────────────────────────────────
  // Healthify Glass Theme — Light + Dark
  // ─────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  Color _surfaceStrong(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);

  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.white.withValues(alpha: 0.88);

  Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;

  Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  Widget _glassSurface({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double radius = 18,
    Color? accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: accent != null
                  ? accent.withValues(alpha: isDark ? 0.22 : 0.18)
                  : _border(isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.17 : 0.035),
                blurRadius: 24,
                offset: const Offset(0, 9),
              ),
              if (accent != null)
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.055 : 0.035),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                blurRadius: 34,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(
                        alpha: isDark ? 0.13 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.purple.withValues(
                          alpha: isDark ? 0.18 : 0.12,
                        ),
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
                    child: Text(
                      'AI Blood Availability Matcher',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryText(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Smart matching based on live component stock, distance, 24/7 service, and freshness.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _secondaryText(isDark),
                  height: 1.35,
                ),
              ),
              Divider(height: 24, color: _border(isDark)),

              // Control row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      initialValue: _bloodGroup,
                      decoration: InputDecoration(
                        labelText: 'Group',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _groups
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g,
                                style: const TextStyle(fontSize: 12.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _bloodGroup = val);
                          _runAIMatch();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      initialValue: _component,
                      decoration: InputDecoration(
                        labelText: 'Component',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _components
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(fontSize: 12.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _component = val);
                          _runAIMatch();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      initialValue: _units,
                      decoration: InputDecoration(
                        labelText: 'Units',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: List.generate(8, (i) => i + 1)
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                '$u Units',
                                style: const TextStyle(fontSize: 12.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.purple),
                            SizedBox(height: 14),
                            Text(
                              'Matching blood bank databases...',
                              style: TextStyle(
                                fontSize: 13,
                                color: _secondaryText(isDark),
                              ),
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
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _matchResults![index];
                          final bank = item['bank'] as BloodBankData;
                          final score = (item['score'] as double).round();
                          final totalUnits = item['totalUnits'] as int;
                          final componentCount = item['componentCount'] as int;
                          final hasFull = item['hasFullRequirement'] as bool;

                          return _glassSurface(
                            isDark: isDark,
                            padding: const EdgeInsets.all(14),
                            radius: 18,
                            accent: hasFull ? Colors.purple : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withValues(
                                          alpha: 0.15,
                                        ),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.1,
                                        ),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withValues(
                                          alpha: 0.1,
                                        ),
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Calling ${bank.phone}...',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                      ),
                                      label: const Text(
                                        'Call Bank',
                                        style: TextStyle(fontSize: 11.5),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
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
                                      icon: const Icon(
                                        Icons.send_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Request',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
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
        ),
      ),
    );
  }
}
