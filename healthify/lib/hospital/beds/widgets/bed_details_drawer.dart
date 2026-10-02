import 'dart:ui';
import 'package:flutter/material.dart';
import '../bed_model.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';

class BedDetailsDrawer extends StatefulWidget {
  final BedItem bed;
  final ValueChanged<BedStatus> onStatusChanged;
  final ValueChanged<bool> onVisibilityToggled;
  final VoidCallback onClose;

  const BedDetailsDrawer({
    super.key,
    required this.bed,
    required this.onStatusChanged,
    required this.onVisibilityToggled,
    required this.onClose,
  });

  @override
  State<BedDetailsDrawer> createState() => _BedDetailsDrawerState();
}

class _BedDetailsDrawerState extends State<BedDetailsDrawer> {
  Color _getStatusColor(BedStatus status) {
    switch (status) {
      case BedStatus.available:
        return const Color(0xFF10B981);
      case BedStatus.occupied:
        return const Color(0xFFEF4444);
      case BedStatus.cleaning:
      case BedStatus.reserved:
        return const Color(0xFFF59E0B);
      case BedStatus.maintenance:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(BedStatus status) {
    switch (status) {
      case BedStatus.available:
        return 'Available';
      case BedStatus.occupied:
        return 'Occupied';
      case BedStatus.cleaning:
        return 'Cleaning';
      case BedStatus.reserved:
        return 'Reserved';
      case BedStatus.maintenance:
        return 'Maintenance';
    }
  }

  void _showStatusChangeDialog() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Status for ${widget.bed.id}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...BedStatus.values.map((status) {
                    final isSelected = widget.bed.status == status;
                    return ListTile(
                      leading: Icon(Icons.circle, color: _getStatusColor(status), size: 14),
                      title: Text(
                        _getStatusText(status),
                        style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                      onTap: () {
                        widget.onStatusChanged(status);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: isDark
                ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.90)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            border: Border(
              left: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.getGlassSurface(isDark),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const GlassIconContainer(
                          icon: Icons.king_bed_outlined,
                          color: AppTheme.primaryColor,
                          size: 38,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bed.id,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.bed.type} Ward • Floor ${widget.bed.floor}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),

              // Drawer Body Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.bed.status).withValues(alpha: isDark ? 0.22 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(widget.bed.status).withValues(alpha: isDark ? 0.45 : 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle, color: _getStatusColor(widget.bed.status), size: 12),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusText(widget.bed.status),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(widget.bed.status),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _showStatusChangeDialog,
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bed Attributes Grid
                      _buildDetailTile(
                        context: context,
                        icon: Icons.apartment_rounded,
                        label: 'Ward & Location',
                        value: 'Ward ${widget.bed.ward} (Floor ${widget.bed.floor})',
                      ),
                      const SizedBox(height: 14),

                      _buildDetailTile(
                        context: context,
                        icon: Icons.badge_outlined,
                        label: 'Patient ID (Staff Only)',
                        value: widget.bed.patientId ?? '— (Unassigned)',
                      ),
                      const SizedBox(height: 14),

                      _buildDetailTile(
                        context: context,
                        icon: Icons.access_time_rounded,
                        label: 'Last Updated',
                        value: widget.bed.lastUpdated,
                      ),

                      const SizedBox(height: 24),
                      Divider(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                      const SizedBox(height: 16),

                      // Equipment Checklist Section
                      Text(
                        'Equipment Availability',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children: [
                          'Ventilator',
                          'Oxygen Unit',
                          'Cardiac Monitor',
                          'Infusion Pump'
                        ].map((equip) {
                          final hasEquip = widget.bed.equipment.contains(equip);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  hasEquip ? Icons.check_circle_rounded : Icons.cancel_outlined,
                                  color: hasEquip ? const Color(0xFF10B981) : (isDark ? Colors.white38 : AppTheme.textMuted),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  equip,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: hasEquip ? FontWeight.w600 : FontWeight.normal,
                                    color: hasEquip
                                        ? (isDark ? Colors.white : AppTheme.textPrimary)
                                        : (isDark ? Colors.white38 : AppTheme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: HealthifyGlassTheme.getGlassBorder(isDark)),
                      const SizedBox(height: 16),

                      // Patient App Visibility Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient App Visibility',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: widget.bed.isVisibleToPatientApp
                                        ? const Color(0xFF10B981)
                                        : (isDark ? Colors.white38 : AppTheme.textMuted),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.bed.isVisibleToPatientApp ? 'Visible' : 'Hidden',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.bed.isVisibleToPatientApp
                                          ? const Color(0xFF10B981)
                                          : (isDark ? Colors.white38 : AppTheme.textMuted),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: widget.bed.isVisibleToPatientApp,
                            activeTrackColor: AppTheme.primaryColor,
                            onChanged: (val) {
                              widget.onVisibilityToggled(val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Drawer Footer Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.getGlassSurface(isDark),
                  border: Border(top: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassSecondaryButton(
                        height: 48,
                        onPressed: _showStatusChangeDialog,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Status'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassPrimaryButton(
                        height: 48,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Bed ${widget.bed.id} details updated')),
                          );
                          widget.onClose();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Edit Bed'),
                          ],
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

  Widget _buildDetailTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white70 : AppTheme.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white54 : AppTheme.textMuted),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}