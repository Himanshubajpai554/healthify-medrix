import 'package:flutter/material.dart';
import '../../enums/domain_enums.dart';
import '../../models/core_models.dart';

class MockDataStore {
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  MockDataStore._internal() {
    _initData();
  }

  late HospitalInfo hospitalInfo;
  late List<PatientItem> patients;
  late List<DoctorItem> doctors;
  late List<StaffModel> staff;
  late List<AppointmentItem> appointments;
  late List<BedItem> beds;
  late List<WardCapacityItem> wardCapacities;
  late List<LiveActivityItem> liveActivities;
  late List<BloodGroupSummaryItem> bloodSummaries;
  late List<BloodInventoryUnit> bloodInventory;
  late List<DonationRecordItem> donationRecords;
  late List<BloodRequestItem> bloodRequests;
  late List<FacilityModel> facilities;
  late List<EmergencyCaseItem> emergencyCases;
  late List<DiagnosticReportItem> diagnosticReports;
  late List<PrescriptionRecordItem> prescriptions;
  late List<SystemNotificationItem> notifications;
  late List<NotificationRecord> notificationRecords;
  late List<OperationalAlert> operationalAlerts;
  late List<NotificationDispatch> notificationDispatches;
  late List<NotificationRoutingRule> notificationRoutingRules;
  late List<NotificationPreference> notificationPreferences;
  late List<AlertEscalationRule> alertEscalationRules;
  late List<NotificationActivity> notificationActivities;
  late List<AIInsightItem> aiInsights;
  late List<AuditLog> auditLogs;
  late List<SecurityEvent> securityEvents;
  late List<UserAccessItem> userAccessItems;
  late List<UserSessionInfo> userSessions;
  late List<BreakGlassAccess> breakGlassRequests;
  late List<AuditRetentionPolicy> retentionPolicies;

  late HospitalSettings hospitalSettings;
  late OperationalSettings operationalSettings;
  late EmergencySettings emergencySettings;
  late BedManagementSettings bedManagementSettings;
  late BloodBankSettings bloodBankSettings;
  late NotificationSystemSettings notificationSystemSettings;
  late AISettings aiSettings;
  late SecuritySettings securitySettings;
  late UserPreferences userPreferences;
  late AppearanceSettings appearanceSettings;
  late SystemInformation systemInformation;
  late List<ConfigurationChange> configurationHistory;

  void resetData() {
    _initData();
  }

  void resetAppointments() {
    _initData();
  }

  void _initData() {


    hospitalInfo = const HospitalInfo(
      id: 'HOSP-101',
      name: 'St. Jude Memorial Hospital',
      code: 'MEDRIX-STJUDE',
      tagline: 'Multi-specialty Trauma & Advanced Healthcare Center',
      address: '742 Healthcare Boulevard, Medical District, NY 10001',
      phone: '+1 (555) 900-MEDRIX',
      email: 'admin@stjude-hospital.org',
      emergencyHotline: '+1 (555) 911-STJUDE',
      totalBedCapacity: 450,
      icuCapacity: 60,
      activeDoctorCount: 48,
      totalStaffCount: 320,
    );

    doctors = [
      DoctorItem(
        id: 'DOC-1001',
        name: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        status: DoctorStatus.available,
        activePatients: 18,
        phone: '+1 (555) 019-2834',
        email: 'sarah.jenkins@stjude-hospital.org',
        experienceYears: 14,
        shiftHours: '08:00 AM - 04:00 PM',
      ),
      DoctorItem(
        id: 'DOC-1004',
        name: 'Dr. Michael Chen',
        department: 'General Surgery',
        status: DoctorStatus.inSurgery,
        activePatients: 24,
        phone: '+1 (555) 018-3746',
        email: 'michael.chen@stjude-hospital.org',
        experienceYears: 18,
        shiftHours: '07:00 AM - 03:00 PM',
      ),
      DoctorItem(
        id: 'DOC-1009',
        name: 'Dr. Emily Vance',
        department: 'Neurology',
        status: DoctorStatus.busy,
        activePatients: 15,
        phone: '+1 (555) 017-4859',
        email: 'emily.vance@stjude-hospital.org',
        experienceYears: 9,
        shiftHours: '09:00 AM - 05:00 PM',
      ),
      DoctorItem(
        id: 'DOC-1015',
        name: 'Dr. Alex Rivera',
        department: 'Emergency',
        status: DoctorStatus.available,
        activePatients: 32,
        phone: '+1 (555) 016-5960',
        email: 'alex.rivera@stjude-hospital.org',
        experienceYears: 11,
        shiftHours: '12:00 PM - 08:00 PM',
      ),
      DoctorItem(
        id: 'DOC-1022',
        name: 'Dr. Rachel Green',
        department: 'Pediatrics',
        status: DoctorStatus.offDuty,
        activePatients: 12,
        phone: '+1 (555) 015-6071',
        email: 'rachel.green@stjude-hospital.org',
        experienceYears: 7,
        shiftHours: 'Off Duty (Night)',
      ),
      DoctorItem(
        id: 'DOC-1028',
        name: 'Dr. Marcus Thorne',
        department: 'Orthopedics',
        status: DoctorStatus.inSurgery,
        activePatients: 21,
        phone: '+1 (555) 014-7182',
        email: 'marcus.thorne@stjude-hospital.org',
        experienceYears: 15,
        shiftHours: '08:00 AM - 04:00 PM',
      ),
    ];

    patients = [
      PatientItem(
        id: 'PT-1002',
        name: 'Jane Cooper',
        age: 45,
        gender: 'Female',
        bloodGroup: 'O-',
        ward: 'ICU Main',
        admissionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: PatientStatus.icu,
        doctorName: 'Dr. Sarah Jenkins',
        vitals: {
          'BP': '140/90',
          'Heart Rate': '98 bpm',
          'SpO2': '93%',
          'Temp': '99.1 °F',
        },
      ),
      PatientItem(
        id: 'PT-1005',
        name: 'Robert Fox',
        age: 62,
        gender: 'Male',
        bloodGroup: 'A+',
        ward: 'General Ward A',
        admissionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: PatientStatus.admitted,
        doctorName: 'Dr. Michael Chen',
        vitals: {
          'BP': '120/80',
          'Heart Rate': '72 bpm',
          'SpO2': '98%',
          'Temp': '98.6 °F',
        },
      ),
      PatientItem(
        id: 'PT-1012',
        name: 'Esther Howard',
        age: 29,
        gender: 'Female',
        bloodGroup: 'B+',
        ward: 'Observation Unit',
        admissionDate: DateTime.now(),
        status: PatientStatus.observation,
        doctorName: 'Dr. Emily Vance',
        vitals: {
          'BP': '118/75',
          'Heart Rate': '68 bpm',
          'SpO2': '99%',
          'Temp': '98.4 °F',
        },
      ),
      PatientItem(
        id: 'PT-1018',
        name: 'Cameron Williamson',
        age: 54,
        gender: 'Male',
        bloodGroup: 'AB-',
        ward: 'General Ward B',
        admissionDate: DateTime.now().subtract(const Duration(days: 4)),
        status: PatientStatus.admitted,
        doctorName: 'Dr. Sarah Jenkins',
        vitals: {
          'BP': '125/82',
          'Heart Rate': '76 bpm',
          'SpO2': '97%',
          'Temp': '98.7 °F',
        },
      ),
      PatientItem(
        id: 'PT-1024',
        name: 'Leslie Alexander',
        age: 38,
        gender: 'Female',
        bloodGroup: 'O+',
        ward: 'ICU Emergency',
        admissionDate: DateTime.now().subtract(const Duration(days: 3)),
        status: PatientStatus.icu,
        doctorName: 'Dr. Alex Rivera',
        vitals: {
          'BP': '150/95',
          'Heart Rate': '104 bpm',
          'SpO2': '91%',
          'Temp': '100.2 °F',
        },
      ),
      PatientItem(
        id: 'PT-1031',
        name: 'Guy Hawkins',
        age: 71,
        gender: 'Male',
        bloodGroup: 'A-',
        ward: 'Private Suite 101',
        admissionDate: DateTime.now().subtract(const Duration(days: 7)),
        status: PatientStatus.discharged,
        doctorName: 'Dr. Michael Chen',
        vitals: {
          'BP': '118/78',
          'Heart Rate': '70 bpm',
          'SpO2': '99%',
          'Temp': '98.6 °F',
        },
      ),
    ];

    staff = [
      const StaffModel(
        id: 'STF-301',
        name: 'Nurse Clara Oswald',
        role: StaffRole.nurse,
        department: 'ICU Main',
        status: StaffStatus.inShift,
        phone: '+1 (555) 012-3401',
        shift: 'Morning (07:00 - 15:00)',
      ),
      const StaffModel(
        id: 'STF-304',
        name: 'David Miller',
        role: StaffRole.technician,
        department: 'Radiology',
        status: StaffStatus.active,
        phone: '+1 (555) 012-3404',
        shift: 'Day (09:00 - 17:00)',
      ),
      const StaffModel(
        id: 'STF-308',
        name: 'Elena Rostova',
        role: StaffRole.pharmacist,
        department: 'Central Pharmacy',
        status: StaffStatus.inShift,
        phone: '+1 (555) 012-3408',
        shift: 'Day (08:00 - 16:00)',
      ),
    ];

    appointments = [
      AppointmentItem(
        id: 'APT-101',
        patientName: 'Robert Vance',
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        status: 'scheduled',
        type: 'Consultation',
      ),
      AppointmentItem(
        id: 'APT-102',
        patientName: 'Eleanor Vance',
        doctorName: 'Dr. Michael Chen',
        department: 'General Surgery',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        status: 'checkedIn',
        type: 'FollowUp',
      ),
    ];

    beds = [

      BedItem(
        id: 'BED-101',
        type: 'ICU',
        ward: 'ICU Main Wing',
        floor: 3,
        status: BedStatus.occupied,
        patientId: 'PT-1002',
        equipment: ['Ventilator V2', 'Multi-Para Monitor', 'Infusion Pump'],
        lastUpdated: '10 mins ago',
      ),
      BedItem(
        id: 'BED-102',
        type: 'ICU',
        ward: 'ICU Main Wing',
        floor: 3,
        status: BedStatus.available,
        equipment: ['Multi-Para Monitor', 'Oxygen Point'],
        lastUpdated: 'Just now',
      ),
      BedItem(
        id: 'BED-201',
        type: 'General',
        ward: 'General Ward A',
        floor: 2,
        status: BedStatus.occupied,
        patientId: 'PT-1005',
        equipment: ['IV Pole', 'Call Button'],
        lastUpdated: '1 hour ago',
      ),
      BedItem(
        id: 'BED-202',
        type: 'General',
        ward: 'General Ward A',
        floor: 2,
        status: BedStatus.cleaning,
        equipment: ['IV Pole', 'Call Button'],
        lastUpdated: '25 mins ago',
      ),
      BedItem(
        id: 'BED-301',
        type: 'Emergency',
        ward: 'Trauma Bay',
        floor: 1,
        status: BedStatus.occupied,
        patientId: 'PT-1024',
        equipment: ['Defibrillator', 'Suction Machine', 'Cardiac Monitor'],
        lastUpdated: '5 mins ago',
      ),
      BedItem(
        id: 'BED-401',
        type: 'Private',
        ward: 'Deluxe Wing',
        floor: 4,
        status: BedStatus.reserved,
        equipment: ['Electric Bed Control', 'Telemetry System'],
        lastUpdated: '40 mins ago',
      ),
    ];

    wardCapacities = const [
      WardCapacityItem(name: 'ICU Main Wing', occupied: 14, total: 16, status: 'High'),
      WardCapacityItem(name: 'General Ward A', occupied: 28, total: 35, status: 'Normal'),
      WardCapacityItem(name: 'General Ward B', occupied: 31, total: 35, status: 'Normal'),
      WardCapacityItem(name: 'Emergency Trauma Bay', occupied: 11, total: 12, status: 'Critical'),
      WardCapacityItem(name: 'Private Deluxe Wing', occupied: 18, total: 20, status: 'High'),
    ];

    liveActivities = const [
      LiveActivityItem(
        timeAgo: '2 mins ago',
        description: 'Bed BED-102 disinfected & released to Available stock in ICU Main Wing',
        icon: Icons.cleaning_services_rounded,
        iconColor: Color(0xFF0D9488),
      ),
      LiveActivityItem(
        timeAgo: '12 mins ago',
        description: 'Patient Jane Cooper (PT-1002) admitted to ICU Bed BED-101',
        icon: Icons.airline_seat_flat_rounded,
        iconColor: Color(0xFFEF4444),
      ),
      LiveActivityItem(
        timeAgo: '34 mins ago',
        description: 'Dr. Michael Chen ordered bed transfer request for PT-1005',
        icon: Icons.swap_horiz_rounded,
        iconColor: Color(0xFF3B82F6),
      ),
    ];

    bloodSummaries = const [
      BloodGroupSummaryItem(bloodGroup: 'A+', available: 42, reserved: 8, minRequired: 25, status: 'Healthy'),
      BloodGroupSummaryItem(bloodGroup: 'A-', available: 12, reserved: 4, minRequired: 15, status: 'Limited'),
      BloodGroupSummaryItem(bloodGroup: 'B+', available: 38, reserved: 6, minRequired: 20, status: 'Healthy'),
      BloodGroupSummaryItem(bloodGroup: 'B-', available: 8, reserved: 5, minRequired: 10, status: 'Critical'),
      BloodGroupSummaryItem(bloodGroup: 'AB+', available: 18, reserved: 2, minRequired: 10, status: 'Healthy'),
      BloodGroupSummaryItem(bloodGroup: 'AB-', available: 5, reserved: 3, minRequired: 8, status: 'Critical'),
      BloodGroupSummaryItem(bloodGroup: 'O+', available: 55, reserved: 14, minRequired: 30, status: 'Healthy'),
      BloodGroupSummaryItem(bloodGroup: 'O-', available: 9, reserved: 6, minRequired: 15, status: 'Critical'),
    ];

    bloodInventory = [
      BloodInventoryUnit(
        unitId: 'BG-10921',
        bloodGroup: 'O-',
        component: 'Whole Blood',
        quantityUnits: 1,
        collectionDate: DateTime.now().subtract(const Duration(days: 10)),
        expiryDate: DateTime.now().add(const Duration(days: 25)),
        status: InventoryUnitStatus.available,
        storageLocation: 'Vault Alpha - Frig 1',
        lastUpdated: 'Today, 08:30 AM',
      ),
      BloodInventoryUnit(
        unitId: 'BG-10922',
        bloodGroup: 'A+',
        component: 'RBC Concentrate',
        quantityUnits: 2,
        collectionDate: DateTime.now().subtract(const Duration(days: 14)),
        expiryDate: DateTime.now().add(const Duration(days: 21)),
        status: InventoryUnitStatus.reserved,
        storageLocation: 'Vault Alpha - Frig 2',
        lastUpdated: 'Today, 09:15 AM',
      ),
      BloodInventoryUnit(
        unitId: 'BG-10930',
        bloodGroup: 'B-',
        component: 'Platelets',
        quantityUnits: 1,
        collectionDate: DateTime.now().subtract(const Duration(days: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        status: InventoryUnitStatus.expiringSoon,
        storageLocation: 'Vault Beta - Agitator 1',
        lastUpdated: '1 hour ago',
      ),
    ];

    donationRecords = const [
      DonationRecordItem(
        donorId: 'DNR-801',
        bloodGroup: 'O+',
        donationType: 'Whole Blood',
        units: 1,
        donationDate: '01 Oct 2026',
        screeningStatus: 'Passed',
        storageStatus: 'Stored in Vault A',
      ),
      DonationRecordItem(
        donorId: 'DNR-805',
        bloodGroup: 'A+',
        donationType: 'Platelets',
        units: 2,
        donationDate: '30 Sep 2026',
        screeningStatus: 'Passed',
        storageStatus: 'Stored in Vault B',
      ),
    ];

    bloodRequests = [
      BloodRequestItem(
        requestId: 'BR-402',
        bloodGroup: 'O-',
        requiredUnits: 3,
        allocatedUnits: 2,
        department: 'Emergency & Trauma',
        priority: RequestPriority.critical,
        status: RequestStatus.partiallyAllocated,
      ),
      BloodRequestItem(
        requestId: 'BR-409',
        bloodGroup: 'A+',
        requiredUnits: 2,
        allocatedUnits: 2,
        department: 'General Surgery',
        priority: RequestPriority.urgent,
        status: RequestStatus.completed,
      ),
    ];

    facilities = [
      const FacilityModel(
        id: 'FAC-101',
        name: 'Advanced MRI Imaging Suite',
        category: 'Radiology',
        availability: 'Available',
        capacity: '12 Scans / Day',
        operatingHours: '24/7 Emergency & OPD (08:00 - 20:00)',
        location: 'Ground Floor, Block C',
        description: '3.0 Tesla High-Field MRI system with cardiac & neuro-vascular coils.',
        isVisibleToPatients: true,
        lastUpdated: '15 mins ago',
      ),
      const FacilityModel(
        id: 'FAC-104',
        name: 'Cardiac Catheterization Lab 1',
        category: 'Cardiology',
        availability: 'Available',
        capacity: '8 Procedures / Day',
        operatingHours: '24/7 Emergency Stenting',
        location: '2nd Floor, Heart Institute',
        description: 'Bi-plane digital subtraction angiography system for PCI and EP studies.',
        isVisibleToPatients: true,
        lastUpdated: '1 hour ago',
      ),
      const FacilityModel(
        id: 'FAC-108',
        name: 'Hyperbaric Oxygen Therapy (HBOT)',
        category: 'Specialized Care',
        availability: 'Maintenance',
        capacity: '4 Patients / Session',
        operatingHours: '09:00 AM - 05:00 PM',
        location: 'Basement 1, Rehab Wing',
        description: 'Multi-place hyperbaric chamber undergoing scheduled sensor recalibration.',
        isVisibleToPatients: false,
        lastUpdated: 'Yesterday',
      ),
    ];

    emergencyCases = [
      EmergencyCaseItem(
        id: 'EMG-901',
        patientName: 'Marcus Brody',
        age: 34,
        gender: 'Male',
        chiefComplaint: 'Acute chest pain & radiation to left shoulder',
        priority: TriagePriority.level1Resuscitation,
        status: EmergencyStatus.inTreatment,
        assignedDoctor: 'Dr. Alex Rivera',
        arrivalTime: '10:14 AM',
        locationBed: 'Trauma Bay 01',
      ),
      EmergencyCaseItem(
        id: 'EMG-905',
        patientName: 'Sophia Lin',
        age: 22,
        gender: 'Female',
        chiefComplaint: 'Laceration injury left forearm',
        priority: TriagePriority.level3Urgent,
        status: EmergencyStatus.triage,
        assignedDoctor: 'Dr. Sarah Jenkins',
        arrivalTime: '10:32 AM',
        locationBed: 'Minor OT Room B',
      ),
    ];

    diagnosticReports = [
      DiagnosticReportItem(
        id: 'REP-701',
        patientId: 'PT-1002',
        patientName: 'Jane Cooper',
        title: 'Comprehensive Lipid Panel & HbA1c',
        category: 'Laboratory',
        orderingDoctor: 'Dr. Sarah Jenkins',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: DiagnosticReportStatus.completed,
        labResults: {
          'Total Cholesterol': '218 mg/dL',
          'LDL Cholesterol': '142 mg/dL',
          'HDL Cholesterol': '44 mg/dL',
          'HbA1c': '6.6 %',
        },
      ),
    ];

    prescriptions = [
      PrescriptionRecordItem(
        id: 'RX-9082',
        patientId: 'PT-1002',
        patientName: 'Jane Cooper',
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        date: DateTime.now().subtract(const Duration(days: 2)),
        diagnosis: 'Exertional Angina & Dyslipidemia',
        medications: const [
          MedicationItem(
            drugName: 'Atorvastatin',
            dosage: '40 mg',
            frequency: 'Once Daily (OD)',
            duration: '90 Days',
            instructions: 'Take at night after dinner.',
          ),
        ],
        isActive: true,
      ),
    ];

    notifications = [
      SystemNotificationItem(
        id: 'NTF-101',
        title: 'ICU Capacity Alert',
        message: 'ICU Main Wing capacity reached 87.5% (14/16 beds occupied).',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        severity: NotificationSeverity.warning,
      ),
      SystemNotificationItem(
        id: 'NTF-102',
        title: 'Critical Blood Request',
        message: 'Emergency department placed critical request for 3 units O- Negative.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        severity: NotificationSeverity.critical,
      ),
    ];

    notificationRecords = [
      NotificationRecord(
        id: 'NTF-REC-101',
        hospitalId: 'HOSP-101',
        recipientId: 'DOC-1015',
        recipientRole: UserRole.doctor,
        type: NotificationType.newEmergencyArrival,
        title: 'New Level 1 Emergency Trauma Arrival',
        message: 'Male, 45 yrs, Cardiac Arrest / Severe Trauma in ER Bay 1. Assigned to Dr. Alex Rivera.',
        priority: NotificationPriority.critical,
        status: NotificationStatus.unread,
        sourceEntityType: 'EmergencyCase',
        sourceEntityId: 'EMG-101',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      NotificationRecord(
        id: 'NTF-REC-102',
        hospitalId: 'HOSP-101',
        recipientId: 'NURSE-201',
        recipientRole: UserRole.nurse,
        type: NotificationType.icuVitalCritical,
        title: 'ICU Vital Sign Alert: SpO2 Critical Drop',
        message: 'Patient Eleanor Vance (ICU Bed 4) SpO2 dropped below 85% safety threshold.',
        priority: NotificationPriority.critical,
        status: NotificationStatus.unread,
        sourceEntityType: 'Bed',
        sourceEntityId: 'ICU-BED-04',
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      NotificationRecord(
        id: 'NTF-REC-103',
        hospitalId: 'HOSP-101',
        recipientId: 'ADM-001',
        recipientRole: UserRole.hospitalAdmin,
        type: NotificationType.bloodStockCritical,
        title: 'Critical Blood Inventory: O- Negative',
        message: 'O- Negative reserve depleted to 2 units. Immediate replenishment required.',
        priority: NotificationPriority.critical,
        status: NotificationStatus.acknowledged,
        acknowledgedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        sourceEntityType: 'BloodUnit',
        sourceEntityId: 'BLD-O-NEG',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      NotificationRecord(
        id: 'NTF-REC-104',
        hospitalId: 'HOSP-101',
        recipientId: 'DOC-1001',
        recipientRole: UserRole.doctor,
        type: NotificationType.reportUploaded,
        title: 'Diagnostic Report Uploaded & Ready',
        message: 'Chest CT Angiography uploaded for Patient Jane Cooper. Verification required.',
        priority: NotificationPriority.medium,
        status: NotificationStatus.read,
        readAt: DateTime.now().subtract(const Duration(minutes: 20)),
        sourceEntityType: 'DiagnosticReport',
        sourceEntityId: 'REP-9081',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationRecord(
        id: 'NTF-REC-105',
        hospitalId: 'HOSP-101',
        recipientId: 'REC-101',
        recipientRole: UserRole.receptionist,
        type: NotificationType.bedSanitizationCleared,
        title: 'Ward Bed Sanitization Complete',
        message: 'Bed 201 in Ward 3 has been sanitized and marked available for patient admission.',
        priority: NotificationPriority.low,
        status: NotificationStatus.read,
        readAt: DateTime.now().subtract(const Duration(minutes: 40)),
        sourceEntityType: 'Bed',
        sourceEntityId: 'BED-201',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationRecord(
        id: 'NTF-REC-106',
        hospitalId: 'HOSP-101',
        recipientId: 'STF-501',
        recipientRole: UserRole.nurse,
        type: NotificationType.staffShiftReminder,
        title: 'Upcoming Roster Shift Reminder',
        message: 'Your night shift at ICU West Wing begins in 45 minutes.',
        priority: NotificationPriority.informational,
        status: NotificationStatus.unread,
        sourceEntityType: 'Staff',
        sourceEntityId: 'STF-501',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      NotificationRecord(
        id: 'NTF-REC-107',
        hospitalId: 'HOSP-101',
        recipientId: 'ADM-001',
        recipientRole: UserRole.hospitalAdmin,
        type: NotificationType.aiForecastAlert,
        title: 'AI Forecast Alert: Emergency Surge Expected',
        message: 'AI prediction engine forecasts 35% ER influx surge between 18:00 and 22:00.',
        priority: NotificationPriority.high,
        status: NotificationStatus.unread,
        sourceEntityType: 'AIPrediction',
        sourceEntityId: 'AI-INS-101',
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
      NotificationRecord(
        id: 'NTF-REC-108',
        hospitalId: 'HOSP-101',
        recipientId: 'PT-1001',
        recipientRole: UserRole.patient,
        type: NotificationType.patientAppointmentReminder,
        title: 'Upcoming Appointment Reminder',
        message: 'Reminder: Cardiology Consultation with Dr. Sarah Jenkins tomorrow at 10:00 AM.',
        priority: NotificationPriority.informational,
        status: NotificationStatus.unread,
        sourceEntityType: 'Appointment',
        sourceEntityId: 'APT-301',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    operationalAlerts = [
      OperationalAlert(
        id: 'ALT-201',
        hospitalId: 'HOSP-101',
        type: NotificationType.icuCapacityWarning,
        title: 'ICU Capacity Critical Threshold',
        description: 'ICU Main Wing is at 95% capacity (57/60 beds occupied). Immediate step-down review required.',
        severity: NotificationPriority.critical,
        sourceEntityType: 'Bed',
        sourceEntityId: 'ICU-WING-A',
        status: OperationalAlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      OperationalAlert(
        id: 'ALT-202',
        hospitalId: 'HOSP-101',
        type: NotificationType.bloodStockCritical,
        title: 'O- Negative Blood Depletion Risk',
        description: 'Reserve dropped below emergency safety threshold of 5 units.',
        severity: NotificationPriority.critical,
        sourceEntityType: 'BloodUnit',
        sourceEntityId: 'BLD-BANK-01',
        status: OperationalAlertStatus.acknowledged,
        acknowledgedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      OperationalAlert(
        id: 'ALT-203',
        hospitalId: 'HOSP-101',
        type: NotificationType.emergencyQueueWarning,
        title: 'Triage Queue Congestion Warning',
        description: '14 patients currently in ER triage wait queue. Average wait time exceeds 35 mins.',
        severity: NotificationPriority.high,
        sourceEntityType: 'EmergencyCase',
        sourceEntityId: 'EMG-DEPT-01',
        status: OperationalAlertStatus.active,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    notificationDispatches = [
      NotificationDispatch(
        id: 'DSP-301',
        notificationId: 'NTF-REC-101',
        channel: DispatchChannel.inApp,
        recipientId: 'DOC-1015',
        status: DispatchStatus.delivered,
        attemptedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        deliveredAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      NotificationDispatch(
        id: 'DSP-302',
        notificationId: 'NTF-REC-101',
        channel: DispatchChannel.push,
        recipientId: 'DOC-1015',
        status: DispatchStatus.delivered,
        attemptedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        deliveredAt: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
      NotificationDispatch(
        id: 'DSP-303',
        notificationId: 'NTF-REC-102',
        channel: DispatchChannel.sms,
        recipientId: 'NURSE-201',
        status: DispatchStatus.failed,
        attemptedAt: DateTime.now().subtract(const Duration(minutes: 17)),
        failedAt: DateTime.now().subtract(const Duration(minutes: 16)),
        failureReason: 'Carrier SMS Gateway Connection Timeout',
      ),
      NotificationDispatch(
        id: 'DSP-304',
        notificationId: 'NTF-REC-103',
        channel: DispatchChannel.email,
        recipientId: 'ADM-001',
        status: DispatchStatus.sent,
        attemptedAt: DateTime.now().subtract(const Duration(minutes: 34)),
      ),
    ];

    notificationRoutingRules = [
      const NotificationRoutingRule(
        id: 'RTR-401',
        hospitalId: 'HOSP-101',
        notificationType: NotificationType.newEmergencyArrival,
        recipientRole: UserRole.doctor,
        priority: NotificationPriority.critical,
        channels: [DispatchChannel.inApp, DispatchChannel.push, DispatchChannel.sms],
        enabled: true,
      ),
      const NotificationRoutingRule(
        id: 'RTR-402',
        hospitalId: 'HOSP-101',
        notificationType: NotificationType.bloodStockCritical,
        recipientRole: UserRole.hospitalAdmin,
        priority: NotificationPriority.critical,
        channels: [DispatchChannel.inApp, DispatchChannel.email, DispatchChannel.sms],
        enabled: true,
      ),
      const NotificationRoutingRule(
        id: 'RTR-403',
        hospitalId: 'HOSP-101',
        notificationType: NotificationType.reportUploaded,
        recipientRole: UserRole.doctor,
        priority: NotificationPriority.medium,
        channels: [DispatchChannel.inApp, DispatchChannel.push],
        enabled: true,
      ),
      const NotificationRoutingRule(
        id: 'RTR-404',
        hospitalId: 'HOSP-101',
        notificationType: NotificationType.staffShiftReminder,
        recipientRole: UserRole.nurse,
        priority: NotificationPriority.informational,
        channels: [DispatchChannel.inApp, DispatchChannel.push],
        enabled: true,
      ),
    ];

    notificationPreferences = [
      const NotificationPreference(userId: 'DOC-1015', notificationType: NotificationType.newEmergencyArrival, inAppEnabled: true, pushEnabled: true, emailEnabled: false, smsEnabled: true),
      const NotificationPreference(userId: 'DOC-1015', notificationType: NotificationType.reportUploaded, inAppEnabled: true, pushEnabled: true, emailEnabled: true, smsEnabled: false),
      const NotificationPreference(userId: 'ADM-001', notificationType: NotificationType.bloodStockCritical, inAppEnabled: true, pushEnabled: true, emailEnabled: true, smsEnabled: true),
      const NotificationPreference(userId: 'ADM-001', notificationType: NotificationType.icuCapacityWarning, inAppEnabled: true, pushEnabled: true, emailEnabled: true, smsEnabled: true),
    ];

    alertEscalationRules = [
      const AlertEscalationRule(
        id: 'ESC-501',
        alertType: NotificationType.icuVitalCritical,
        initialRecipientRole: UserRole.nurse,
        escalationRecipientRole: UserRole.doctor,
        delayMinutes: 10,
        enabled: true,
      ),
      const AlertEscalationRule(
        id: 'ESC-502',
        alertType: NotificationType.icuCapacityWarning,
        initialRecipientRole: UserRole.doctor,
        escalationRecipientRole: UserRole.hospitalAdmin,
        delayMinutes: 15,
        enabled: true,
      ),
    ];

    notificationActivities = [];

    aiInsights = [
      AIInsightItem(
        id: 'AI-501',
        title: 'Predicted ICU Bed Deficit by 18:00',
        description: 'Based on current emergency admission rate (2.4/hr) and scheduled post-op recoveries, ICU beds will be 100% occupied in 4 hours.',
        category: InsightCategory.capacityPlanning,
        recommendation: 'Initiate step-down evaluation for 2 stable ICU patients (BED-105 & BED-108) to General Ward A.',
        confidenceScore: 0.92,
        generatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        actionText: 'Review Step-Down Candidates',
      ),
      AIInsightItem(
        id: 'AI-502',
        title: 'O- Negative Inventory Replenishment Alert',
        description: 'Current O- stock is at 9 units with 6 units reserved for pending trauma surgeries.',
        category: InsightCategory.inventoryForecast,
        recommendation: 'Issue voluntary donor drive trigger or order 10 units from Regional Blood Center.',
        confidenceScore: 0.95,
        generatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        actionText: 'Trigger Blood Drive',
      ),
    ];

    auditLogs = [
      AuditLog(
        id: 'AUD-9001',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        actorId: 'DOC-1015',
        actorRole: UserRole.doctor,
        ipAddress: '192.168.1.105',
        userAgent: 'Medrix App iOS 2.4.0',
        actionType: AuditActionType.create,
        targetEntityType: 'EmergencyCase',
        targetEntityId: 'EMG-101',
        previousState: null,
        newState: const {'priority': 'Level1', 'location': 'ER Bay 1', 'chiefComplaint': 'Cardiac Arrest / Severe Trauma'},
        status: 'SUCCESS',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      AuditLog(
        id: 'AUD-9002',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        actorId: 'NURSE-201',
        actorRole: UserRole.nurse,
        ipAddress: '192.168.1.112',
        userAgent: 'Medrix App Web Chrome 122.0',
        actionType: AuditActionType.assignment,
        targetEntityType: 'Bed',
        targetEntityId: 'ICU-BED-04',
        previousState: const {'status': 'available', 'patientId': null},
        newState: const {'status': 'occupied', 'patientId': 'PT-1002'},
        status: 'SUCCESS',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      AuditLog(
        id: 'AUD-9003',
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        actorId: 'STF-401',
        actorRole: UserRole.bloodBankStaff,
        ipAddress: '192.168.1.118',
        userAgent: 'Medrix App Web Firefox 120.0',
        actionType: AuditActionType.update,
        targetEntityType: 'BloodUnit',
        targetEntityId: 'BLD-O-NEG',
        previousState: const {'availableUnits': 8, 'reservedUnits': 4},
        newState: const {'availableUnits': 2, 'reservedUnits': 10},
        status: 'SUCCESS',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      AuditLog(
        id: 'AUD-9004',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        actorId: 'DOC-1001',
        actorRole: UserRole.doctor,
        ipAddress: '192.168.1.102',
        userAgent: 'Medrix App Windows Desktop 2.4.0',
        actionType: AuditActionType.verification,
        targetEntityType: 'DiagnosticReport',
        targetEntityId: 'REP-9081',
        previousState: const {'verificationStatus': 'uploaded'},
        newState: const {'verificationStatus': 'verified', 'verifiedBy': 'DOC-1001'},
        status: 'SUCCESS',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AuditLog(
        id: 'AUD-9005',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actorId: 'REC-101',
        actorRole: UserRole.receptionist,
        ipAddress: '192.168.1.140',
        userAgent: 'Medrix App Web Edge 121.0',
        actionType: AuditActionType.permissionDenied,
        targetEntityType: 'HospitalSettings',
        targetEntityId: 'SET-001',
        previousState: null,
        newState: null,
        status: 'DENIED',
        details: const {'attemptedAction': 'manageSystemSettings', 'requiredPermission': 'manageSystemSettings'},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AuditLog(
        id: 'AUD-9006',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        actorId: 'DOC-1015',
        actorRole: UserRole.doctor,
        ipAddress: '192.168.1.105',
        userAgent: 'Medrix App iOS 2.4.0',
        actionType: AuditActionType.breakGlassRequested,
        targetEntityType: 'Patient',
        targetEntityId: 'PT-1001',
        previousState: const {'accessMode': 'standard'},
        newState: const {'accessMode': 'breakGlassEmergency', 'expiresInMinutes': 60},
        status: 'SUCCESS',
        details: const {'reason': 'Acute Unresponsive Patient Trauma Emergency in ER'},
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    securityEvents = [
      SecurityEvent(
        id: 'SEC-EVT-101',
        type: SecurityEventType.permissionDenied,
        severity: SecurityEventSeverity.medium,
        actorId: 'REC-101',
        description: 'Unauthorized access attempt to System Settings & RBAC panel by Receptionist user.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Investigated',
        relatedAuditId: 'AUD-9005',
      ),
      SecurityEvent(
        id: 'SEC-EVT-102',
        type: SecurityEventType.breakGlassTriggered,
        severity: SecurityEventSeverity.high,
        actorId: 'DOC-1015',
        description: 'Emergency Break-Glass clinical override requested for Patient PT-1001.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'Active',
        relatedAuditId: 'AUD-9006',
      ),
      SecurityEvent(
        id: 'SEC-EVT-103',
        type: SecurityEventType.sensitiveDataAccess,
        severity: SecurityEventSeverity.low,
        actorId: 'DOC-1001',
        description: 'Sensitive diagnostic report REP-9081 opened for verification.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'Resolved',
        relatedAuditId: 'AUD-9004',
      ),
    ];

    userAccessItems = [
      UserAccessItem(
        userId: 'ADM-001',
        userName: 'Admin Sarah Connor',
        email: 'sarah.connor@stjude-hospital.org',
        role: UserRole.hospitalAdmin,
        department: 'Hospital Administration',
        status: 'Active',
        lastAccess: DateTime.now().subtract(const Duration(minutes: 1)),
        permissionSummary: 'Full Operational Control • 48 Permissions',
      ),
      UserAccessItem(
        userId: 'DOC-1015',
        userName: 'Dr. Alex Rivera',
        email: 'alex.rivera@stjude-hospital.org',
        role: UserRole.doctor,
        department: 'Emergency & Trauma',
        status: 'Active',
        lastAccess: DateTime.now().subtract(const Duration(minutes: 5)),
        permissionSummary: 'Clinical Emergency & Patient Management',
      ),
      UserAccessItem(
        userId: 'NURSE-201',
        userName: 'Nurse Mark Sloan',
        email: 'mark.sloan@stjude-hospital.org',
        role: UserRole.nurse,
        department: 'ICU Critical Care',
        status: 'Active',
        lastAccess: DateTime.now().subtract(const Duration(minutes: 12)),
        permissionSummary: 'Inpatient Ward & Vital Monitoring Access',
      ),
      UserAccessItem(
        userId: 'REC-101',
        userName: 'Receptionist Amanda Waller',
        email: 'amanda.waller@stjude-hospital.org',
        role: UserRole.receptionist,
        department: 'Front Desk & Admissions',
        status: 'Active',
        lastAccess: DateTime.now().subtract(const Duration(minutes: 45)),
        permissionSummary: 'Patient Scheduling & Check-In Only',
      ),
    ];

    userSessions = [
      UserSessionInfo(
        sessionId: 'SES-801',
        userId: 'DOC-1015',
        role: UserRole.doctor,
        loginTime: DateTime.now().subtract(const Duration(hours: 4)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 2)),
        device: 'iPad Pro / Medrix Mobile iOS 2.4',
        locationSummary: 'ER Trauma Bay Terminal (192.168.1.105)',
        status: SessionStatus.active,
      ),
      UserSessionInfo(
        sessionId: 'SES-802',
        userId: 'ADM-001',
        role: UserRole.hospitalAdmin,
        loginTime: DateTime.now().subtract(const Duration(hours: 6)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 1)),
        device: 'Windows Workstation / Chrome 122',
        locationSummary: 'Admin Suite Workstation (192.168.1.101)',
        status: SessionStatus.active,
      ),
    ];

    breakGlassRequests = [
      BreakGlassAccess(
        id: 'BG-701',
        userId: 'DOC-1015',
        patientId: 'PT-1001',
        reason: 'Acute Unresponsive Patient Trauma Emergency in ER Bay 1',
        grantedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        status: BreakGlassStatus.granted,
        auditLogId: 'AUD-9006',
      ),
    ];

    retentionPolicies = const [
      AuditRetentionPolicy(auditType: 'Clinical Access & Mutations', retentionDays: 2555, enabled: true),
      AuditRetentionPolicy(auditType: 'Operational & Bed Allocations', retentionDays: 365, enabled: true),
      AuditRetentionPolicy(auditType: 'Security & Permission Denials', retentionDays: 1825, enabled: true),
    ];

    hospitalSettings = const HospitalSettings(hospitalId: 'HOSP-101');
    operationalSettings = const OperationalSettings();
    emergencySettings = const EmergencySettings();
    bedManagementSettings = const BedManagementSettings();
    bloodBankSettings = const BloodBankSettings();
    notificationSystemSettings = const NotificationSystemSettings();
    aiSettings = const AISettings();
    securitySettings = const SecuritySettings();
    userPreferences = const UserPreferences(userId: 'USR-001');
    appearanceSettings = const AppearanceSettings();
    systemInformation = const SystemInformation();
    configurationHistory = [
      ConfigurationChange(
        id: 'CFG-001',
        hospitalId: 'HOSP-101',
        category: 'Operating Mode',
        setting: 'operatingMode',
        previousValue: 'Maintenance Mode',
        newValue: 'Normal Operations',
        changedBy: 'System Administrator (ADM-001)',
        changedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ConfigurationChange(
        id: 'CFG-002',
        hospitalId: 'HOSP-101',
        category: 'Bed Management',
        setting: 'icuCriticalThreshold',
        previousValue: '0.90',
        newValue: '0.85',
        changedBy: 'Medical Director (DOC-1001)',
        changedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

}
