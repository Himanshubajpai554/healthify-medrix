import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class EmergencyHeader extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onNewEmergencyPressed;
  final VoidCallback onRefreshPressed;
  final String lastUpdatedText;

  const EmergencyHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onNewEmergencyPressed,
    required this.onRefreshPressed,
    this.lastUpdatedText = 'Just now',
  });

  @override
  State<EmergencyHeader> createState() => _EmergencyHeaderState();
}

class _EmergencyHeaderState extends State<EmergencyHeader>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  late final AnimationController _entryController;
  late final AnimationController _livePulseController;
  late final AnimationController _refreshController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(text: widget.searchQuery);

    _searchFocusNode = FocusNode();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _livePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.985, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant EmergencyHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchQuery != widget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    _entryController.dispose();
    _livePulseController.dispose();
    _refreshController.dispose();

    super.dispose();
  }

  void _handleSearchChanged(String value) {
    widget.onSearchChanged(value);
  }

  void _handleClearSearch() {
    _searchController.clear();
    widget.onClearSearch();
    _searchFocusNode.requestFocus();
  }

  void _handleRefresh() {
    _refreshController
      ..reset()
      ..forward();

    widget.onRefreshPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    final isCompact = screenWidth < 850;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildGlassShell(
            context,
            isDark,
            isMobile,
            isTablet,
            isCompact,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassShell(
    BuildContext context,
    bool isDark,
    bool isMobile,
    bool isTablet,
    bool isCompact,
  ) {
    final radius = isMobile ? 22.0 : 26.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 15 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: isDark
                ? Colors.white.withOpacity(0.045)
                : Colors.white.withOpacity(0.72),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.085)
                  : Colors.white.withOpacity(0.92),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.16 : 0.055),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(context, isDark, isMobile, isTablet, isCompact),

              SizedBox(height: isMobile ? 14 : 17),

              _buildSearchBar(context, isDark, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    bool isDark,
    bool isMobile,
    bool isTablet,
    bool isCompact,
  ) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(context, isDark, isMobile: true),
          const SizedBox(height: 14),
          _buildMobileActions(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTitleRow(context, isDark, isMobile: false)),

        if (!isCompact) ...[const SizedBox(width: 18), _buildDesktopActions()],
      ],
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    bool isDark, {
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmergencyIcon(isDark, isMobile),

        SizedBox(width: isMobile ? 11 : 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 9,
                runSpacing: 7,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Emergency Cases',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  _buildLiveBadge(isDark, isMobile),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'Monitor and manage active emergency cases in real time.',
                style: TextStyle(
                  fontSize: isMobile ? 12.5 : 13,
                  height: 1.35,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyIcon(bool isDark, bool isMobile) {
    final size = isMobile ? 46.0 : 52.0;

    return AnimatedBuilder(
      animation: _livePulseController,
      builder: (context, child) {
        final pulse = _livePulseController.value;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
            color: Colors.redAccent.withOpacity(isDark ? 0.18 : 0.09),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.30 + (pulse * 0.15)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.05 + (pulse * 0.08)),
                blurRadius: 12 + (pulse * 10),
                spreadRadius: pulse * 2,
              ),
            ],
          ),
          child: Icon(
            Icons.emergency_rounded,
            size: isMobile ? 23 : 27,
            color: Colors.redAccent,
          ),
        );
      },
    );
  }

  Widget _buildLiveBadge(bool isDark, bool isMobile) {
    return AnimatedBuilder(
      animation: _livePulseController,
      builder: (context, child) {
        final pulse = _livePulseController.value;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(isDark ? 0.13 : 0.075),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.20 + (pulse * 0.15)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.82 + (pulse * 0.30),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: isMobile ? 9.5 : 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '• ${widget.lastUpdatedText}',
                style: TextStyle(
                  fontSize: isMobile ? 9 : 9.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRefreshButton(compact: false),
        const SizedBox(width: 10),
        _buildNewEmergencyButton(compact: false),
      ],
    );
  }

  Widget _buildMobileActions() {
    return Row(
      children: [
        Expanded(child: _buildRefreshButton(compact: true)),
        const SizedBox(width: 10),
        Expanded(child: _buildNewEmergencyButton(compact: true)),
      ],
    );
  }

  Widget _buildRefreshButton({required bool compact}) {
    return GlassSecondaryButton(
      onPressed: _handleRefresh,
      height: compact ? 43 : 42,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _refreshController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshController.value * 2 * 3.14159265359,
                child: const Icon(Icons.refresh_rounded, size: 18),
              );
            },
          ),
          const SizedBox(width: 7),
          Text(
            compact ? 'Refresh' : 'Refresh',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEmergencyButton({required bool compact}) {
    return GlassPrimaryButton(
      onPressed: widget.onNewEmergencyPressed,
      height: compact ? 43 : 42,
      color: Colors.redAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_alert_rounded, size: 18),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              compact ? 'New Emergency' : 'New Emergency Case',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark, bool isMobile) {
    const primary = Color(0xFF0D9488);
    const primaryDark = Color(0xFF0F766E);

    final surfaceStrong = isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);

    final border = isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.88);

    final primaryText = isDark ? Colors.white : AppTheme.textPrimary;

    final secondaryText = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: isMobile ? 46 : 48,
          decoration: BoxDecoration(
            color: surfaceStrong,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.06 : 0.035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _handleSearchChanged,
            textInputAction: TextInputAction.search,
            cursorColor: primary,
            style: TextStyle(
              color: primaryText,
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: isMobile
                  ? 'Search emergency cases...'
                  : 'Search emergency cases by patient name, ID, case ID, phone number...',
              hintStyle: TextStyle(
                color: secondaryText,
                fontSize: isMobile ? 12.5 : 13,
              ),

              // Same style as your reference UI.
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: primary,
                size: 20,
              ),

              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: _handleClearSearch,
                      tooltip: 'Clear search',
                      icon: Icon(
                        Icons.clear_rounded,
                        color: secondaryText,
                        size: 19,
                      ),
                    )
                  : null,

              filled: true,
              fillColor: Colors.transparent,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: border),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: primary.withValues(alpha: isDark ? 0.55 : 0.40),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
