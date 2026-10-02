import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class LiveHospitalCapacityWidget extends StatelessWidget {
  const LiveHospitalCapacityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.pie_chart_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 34,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live Ward Capacity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '208 / 250 Beds In Use',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildCapacityItem(context, 'General Wards', 160, 180, const Color(0xFF0D9488)),
          const SizedBox(height: 12),
          _buildCapacityItem(context, 'ICU Wards', 26, 30, const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          _buildCapacityItem(context, 'Emergency Care', 18, 20, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildCapacityItem(context, 'Pediatric Ward', 30, 35, const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildCapacityItem(context, 'Surgical ICU', 8, 10, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildCapacityItem(BuildContext context, String label, int occupied, int total, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final double ratio = occupied / total;
    final int percentage = (ratio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$occupied / $total ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: percentage >= 90
                    ? const Color(0xFFEF4444)
                    : (percentage >= 80 ? const Color(0xFFF59E0B) : (isDark ? Colors.white70 : AppTheme.textSecondary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: HealthifyGlassTheme.getGlassBorder(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 90
                  ? const Color(0xFFEF4444)
                  : (percentage >= 85 ? const Color(0xFFF59E0B) : color),
            ),
          ),
        ),
      ],
    );
  }
}

class HospitalResourceSnapshotWidget extends StatelessWidget {
  const HospitalResourceSnapshotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.inventory_outlined,
                color: AppTheme.accentColor,
                size: 34,
                iconSize: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resource & Facility Readiness',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ResourceTile(
                name: 'Ventilators',
                status: '28 / 30 Active',
                subtext: '2 in maintenance',
                icon: Icons.air_rounded,
                color: Color(0xFF10B981),
              ),
              _ResourceTile(
                name: 'MRI Machines',
                status: '3 / 3 Ready',
                subtext: '0 queue delay',
                icon: Icons.personal_injury_outlined,
                color: AppTheme.accentColor,
              ),
              _ResourceTile(
                name: 'CT Scanners',
                status: '2 / 2 Ready',
                subtext: '1 scan in progress',
                icon: Icons.document_scanner_outlined,
                color: AppTheme.primaryColor,
              ),
              _ResourceTile(
                name: 'Oxygen Storage',
                status: '94% Full',
                subtext: 'Bulk tank normal',
                icon: Icons.speed_rounded,
                color: Color(0xFF10B981),
              ),
              _ResourceTile(
                name: 'Operating Rooms',
                status: '6 / 8 In Use',
                subtext: '2 emergency ready',
                icon: Icons.meeting_room_outlined,
                color: Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final String name;
  final String status;
  final String subtext;
  final IconData icon;
  final Color color;

  const _ResourceTile({
    required this.name,
    required this.status,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white38 : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class DepartmentLoadWidget extends StatelessWidget {
  const DepartmentLoadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.local_hospital_outlined,
                color: AppTheme.primaryColor,
                size: 34,
                iconSize: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Department Load & Pressure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildDeptRow(context, 'Emergency Medicine', 0.92, '92% Heavy', const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          _buildDeptRow(context, 'General Surgery', 0.85, '85% High', const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildDeptRow(context, 'Cardiology', 0.78, '78% Moderate', const Color(0xFF0D9488)),
          const SizedBox(height: 12),
          _buildDeptRow(context, 'Orthopedics', 0.64, '64% Normal', const Color(0xFF0284C7)),
          const SizedBox(height: 12),
          _buildDeptRow(context, 'Pediatrics', 0.55, '55% Light', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildDeptRow(BuildContext context, String dept, double ratio, String statusText, Color color) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dept,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: HealthifyGlassTheme.getGlassBorder(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}