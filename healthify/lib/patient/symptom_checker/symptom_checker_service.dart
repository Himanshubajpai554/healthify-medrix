import '../models/patient_portal_models.dart';

class SymptomCheckerService {
  /// Mock dataset of nearby hospitals
  static List<NearbyHospital> getNearbyHospitals() {
    return const [
      NearbyHospital(
        id: 'HOSP-001',
        name: 'St. Jude Memorial Hospital',
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
        facilities: [
          '24/7 ER & Trauma',
          'Level-1 ICU',
          'Cath Lab',
          'MRI & CT 128-Slice',
          'Central Blood Bank',
          'Ambulance Fleet'
        ],
        phone: '+1 (555) 019-2834',
        openHours: 'Open 24 Hours',
      ),
      NearbyHospital(
        id: 'HOSP-002',
        name: 'City Health Heart & General Hospital',
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
        facilities: [
          'Cardiac Care Unit',
          'Emergency Care',
          'Dialysis Center',
          'Digital X-Ray',
          '24/7 Pharmacy'
        ],
        phone: '+1 (555) 018-9941',
        openHours: 'Open 24 Hours',
      ),
      NearbyHospital(
        id: 'HOSP-003',
        name: 'Apex Care Multi-Specialty Medical Center',
        address: '450 University Boulevard, North Wing',
        distanceKm: 5.8,
        rating: 4.9,
        reviewsCount: 2150,
        isEmergencyOpen: true,
        availableBeds: 65,
        totalBeds: 350,
        icuAvailable: 8,
        icuTotal: 45,
        bloodStock: {'O+': 22, 'O-': 5, 'A+': 30, 'B+': 18, 'AB+': 8},
        facilities: [
          'Robotic Surgery',
          'Neuro ICU',
          'Pediatric ER',
          'Organ Transplant Center',
          'Helipad'
        ],
        phone: '+1 (555) 017-7720',
        openHours: 'Open 24 Hours',
      ),
      NearbyHospital(
        id: 'HOSP-004',
        name: 'Green Valley Community Hospital',
        address: '12 Westside Road, Green Valley',
        distanceKm: 8.1,
        rating: 4.4,
        reviewsCount: 430,
        isEmergencyOpen: false,
        availableBeds: 12,
        totalBeds: 100,
        icuAvailable: 1,
        icuTotal: 10,
        bloodStock: {'O+': 5, 'O-': 0, 'A+': 6, 'B+': 4, 'AB+': 1},
        facilities: [
          'OPD Clinics',
          'General Wards',
          'Lab Diagnostics',
          'Ultrasound'
        ],
        phone: '+1 (555) 016-3390',
        openHours: '08:00 AM - 10:00 PM',
      ),
    ];
  }

  /// Mock dataset of doctors
  static List<DoctorSearchResult> getDoctors() {
    return const [
      DoctorSearchResult(
        id: 'DOC-4019',
        name: 'Dr. Sarah Jenkins',
        specialty: 'Senior Cardiologist & Interventionalist',
        department: 'Cardiology',
        hospitalName: 'St. Jude Memorial Hospital',
        distanceKm: 1.2,
        rating: 4.9,
        reviewsCount: 384,
        experienceYears: 16,
        consultationFee: 85.0,
        availableSlots: ['Today 10:30 AM', 'Today 03:15 PM', 'Tomorrow 11:00 AM'],
        isTeleconsultAvailable: true,
      ),
      DoctorSearchResult(
        id: 'DOC-3022',
        name: 'Dr. Marcus Vance',
        specialty: 'Orthopedic Surgeon & Joint Specialist',
        department: 'Orthopedics',
        hospitalName: 'St. Jude Memorial Hospital',
        distanceKm: 1.2,
        rating: 4.7,
        reviewsCount: 290,
        experienceYears: 12,
        consultationFee: 75.0,
        availableSlots: ['Oct 4, 02:00 PM', 'Oct 4, 04:30 PM'],
        isTeleconsultAvailable: false,
      ),
      DoctorSearchResult(
        id: 'DOC-5011',
        name: 'Dr. Elena Rostova',
        specialty: 'Neurologist & Stroke Specialist',
        department: 'Neurology',
        hospitalName: 'Apex Care Medical Center',
        distanceKm: 5.8,
        rating: 4.95,
        reviewsCount: 512,
        experienceYears: 18,
        consultationFee: 110.0,
        availableSlots: ['Today 04:00 PM', 'Tomorrow 09:30 AM'],
        isTeleconsultAvailable: true,
      ),
      DoctorSearchResult(
        id: 'DOC-2099',
        name: 'Dr. Robert Thorne',
        specialty: 'Pulmonologist & Critical Care Specialist',
        department: 'Pulmonology',
        hospitalName: 'City Health Hospital',
        distanceKm: 3.5,
        rating: 4.8,
        reviewsCount: 210,
        experienceYears: 14,
        consultationFee: 80.0,
        availableSlots: ['Today 11:45 AM', 'Today 05:00 PM'],
        isTeleconsultAvailable: true,
      ),
      DoctorSearchResult(
        id: 'DOC-1088',
        name: 'Dr. Amara Patel',
        specialty: 'Pediatric Consultant',
        department: 'Pediatrics',
        hospitalName: 'Apex Care Medical Center',
        distanceKm: 5.8,
        rating: 4.85,
        reviewsCount: 420,
        experienceYears: 10,
        consultationFee: 65.0,
        availableSlots: ['Tomorrow 10:00 AM', 'Tomorrow 02:30 PM'],
        isTeleconsultAvailable: true,
      ),
    ];
  }

  /// Mock personal medical reports
  static List<MedicalReport> getMedicalReports() {
    return [
      MedicalReport(
        id: 'REP-8821',
        title: 'ECG & Cardiac Stress Diagnostic Report',
        category: 'Cardiology',
        doctorName: 'Dr. Sarah Jenkins',
        hospitalName: 'St. Jude Memorial Hospital',
        date: DateTime.now().subtract(const Duration(days: 2)),
        summary: 'Normal sinus rhythm. Mild elevated HR on exertion (72-98 bpm). No ischemic changes observed.',
        fileFormat: 'PDF',
        fileSize: '3.1 MB',
      ),
      MedicalReport(
        id: 'REP-7410',
        title: 'Comprehensive Metabolic & Blood Panel (CBC)',
        category: 'Lab Report',
        doctorName: 'Dr. Healthify Diagnostics',
        hospitalName: 'St. Jude Memorial Hospital',
        date: DateTime.now().subtract(const Duration(days: 15)),
        summary: 'Hemoglobin 14.2 g/dL, WBC 6,800/mcL, Platelets 240,000/mcL. All lipid markers within healthy optimal range.',
        fileFormat: 'PDF',
        fileSize: '1.8 MB',
      ),
      MedicalReport(
        id: 'REP-6302',
        title: 'Lumbar Spine X-Ray & MRI Scan Report',
        category: 'Radiology',
        doctorName: 'Dr. Marcus Vance',
        hospitalName: 'St. Jude Memorial Hospital',
        date: DateTime.now().subtract(const Duration(days: 45)),
        summary: 'L4-L5 mild disc bulge with no neural compression. Physical therapy recommended.',
        fileFormat: 'DICOM',
        fileSize: '14.5 MB',
      ),
    ];
  }

  /// AI / Rule-based Symptom & Health Concern Analyzer
  static SymptomAnalysisResult analyzeHealthConcern(String userQuery) {
    final query = userQuery.toLowerCase().trim();
    final hospitals = getNearbyHospitals();
    final doctors = getDoctors();

    String department = 'General Medicine';
    UrgencyLevel urgency = UrgencyLevel.routine;
    String advice = 'Schedule a routine consultation with a physician for evaluation.';
    List<String> matchedSymptoms = [];

    if (query.contains('chest') ||
        query.contains('heart') ||
        query.contains('palpitation') ||
        query.contains('cardiac') ||
        query.contains('arm pain')) {
      department = 'Cardiology';
      matchedSymptoms.add('Chest Tightness / Heart Concern');
      if (query.contains('severe') || query.contains('tightness') || query.contains('sweat') || query.contains('breath')) {
        urgency = UrgencyLevel.emergency;
        advice = '🚨 CRITICAL WARNING: Severe chest symptoms require immediate emergency medical care. Go to nearest ER or call Emergency Services.';
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
      if (query.contains('numbness') || query.contains('slurred') || query.contains('seizure')) {
        urgency = UrgencyLevel.emergency;
        advice = '🚨 EMERGENCY NOTICE: Sudden neurological deficits or numbness may indicate stroke. Seek emergency care immediately.';
      } else {
        urgency = UrgencyLevel.urgent;
        advice = 'Consult a neurologist for diagnostic MRI and nerve evaluation.';
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
        advice = '🚨 HIGH RISK: Acute respiratory distress detected. Seek emergency oxygen and ER evaluation.';
      } else {
        urgency = UrgencyLevel.urgent;
        advice = 'Consult a pulmonologist or visit acute care for nebulization and oxygen check.';
      }
    } else if (query.contains('bone') ||
        query.contains('fracture') ||
        query.contains('joint') ||
        query.contains('knee') ||
        query.contains('back pain') ||
        query.contains('spine')) {
      department = 'Orthopedics';
      matchedSymptoms.add('Musculoskeletal / Joint Symptoms');
      urgency = query.contains('fracture') || query.contains('severe') ? UrgencyLevel.urgent : UrgencyLevel.routine;
      advice = 'Consult an orthopedic specialist for X-ray scanning and mobility assessment.';
    } else if (query.contains('child') || query.contains('baby') || query.contains('infant') || query.contains('pediatric')) {
      department = 'Pediatrics';
      matchedSymptoms.add('Pediatric Care Symptoms');
      urgency = query.contains('high fever') ? UrgencyLevel.urgent : UrgencyLevel.routine;
      advice = 'Consult a certified pediatrician for child vitals assessment.';
    } else {
      matchedSymptoms.add('General Health / Symptom Evaluation');
      advice = 'Based on your concern, a General Medicine physician can conduct primary triage.';
    }

    final suggestedDoctors = doctors.where((d) => d.department.toLowerCase() == department.toLowerCase()).toList();
    final matchingDocs = suggestedDoctors.isNotEmpty
        ? suggestedDoctors
        : doctors;

    final recommendedHospitals = hospitals.where((h) => h.isEmergencyOpen).toList();

    return SymptomAnalysisResult(
      userQuery: userQuery,
      recommendedDepartment: department,
      urgency: urgency,
      advice: advice,
      matchedSymptoms: matchedSymptoms,
      suggestedDoctors: matchingDocs,
      recommendedHospitals: recommendedHospitals,
    );
  }
}