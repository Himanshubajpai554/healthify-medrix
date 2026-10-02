import '../models/doctor_dashboard_models.dart';

class DoctorProfileModel {
  final String id;
  final String fullName;
  final String title;
  final String? photoUrl;
  final String phone;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final DoctorAvailability availabilityStatus;

  const DoctorProfileModel({
    required this.id,
    required this.fullName,
    required this.title,
    this.photoUrl,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.availabilityStatus,
  });

  DoctorProfileModel copyWith({
    String? id,
    String? fullName,
    String? title,
    String? photoUrl,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    DoctorAvailability? availabilityStatus,
  }) {
    return DoctorProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }
}

class ProfessionalInfoModel {
  final String doctorId;
  final String specialization;
  final String department;
  final String qualifications;
  final String registrationNumber;
  final String yearsOfExperience;
  final String joiningDate;
  final String languages;
  final String verificationStatus; // Verified, Pending Verification, Verification Required
  final String verifiedBy;
  final String verificationDate;

  const ProfessionalInfoModel({
    required this.doctorId,
    required this.specialization,
    required this.department,
    required this.qualifications,
    required this.registrationNumber,
    required this.yearsOfExperience,
    required this.joiningDate,
    required this.languages,
    required this.verificationStatus,
    required this.verifiedBy,
    required this.verificationDate,
  });

  ProfessionalInfoModel copyWith({
    String? doctorId,
    String? specialization,
    String? department,
    String? qualifications,
    String? registrationNumber,
    String? yearsOfExperience,
    String? joiningDate,
    String? languages,
    String? verificationStatus,
    String? verifiedBy,
    String? verificationDate,
  }) {
    return ProfessionalInfoModel(
      doctorId: doctorId ?? this.doctorId,
      specialization: specialization ?? this.specialization,
      department: department ?? this.department,
      qualifications: qualifications ?? this.qualifications,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      joiningDate: joiningDate ?? this.joiningDate,
      languages: languages ?? this.languages,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verificationDate: verificationDate ?? this.verificationDate,
    );
  }
}

class HospitalAffiliationModel {
  final String hospitalId;
  final String hospitalName;
  final String department;
  final String role;
  final String location;
  final String joiningDate;
  final bool isPrimary;

  const HospitalAffiliationModel({
    required this.hospitalId,
    required this.hospitalName,
    required this.department,
    required this.role,
    required this.location,
    required this.joiningDate,
    this.isPrimary = true,
  });
}

class DayScheduleModel {
  final String dayName;
  final bool isAvailable;
  final List<String> timeSlots;

  const DayScheduleModel({
    required this.dayName,
    required this.isAvailable,
    required this.timeSlots,
  });

  DayScheduleModel copyWith({
    String? dayName,
    bool? isAvailable,
    List<String>? timeSlots,
  }) {
    return DayScheduleModel(
      dayName: dayName ?? this.dayName,
      isAvailable: isAvailable ?? this.isAvailable,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}

class AvailabilityExceptionModel {
  final String id;
  final DateTime date;
  final bool isAvailable;
  final String reason;
  final String? notes;

  const AvailabilityExceptionModel({
    required this.id,
    required this.date,
    required this.isAvailable,
    required this.reason,
    this.notes,
  });
}

class ConsultationSettingsModel {
  final int consultationDurationMinutes;
  final int appointmentBufferMinutes;
  final int maxDailyAppointments;
  final bool acceptNewPatients;
  final bool allowFollowUpAppointments;
  final bool allowEmergencyAssignments;
  final bool allowOnlineConsultations;

  const ConsultationSettingsModel({
    this.consultationDurationMinutes = 30,
    this.appointmentBufferMinutes = 10,
    this.maxDailyAppointments = 20,
    this.acceptNewPatients = true,
    this.allowFollowUpAppointments = true,
    this.allowEmergencyAssignments = true,
    this.allowOnlineConsultations = true,
  });

  ConsultationSettingsModel copyWith({
    int? consultationDurationMinutes,
    int? appointmentBufferMinutes,
    int? maxDailyAppointments,
    bool? acceptNewPatients,
    bool? allowFollowUpAppointments,
    bool? allowEmergencyAssignments,
    bool? allowOnlineConsultations,
  }) {
    return ConsultationSettingsModel(
      consultationDurationMinutes:
          consultationDurationMinutes ?? this.consultationDurationMinutes,
      appointmentBufferMinutes:
          appointmentBufferMinutes ?? this.appointmentBufferMinutes,
      maxDailyAppointments:
          maxDailyAppointments ?? this.maxDailyAppointments,
      acceptNewPatients: acceptNewPatients ?? this.acceptNewPatients,
      allowFollowUpAppointments:
          allowFollowUpAppointments ?? this.allowFollowUpAppointments,
      allowEmergencyAssignments:
          allowEmergencyAssignments ?? this.allowEmergencyAssignments,
      allowOnlineConsultations:
          allowOnlineConsultations ?? this.allowOnlineConsultations,
    );
  }
}

class DoctorPrivacySettingsModel {
  final String profileVisibility; // Hospital Staff, Patients, Public
  final bool showPhoneNumber;
  final bool showEmail;
  final bool showQualifications;
  final bool showConsultationAvailability;

  const DoctorPrivacySettingsModel({
    this.profileVisibility = 'Hospital Staff',
    this.showPhoneNumber = false,
    this.showEmail = true,
    this.showQualifications = true,
    this.showConsultationAvailability = true,
  });

  DoctorPrivacySettingsModel copyWith({
    String? profileVisibility,
    bool? showPhoneNumber,
    bool? showEmail,
    bool? showQualifications,
    bool? showConsultationAvailability,
  }) {
    return DoctorPrivacySettingsModel(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showPhoneNumber: showPhoneNumber ?? this.showPhoneNumber,
      showEmail: showEmail ?? this.showEmail,
      showQualifications: showQualifications ?? this.showQualifications,
      showConsultationAvailability:
          showConsultationAvailability ?? this.showConsultationAvailability,
    );
  }
}

class DoctorSecuritySessionModel {
  final String id;
  final String device;
  final String browser;
  final String locationApprox;
  final DateTime lastActive;
  final bool isCurrent;

  const DoctorSecuritySessionModel({
    required this.id,
    required this.device,
    required this.browser,
    required this.locationApprox,
    required this.lastActive,
    this.isCurrent = false,
  });
}

class DoctorLoginActivityModel {
  final String id;
  final DateTime timestamp;
  final String device;
  final String locationApprox;
  final String ipAddress;
  final bool isSuccessful;

  const DoctorLoginActivityModel({
    required this.id,
    required this.timestamp,
    required this.device,
    required this.locationApprox,
    required this.ipAddress,
    required this.isSuccessful,
  });
}

class DoctorPreferencesModel {
  final String language;
  final String dateFormat;
  final String timeFormat;
  final String timezone;
  final String defaultLandingPage;
  final String theme;

  const DoctorPreferencesModel({
    this.language = 'English',
    this.dateFormat = 'DD/MM/YYYY',
    this.timeFormat = '12-hour',
    this.timezone = 'Asia/Kolkata (GMT+5:30)',
    this.defaultLandingPage = '/doctor-dashboard',
    this.theme = 'Light',
  });

  DoctorPreferencesModel copyWith({
    String? language,
    String? dateFormat,
    String? timeFormat,
    String? timezone,
    String? defaultLandingPage,
    String? theme,
  }) {
    return DoctorPreferencesModel(
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      timezone: timezone ?? this.timezone,
      defaultLandingPage: defaultLandingPage ?? this.defaultLandingPage,
      theme: theme ?? this.theme,
    );
  }
}
