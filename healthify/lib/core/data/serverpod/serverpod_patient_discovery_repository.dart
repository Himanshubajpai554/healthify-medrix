import 'dart:convert';

import 'package:healthify_server_client/healthify_server_client.dart';

import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';
import '../../queries/domain_queries.dart';
import '../repositories/patient_discovery_repository.dart';

/// Patient-safe directory backed only by verified, discoverable hospitals.
/// It deliberately returns no fabricated live bed, rating, or emergency data.
class ServerpodPatientDiscoveryRepository implements PatientDiscoveryRepository {
  ServerpodPatientDiscoveryRepository(this.client);

  final Client client;

  Future<List<Map<String, dynamic>>> _directory(String type) async {
    final json = await client.hospital.getPatientDirectory(type);
    return (jsonDecode(json) as List).whereType<Map>().map(
      (item) => Map<String, dynamic>.from(item),
    ).toList();
  }

  /// Returns only aggregate occupancy for beds that hospital staff explicitly
  /// made visible in patient discovery. Individual bed or patient details are
  /// never returned.
  @override
  Future<List<Map<String, dynamic>>> getVisibleBedAvailability() =>
      _directory('beds');

  @override
  Future<List<Map<String, dynamic>>> getVisibleBloodAvailability() =>
      _directory('bloodInventory');

  DateTime _date(Object? value) =>
      value is String ? DateTime.tryParse(value) ?? DateTime.now() : DateTime.now();

  Hospital _hospital(Map<String, dynamic> row) => Hospital(
        id: '${row['id']}',
        name: '${row['name'] ?? ''}',
        address: [row['address'], row['city'], row['state'], row['country']]
            .where((part) => part != null && '$part'.trim().isNotEmpty)
            .join(', '),
        contactNumber: '${row['phone'] ?? ''}',
        email: '${row['email'] ?? ''}',
        type: '${row['type'] ?? 'Hospital'}',
        rating: (row['rating'] as num?)?.toDouble() ?? 0,
        totalBeds: (row['totalBeds'] as num?)?.toInt() ?? 0,
        totalDoctors: (row['totalDoctors'] as num?)?.toInt() ?? 0,
        reviewCount: (row['reviewCount'] as num?)?.toInt() ?? 0,
        icuBeds: (row['icuBeds'] as num?)?.toInt() ?? 0,
        has247Emergency: row['has247Emergency'] as bool? ?? false,
        createdAt: _date(row['createdAt']),
        updatedAt: _date(row['updatedAt']),
      );

  HospitalProfile _profile(Map<String, dynamic> r) => HospitalProfile(
        id: '${r['id']}',
        name: '${r['name'] ?? ''}',
        displayName: '${r['name'] ?? ''}',
        legalName: '${r['legalName'] ?? r['name'] ?? ''}',
        hospitalType: '${r['type'] ?? 'Hospital'}',
        establishmentDate: '${r['establishmentDate'] ?? ''}',
        registrationLicenseId: '',
        taxId: '',
        accreditationInfo: '',
        email: '${r['email'] ?? ''}',
        emergencyHelpline: '${r['emergencyPhone'] ?? ''}',
        receptionPhone: '${r['phone'] ?? ''}',
        website: '${r['website'] ?? ''}',
        address: '${r['address'] ?? ''}',
        city: '${r['city'] ?? ''}',
        state: '${r['state'] ?? ''}',
        country: '${r['country'] ?? ''}',
        latitude: (r['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (r['longitude'] as num?)?.toDouble() ?? 0,
        totalBeds: (r['totalBeds'] as num?)?.toInt() ?? 0,
        icuBeds: (r['icuBeds'] as num?)?.toInt() ?? 0,
        operatingTheatres: (r['operatingTheatres'] as num?)?.toInt() ?? 0,
        emergencyCapacity: (r['emergencyCapacity'] as num?)?.toInt() ?? 0,
        has247Emergency: r['has247Emergency'] as bool? ?? false,
        traumaLevel: '${r['traumaLevel'] ?? ''}',
        hasAmbulance: r['hasAmbulance'] as bool? ?? false,
        opdTimings: '${r['opdTimings'] ?? ''}',
        operatingStatus: '${r['operatingStatus'] ?? ''}',
        verificationStatus: VerificationStatus.verified,
        verifiedDate: r['verifiedDate'] == null ? null : _date(r['verifiedDate']),
        verificationNotes: '',
      );

  Doctor _doctor(Map<String, dynamic> r) => Doctor(
        id: '${r['id']}',
        hospitalId: '${r['hospitalId'] ?? ''}',
        departmentId: '${r['departmentId'] ?? r['department'] ?? ''}',
        name: '${r['name'] ?? ''}',
        specialization: '${r['specialization'] ?? r['department'] ?? ''}',
        qualification: '${r['qualification'] ?? ''}',
        email: '${r['email'] ?? ''}',
        phone: '${r['phone'] ?? ''}',
        experienceYears: (r['experienceYears'] as num?)?.toInt() ?? 0,
        availabilityStatus: DoctorAvailabilityStatus.values.firstWhere(
          (value) => value.name == r['availabilityStatus'],
          orElse: () => r['status'] == 'available'
              ? DoctorAvailabilityStatus.available
              : DoctorAvailabilityStatus.offDuty,
        ),
        affiliationStatus: DoctorAffiliationStatus.values.firstWhere(
          (value) => value.name == r['affiliationStatus'],
          orElse: () => DoctorAffiliationStatus.fullTime,
        ),
        rating: (r['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (r['reviewCount'] as num?)?.toInt() ?? 0,
        consultationFee: (r['consultationFee'] as num?)?.toDouble() ?? 0,
        profileImageUrl: r['profileImageUrl'] as String?,
        createdAt: _date(r['createdAt']),
        updatedAt: _date(r['updatedAt']),
      );

  bool _matches(String text, Iterable<Object?> values) {
    final query = text.trim().toLowerCase();
    return query.isEmpty || values.any((value) =>
        value?.toString().toLowerCase().contains(query) ?? false);
  }

  List<T> _page<T>(List<T> rows, int page, int pageSize) {
    final start = ((page - 1) * pageSize).clamp(0, rows.length);
    final end = (start + pageSize).clamp(start, rows.length);
    return rows.sublist(start, end);
  }

  @override
  Future<List<Hospital>> searchHospitals(HospitalSearchQuery query) async {
    var rows = await _directory('hospitals');
    rows = rows.where((r) => _matches(query.searchText, [
      r['name'], r['address'], r['city'], r['type'],
    ])).toList();
    if (query.emergencyOnly) {
      rows = rows.where((r) => r['has247Emergency'] == true).toList();
    }
    if (query.bedsAvailable || query.icuAvailable || query.bloodAvailable ||
        query.facilityIds.isNotEmpty || query.openNow) {
      return const [];
    }
    if (query.minimumRating > 0) {
      rows = rows
          .where((r) => ((r['rating'] as num?)?.toDouble() ?? 0) >= query.minimumRating)
          .toList();
    }
    if (query.sortBy == 'name') rows.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
    if (query.sortBy == 'rating') {
      rows.sort((a, b) =>
          ((b['rating'] as num?)?.toDouble() ?? 0).compareTo((a['rating'] as num?)?.toDouble() ?? 0));
    }
    return _page(rows.map(_hospital).toList(), query.page, query.pageSize);
  }

  @override
  Future<HospitalProfile?> getHospitalDetails(String hospitalId) async {
    final rows = await _directory('hospitals');
    final match = rows.where((r) => r['id'] == hospitalId).firstOrNull;
    return match == null ? null : _profile(match);
  }

  @override
  Future<List<Doctor>> searchDoctors(DoctorSearchQuery query) async {
    var rows = await _directory('doctors');
    rows = rows.where((r) =>
      (query.hospitalId == null || r['hospitalId'] == query.hospitalId) &&
      _matches(query.searchText, [r['name'], r['specialization'], r['department'], r['hospitalName']]) &&
      (query.specialty == null || '${r['specialization'] ?? r['department']}'.toLowerCase().contains(query.specialty!.toLowerCase())) &&
      (query.minimumRating <= 0 || ((r['rating'] as num?)?.toDouble() ?? 0) >= query.minimumRating) &&
      (!query.availableToday || r['availabilityStatus'] == DoctorAvailabilityStatus.available.name || r['status'] == 'available')
    ).toList();
    if (query.sortBy == 'name') rows.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
    if (query.sortBy == 'experience') rows.sort((a, b) => ((b['experienceYears'] as num?)?.toInt() ?? 0).compareTo((a['experienceYears'] as num?)?.toInt() ?? 0));
    return _page(rows.map(_doctor).toList(), query.page, query.pageSize);
  }

  @override
  Future<Doctor?> getDoctorDetails(String doctorId) async {
    final rows = await _directory('doctors');
    final match = rows.where((r) => r['id'] == doctorId).firstOrNull;
    return match == null ? null : _doctor(match);
  }

  @override
  Future<HealthConcernMappingResult> getHealthConcernMapping(HealthConcernQuery query) async {
    final doctors = await searchDoctors(DoctorSearchQuery(searchText: query.healthConcernText, pageSize: 100));
    final hospitals = await searchHospitals(const HospitalSearchQuery(pageSize: 100));
    final text = query.healthConcernText.toLowerCase();
    final specialty = text.contains('heart') || text.contains('chest') ? 'Cardiology'
        : text.contains('skin') || text.contains('rash') ? 'Dermatology'
        : text.contains('bone') || text.contains('joint') ? 'Orthopedics'
        : text.contains('brain') || text.contains('headache') ? 'Neurology'
        : 'General Medicine';
    final matching = doctors.where((d) => d.specialty.toLowerCase().contains(specialty.toLowerCase())).toList();
    return HealthConcernMappingResult(
      queryText: query.healthConcernText,
      relevantDepartments: const [],
      relevantSpecialties: [specialty],
      matchingDoctors: matching,
      nearbyHospitals: hospitals,
      nonDiagnosticDisclaimer: 'This helps you find relevant healthcare services. It is not a diagnosis or clinical recommendation.',
    );
  }

  @override
  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations(EmergencyRecommendationQuery query) async => const [];
}
