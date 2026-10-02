import 'dart:async';
import '../models/doctor_dashboard_models.dart';
import '../models/doctor_profile_models.dart';

class DoctorProfileService {
  static final DoctorProfileService _instance = DoctorProfileService._internal();

  factory DoctorProfileService() {
    return _instance;
  }

  DoctorProfileService._internal() {
    _initSampleData();
  }

  late DoctorProfileModel _profile;
  late ProfessionalInfoModel _professionalInfo;
  final List<HospitalAffiliationModel> _affiliations = [];
  final List<DayScheduleModel> _weeklySchedule = [];
  final List<AvailabilityExceptionModel> _exceptions = [];
  late ConsultationSettingsModel _consultationSettings;
  late DoctorPrivacySettingsModel _privacySettings;
  late DoctorSecurityModel _securityInfo;
  final List<DoctorSecuritySessionModel> _sessions = [];
  final List<DoctorLoginActivityModel> _loginActivity = [];
  late DoctorPreferencesModel _preferences;

  void _initSampleData() {
    final now = DateTime.now();

    _profile = const DoctorProfileModel(
      id: 'MED-DOC-10482',
      fullName: 'Dr. Arjun Mehta',
      title: 'Senior Consultant Cardiologist',
      photoUrl: null,
      phone: '+91 98765 43210',
      email: 'arjun.mehta@medrix.org',
      dateOfBirth: '14 Aug 1982',
      gender: 'Male',
      address: 'Suite 402, Medrix Hospital Tower, BKC',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      availabilityStatus: DoctorAvailability.available,
    );

    _professionalInfo = const ProfessionalInfoModel(
      doctorId: 'MED-DOC-10482',
      specialization: 'Cardiology',
      department: 'Cardiology & Vascular Medicine',
      qualifications: 'MBBS, MD (Cardiology), FACC (Demo Data)',
      registrationNumber: 'MCI-2008-88392 (Demo)',
      yearsOfExperience: '16 Years',
      joiningDate: '12 Jan 2018',
      languages: 'English, Hindi, Marathi, Gujarati',
      verificationStatus: 'Verified',
      verifiedBy: 'Hospital Administration & Medical Board',
      verificationDate: '04 Oct 2026',
    );

    _affiliations.addAll([
      const HospitalAffiliationModel(
        hospitalId: 'HOSP-MEDRIX-01',
        hospitalName: 'Medrix City Hospital & Research Center',
        department: 'Cardiology & Vascular Medicine',
        role: 'Senior Consultant Doctor',
        location: 'Bandra Kurla Complex, Mumbai',
        joiningDate: '12 Jan 2018',
        isPrimary: true,
      ),
      const HospitalAffiliationModel(
        hospitalId: 'HOSP-MEDRIX-02',
        hospitalName: 'Medrix Super Specialty Heart Institute',
        department: 'Interventional Cardiology',
        role: 'Visiting Specialist Consultant',
        location: 'Andheri West, Mumbai',
        joiningDate: '01 Mar 2021',
        isPrimary: false,
      ),
    ]);

    _weeklySchedule.addAll([
      const DayScheduleModel(
        dayName: 'Monday',
        isAvailable: true,
        timeSlots: ['09:00 AM – 01:00 PM', '04:00 PM – 07:00 PM'],
      ),
      const DayScheduleModel(
        dayName: 'Tuesday',
        isAvailable: true,
        timeSlots: ['09:00 AM – 01:00 PM'],
      ),
      const DayScheduleModel(
        dayName: 'Wednesday',
        isAvailable: false,
        timeSlots: [],
      ),
      const DayScheduleModel(
        dayName: 'Thursday',
        isAvailable: true,
        timeSlots: ['09:00 AM – 01:00 PM', '04:00 PM – 07:00 PM'],
      ),
      const DayScheduleModel(
        dayName: 'Friday',
        isAvailable: true,
        timeSlots: ['09:00 AM – 01:00 PM'],
      ),
      const DayScheduleModel(
        dayName: 'Saturday',
        isAvailable: true,
        timeSlots: ['10:00 AM – 02:00 PM'],
      ),
      const DayScheduleModel(
        dayName: 'Sunday',
        isAvailable: false,
        timeSlots: [],
      ),
    ]);

    _exceptions.add(
      AvailabilityExceptionModel(
        id: 'EXC-101',
        date: DateTime(2026, 10, 4),
        isAvailable: false,
        reason: 'Personal Leave',
        notes: 'Annual cardiology conference attendance in New Delhi.',
      ),
    );

    _consultationSettings = const ConsultationSettingsModel(
      consultationDurationMinutes: 30,
      appointmentBufferMinutes: 10,
      maxDailyAppointments: 20,
      acceptNewPatients: true,
      allowFollowUpAppointments: true,
      allowEmergencyAssignments: true,
      allowOnlineConsultations: true,
    );

    _privacySettings = const DoctorPrivacySettingsModel(
      profileVisibility: 'Hospital Staff',
      showPhoneNumber: false,
      showEmail: true,
      showQualifications: true,
      showConsultationAvailability: true,
    );

    _securityInfo = DoctorSecurityModel(
      lastPasswordChange: '15 Aug 2026',
      lastLogin: 'Today at 08:30 AM',
      is2faEnabled: false,
      supported2faMethods: const ['Authenticator App', 'Email OTP'],
    );

    _sessions.addAll([
      DoctorSecuritySessionModel(
        id: 'SES-991',
        device: 'Windows PC (Workstation)',
        browser: 'Chrome 128.0',
        locationApprox: 'Mumbai, MH, India',
        lastActive: now.subtract(const Duration(minutes: 2)),
        isCurrent: true,
      ),
      DoctorSecuritySessionModel(
        id: 'SES-992',
        device: 'Samsung Galaxy A73 (Mobile App)',
        browser: 'Medrix Doctor App v2.4',
        locationApprox: 'Mumbai, MH, India',
        lastActive: now.subtract(const Duration(hours: 4)),
        isCurrent: false,
      ),
    ]);

    _loginActivity.addAll([
      DoctorLoginActivityModel(
        id: 'LOG-301',
        timestamp: now.subtract(const Duration(minutes: 45)),
        device: 'Windows / Chrome 128',
        locationApprox: 'Mumbai, India',
        ipAddress: '103.22.109.14',
        isSuccessful: true,
      ),
      DoctorLoginActivityModel(
        id: 'LOG-302',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        device: 'Android / Medrix App',
        locationApprox: 'Mumbai, India',
        ipAddress: '49.36.14.88',
        isSuccessful: true,
      ),
      DoctorLoginActivityModel(
        id: 'LOG-303',
        timestamp: now.subtract(const Duration(days: 3)),
        device: 'MacOS / Safari 17.2',
        locationApprox: 'Unknown (VPN)',
        ipAddress: '185.220.101.5',
        isSuccessful: false,
      ),
    ]);

    _preferences = const DoctorPreferencesModel(
      language: 'English',
      dateFormat: 'DD/MM/YYYY',
      timeFormat: '12-hour',
      timezone: 'Asia/Kolkata (GMT+5:30)',
      defaultLandingPage: '/doctor-dashboard',
      theme: 'Light',
    );
  }

  // Getters & Updaters
  DoctorProfileModel getProfile() => _profile;

  Future<void> updatePersonalInformation(DoctorProfileModel updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = updated;
  }

  ProfessionalInfoModel getProfessionalInfo() => _professionalInfo;

  List<HospitalAffiliationModel> getHospitalAffiliations() =>
      List.unmodifiable(_affiliations);

  List<DayScheduleModel> getWeeklySchedule() => List.unmodifiable(_weeklySchedule);

  Future<void> updateWeeklySchedule(List<DayScheduleModel> newSchedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _weeklySchedule.clear();
    _weeklySchedule.addAll(newSchedule);
  }

  List<AvailabilityExceptionModel> getAvailabilityExceptions() =>
      List.unmodifiable(_exceptions);

  Future<void> addAvailabilityException(AvailabilityExceptionModel item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _exceptions.add(item);
  }

  Future<void> removeAvailabilityException(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _exceptions.removeWhere((e) => e.id == id);
  }

  ConsultationSettingsModel getConsultationSettings() => _consultationSettings;

  Future<void> updateConsultationSettings(
      ConsultationSettingsModel updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _consultationSettings = updated;
  }

  DoctorPrivacySettingsModel getPrivacySettings() => _privacySettings;

  Future<void> updatePrivacySettings(DoctorPrivacySettingsModel updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _privacySettings = updated;
  }

  DoctorSecurityModel getSecurityInfo() => _securityInfo;

  List<DoctorSecuritySessionModel> getActiveSessions() =>
      List.unmodifiable(_sessions);

  Future<void> signOutSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  Future<void> signOutAllOtherSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sessions.removeWhere((s) => !s.isCurrent);
  }

  List<DoctorLoginActivityModel> getLoginActivity() =>
      List.unmodifiable(_loginActivity);

  DoctorPreferencesModel getPreferences() => _preferences;

  Future<void> updatePreferences(DoctorPreferencesModel updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _preferences = updated;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (currentPassword == 'wrong') return false;
    _securityInfo = DoctorSecurityModel(
      lastPasswordChange: 'Just now',
      lastLogin: _securityInfo.lastLogin,
      is2faEnabled: _securityInfo.is2faEnabled,
      supported2faMethods: _securityInfo.supported2faMethods,
    );
    return true;
  }
}

class DoctorSecurityModel {
  final String lastPasswordChange;
  final String lastLogin;
  final bool is2faEnabled;
  final List<String> supported2faMethods;

  DoctorSecurityModel({
    required this.lastPasswordChange,
    required this.lastLogin,
    required this.is2faEnabled,
    required this.supported2faMethods,
  });
}
