import 'dart:ui';

import 'package:flutter/material.dart';

import '../../shared/widgets/animated_pulse_background.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import '../symptom_checker/symptom_checker_service.dart';

class PatientHospitalProfileScreen extends StatefulWidget {
  final NearbyHospital hospital;
  final Function(String message)? onBookingSuccess;

  const PatientHospitalProfileScreen({
    super.key,
    required this.hospital,
    this.onBookingSuccess,
  });

  @override
  State<PatientHospitalProfileScreen> createState() =>
      _PatientHospitalProfileScreenState();
}

class _PatientHospitalProfileScreenState
    extends State<PatientHospitalProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<DoctorSearchResult> _affiliatedDoctors;

  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);

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

  Widget _glassBackground({required bool isDark, required Widget child}) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          right: -90,
          child: IgnorePointer(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: isDark ? 0.065 : 0.055),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -90,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withValues(alpha: isDark ? 0.035 : 0.025),
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

    _tabController = TabController(length: 4, vsync: this);

    _affiliatedDoctors = SymptomCheckerService.getDoctors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ========================================================================
  // BUILD
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = widget.hospital;

    final background = isDark
        ? const Color(0xFF061817)
        : const Color(0xFFF3FAF9);

    return Scaffold(
      backgroundColor: background,

      // --------------------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------------------
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildGlassAppBar(isDark: isDark, hospital: h),
      ),

      // --------------------------------------------------------------------
      // BODY
      // --------------------------------------------------------------------
      body: _glassBackground(
        isDark: isDark,
        child: AnimatedPulseBackground(
          child: SafeArea(
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildHospitalHero(h, isDark),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _GlassTabBarDelegate(
                      child: _buildGlassTabBar(isDark),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildLiveCapacityTab(h, isDark),
                  _buildDoctorsTab(isDark),
                  _buildFacilitiesTab(h, isDark),
                  _buildReviewsTab(h, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // GLASS APP BAR
  // ========================================================================

  Widget _buildGlassAppBar({
    required bool isDark,
    required NearbyHospital hospital,
  }) {
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const SizedBox(width: 8),

                _glassIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                  isDark: isDark,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    hospital.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                _glassIconButton(
                  icon: Icons.share_outlined,
                  onTap: () {},
                  isDark: isDark,
                ),

                _glassIconButton(
                  icon: Icons.bookmark_border_rounded,
                  onTap: () {},
                  isDark: isDark,
                ),

                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border(isDark)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.82)
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // HOSPITAL HERO
  // ========================================================================

  Widget _buildHospitalHero(NearbyHospital h, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: isDark ? 0.17 : 0.11),
                isDark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.white.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.95),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.045),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hospital icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primary, primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.24),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: _primaryText(isDark),
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Multi-Specialty Healthcare',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.58)
                                : AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${h.distanceKm} km away • ${h.address}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.55)
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Rating + emergency
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _heroStat(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    value: '${h.rating}',
                    label: '${h.reviewsCount} reviews',
                    isDark: isDark,
                  ),

                  _heroStat(
                    icon: Icons.schedule_rounded,
                    iconColor: primary,
                    value: h.openHours,
                    label: 'Opening hours',
                    isDark: isDark,
                  ),

                  _emergencyBadge(isOpen: h.isEmergencyOpen),
                ],
              ),

              const SizedBox(height: 17),

              // Primary actions
              Row(
                children: [
                  Expanded(
                    child: _gradientActionButton(
                      icon: Icons.navigation_rounded,
                      label: 'Directions',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating to ${h.name}...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _glassActionButton(
                      icon: Icons.phone_rounded,
                      label: 'Call Desk',
                      isDark: isDark,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${h.phone}...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _primaryText(isDark),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emergencyBadge({required bool isOpen}) {
    final color = isOpen ? Colors.green : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 7),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'ER OPEN' : 'ER CLOSED',
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // ACTION BUTTONS
  // ========================================================================

  Widget _gradientActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primary, primaryDark]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.22),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Directions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_rounded, color: primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // GLASS TAB BAR
  // ========================================================================

  Widget _buildGlassTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: _surfaceStrong(isDark),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: _border(isDark)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              labelColor: primary,
              unselectedLabelColor: _secondaryText(isDark),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: primary.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              labelStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '⚡ Live Capacity'),
                Tab(text: '👨‍⚕️ Doctors'),
                Tab(text: '🏥 Facilities'),
                Tab(text: '⭐ Reviews'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // LIVE CAPACITY
  // ========================================================================

  Widget _buildLiveCapacityTab(NearbyHospital h, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        _glassInfoBanner(isDark),

        const SizedBox(height: 18),

        _sectionHeader(
          title: 'Live Bed & ICU Capacity',
          subtitle: 'Real-time availability',
          isDark: isDark,
          icon: Icons.monitor_heart_rounded,
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            _buildCapacityCard(
              'Level-1 ICU',
              h.icuAvailable,
              h.icuTotal,
              Colors.green,
              isDark,
            ),
            _buildCapacityCard(
              'Emergency Trauma',
              6,
              20,
              Colors.redAccent,
              isDark,
            ),
            _buildCapacityCard(
              'General Wards',
              h.availableBeds,
              h.totalBeds,
              Colors.blue,
              isDark,
            ),
            _buildCapacityCard(
              'Private Rooms',
              7,
              25,
              Colors.deepPurple,
              isDark,
            ),
          ],
        ),

        const SizedBox(height: 25),

        _sectionHeader(
          title: 'Blood Bank Reserve',
          subtitle: 'Current stock levels',
          isDark: isDark,
          icon: Icons.bloodtype_rounded,
        ),

        const SizedBox(height: 12),

        _buildBloodInventory(h, isDark),
      ],
    );
  }

  Widget _glassInfoBanner(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: isDark ? 0.08 : 0.055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Live capacity reported by hospital desk • Updated 8 mins ago. Availability may change rapidly during emergency traffic.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityCard(
    String label,
    int free,
    int total,
    Color color,
    bool isDark,
  ) {
    final pct = total > 0 ? (free / total).clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.075 : 0.055),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                '$free',
                style: TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: _primaryText(isDark),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'available of $total',
                style: TextStyle(
                  fontSize: 9.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 5,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodInventory(NearbyHospital h, bool isDark) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: h.bloodStock.entries.map((entry) {
        final units = entry.value;
        final isLow = units < 3;
        final color = isLow ? Colors.redAccent : primary;

        return Container(
          width: 83,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.075 : 0.055),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bloodtype_rounded, color: color, size: 19),
              ),

              const SizedBox(height: 7),

              Text(
                entry.key,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: color,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '$units units',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isLow ? 'LOW STOCK' : 'STOCKED',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ========================================================================
  // DOCTORS
  // ========================================================================

  Widget _buildDoctorsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: _affiliatedDoctors.length,
      itemBuilder: (context, index) {
        final doc = _affiliatedDoctors[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: _buildDoctorCard(doc, isDark),
        );
      },
    );
  }

  Widget _buildDoctorCard(DoctorSearchResult doc, bool isDark) {
    final initial = doc.name.replaceFirst('Dr. ', '').trim().isNotEmpty
        ? doc.name.replaceFirst('Dr. ', '').trim()[0]
        : 'D';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.18),
                      primary.withValues(alpha: 0.07),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.18)),
                ),
                child: Center(
                  child: Text(
                    initial.toUpperCase(),
                    style: const TextStyle(
                      color: primary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryText(isDark),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      doc.specialty,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.52)
                            : AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${doc.rating}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.schedule_rounded,
                          color: primary,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            doc.availableSlots.firstOrNull ?? 'Slot Available',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _bookButton(
                onTap: () {
                  if (widget.onBookingSuccess != null) {
                    widget.onBookingSuccess!(
                      'Appointment booked with ${doc.name}!',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primary, primaryDark]),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Book',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // FACILITIES
  // ========================================================================

  Widget _buildFacilitiesTab(NearbyHospital h, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        _sectionHeader(
          title: 'Medical Facilities',
          subtitle: '${h.facilities.length} services available',
          isDark: isDark,
          icon: Icons.medical_services_rounded,
        ),

        const SizedBox(height: 13),

        ...h.facilities.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _facilityCard(entry.value, isDark),
          );
        }),
      ],
    );
  }

  Widget _facilityCard(String facility, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  facility,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  '24/7',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // REVIEWS
  // ========================================================================

  Widget _buildReviewsTab(NearbyHospital h, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildRatingSummary(h, isDark),

        const SizedBox(height: 16),

        _buildReviewTile(
          'Anonymous Patient',
          '5.0',
          'Clean ICU and quick ER admission response.',
          isDark,
        ),

        const SizedBox(height: 10),

        _buildReviewTile(
          'Sarah M.',
          '4.5',
          'Helpful nursing staff and well-maintained diagnostic labs.',
          isDark,
        ),
      ],
    );
  }

  Widget _buildRatingSummary(NearbyHospital h, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.10),
                isDark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.white.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Text(
                '${h.rating}',
                style: const TextStyle(
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 17,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Based on ${h.reviewsCount} patient reviews',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.50)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTile(
    String name,
    String rating,
    String text,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⭐ $rating',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.amber,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              Text(
                text,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.58)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // SECTION HEADER
  // ========================================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required bool isDark,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 19),
        ),

        const SizedBox(width: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==========================================================================
// GLASS TAB BAR DELEGATE
// ==========================================================================

class _GlassTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _GlassTabBarDelegate({required this.child});

  @override
  double get minExtent => 67;

  @override
  double get maxExtent => 67;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _GlassTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
