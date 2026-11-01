import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

export 'healthify_empty_state.dart';
export 'healthify_error_state.dart';
export 'healthify_loading_state.dart';
export 'healthify_status_badge.dart';
export 'access_denied_widget.dart';

typedef HealthifyCard = GlassCard;
typedef HealthifyPrimaryButton = GlassPrimaryButton;
typedef HealthifySecondaryButton = GlassSecondaryButton;
typedef HealthifyIconButton = GlassIconContainer;

class HealthifySectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const HealthifySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing case final Widget t) t,
      ],
    );
  }
}

typedef HealthifyPageHeader = HealthifySectionHeader;

class HealthifyStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const HealthifyStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Row(
        children: [
          GlassIconContainer(
            icon: icon,
            color: color,
            size: 46,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef HealthifyMetricCard = HealthifyStatCard;

class HealthifySearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final String value;

  const HealthifySearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: HealthifyGlassTheme.getTextPrimary(isDark), fontSize: 14),
      decoration: GlassTextFieldTheme.getDecoration(
        context: context,
        hintText: hintText,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: HealthifyGlassTheme.getTextSecondary(isDark),
        ),
      ),
    );
  }
}

class HealthifyFilterBar extends StatelessWidget {
  final List<Widget> children;

  const HealthifyFilterBar({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

class HealthifyChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;

  const HealthifyChartContainer({
    super.key,
    required this.title,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthifySectionHeader(title: title),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: chart,
          ),
        ],
      ),
    );
  }
}

class HealthifyTimeline extends StatelessWidget {
  final List<HealthifyTimelineItem> items;

  const HealthifyTimeline({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassIconContainer(
                icon: item.icon,
                color: item.color,
                size: 36,
                iconSize: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class HealthifyTimelineItem {
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color color;

  const HealthifyTimelineItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    this.color = HealthifyGlassTheme.primaryTeal,
  });
}
