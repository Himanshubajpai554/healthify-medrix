import 'package:flutter/material.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorMockData {
  static const PatientModel patientRahul = PatientModel(
    id: 'PAT-10892',
    name: 'Rahul Sharma',
    age: 42,
    gender: 'Male',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    phone: '+91 98765 12345',
    bloodGroup: 'B+',
    mrn: 'MRN-2026-8812',
    allergies: ['Penicillin', 'Sulfa Drugs'],
    chronicConditions: ['Hypertension (Stage 1)', 'Type 2 Diabetes'],
    currentMedications: [
      'Atorvastatin 20mg (OD)',
      'Metoprolol 50mg (BD)',
      'Metformin 500mg (BD)',
    ],
    lastVisitDate: 'Sep 28',
    lastVisitDoctor: 'Dr. Sarah Jenkins',
    primaryConcern: 'Post-ECG chest tightness, mild exertional dyspnea',
    careStatus: PatientCareStatus.followUpDue,
    nextAppointmentText: 'Oct 02, 10:30 AM',
    followUpStatus: 'Due',
    department: 'Cardiology',
    clinicalAlerts: ['Pending CBC Report', 'Follow-up Due'],
  );

  static const PatientModel patientPriya = PatientModel(
    id: 'PAT-10893',
    name: 'Priya Verma',
    age: 31,
    gender: 'Female',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    phone: '+91 98123 45678',
    bloodGroup: 'O+',
    mrn: 'MRN-2026-9041',
    allergies: ['Dust Mites'],
    chronicConditions: ['Hypothyroidism'],
    currentMedications: ['Thyronorm 50mcg (OD Morning)'],
    lastVisitDate: 'Sep 25',
    lastVisitDoctor: 'Dr. Sarah Jenkins',
    primaryConcern: 'Routine Cardiology Follow-up & Lipid Review',
    careStatus: PatientCareStatus.active,
    nextAppointmentText: 'Oct 04, 02:00 PM',
    followUpStatus: 'Scheduled',
    department: 'Cardiology',
    clinicalAlerts: [],
  );

  static const PatientModel patientAmit = PatientModel(
    id: 'PAT-10894',
    name: 'Amit Kumar',
    age: 58,
    gender: 'Male',
    avatarUrl: 'https://i.pravatar.cc/150?img=60',
    phone: '+91 97654 32109',
    bloodGroup: 'A+',
    mrn: 'MRN-2026-4432',
    allergies: ['NSAIDs / Aspirin Allergy'],
    chronicConditions: ['Coronary Artery Disease (Post-Stent 2024)'],
    currentMedications: ['Clopidogrel 75mg', 'Rosuvastatin 10mg', 'Ramipril 2.5mg'],
    lastVisitDate: 'Sep 29',
    lastVisitDoctor: 'Dr. Rahul Verma',
    primaryConcern: 'Acute Emergency Chest Pain on Arrival',
    careStatus: PatientCareStatus.admitted,
    nextAppointmentText: 'In-Bed ICU-02 Rounds',
    followUpStatus: 'Admitted',
    department: 'Emergency & ICU',
    clinicalAlerts: ['Recent Emergency Admission', 'Medication Review Required'],
  );

  static const PatientModel patientNeha = PatientModel(
    id: 'PAT-10895',
    name: 'Neha Singh',
    age: 28,
    gender: 'Female',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    phone: '+91 99887 76655',
    bloodGroup: 'AB+',
    mrn: 'MRN-2026-1190',
    allergies: [],
    chronicConditions: ['Sinus Tachycardia'],
    currentMedications: ['Ivabradine 5mg'],
    lastVisitDate: 'Sep 20',
    lastVisitDoctor: 'Dr. Sarah Jenkins',
    primaryConcern: 'Palpitations during exercise & fatigue',
    careStatus: PatientCareStatus.active,
    nextAppointmentText: 'Oct 08, 11:00 AM',
    followUpStatus: 'Scheduled',
    department: 'Cardiology',
    clinicalAlerts: [],
  );

  static const PatientModel patientArjun = PatientModel(
    id: 'PAT-10896',
    name: 'Arjun Gupta',
    age: 63,
    gender: 'Male',
    avatarUrl: 'https://i.pravatar.cc/150?img=53',
    phone: '+91 94123 98765',
    bloodGroup: 'O-',
    mrn: 'MRN-2026-7721',
    allergies: ['Contrast Dye'],
    chronicConditions: ['Atrial Fibrillation', 'CKD Stage 2'],
    currentMedications: ['Apixaban 5mg (BD)', 'Diltiazem 120mg (OD)'],
    lastVisitDate: 'Sep 18',
    lastVisitDoctor: 'Dr. Sarah Jenkins',
    primaryConcern: 'INR & Kidney Function Assessment',
    careStatus: PatientCareStatus.followUpDue,
    nextAppointmentText: 'Oct 05, 09:30 AM',
    followUpStatus: 'Due',
    department: 'Nephrology',
    clinicalAlerts: ['Follow-up overdue'],
  );

  static const PatientModel patientRajesh = patientArjun;

  static const PatientModel patientSneha = PatientModel(
    id: 'PAT-10897',
    name: 'Sneha Patel',
    age: 35,
    gender: 'Female',
    avatarUrl: 'https://i.pravatar.cc/150?img=49',
    phone: '+91 95432 10987',
    bloodGroup: 'B-',
    mrn: 'MRN-2026-3389',
    allergies: [],
    chronicConditions: ['Eczema', 'Seasonal Asthma'],
    currentMedications: ['Desloratadine 5mg', 'Fluticasone Inhaler'],
    lastVisitDate: 'Sep 30',
    lastVisitDoctor: 'Dr. Ananya Sharma',
    primaryConcern: 'Skin Rash & Allergic Flare-up',
    careStatus: PatientCareStatus.newPatient,
    nextAppointmentText: 'Oct 06, 04:00 PM',
    followUpStatus: 'Scheduled',
    department: 'Dermatology',
    clinicalAlerts: [],
  );

  static List<PatientModel> getAllPatients() {
    return [
      patientRahul,
      patientPriya,
      patientAmit,
      patientNeha,
      patientArjun,
      patientSneha,
    ];
  }

  static List<DoctorAppointmentModel> getAppointments() {
    final today = DateTime.now();

    return [
      DoctorAppointmentModel(
        id: 'APT-101',
        patient: patientRahul,
        appointmentTime: '09:00 AM',
        appointmentType: 'Follow-up',
        department: 'Cardiology',
        status: AppointmentStatus.waiting,
        tokenNumber: '#01',
        isNextUpcoming: true,
        reasonForVisit: 'Post-ECG chest tightness, shortness of breath on exertion',
        clinicalAlert: 'High BP (142/90 mmHg) • Penicillin Allergy',
        checkedInTime: '08:52 AM',
        waitingDuration: '16 min',
        consultationMode: 'In-Person OPD',
        previousVisitDate: 'Sep 21',
        date: today,
      ),
      DoctorAppointmentModel(
        id: 'APT-102',
        patient: patientPriya,
        appointmentTime: '09:30 AM',
        appointmentType: 'New Patient',
        department: 'General Medicine',
        status: AppointmentStatus.checkedIn,
        tokenNumber: '#02',
        reasonForVisit: 'Lipid Panel Review & Routine Checkup',
        checkedInTime: '09:18 AM',
        waitingDuration: '12 min',
        consultationMode: 'In-Person OPD',
        previousVisitDate: 'First Visit',
        date: today,
      ),
      DoctorAppointmentModel(
        id: 'APT-103',
        patient: patientAmit,
        appointmentTime: '10:00 AM',
        appointmentType: 'Follow-up',
        department: 'Cardiology',
        status: AppointmentStatus.completed,
        tokenNumber: '#03',
        reasonForVisit: 'Post-treatment stent review & ECG analysis',
        checkedInTime: '09:50 AM',
        waitingDuration: '10 min',
        consultationMode: 'In-Person OPD',
        previousVisitDate: 'Sep 15',
        date: today,
      ),
      DoctorAppointmentModel(
        id: 'APT-104',
        patient: patientNeha,
        appointmentTime: '10:30 AM',
        appointmentType: 'Teleconsultation',
        department: 'Cardiology',
        status: AppointmentStatus.upcoming,
        tokenNumber: '#04',
        reasonForVisit: 'Holter Monitor Results Review via Video Call',
        consultationMode: 'Teleconsultation',
        previousVisitDate: 'Aug 28',
        date: today,
      ),
      DoctorAppointmentModel(
        id: 'APT-105',
        patient: patientArjun,
        appointmentTime: '11:00 AM',
        appointmentType: 'Consultation',
        department: 'Nephrology',
        status: AppointmentStatus.upcoming,
        tokenNumber: '#05',
        reasonForVisit: 'Electrolyte & Kidney Function Lab Review',
        consultationMode: 'In-Person OPD',
        previousVisitDate: 'Sep 25',
        date: today,
      ),
      DoctorAppointmentModel(
        id: 'APT-106',
        patient: patientSneha,
        appointmentTime: '04:00 PM',
        appointmentType: 'New Patient',
        department: 'Dermatology',
        status: AppointmentStatus.upcoming,
        tokenNumber: '#06',
        reasonForVisit: 'Skin Allergy & Eczema Consultation',
        consultationMode: 'In-Person OPD',
        previousVisitDate: 'First Visit',
        date: today,
      ),
    ];
  }

  static List<PatientQueueItemModel> getPatientQueue() {
    return [
      const PatientQueueItemModel(
        position: '#01',
        patient: patientRahul,
        appointmentTime: '09:00 AM',
        waitingTime: '16 min',
        status: AppointmentStatus.waiting,
      ),
      const PatientQueueItemModel(
        position: '#02',
        patient: patientPriya,
        appointmentTime: '09:30 AM',
        waitingTime: '12 min',
        status: AppointmentStatus.checkedIn,
      ),
      const PatientQueueItemModel(
        position: '#03',
        patient: patientNeha,
        appointmentTime: '10:30 AM',
        waitingTime: 'Arrived Online',
        status: AppointmentStatus.upcoming,
      ),
      const PatientQueueItemModel(
        position: '#04',
        patient: patientArjun,
        appointmentTime: '11:00 AM',
        waitingTime: 'Scheduled',
        status: AppointmentStatus.upcoming,
      ),
    ];
  }

  static List<DoctorEmergencyCaseModel> getEmergencyCases() {
    return [
      const DoctorEmergencyCaseModel(
        id: 'EMG-401',
        patient: patientAmit,
        severity: EmergencySeverity.critical,
        arrivalTime: '10:42 AM',
        assignedBed: 'ER Bed 03 (Trauma Bay)',
        department: 'Emergency & Critical Care',
        assignedDoctor: 'Dr. Sarah Jenkins',
        currentStatus: 'Under Treatment • Troponin-I High',
      ),
      const DoctorEmergencyCaseModel(
        id: 'EMG-402',
        patient: patientArjun,
        severity: EmergencySeverity.high,
        arrivalTime: '08:15 AM',
        assignedBed: 'ICU Bed 05',
        department: 'ICU / Cardiac Care',
        assignedDoctor: 'Dr. Sarah Jenkins',
        currentStatus: 'Stable • Continuous ECG Monitoring',
      ),
    ];
  }

  static List<PendingReportModel> getPendingReports() {
    return [
      const PendingReportModel(
        id: 'REP-701',
        patient: patientRahul,
        reportType: 'CBC & Troponin-I Test',
        date: 'Today, 08:30 AM',
        priority: ReportPriority.urgent,
        labValues: {
          'Troponin-I': '0.14 ng/mL (Elevated)',
          'WBC Count': '11,200 /uL',
          'Hemoglobin': '14.2 g/dL',
          'Platelets': '245,000 /uL',
        },
      ),
      const PendingReportModel(
        id: 'REP-702',
        patient: patientPriya,
        reportType: 'Lipid Profile & Thyroid Panel',
        date: 'Yesterday, 04:20 PM',
        priority: ReportPriority.normal,
        labValues: {
          'Serum Cholesterol': '210 mg/dL',
          'LDL Cholesterol': '138 mg/dL',
          'HDL Cholesterol': '48 mg/dL',
          'TSH': '3.8 mIU/L',
        },
      ),
      const PendingReportModel(
        id: 'REP-703',
        patient: patientAmit,
        reportType: '12-Lead ECG & Echo',
        date: 'Today, 10:50 AM',
        priority: ReportPriority.urgent,
        labValues: {
          'Ejection Fraction': '52%',
          'ST Segment': 'T-Wave Inversion V2-V4',
          'Rhythm': 'Sinus Rhythm 88 bpm',
        },
      ),
    ];
  }

  static AIPatientSummaryModel getAISummary() {
    return const AIPatientSummaryModel(
      patient: patientRahul,
      previousVisitsCount: 4,
      recentLabReportsCount: 2,
      currentMedications: [
        'Atorvastatin 20mg (OD)',
        'Metoprolol 50mg (BD)',
        'Metformin 500mg (BD)',
      ],
      lastConsultationText: '5 days ago by Dr. Sarah Jenkins',
      recentReportAttention: 'CBC & Troponin-I (Mild Elevation)',
      keyFindings:
          'Patient exhibits mild exertional chest tightness. ECG shows non-specific ST changes. Troponin-I slightly elevated at 0.14 ng/mL. Blood pressure remains controlled at 142/90 mmHg.',
    );
  }

  static List<DoctorNotificationModel> getNotifications() {
    return [
      const DoctorNotificationModel(
        id: 'NOT-1',
        title: 'Patient Checked In',
        message: 'Rahul Sharma (#01) checked in for 09:00 AM appointment (Waited 16 min).',
        time: '5 mins ago',
        icon: Icons.how_to_reg_rounded,
        iconColor: Color(0xFF0D9488),
        isRead: false,
        category: 'Queue',
      ),
      const DoctorNotificationModel(
        id: 'NOT-2',
        title: 'Emergency Case Assigned',
        message: 'Patient Amit Kumar (ER Bed 03) assigned to you for urgent assessment.',
        time: '12 mins ago',
        icon: Icons.emergency_rounded,
        iconColor: Colors.redAccent,
        isRead: false,
        category: 'Emergency',
      ),
      const DoctorNotificationModel(
        id: 'NOT-3',
        title: 'Follow-up Due Reminder',
        message: 'Rahul Sharma has a follow-up review due today.',
        time: '30 mins ago',
        icon: Icons.health_and_safety_rounded,
        iconColor: Colors.blueAccent,
        isRead: true,
        category: 'Follow-up',
      ),
    ];
  }

  static DoctorAnalyticsModel getAnalytics() {
    return const DoctorAnalyticsModel(
      patientsSeenThisWeek: 48,
      appointmentsCompletedPercent: 92.5,
      followUpRatePercent: 84.0,
      avgConsultationTime: '14.2 mins',
      cancelledPercent: 3.2,
      patientRating: 4.9,
      dailyPatientsSeen: [8, 11, 9, 12, 8, 0, 0],
    );
  }

  static DoctorAvailabilityConfig getAvailabilityConfig() {
    return const DoctorAvailabilityConfig(
      status: DoctorAvailability.available,
      workingHoursStart: '09:00 AM',
      workingHoursEnd: '05:00 PM',
      breakStart: '01:00 PM',
      breakEnd: '02:00 PM',
      slotDurationMinutes: 20,
      nextAvailableSlot: 'Today, 04:30 PM',
    );
  }
}
