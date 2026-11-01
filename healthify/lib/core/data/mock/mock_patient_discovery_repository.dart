import '../../enums/domain_enums.dart';
import '../../models/ai_insight_model.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';

import '../../queries/domain_queries.dart';
import '../repositories/patient_discovery_repository.dart';

class MockPatientDiscoveryRepository implements PatientDiscoveryRepository {
  @override
  Future<List<Map<String, dynamic>>> getVisibleBloodAvailability() async => const [];

  @override
  Future<List<Map<String, dynamic>>> getVisibleBedAvailability() async => [
    {
      'hospitalId': 'HOSP-101',
      'type': 'General',
      'available': 15,
      'total': 100,
      'lastUpdated': DateTime.now().toIso8601String(),
    },
    {
      'hospitalId': 'HOSP-101',
      'type': 'ICU',
      'available': 4,
      'total': 20,
      'lastUpdated': DateTime.now().toIso8601String(),
    },
    {
      'hospitalId': 'HOSP-102',
      'type': 'General',
      'available': 8,
      'total': 60,
      'lastUpdated': DateTime.now().toIso8601String(),
    },
  ];
  final List<Hospital> _hospitals = [
    Hospital(
      id: 'HOSP-101',
      name: 'St. Jude Memorial Hospital',
      address: '742 Healthcare Boulevard, Medical District, NY 10001',
      contactNumber: '+1 (555) 900-HEALTHIFY',
      email: 'admin@stjude-hospital.org',
      type: 'Trauma Center & Multi-Specialty',
      rating: 4.8,
      totalBeds: 450,
      totalDoctors: 48,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 7)),
    ),
    Hospital(
      id: 'HOSP-102',
      name: 'City Health Heart & General Hospital',
      address: '108 Metro Avenue, City Center, NY 10002',
      contactNumber: '+1 (555) 901-CITY',
      email: 'contact@cityhealth.org',
      type: 'General & Cardiology Care',
      rating: 4.6,
      totalBeds: 180,
      totalDoctors: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    Hospital(
      id: 'HOSP-103',
      name: 'Apex Care Multi-Specialty Medical Center',
      address: '450 University Boulevard, North Wing, NY 10003',
      contactNumber: '+1 (555) 902-APEX',
      email: 'info@apexcare.org',
      type: 'Tertiary Care & Organ Transplant Center',
      rating: 4.9,
      totalBeds: 350,
      totalDoctors: 56,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Hospital(
      id: 'HOSP-104',
      name: 'Green Valley Community Hospital',
      address: '12 Westside Road, Green Valley, NY 10004',
      contactNumber: '+1 (555) 903-GREEN',
      email: 'reception@greenvalley.org',
      type: 'Community Care & Outpatient Services',
      rating: 4.4,
      totalBeds: 100,
      totalDoctors: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
  ];

  final List<Doctor> _doctors = [
    Doctor(
      id: 'DOC-1001',
      hospitalId: 'HOSP-101',
      departmentId: 'DEP-101',
      name: 'Dr. Sarah Jenkins',
      specialization: 'Cardiology',
      qualification: 'MD, FACC',
      email: 'sarah.jenkins@stjude-hospital.org',
      phone: '+1 (555) 019-2834',
      experienceYears: 16,
      availabilityStatus: DoctorAvailabilityStatus.available,
      affiliationStatus: DoctorAffiliationStatus.fullTime,
      rating: 4.9,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    Doctor(
      id: 'DOC-1004',
      hospitalId: 'HOSP-101',
      departmentId: 'DEP-102',
      name: 'Dr. Michael Chen',
      specialization: 'General Surgery',
      qualification: 'MD, FACS',
      email: 'michael.chen@stjude-hospital.org',
      phone: '+1 (555) 018-3746',
      experienceYears: 18,
      availabilityStatus: DoctorAvailabilityStatus.inSurgery,
      affiliationStatus: DoctorAffiliationStatus.fullTime,
      rating: 4.8,
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    Doctor(
      id: 'DOC-1009',
      hospitalId: 'HOSP-101',
      departmentId: 'DEP-103',
      name: 'Dr. Emily Vance',
      specialization: 'Neurology',
      qualification: 'MD, FAAN',
      email: 'emily.vance@stjude-hospital.org',
      phone: '+1 (555) 017-9912',
      experienceYears: 14,
      availabilityStatus: DoctorAvailabilityStatus.available,
      affiliationStatus: DoctorAffiliationStatus.fullTime,
      rating: 4.95,
      createdAt: DateTime.now().subtract(const Duration(days: 250)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Doctor(
      id: 'DOC-1015',
      hospitalId: 'HOSP-102',
      departmentId: 'DEP-104',
      name: 'Dr. Robert Thorne',
      specialization: 'Gastroenterology',
      qualification: 'MD, FACG',
      email: 'robert.thorne@cityhealth.org',
      phone: '+1 (555) 016-5544',
      experienceYears: 12,
      availabilityStatus: DoctorAvailabilityStatus.available,
      affiliationStatus: DoctorAffiliationStatus.fullTime,
      rating: 4.7,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  @override
  Future<List<Hospital>> searchHospitals(HospitalSearchQuery query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    var results = List<Hospital>.from(_hospitals);

    if (query.searchText.isNotEmpty) {
      final q = query.searchText.toLowerCase();
      results = results
          .where((h) =>
              h.name.toLowerCase().contains(q) ||
              h.address.toLowerCase().contains(q) ||
              h.type.toLowerCase().contains(q))
          .toList();
    }

    if (query.minimumRating > 0) {
      results = results.where((h) => h.rating >= query.minimumRating).toList();
    }

    if (query.sortBy == 'rating') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (query.sortBy == 'name') {
      results.sort((a, b) => a.name.compareTo(b.name));
    }

    return results;
  }

  @override
  Future<HospitalProfile?> getHospitalDetails(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return HospitalProfile(
      id: hospitalId,
      name: 'St. Jude Memorial Hospital',
      legalName: 'St. Jude Health System Inc.',
      displayName: 'St. Jude Memorial Hospital',
      hospitalType: 'Multi-Specialty Medical & Trauma Center',
      establishmentDate: '1984',
      registrationLicenseId: 'LIC-HEALTHIFY-9981',
      taxId: 'TX-991204',
      accreditationInfo: 'JCI Accredited & Level-1 Trauma Certified',
      email: 'admin@stjude-hospital.org',
      emergencyHelpline: '+1 (555) 911-STJUDE',
      receptionPhone: '+1 (555) 900-HEALTHIFY',
      website: 'https://stjude-hospital.org',
      address: '742 Healthcare Boulevard, Medical District',
      city: 'New York',
      state: 'NY',
      country: 'USA',
      latitude: 40.730610,
      longitude: -73.935242,
      totalBeds: 450,
      icuBeds: 60,
      operatingTheatres: 12,
      emergencyCapacity: 40,
      has247Emergency: true,
      traumaLevel: 'Level 1 Trauma Center',
      hasAmbulance: true,
      opdTimings: '08:00 AM - 08:00 PM',
      operatingStatus: 'Normal Operations',
      verificationStatus: VerificationStatus.verified,
      verificationNotes: 'Fully verified hospital system.',
    );
  }

  @override
  Future<List<Doctor>> searchDoctors(DoctorSearchQuery query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    var results = List<Doctor>.from(_doctors);

    if (query.searchText.isNotEmpty) {
      final q = query.searchText.toLowerCase();
      results = results
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.toLowerCase().contains(q))
          .toList();
    }

    if (query.specialty != null && query.specialty!.isNotEmpty) {
      results = results
          .where((d) => d.specialty.toLowerCase().contains(query.specialty!.toLowerCase()))
          .toList();
    }

    if (query.minimumRating > 0) {
      results = results.where((d) => d.rating >= query.minimumRating).toList();
    }

    return results;
  }

  @override
  Future<Doctor?> getDoctorDetails(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _doctors.firstWhere(
      (d) => d.id == doctorId,
      orElse: () => _doctors.first,
    );
  }

  @override
  Future<HealthConcernMappingResult> getHealthConcernMapping(HealthConcernQuery query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final text = query.healthConcernText.toLowerCase();

    List<Department> departments = [
      Department(
        id: 'DEP-101',
        hospitalId: 'HOSP-101',
        name: 'General Medicine',
        code: 'GEN-MED',
        totalStaff: 15,
        description: 'Comprehensive primary care and general diagnosis.',
        isOpdAvailable: true,
        isEmergencyAvailable: true,
        doctorCount: 8,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    List<String> specialties = ['General Physician'];

    if (text.contains('chest') || text.contains('heart') || text.contains('breath')) {
      departments.add(
        Department(
          id: 'DEP-102',
          hospitalId: 'HOSP-101',
          name: 'Cardiology',
          code: 'CARDIO',
          totalStaff: 22,
          description: 'Advanced cardiovascular diagnostics and treatments.',
          isOpdAvailable: true,
          isEmergencyAvailable: true,
          doctorCount: 10,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      specialties.add('Cardiology');
    } else if (text.contains('stomach') || text.contains('digest') || text.contains('pain')) {
      departments.add(
        Department(
          id: 'DEP-104',
          hospitalId: 'HOSP-101',
          name: 'Gastroenterology',
          code: 'GASTRO',
          totalStaff: 14,
          description: 'Digestive health and endoscopic procedures.',
          isOpdAvailable: true,
          isEmergencyAvailable: true,
          doctorCount: 6,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      specialties.add('Gastroenterology');
    } else if (text.contains('headache') || text.contains('dizzy') || text.contains('brain')) {
      departments.add(
        Department(
          id: 'DEP-103',
          hospitalId: 'HOSP-101',
          name: 'Neurology',
          code: 'NEURO',
          totalStaff: 18,
          description: 'Neurological evaluation and specialized brain care.',
          isOpdAvailable: true,
          isEmergencyAvailable: true,
          doctorCount: 7,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      specialties.add('Neurology');
    }

    final matchingDoctors = _doctors.where((d) {
      return specialties.any((s) => d.specialty.toLowerCase().contains(s.toLowerCase()));
    }).toList();

    return HealthConcernMappingResult(
      queryText: query.healthConcernText,
      relevantDepartments: departments,
      relevantSpecialties: specialties,
      matchingDoctors: matchingDoctors.isNotEmpty ? matchingDoctors : [_doctors.first],
      nearbyHospitals: _hospitals,
      nonDiagnosticDisclaimer:
          'This helps you find relevant healthcare services. It is not a diagnosis or clinical decision.',
    );
  }

  @override
  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations(
    EmergencyRecommendationQuery query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      EmergencyHospitalRecommendation(
        hospitalId: 'HOSP-101',
        hospitalName: 'St. Jude Memorial Hospital',
        distanceKm: 1.2,
        emergencyAvailability: 'Open 24/7',
        availableERCapacity: 12,
        icuAvailability: 6,
        specialistAvailability: true,
        bloodAvailability: true,
        estimatedWaitMinutes: 5,
        recommendationScore: 0.96,
        confidence: 0.92,
        generatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
      EmergencyHospitalRecommendation(
        hospitalId: 'HOSP-103',
        hospitalName: 'Apex Care Multi-Specialty Medical Center',
        distanceKm: 3.8,
        emergencyAvailability: 'Open 24/7',
        availableERCapacity: 18,
        icuAvailability: 8,
        specialistAvailability: true,
        bloodAvailability: true,
        estimatedWaitMinutes: 8,
        recommendationScore: 0.94,
        confidence: 0.90,
        generatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    ];
  }
}
