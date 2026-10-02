import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../models/patient_portal_models.dart';
import './patient_report_detail_screen.dart';
import './add_report_modal.dart';
import './share_report_modal.dart';

class PatientReportsWidget extends StatefulWidget {
  final VoidCallback? onFindHospitalTap;

  const PatientReportsWidget({super.key, this.onFindHospitalTap});

  @override
  State<PatientReportsWidget> createState() => _PatientReportsWidgetState();
}

class _PatientReportsWidgetState extends State<PatientReportsWidget> {
  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  String _selectedCategory = 'All';
  bool _isTimelineView = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  late List<MedicalReport> _reports;

  final List<String> _categories = [
    'All',
    'Lab Reports',
    'Prescriptions',
    'Imaging',
    'Doctor Notes',
    'Discharge Summary',
  ];

  // ─────────────────────────────────────────────────────────────
  // HEALTHIFY GLASS THEME
  // ─────────────────────────────────────────────────────────────

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

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
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
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              if (accent != null)
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.055 : 0.035),
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

  Widget _glassIconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: _surfaceStrong(isDark),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _border(isDark)),
                ),
                child: Icon(icon, size: 20, color: _primaryText(isDark)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconBadge({
    required bool isDark,
    required IconData icon,
    required Color color,
    double size = 44,
    double iconSize = 22,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.09),
        borderRadius: BorderRadius.circular(size * 0.30),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.18 : 0.13),
        ),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }

  Widget _glassBackground({required bool isDark, required Widget child}) {
    return Stack(
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
                color: _primary.withValues(alpha: isDark ? 0.055 : 0.045),
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
                color: Colors.indigo.withValues(alpha: isDark ? 0.04 : 0.025),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _reports = [
      MedicalReport(
        id: 'REP-9021',
        title: 'CBC Blood Test Report',
        category: 'Lab Reports',
        hospitalName: 'City Care Hospital',
        doctorName: 'Dr. Sharma',
        date: DateTime(2026, 9, 24),
        summary:
            'Complete Blood Count (CBC) analysis showing normal hemoglobin and WBC levels. Fasting blood sugar slightly elevated.',
        fileFormat: 'PDF',
        fileSize: '1.8 MB',
        parameters: const [
          ReportParameter(
            name: 'Hemoglobin',
            value: '13.8',
            unit: 'g/dL',
            normalRange: '13.0 – 17.0 g/dL',
            isNormal: true,
          ),
          ReportParameter(
            name: 'WBC Count',
            value: '7,200',
            unit: '/µL',
            normalRange: '4,000 – 11,000 /µL',
            isNormal: true,
          ),
          ReportParameter(
            name: 'Platelet Count',
            value: '2.4',
            unit: 'lakh /µL',
            normalRange: '1.5 – 4.5 lakh /µL',
            isNormal: true,
          ),
          ReportParameter(
            name: 'Fasting Blood Sugar',
            value: '118',
            unit: 'mg/dL',
            normalRange: '70 – 99 mg/dL',
            isNormal: false,
          ),
        ],
        accessLogs: [
          ReportAccessLog(
            viewerName: 'Dr. Sharma',
            viewerRole: 'Attending Physician',
            timestamp: DateTime(2026, 9, 24, 11, 30),
          ),
          ReportAccessLog(
            viewerName: 'Alex Rivera',
            viewerRole: 'Patient (Owner)',
            timestamp: DateTime(2026, 9, 24, 14, 15),
          ),
        ],
      ),
      MedicalReport(
        id: 'REP-8810',
        title: 'Amoxicillin & Antibiotic Prescription',
        category: 'Prescriptions',
        hospitalName: 'St. Jude Medical Center',
        doctorName: 'Dr. Marcus Vance',
        date: DateTime(2026, 9, 18),
        summary:
            'Prescription for Amoxicillin 500mg (TDS x 5 days) and Paracetamol 650mg SOS for acute upper respiratory infection.',
        fileFormat: 'PDF',
        fileSize: '950 KB',
        parameters: const [
          ReportParameter(
            name: 'Amoxicillin 500mg',
            value: '1 Tab TDS',
            unit: '5 Days',
            normalRange: 'Oral After Meals',
            isNormal: true,
          ),
          ReportParameter(
            name: 'Paracetamol 650mg',
            value: '1 Tab SOS',
            unit: 'As Needed',
            normalRange: 'Max 3 / Day',
            isNormal: true,
          ),
        ],
        accessLogs: [
          ReportAccessLog(
            viewerName: 'Dr. Marcus Vance',
            viewerRole: 'Orthopedist',
            timestamp: DateTime(2026, 9, 18, 10, 00),
          ),
        ],
      ),
      MedicalReport(
        id: 'REP-8402',
        title: 'Chest Radiogram X-Ray (PA View)',
        category: 'Imaging',
        hospitalName: 'Metro Imaging & Diagnostics',
        doctorName: 'Dr. Elena Rostova',
        date: DateTime(2026, 9, 2),
        summary:
            'Digital Chest X-Ray PA View. Lung fields are clear bilateral. Cardiac silhouette is normal size. No active infiltrates.',
        fileFormat: 'DICOM',
        fileSize: '14.2 MB',
        accessLogs: [
          ReportAccessLog(
            viewerName: 'Dr. Elena Rostova',
            viewerRole: 'Radiologist',
            timestamp: DateTime(2026, 9, 2, 16, 20),
          ),
        ],
      ),
      MedicalReport(
        id: 'REP-7930',
        title: 'Lipid Profile & Cholesterol Panel',
        category: 'Lab Reports',
        hospitalName: 'City Care Hospital',
        doctorName: 'Dr. Sharma',
        date: DateTime(2026, 8, 12),
        summary:
            'Total cholesterol 215 mg/dL. Triglycerides 160 mg/dL. Recommended dietary lifestyle modifications.',
        fileFormat: 'PDF',
        fileSize: '2.1 MB',
        parameters: const [
          ReportParameter(
            name: 'Total Cholesterol',
            value: '215',
            unit: 'mg/dL',
            normalRange: '< 200 mg/dL',
            isNormal: false,
          ),
          ReportParameter(
            name: 'HDL (Good Cholesterol)',
            value: '48',
            unit: 'mg/dL',
            normalRange: '> 40 mg/dL',
            isNormal: true,
          ),
          ReportParameter(
            name: 'LDL (Bad Cholesterol)',
            value: '135',
            unit: 'mg/dL',
            normalRange: '< 100 mg/dL',
            isNormal: false,
          ),
        ],
      ),
      MedicalReport(
        id: 'REP-7601',
        title: 'Inpatient Ward Discharge Summary',
        category: 'Discharge Summary',
        hospitalName: 'City Care Hospital',
        doctorName: 'Dr. Rajesh Kumar',
        date: DateTime(2026, 8, 5),
        summary:
            'Admitted for Acute Gastroenteritis. Treated with IV rehydration and probiotics. Discharged in stable condition.',
        fileFormat: 'PDF',
        fileSize: '3.4 MB',
      ),
      MedicalReport(
        id: 'REP-7120',
        title: 'Cardiology OPD Consultation Notes',
        category: 'Doctor Notes',
        hospitalName: 'Medrix Heart Institute',
        doctorName: 'Dr. Sarah Jenkins',
        date: DateTime(2026, 7, 15),
        summary:
            'Routine cardiac evaluation. BP 120/80 mmHg, HR 72 bpm. S1/S2 normal. Advised 30 min daily cardiovascular walk.',
        fileFormat: 'PDF',
        fileSize: '1.2 MB',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MedicalReport> get _filteredReports {
    return _reports.where((report) {
      final matchesCategory =
          _selectedCategory == 'All' || report.category == _selectedCategory;

      final query = _searchQuery.trim().toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.doctorName.toLowerCase().contains(query) ||
          report.hospitalName.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openAddReportModal() {
    AddReportModal.show(
      context,
      onReportAdded: (newReport) {
        setState(() {
          _reports.insert(0, newReport);
        });
      },
    );
  }

  void _openReport(MedicalReport report) {
    Navigator.push(
      context,
      FadePageRoute(
        page: PatientReportDetailScreen(
          report: report,
          onReportUpdated: (updated) {
            setState(() {
              final index = _reports.indexWhere((r) => r.id == updated.id);

              if (index != -1) {
                _reports[index] = updated;
              }
            });
          },
        ),
      ),
    );
  }

  void _shareReport(MedicalReport report) {
    ShareReportModal.show(
      context,
      report: report,
      onReportUpdated: (updated) {
        setState(() {
          final index = _reports.indexWhere((r) => r.id == updated.id);

          if (index != -1) {
            _reports[index] = updated;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _filteredReports;

    return _glassBackground(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────────────────────────────
          // 1. HEADER
          // ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Reports',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Your health records, lab results & prescriptions',
                      style: TextStyle(
                        fontSize: 13,
                        color: _secondaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              ElevatedButton.icon(
                onPressed: _openAddReportModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Add Report',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─────────────────────────────────────────────────────
          // 2. PRIVACY BANNER
          // ─────────────────────────────────────────────────────
          _glassCard(
            isDark: isDark,
            accent: _primary,
            padding: const EdgeInsets.all(14),
            radius: 18,
            child: Row(
              children: [
                _glassIconBadge(
                  isDark: isDark,
                  icon: Icons.verified_user_outlined,
                  color: _primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your Medical Records are End-to-End Encrypted & Private. Only you and authorized physicians can access them.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF5EEAD4) : _primaryDark,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─────────────────────────────────────────────────────
          // 3. SEARCH
          // ─────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(color: _primaryText(isDark), fontSize: 14),
                cursorColor: _primary,
                decoration: InputDecoration(
                  hintText: 'Search by test title, doctor, hospital...',
                  hintStyle: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: _primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: _secondaryText(isDark),
                          ),
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: _surfaceStrong(isDark),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: _border(isDark)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: _border(isDark)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: _primary.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─────────────────────────────────────────────────────
          // 4. CATEGORY FILTERS
          // ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;

                      final icons = <String, IconData>{
                        'All': Icons.grid_view_rounded,
                        'Lab Reports': Icons.biotech_rounded,
                        'Prescriptions': Icons.medication_rounded,
                        'Imaging': Icons.scanner_rounded,
                        'Doctor Notes': Icons.description_rounded,
                        'Discharge Summary': Icons.local_hospital_rounded,
                      };

                      return Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _primary
                                  : _surfaceStrong(isDark),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected ? _primary : _border(isDark),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _primary.withValues(
                                          alpha: isDark ? 0.28 : 0.16,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icons[category] ??
                                      Icons.folder_shared_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.7,
                                              )
                                            : _primaryDark),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : _primaryText(isDark),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              _buildViewSwitcher(isDark),
            ],
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────────────────────
          // 5. MAIN CONTENT
          // ─────────────────────────────────────────────────────
          if (_reports.isEmpty)
            _buildEmptyState(isDark)
          else if (filtered.isEmpty)
            _buildNoSearchResultsState(isDark)
          else if (_isTimelineView)
            _buildTimelineView(filtered, isDark)
          else if (MediaQuery.of(context).size.width >= 600)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 1200 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 260,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildReportCard(filtered[index], isDark);
              },
            )
          else
            ...filtered.map((report) => _buildReportCard(report, isDark)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REPORT CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildReportCard(MedicalReport report, bool isDark) {
    final categoryColor = _getCategoryColor(report.category);

    final categoryIcon = _getCategoryIcon(report.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: categoryColor.withValues(alpha: isDark ? 0.035 : 0.025),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: InkWell(
            onTap: () => _openReport(report),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(
                            alpha: isDark ? 0.13 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.13),
                          ),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 5,
                              children: [
                                _statusPill(
                                  isDark: isDark,
                                  text: report.category.toUpperCase(),
                                  color: categoryColor,
                                ),

                                if (report.isExternalUploaded)
                                  _statusPill(
                                    isDark: isDark,
                                    text: 'EXTERNAL',
                                    color: Colors.blue,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              report.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _primaryText(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        _formatDate(report.date),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _secondaryText(isDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  Divider(height: 1, color: _border(isDark)),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.hospitalName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _primaryText(isDark),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Prescribed by ${report.doctorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryText(isDark),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      _glassIconButton(
                        isDark: isDark,
                        icon: Icons.share_outlined,
                        tooltip: 'Share Report',
                        onTap: () => _shareReport(report),
                      ),

                      const SizedBox(width: 7),

                      ElevatedButton.icon(
                        onPressed: () => _openReport(report),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary.withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          foregroundColor: isDark
                              ? const Color(0xFF5EEAD4)
                              : _primaryDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _primary.withValues(alpha: 0.16),
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.remove_red_eye_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TIMELINE
  // ─────────────────────────────────────────────────────────────

  Widget _buildTimelineView(List<MedicalReport> reports, bool isDark) {
    final Map<String, List<MedicalReport>> grouped = {};

    for (final report in reports) {
      final key = '${_getMonthName(report.date.month)} ${report.date.year}';

      grouped.putIfAbsent(key, () => []).add(report);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _statusPill(
                    isDark: isDark,
                    text: entry.key,
                    color: _primary,
                    filled: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Divider(color: _primary.withValues(alpha: 0.24)),
                  ),
                ],
              ),
            ),
            ...entry.value.map((report) => _buildTimelineTile(report, isDark)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTimelineTile(MedicalReport report, bool isDark) {
    final color = _getCategoryColor(report.category);

    return Container(
      margin: const EdgeInsets.only(left: 12, bottom: 12),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color.withValues(alpha: 0.75), width: 3),
        ),
      ),
      child: _buildReportCard(report, isDark),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return _glassCard(
      isDark: isDark,
      radius: 22,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _glassIconBadge(
            isDark: isDark,
            icon: Icons.folder_shared_outlined,
            color: _primary,
            size: 70,
            iconSize: 40,
          ),

          const SizedBox(height: 16),

          Text(
            'No medical reports yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _primaryText(isDark),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Reports from your Medrix appointments and connected healthcare providers will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: _secondaryText(isDark),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: widget.onFindHospitalTap ?? _openAddReportModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add External Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NO SEARCH RESULTS
  // ─────────────────────────────────────────────────────────────

  Widget _buildNoSearchResultsState(bool isDark) {
    return _glassCard(
      isDark: isDark,
      radius: 22,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: _secondaryText(isDark),
            size: 44,
          ),

          const SizedBox(height: 12),

          Text(
            'No matching medical reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryText(isDark),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'No records match "$_searchQuery" under category "$_selectedCategory".',
            style: TextStyle(fontSize: 12.5, color: _secondaryText(isDark)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : _primaryDark,
              side: BorderSide(
                color: _primary.withValues(alpha: isDark ? 0.55 : 0.42),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset Category & Search Filters'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VIEW SWITCHER
  // ─────────────────────────────────────────────────────────────

  Widget _buildViewSwitcher(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border(isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _viewButton(
                isDark: isDark,
                selected: !_isTimelineView,
                icon: Icons.format_list_bulleted_rounded,
                tooltip: 'List View',
                onTap: () {
                  setState(() {
                    _isTimelineView = false;
                  });
                },
              ),
              _viewButton(
                isDark: isDark,
                selected: _isTimelineView,
                icon: Icons.timeline_rounded,
                tooltip: 'Health Timeline View',
                onTap: () {
                  setState(() {
                    _isTimelineView = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewButton({
    required bool isDark,
    required bool selected,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? _primary.withValues(alpha: isDark ? 0.18 : 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: selected
                ? (isDark ? const Color(0xFF5EEAD4) : _primaryDark)
                : _secondaryText(isDark),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STATUS PILL
  // ─────────────────────────────────────────────────────────────

  Widget _statusPill({
    required bool isDark,
    required String text,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: isDark ? 0.13 : 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: filled ? 0.0 : 0.13)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORY HELPERS
  // ─────────────────────────────────────────────────────────────

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Lab Reports':
        return _primary;

      case 'Prescriptions':
        return Colors.blue;

      case 'Imaging':
        return Colors.purple;

      case 'Doctor Notes':
        return Colors.orange;

      case 'Discharge Summary':
        return Colors.indigo;

      default:
        return _primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Lab Reports':
        return Icons.biotech_rounded;

      case 'Prescriptions':
        return Icons.medication_rounded;

      case 'Imaging':
        return Icons.scanner_rounded;

      case 'Doctor Notes':
        return Icons.description_rounded;

      case 'Discharge Summary':
        return Icons.local_hospital_rounded;

      default:
        return Icons.folder_shared_rounded;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}