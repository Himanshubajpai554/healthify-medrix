import '../../core/provider/repository_provider.dart';
import '../../core/queries/domain_queries.dart';
import '../models/patient_portal_models.dart';

/// Clinical triage assistant service.
///
/// Under medical device and clinical governance rules, this service is an
/// informational triage routing tool only and NOT a diagnostic device.
///
/// **Connected mode**:
/// Dynamically queries [PatientDiscoveryRepository] to recommend verified,
/// discoverable hospitals and active doctor records matching the triage department.
///
/// **Offline / Demo mode**:
/// Clearly labels sample recommendations with [DEMO] prefix so they can never
/// be presented as live clinical availability.
class SymptomCheckerService {
  static const String clinicalDisclaimer =
      'NOTICE: Healthify Triage Routing Assistant is an informational triage aid only. '
      'It does not provide medical diagnoses or replace clinical evaluation by a licensed physician. '
      'If you are experiencing severe, worsening, or life-threatening symptoms, dial emergency services immediately.';

  /// Returns verified hospitals from the server if connected, else fallback demo data.
  static Future<List<NearbyHospital>> getNearbyHospitals() async {
    final discoveryRepo =
        RepositoryContainer.instance.patientDiscoveryRepository;

    try {
      final verified = await discoveryRepo.searchHospitals(
        const HospitalSearchQuery(pageSize: 50),
      );
      if (verified.isNotEmpty) {
        return verified
            .map(
              (h) => NearbyHospital(
                id: h.id,
                name: h.name,
                address: h.address,
                distanceKm: 0.0,
                distanceAvailable: false,
                rating: h.rating,
                reviewsCount: h.reviewCount,
                isEmergencyOpen: h.has247Emergency,
                emergencyStatusKnown: true,
                availableBeds: h.totalBeds,
                totalBeds: h.totalBeds,
                icuAvailable: h.icuBeds,
                icuTotal: h.icuBeds,
                bloodStock: const {},
                facilities: const [
                  'Emergency Care',
                  'Inpatient Services',
                  'Diagnostics'
                ],
                phone: h.contactNumber,
                openHours: h.has247Emergency
                    ? 'Open 24 Hours'
                    : 'Hospital Clinical Hours',
              ),
            )
            .toList();
      }
    } catch (_) {
      // Fall through to fallback
    }

    return _demoHospitals;
  }

  /// Returns verified doctors from the server if connected, else fallback demo data.
  static Future<List<DoctorSearchResult>> getDoctors() async {
    final discoveryRepo =
        RepositoryContainer.instance.patientDiscoveryRepository;

    try {
      final verified = await discoveryRepo.searchDoctors(
        const DoctorSearchQuery(pageSize: 50),
      );
      if (verified.isNotEmpty) {
        return verified
            .map(
              (d) => DoctorSearchResult(
                id: d.id,
                name: d.name,
                specialty: d.specialty.isNotEmpty
                    ? d.specialty
                    : 'General Specialist',
                department: d.departmentId.isNotEmpty
                    ? d.departmentId
                    : 'General Medicine',
                hospitalName: d.hospitalId,
                distanceKm: 0.0,
                distanceAvailable: false,
                rating: d.rating,
                reviewsCount: d.reviewCount,
                experienceYears: d.experienceYears,
                consultationFee: d.consultationFee,
                availableSlots: const ['Contact Hospital for Slots'],
                isTeleconsultAvailable: false,
                hospitalId: d.hospitalId,
                departmentId: d.departmentId,
              ),
            )
            .toList();
      }
    } catch (_) {
      // Fall through to fallback
    }

    return _demoDoctors;
  }

  /// Evaluates patient health concern and returns department triage recommendations.
  static Future<SymptomAnalysisResult> analyzeHealthConcern(
    String userQuery,
  ) async {
    final query = userQuery.toLowerCase().trim();
    final hospitals = await getNearbyHospitals();
    final doctors = await getDoctors();

    String department = 'General Medicine';
    UrgencyLevel urgency = UrgencyLevel.routine;
    String advice =
        'Schedule an appointment with a primary care physician for clinical evaluation.';
    List<String> matchedSymptoms = [];

    if (query.contains('chest') ||
        query.contains('heart') ||
        query.contains('palpitation') ||
        query.contains('cardiac') ||
        query.contains('arm pain')) {
      department = 'Cardiology';
      matchedSymptoms.add('Chest Tightness / Heart Concern');
      if (query.contains('severe') ||
          query.contains('tightness') ||
          query.contains('sweat') ||
          query.contains('breath')) {
        urgency = UrgencyLevel.emergency;
        advice =
            '🚨 CRITICAL WARNING: Severe chest symptoms require immediate emergency medical care. Go to the nearest ER or call Emergency Services.';
      } else {
        urgency = UrgencyLevel.urgent;
        advice = 'Prompt evaluation by a cardiologist is advised within 24 hours.';
      }
    } else if (query.contains('headache') ||
        query.contains('dizzy') ||
        query.contains('numbness') ||
        query.contains('seizure') ||
        query.contains('stroke') ||
        query.contains('migraine')) {
      department = 'Neurology';
      matchedSymptoms.add('Neurological / Headache Symptoms');
      if (query.contains('numbness') ||
          query.contains('slurred') ||
          query.contains('seizure')) {
        urgency = UrgencyLevel.emergency;
        advice =
            '🚨 EMERGENCY NOTICE: Sudden neurological deficits or numbness may indicate stroke. Seek emergency care immediately.';
      } else {
        urgency = UrgencyLevel.urgent;
        advice =
            'Consult a neurologist for diagnostic imaging and clinical assessment.';
      }
    } else if (query.contains('breath') ||
        query.contains('shortness') ||
        query.contains('cough') ||
        query.contains('wheezing') ||
        query.contains('asthma')) {
      department = 'Pulmonology';
      matchedSymptoms.add('Respiratory / Breathing Difficulty');
      if (query.contains('severe') || query.contains('gasping')) {
        urgency = UrgencyLevel.emergency;
        advice =
            '🚨 HIGH RISK: Acute respiratory distress detected. Seek emergency oxygen and ER evaluation.';
      } else {
        urgency = UrgencyLevel.urgent;
        advice =
            'Consult a pulmonologist or visit acute care for clinical evaluation.';
      }
    } else if (query.contains('bone') ||
        query.contains('fracture') ||
        query.contains('joint') ||
        query.contains('knee') ||
        query.contains('back pain') ||
        query.contains('spine')) {
      department = 'Orthopedics';
      matchedSymptoms.add('Musculoskeletal / Joint Symptoms');
      urgency = query.contains('fracture') || query.contains('severe')
          ? UrgencyLevel.urgent
          : UrgencyLevel.routine;
      advice =
          'Consult an orthopedic specialist for X-ray imaging and mobility evaluation.';
    } else if (query.contains('child') ||
        query.contains('baby') ||
        query.contains('infant') ||
        query.contains('pediatric')) {
      department = 'Pediatrics';
      matchedSymptoms.add('Pediatric Care Symptoms');
      urgency = query.contains('high fever')
          ? UrgencyLevel.urgent
          : UrgencyLevel.routine;
      advice = 'Consult a certified pediatrician for child vitals evaluation.';
    } else {
      matchedSymptoms.add('General Health / Symptom Evaluation');
      advice =
          'Based on your concern, a General Medicine physician can conduct primary triage.';
    }

    final suggestedDoctors = doctors
        .where(
          (d) =>
              d.department.toLowerCase() == department.toLowerCase() ||
              d.specialty.toLowerCase().contains(department.toLowerCase()),
        )
        .toList();
    final matchingDocs = suggestedDoctors.isNotEmpty
        ? suggestedDoctors
        : doctors;

    final recommendedHospitals =
        hospitals.where((h) => h.isEmergencyOpen).toList();

    return SymptomAnalysisResult(
      userQuery: userQuery,
      recommendedDepartment: department,
      urgency: urgency,
      advice: '$advice\n\n$clinicalDisclaimer',
      matchedSymptoms: matchedSymptoms,
      suggestedDoctors: matchingDocs,
      recommendedHospitals: recommendedHospitals.isNotEmpty
          ? recommendedHospitals
          : hospitals,
    );
  }

  // ── Offline Demo Fallbacks ────────────────────────────────────────────────

  static const List<NearbyHospital> _demoHospitals = [
    NearbyHospital(
      id: 'HOSP-DEMO-001',
      name: '[DEMO] St. Jude Memorial Hospital',
      address: '742 Evergreen Terrace, Medical District',
      distanceKm: 1.2,
      rating: 4.8,
      reviewsCount: 1240,
      isEmergencyOpen: true,
      availableBeds: 42,
      totalBeds: 250,
      icuAvailable: 4,
      icuTotal: 30,
      bloodStock: {'O+': 14, 'O-': 2, 'A+': 18, 'B+': 10, 'AB+': 5},
      facilities: ['24/7 ER & Trauma', 'Level-1 ICU', 'Cath Lab'],
      phone: '+1 (555) 019-2834',
      openHours: 'Open 24 Hours',
    ),
    NearbyHospital(
      id: 'HOSP-DEMO-002',
      name: '[DEMO] City Health Heart & General Hospital',
      address: '108 Metro Avenue, City Center',
      distanceKm: 3.5,
      rating: 4.6,
      reviewsCount: 890,
      isEmergencyOpen: true,
      availableBeds: 18,
      totalBeds: 180,
      icuAvailable: 2,
      icuTotal: 20,
      bloodStock: {'O+': 8, 'O-': 1, 'A+': 12, 'B+': 6, 'AB+': 3},
      facilities: ['Cardiac Care Unit', 'Emergency Care', 'Dialysis Center'],
      phone: '+1 (555) 018-9941',
      openHours: 'Open 24 Hours',
    ),
  ];

  static const List<DoctorSearchResult> _demoDoctors = [
    DoctorSearchResult(
      id: 'DOC-DEMO-4019',
      name: '[DEMO] Dr. Sarah Jenkins',
      specialty: 'Senior Cardiologist & Interventionalist',
      department: 'Cardiology',
      hospitalName: '[DEMO] St. Jude Memorial Hospital',
      distanceKm: 1.2,
      rating: 4.9,
      reviewsCount: 384,
      experienceYears: 16,
      consultationFee: 85.0,
      availableSlots: ['Today 10:30 AM', 'Tomorrow 11:00 AM'],
      isTeleconsultAvailable: true,
    ),
    DoctorSearchResult(
      id: 'DOC-DEMO-3022',
      name: '[DEMO] Dr. Marcus Vance',
      specialty: 'Orthopedic Surgeon & Joint Specialist',
      department: 'Orthopedics',
      hospitalName: '[DEMO] St. Jude Memorial Hospital',
      distanceKm: 1.2,
      rating: 4.7,
      reviewsCount: 290,
      experienceYears: 12,
      consultationFee: 75.0,
      availableSlots: ['Oct 4, 02:00 PM'],
      isTeleconsultAvailable: false,
    ),
    DoctorSearchResult(
      id: 'DOC-DEMO-5011',
      name: '[DEMO] Dr. Elena Rostova',
      specialty: 'Neurologist & Stroke Specialist',
      department: 'Neurology',
      hospitalName: '[DEMO] Apex Care Medical Center',
      distanceKm: 5.8,
      rating: 4.95,
      reviewsCount: 512,
      experienceYears: 18,
      consultationFee: 110.0,
      availableSlots: ['Today 04:00 PM'],
      isTeleconsultAvailable: true,
    ),
  ];
}