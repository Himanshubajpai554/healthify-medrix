import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class BedDetailsModal extends StatelessWidget {
  final HospitalBedData bedData;

  const BedDetailsModal({
    super.key,
    required this.bedData,
  });

  static void show(BuildContext context, {required HospitalBedData bedData}) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BedDetailsModal(bedData: bedData),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = bedData.hospital;
    final isStale = bedData.isStale;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle Bar Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.teal),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${h.distanceKm} km (${bedData.estimatedTravelTime}) • ${h.address}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Modal Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DATA FRESHNESS & DISCLAIMER BANNER
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isStale ? Colors.amber.withValues(alpha: 0.12) : Colors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isStale ? Colors.amber.withValues(alpha: 0.4) : Colors.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isStale ? Icons.warning_amber_rounded : Icons.history_rounded,
                              color: isStale ? Colors.amber.shade900 : Colors.teal,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isStale
                                  ? 'Availability last updated ${_formatTimestamp(bedData.lastUpdated)} (Stale Data)'
                                  : 'Updated ${_formatTimestamp(bedData.lastUpdated)}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isStale ? Colors.amber.shade900 : Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '⚠️ Bed availability changes rapidly. Please contact the hospital to confirm before travelling. Bed capacity is NOT guaranteed until confirmed by hospital staff.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CURRENT BED AVAILABILITY BY CATEGORY
                  const Text(
                    'Current Bed Availability Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: bedData.categories.map((cat) {
                      return _buildCategoryDetailCard(cat, isDark);
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // AVAILABILITY TIMELINE HISTORY
                  const Text(
                    'Availability Updates Timeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track historical changes over the past hours to understand capacity flow.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCardColor : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight),
                    ),
                    child: Column(
                      children: bedData.timeline.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatTimestamp(entry.timestamp),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${entry.categoryName}: ${entry.availableCount} beds reported available',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RELATED HOSPITAL FACILITIES CONTEXT
                  const Text(
                    'Related Critical Facilities Context',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: h.facilities.map((fac) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text(
                              fac,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Modal Footer Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening Navigation to ${h.name} (${h.address}). Travel time: ${bedData.estimatedTravelTime} (estimate).'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: const Text('Get Directions'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${h.name} Admission Line (${h.phone}) to confirm bed availability...'),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: const Text('Call to Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailCard(BedCategoryDetail cat, bool isDark) {
    Color statusColor;
    if (cat.available == 0) {
      statusColor = Colors.red;
    } else if (cat.available <= 3) {
      statusColor = Colors.amber.shade800;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '${cat.name} Beds',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cat.available} / ${cat.total} ${cat.status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (cat.relatedFacilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Equipment: ${cat.relatedFacilities.join(" • ")}',
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}