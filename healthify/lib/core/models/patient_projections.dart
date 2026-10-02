import 'doctor_model.dart';
import 'hospital_model.dart';

/// Patient-Safe Hospital Summary Projection
/// Excludes internal staff rosters, private security events, and raw audit logs.
class PatientHospitalSummary {
  final String hospitalId;
  final String name;
  final String address;
  final double rating;
  final String phone;
  final String emergencyHelpline;
  final bool has247Emergency;
  final int availableBedsCount;
  final int availableICUCount;
  final bool bloodAvailable;
  final List<String> topFacilities;
  final DateTime lastUpdated;

  const PatientHospitalSummary({
    required this.hospitalId,
    required this.name,
    required this.address,
    required this.rating,
    required this.phone,
    required this.emergencyHelpline,
    required this.has247Emergency,
    required this.availableBedsCount,
    required this.availableICUCount,
    required this.bloodAvailable,
    required this.topFacilities,
    required this.lastUpdated,
  });

  factory PatientHospitalSummary.fromHospital(Hospital hospital, {
    int availableBeds = 42,
    int availableICU = 6,
    bool bloodAvailable = true,
  }) {
    return PatientHospitalSummary(
      hospitalId: hospital.id,
      name: hospital.name,
      address: hospital.address,
      rating: hospital.rating,
      phone: hospital.contactNumber,
      emergencyHelpline: hospital.contactNumber,
      has247Emergency: true,
      availableBedsCount: availableBeds,
      availableICUCount: availableICU,
      bloodAvailable: bloodAvailable,
      topFacilities: const ['Level-1 ER', 'ICU', 'Central Blood Bank', 'Radiology'],
      lastUpdated: hospital.updatedAt,
    );
  }
}

/// Patient-Safe Doctor Summary Projection
class PatientDoctorSummary {
  final String doctorId;
  final String name;
  final String specialty;
  final String qualification;
  final double rating;
  final int experienceYears;
  final String primaryHospitalName;
  final List<String> availableSlots;

  const PatientDoctorSummary({
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.rating,
    required this.experienceYears,
    required this.primaryHospitalName,
    required this.availableSlots,
  });

  factory PatientDoctorSummary.fromDoctor(Doctor doctor, {
    String hospitalName = 'St. Jude Memorial Hospital',
    List<String> slots = const ['Today 10:30 AM', 'Today 02:15 PM'],
  }) {
    return PatientDoctorSummary(
      doctorId: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      qualification: doctor.qualification,
      rating: doctor.rating,
      experienceYears: doctor.experienceYears,
      primaryHospitalName: hospitalName,
      availableSlots: slots,
    );
  }
}
