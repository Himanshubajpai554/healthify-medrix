import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class HospitalComparisonModal extends StatelessWidget {
  final List<NearbyHospital> hospitals;

  const HospitalComparisonModal({super.key, required this.hospitals});

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

  static void show(
    BuildContext context, {
    required List<NearbyHospital> hospitals,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => HospitalComparisonModal(hospitals: hospitals),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayHospitals = hospitals.take(3).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF061817).withValues(alpha: 0.84)
                : const Color(0xFFF3FAF9).withValues(alpha: 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.055),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Soft background glow
              Positioned(
                top: -90,
                right: -60,
                child: IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withValues(alpha: isDark ? 0.07 : 0.045),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -100,
                left: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo.withValues(
                        alpha: isDark ? 0.045 : 0.025,
                      ),
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 12,
                  left: 18,
                  right: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─────────────────────────────────────
                    // HANDLE
                    // ─────────────────────────────────────
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.22)
                              : Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────────────────
                    // HEADER
                    // ─────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primary, _primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withValues(
                                  alpha: isDark ? 0.24 : 0.14,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.compare_arrows_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compare Hospitals',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryText(isDark),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Compare up to ${displayHospitals.length} hospitals',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _secondaryText(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: _surfaceStrong(isDark),
                            shape: BoxShape.circle,
                            border: Border.all(color: _border(isDark)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: _primaryText(isDark),
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Side-by-side comparison of availability, emergency care, distance and facilities.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: _secondaryText(isDark),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────────────────
                    // HOSPITAL HEADER CARDS
                    // ─────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: displayHospitals.map((hospital) {
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _surfaceStrong(isDark),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border(isDark)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(
                                      alpha: isDark ? 0.14 : 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital_rounded,
                                    size: 18,
                                    color: isDark
                                        ? const Color(0xFF5EEAD4)
                                        : _primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hospital.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryText(isDark),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${hospital.rating}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─────────────────────────────────────
                    // COMPARISON TABLE
                    // ─────────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _surface(isDark),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _border(isDark)),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: _border(isDark),
                                  width: 0.7,
                                ),
                                verticalInside: BorderSide(
                                  color: _border(isDark),
                                  width: 0.7,
                                ),
                              ),
                              columnWidths: {
                                0: const FixedColumnWidth(118),
                                for (
                                  int i = 1;
                                  i <= displayHospitals.length;
                                  i++
                                )
                                  i: const FixedColumnWidth(145),
                              },
                              children: [
                                // HEADER
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: _primary.withValues(
                                      alpha: isDark ? 0.10 : 0.06,
                                    ),
                                  ),
                                  children: [
                                    _buildCell(
                                      'FEATURE',
                                      isDark: isDark,
                                      isHeader: true,
                                    ),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        h.name,
                                        isDark: isDark,
                                        isHeader: true,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                // DISTANCE
                                TableRow(
                                  children: [
                                    _buildCell('Distance', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        '${h.distanceKm} km\n(~${(h.distanceKm * 3 + 4).toInt()} min)',
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),

                                // RATING
                                TableRow(
                                  children: [
                                    _buildCell('Rating', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        '★ ${h.rating} (${h.reviewsCount})',
                                        isDark: isDark,
                                        textColor: Colors.amber,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                // ER
                                TableRow(
                                  children: [
                                    _buildCell('24/7 ER', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        h.isEmergencyOpen
                                            ? '●  ER Open'
                                            : '●  Closed',
                                        isDark: isDark,
                                        textColor: h.isEmergencyOpen
                                            ? Colors.green
                                            : Colors.red,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                // ICU
                                TableRow(
                                  children: [
                                    _buildCell('ICU Beds', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        '${h.icuAvailable} / ${h.icuTotal} Free',
                                        isDark: isDark,
                                        textColor: h.icuAvailable > 0
                                            ? Colors.green
                                            : Colors.red,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                // GENERAL
                                TableRow(
                                  children: [
                                    _buildCell('General Beds', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        '${h.availableBeds} / ${h.totalBeds} Free',
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),

                                // BLOOD
                                TableRow(
                                  children: [
                                    _buildCell('Blood O−', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        '${h.bloodStock['O-'] ?? 0} Units',
                                        isDark: isDark,
                                        textColor: (h.bloodStock['O-'] ?? 0) > 0
                                            ? _primary
                                            : Colors.red,
                                        isBold: true,
                                      ),
                                    ),
                                  ],
                                ),

                                // FACILITIES
                                TableRow(
                                  children: [
                                    _buildCell('Facilities', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        h.facilities.take(3).join('\n• '),
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),

                                // UPDATED
                                TableRow(
                                  children: [
                                    _buildCell('Last Update', isDark: isDark),
                                    ...displayHospitals.map(
                                      (h) => _buildCell(
                                        'Updated 8m ago',
                                        isDark: isDark,
                                        textColor: _secondaryText(isDark),
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

                    const SizedBox(height: 20),

                    // ─────────────────────────────────────
                    // CLOSE BUTTON
                    // ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Close Comparison',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    String text, {
    required bool isDark,
    bool isHeader = false,
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 10.5 : 11.5,
          height: 1.35,
          fontWeight: isHeader || isBold ? FontWeight.w700 : FontWeight.w500,
          color:
              textColor ??
              (isHeader
                  ? (isDark ? const Color(0xFF5EEAD4) : _primaryDark)
                  : _primaryText(isDark)),
        ),
      ),
    );
  }
}
