import '../enums/domain_enums.dart';

class VerificationDocument {
  final String id;
  final String title;
  final String documentType;
  final String fileUrl;
  final DateTime uploadDate;
  final String status;

  const VerificationDocument({
    required this.id,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    required this.uploadDate,
    required this.status,
  });
}

class HospitalProfile {
  final String id;
  final String name;
  final String legalName;
  final String displayName;
  final String hospitalType;
  final String establishmentDate;
  final String registrationLicenseId;
  final String taxId;
  final String accreditationInfo;
  
  final String email;
  final String emergencyHelpline;
  final String receptionPhone;
  final String website;

  final String address;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;

  final int totalBeds;
  final int icuBeds;
  final int operatingTheatres;
  final int emergencyCapacity;

  final bool has247Emergency;
  final String traumaLevel;
  final bool hasAmbulance;
  final String opdTimings;
  final String operatingStatus;

  final VerificationStatus verificationStatus;
  final DateTime? submittedDate;
  final DateTime? verifiedDate;
  final List<VerificationDocument> verificationDocuments;
  final String verificationNotes;

  const HospitalProfile({
    required this.id,
    required this.name,
    required this.legalName,
    required this.displayName,
    required this.hospitalType,
    required this.establishmentDate,
    required this.registrationLicenseId,
    required this.taxId,
    required this.accreditationInfo,
    required this.email,
    required this.emergencyHelpline,
    required this.receptionPhone,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.totalBeds,
    required this.icuBeds,
    required this.operatingTheatres,
    required this.emergencyCapacity,
    required this.has247Emergency,
    required this.traumaLevel,
    required this.hasAmbulance,
    required this.opdTimings,
    required this.operatingStatus,
    required this.verificationStatus,
    this.submittedDate,
    this.verifiedDate,
    this.verificationDocuments = const [],
    required this.verificationNotes,
  });

  HospitalProfile copyWith({
    String? name,
    String? legalName,
    String? displayName,
    String? hospitalType,
    String? establishmentDate,
    String? registrationLicenseId,
    String? taxId,
    String? accreditationInfo,
    String? email,
    String? emergencyHelpline,
    String? receptionPhone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? totalBeds,
    int? icuBeds,
    int? operatingTheatres,
    int? emergencyCapacity,
    bool? has247Emergency,
    String? traumaLevel,
    bool? hasAmbulance,
    String? opdTimings,
    String? operatingStatus,
    VerificationStatus? verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    List<VerificationDocument>? verificationDocuments,
    String? verificationNotes,
  }) {
    return HospitalProfile(
      id: id,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      hospitalType: hospitalType ?? this.hospitalType,
      establishmentDate: establishmentDate ?? this.establishmentDate,
      registrationLicenseId: registrationLicenseId ?? this.registrationLicenseId,
      taxId: taxId ?? this.taxId,
      accreditationInfo: accreditationInfo ?? this.accreditationInfo,
      email: email ?? this.email,
      emergencyHelpline: emergencyHelpline ?? this.emergencyHelpline,
      receptionPhone: receptionPhone ?? this.receptionPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalBeds: totalBeds ?? this.totalBeds,
      icuBeds: icuBeds ?? this.icuBeds,
      operatingTheatres: operatingTheatres ?? this.operatingTheatres,
      emergencyCapacity: emergencyCapacity ?? this.emergencyCapacity,
      has247Emergency: has247Emergency ?? this.has247Emergency,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      hasAmbulance: hasAmbulance ?? this.hasAmbulance,
      opdTimings: opdTimings ?? this.opdTimings,
      operatingStatus: operatingStatus ?? this.operatingStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      submittedDate: submittedDate ?? this.submittedDate,
      verifiedDate: verifiedDate ?? this.verifiedDate,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }
}

class HospitalInfo {
  final String id;
  final String name;
  final String code;
  final String tagline;
  final String address;
  final String phone;
  final String email;
  final String emergencyHotline;
  final int totalBedCapacity;
  final int icuCapacity;
  final int activeDoctorCount;
  final int totalStaffCount;

  const HospitalInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.tagline,
    required this.address,
    required this.phone,
    required this.email,
    required this.emergencyHotline,
    required this.totalBedCapacity,
    required this.icuCapacity,
    required this.activeDoctorCount,
    required this.totalStaffCount,
  });
}

class Hospital {
  final String id;
  final String name;
  final String address;
  final String contactNumber;
  final String email;
  final String type;
  final double rating;
  final int totalBeds;
  final int totalDoctors;
  final int reviewCount;
  final int icuBeds;
  final bool has247Emergency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.email,
    required this.type,
    required this.rating,
    required this.totalBeds,
    required this.totalDoctors,
    this.reviewCount = 0,
    this.icuBeds = 0,
    this.has247Emergency = false,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Department {
  final String id;
  final String hospitalId;
  final String name;
  final String code;
  final String? headDoctorId;
  final int totalStaff;
  final String description;
  final String? location;
  final String? contactPhone;
  final bool isOpdAvailable;
  final bool isEmergencyAvailable;
  final int doctorCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Department({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.code,
    this.headDoctorId,
    required this.totalStaff,
    required this.description,
    this.location,
    this.contactPhone,
    this.isOpdAvailable = true,
    this.isEmergencyAvailable = true,
    this.doctorCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Department copyWith({
    String? name,
    String? code,
    String? headDoctorId,
    int? totalStaff,
    String? description,
    String? location,
    String? contactPhone,
    bool? isOpdAvailable,
    bool? isEmergencyAvailable,
    int? doctorCount,
    bool? isActive,
  }) {
    return Department(
      id: id,
      hospitalId: hospitalId,
      name: name ?? this.name,
      code: code ?? this.code,
      headDoctorId: headDoctorId ?? this.headDoctorId,
      totalStaff: totalStaff ?? this.totalStaff,
      description: description ?? this.description,
      location: location ?? this.location,
      contactPhone: contactPhone ?? this.contactPhone,
      isOpdAvailable: isOpdAvailable ?? this.isOpdAvailable,
      isEmergencyAvailable: isEmergencyAvailable ?? this.isEmergencyAvailable,
      doctorCount: doctorCount ?? this.doctorCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Building {
  final String id;
  final String hospitalId;
  final String name;
  final String code;
  final int totalFloors;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Building({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.code,
    required this.totalFloors,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Floor {
  final String id;
  final String buildingId;
  final int floorNumber;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Floor({
    required this.id,
    required this.buildingId,
    required this.floorNumber,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Ward {
  final String id;
  final String floorId;
  final String departmentId;
  final String name;
  final String wardType;
  final int totalBeds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ward({
    required this.id,
    required this.floorId,
    required this.departmentId,
    required this.name,
    required this.wardType,
    required this.totalBeds,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Room {
  final String id;
  final String wardId;
  final String roomNumber;
  final int capacity;
  final FacilityStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Room({
    required this.id,
    required this.wardId,
    required this.roomNumber,
    required this.capacity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class HospitalRating {
  final String id;
  final String hospitalId;
  final String patientId;
  final double ratingScore;
  final String feedback;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HospitalRating({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    required this.ratingScore,
    required this.feedback,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });
}
