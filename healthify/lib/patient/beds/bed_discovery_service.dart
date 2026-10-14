import '../../core/data/serverpod/serverpod_patient_discovery_repository.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/queries/domain_queries.dart' as queries;
import '../models/patient_portal_models.dart';

/// Patient bed discovery uses only hospital-published, patient-visible bed
/// availability. It never fills missing occupancy with demo values.
class BedDiscoveryService {
  static Future<List<HospitalBedData>> getHospitalBedDataList() async {
    final repository = RepositoryContainer.instance.patientDiscoveryRepository;
    final hospitals = await repository.searchHospitals(
      const queries.HospitalSearchQuery(pageSize: 100),
    );
    final rows = await repository.getVisibleBedAvailability();
    final hospitalsById = {for (final hospital in hospitals) hospital.id: hospital};
    final categoriesByHospital = <String, List<BedCategoryDetail>>{};
    final newestByHospital = <String, DateTime>{};
    for (final row in rows) {
      final hospitalId = '${row['hospitalId'] ?? ''}';
      final hospital = hospitalsById[hospitalId];
      if (hospital == null) continue;
      final type = '${row['type'] ?? 'General'}';
      final available = (row['available'] as num?)?.toInt() ?? 0;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      final updated = row['lastUpdated'] is String
          ? DateTime.tryParse(row['lastUpdated'] as String)
          : null;
      final lastUpdated = updated ?? DateTime.fromMillisecondsSinceEpoch(0);
      (categoriesByHospital[hospitalId] ??= []).add(BedCategoryDetail(
        name: type,
        icon: _iconFor(type),
        available: available,
        total: total,
        status: available == 0 ? 'Full' : available < 3 ? 'Limited' : 'Available',
        lastUpdated: lastUpdated,
      ));
      final previous = newestByHospital[hospitalId];
      if (previous == null || lastUpdated.isAfter(previous)) {
        newestByHospital[hospitalId] = lastUpdated;
      }
    }

    return categoriesByHospital.entries.map((entry) {
      final hospital = hospitalsById[entry.key]!;
      return HospitalBedData(
        hospital: NearbyHospital(
          id: hospital.id,
          name: hospital.name,
          address: hospital.address,
          type: hospital.type,
          distanceKm: 0,
          distanceAvailable: false,
          rating: hospital.rating,
          reviewsCount: hospital.reviewCount,
          isEmergencyOpen: hospital.has247Emergency,
          emergencyStatusKnown: true,
          availableBeds: entry.value.fold(0, (sum, category) => sum + category.available),
          totalBeds: entry.value.fold(0, (sum, category) => sum + category.total),
          icuAvailable: entry.value
              .where((category) => category.name.toLowerCase().contains('icu'))
              .fold(0, (sum, category) => sum + category.available),
          icuTotal: entry.value
              .where((category) => category.name.toLowerCase().contains('icu'))
              .fold(0, (sum, category) => sum + category.total),
          bloodStock: const {},
          facilities: const [],
          availabilityKnown: true,
          phone: hospital.contactNumber,
        ),
        estimatedTravelTime: 'Unavailable',
        lastUpdated: newestByHospital[entry.key] ?? DateTime.fromMillisecondsSinceEpoch(0),
        categories: entry.value,
        timeline: const [],
      );
    }).toList();
  }

  static String _iconFor(String type) {
    final value = type.toLowerCase();
    if (value.contains('icu')) return '❤️';
    if (value.contains('emergency')) return '🚨';
    if (value.contains('pediatric') || value.contains('picu')) return '👶';
    if (value.contains('maternity')) return '🤰';
    if (value.contains('private')) return '🏥';
    return '🛏️';
  }
}
