import 'package:flutter/material.dart';

import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../symptom_checker/symptom_checker_service.dart';

class EmergencyHospitalsModal extends StatelessWidget {
  const EmergencyHospitalsModal({super.key});

  static void show(BuildContext context) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => const EmergencyHospitalsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final hospitals =
        SymptomCheckerService.getNearbyHospitals()
            .where((hospital) => hospital.isEmergencyOpen)
            .toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final media = MediaQuery.sizeOf(context);

    final width = media.width;
    final height = media.height;

    final bool isDesktop = width >= 1000;
    final bool isTablet = width >= 600 && width < 1000;

    final double maxWidth = isDesktop
        ? 1120
        : isTablet
        ? 820
        : width;

    final double maxHeight = isDesktop ? height * 0.90 : height * 0.94;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Container(
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 30 : 26),
                topRight: Radius.circular(isDesktop ? 30 : 26),
                bottomLeft: Radius.circular(isDesktop ? 30 : 0),
                bottomRight: Radius.circular(isDesktop ? 30 : 0),
              ),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDesktop) _buildHandle(),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 28 : 18,
                    isDesktop ? 20 : 8,
                    isDesktop ? 28 : 18,
                    0,
                  ),
                  child: _buildHeader(
                    context: context,
                    isDark: isDark,
                    isDesktop: isDesktop,
                    isTablet: isTablet,
                    hospitalCount: hospitals.length,
                  ),
                ),

                const SizedBox(height: 14),

                // IMPORTANT:
                // Only one scrollable area.
                // No Expanded/Spacer inside its children.
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 28 : 18,
                      0,
                      isDesktop ? 28 : 18,
                      28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSafetyNotice(
                          isDark: isDark,
                          isDesktop: isDesktop,
                        ),

                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          isDark: isDark,
                          isDesktop: isDesktop,
                          count: hospitals.length,
                        ),

                        const SizedBox(height: 14),

                        if (hospitals.isEmpty)
                          _buildEmptyState(isDark: isDark, isDesktop: isDesktop)
                        else
                          _buildHospitalLayout(
                            context: context,
                            hospitals: hospitals,
                            isDark: isDark,
                            isDesktop: isDesktop,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HANDLE
  // ---------------------------------------------------------------------------

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader({
    required BuildContext context,
    required bool isDark,
    required bool isDesktop,
    required bool isTablet,
    required int hospitalCount,
  }) {
    final double titleSize = isDesktop
        ? 22
        : isTablet
        ? 19
        : 17;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 21 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF9F1239)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isDesktop ? 58 : 48,
            height: isDesktop ? 58 : 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: isDesktop ? 32 : 27,
            ),
          ),

          SizedBox(width: isDesktop ? 16 : 12),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Hospitals',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: titleSize,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Nearby emergency-ready hospitals ranked by distance',
                  maxLines: isDesktop ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: isDesktop ? 13 : 11.5,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$hospitalCount emergency facilities available',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Material(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 21),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SAFETY NOTICE
  // ---------------------------------------------------------------------------

  Widget _buildSafetyNotice({required bool isDark, required bool isDesktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 15 : 13),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.amber,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency information',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w800,
                    fontSize: isDesktop ? 13 : 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Availability can change rapidly. Always confirm directly with the hospital or local emergency services before travelling.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.amber.shade200
                        : Colors.amber.shade900,
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required bool isDark,
    required bool isDesktop,
    required int count,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Emergency Care',
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Sorted by nearest available emergency facility',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                  fontSize: isDesktop ? 12 : 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count found',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HOSPITAL LAYOUT
  // ---------------------------------------------------------------------------

  Widget _buildHospitalLayout({
    required BuildContext context,
    required List hospitals,
    required bool isDark,
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: hospitals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,

          // Fixed card height prevents desktop grid sizing issues.
          mainAxisExtent: 322,
        ),
        itemBuilder: (context, index) {
          return _buildHospitalCard(
            context: context,
            hospital: hospitals[index],
            isDark: isDark,
            isDesktop: true,
          );
        },
      );
    }

    // Mobile + tablet.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 0; index < hospitals.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == hospitals.length - 1 ? 0 : 12,
            ),
            child: _buildHospitalCard(
              context: context,
              hospital: hospitals[index],
              isDark: isDark,
              isDesktop: false,
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HOSPITAL CARD
  // ---------------------------------------------------------------------------

  Widget _buildHospitalCard({
    required BuildContext context,
    required dynamic hospital,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 17 : 15),
        child: Column(
          // IMPORTANT:
          // Never use Expanded/Spacer here.
          // This card can live inside a vertical scroll view.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHospitalHeader(
              hospital: hospital,
              isDark: isDark,
              isDesktop: isDesktop,
            ),

            const SizedBox(height: 14),

            _buildHospitalStats(
              hospital: hospital,
              isDark: isDark,
              isDesktop: isDesktop,
            ),

            const SizedBox(height: 14),

            _buildActionButtons(
              context: context,
              hospital: hospital,
              isDark: isDark,
              isDesktop: isDesktop,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HOSPITAL HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHospitalHeader({
    required dynamic hospital,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isDesktop ? 48 : 44,
          height: isDesktop ? 48 : 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.16),
                Colors.red.withValues(alpha: 0.07),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: Colors.red,
            size: 25,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hospital.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                  fontSize: isDesktop ? 15 : 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),

                  const SizedBox(width: 3),

                  Expanded(
                    child: Text(
                      '${hospital.distanceKm} km • ${hospital.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        _buildRatingBadge(rating: hospital.rating),
      ],
    );
  }

  Widget _buildRatingBadge({required dynamic rating}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.red, size: 14),

          const SizedBox(width: 3),

          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HOSPITAL STATS
  // ---------------------------------------------------------------------------

  Widget _buildHospitalStats({
    required dynamic hospital,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_hospital_rounded,
            title: 'ICU Beds',
            value: '${hospital.icuAvailable}/${hospital.icuTotal}',
            color: Colors.blue,
            isDark: isDark,
            isDesktop: isDesktop,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _buildStatCard(
            icon: Icons.bloodtype_rounded,
            title: 'O− Blood',
            value: '${hospital.bloodStock['O-'] ?? 0} units',
            color: Colors.red,
            isDark: isDark,
            isDesktop: isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 10,
        vertical: isDesktop ? 11 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isDesktop ? 20 : 18),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: isDesktop ? 13 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION BUTTONS
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons({
    required BuildContext context,
    required dynamic hospital,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ER Hotline ${hospital.phone}...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.phone_rounded, size: 16),
            label: const Text(
              'Call ER',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              side: BorderSide(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
              foregroundColor: HealthifyGlassTheme.getTextPrimary(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Opening navigation route to ${hospital.name}...',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.navigation_rounded, size: 16),
            label: const Text(
              'Navigate',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState({required bool isDark, required bool isDesktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 55 : 42,
      ),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_outlined,
              color: Colors.blue,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'No emergency hospitals found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HealthifyGlassTheme.getTextPrimary(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try again or contact local emergency services.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HealthifyGlassTheme.getTextSecondary(isDark),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
