import '../enums/domain_enums.dart';

enum Permission {
  viewDashboard,
  manageHospital,
  viewHospitalProfile,
  manageHospitalProfile,
  viewDepartments,
  manageDepartments,
  viewDoctors,
  manageDoctors,
  manageDoctorAffiliations,
  viewStaff,
  manageStaff,
  manageShiftRoster,
  viewPatients,
  viewPatientDetails,
  admitPatient,
  dischargePatient,
  updatePatient,
  manageAdmissions,
  viewAppointments,
  manageAppointments,
  scheduleAppointment,
  cancelAppointment,
  viewBeds,
  manageBeds,
  assignBeds,
  viewICU,
  manageICU,
  viewBloodBank,
  manageBloodBank,
  manageFacilities,
  viewEmergency,
  manageEmergency,
  triageEmergency,
  viewReports,
  createReport,
  uploadReport,
  uploadReports,
  reviewReport,
  verifyReport,
  verifyReports,
  rejectReport,
  releaseReport,
  releaseReports,
  viewCriticalReports,
  viewPrescriptions,
  viewPrescriptionIndex,
  viewPrescriptionMetadata,
  viewClinicalDetails,
  prescribeMedication,
  viewResources,
  manageResources,
  viewResourceMatrix,
  viewResourceAnalytics,
  createResourceRequest,
  reviewResourceRequest,
  viewAnalytics,
  viewRecommendations,
  reviewRecommendation,
  acceptRecommendation,
  rejectRecommendation,
  viewAIInsights,
  viewForecasts,
  viewAIModels,
  viewPredictionHistory,
  reviewAIInsight,
  acceptAIInsight,
  rejectAIInsight,
  runWhatIfSimulation,
  viewEmergencyRecommendations,
  viewNotifications,
  manageNotifications,
  viewCriticalAlerts,
  acknowledgeAlert,
  resolveAlert,
  viewDispatch,
  manageNotificationPreferences,
  manageRoutingRules,
  viewAuditLogs,
  manageSecurity,
  manageRoles,
  managePermissions,
  manageSystemSettings,
}

class PermissionService {
  static const Map<UserRole, Set<Permission>> _rolePermissions = {
    UserRole.superAdmin: {
      Permission.viewDashboard,
      Permission.manageHospital,
      Permission.viewPatients,
      Permission.admitPatient,
      Permission.dischargePatient,
      Permission.updatePatient,
      Permission.viewDoctors,
      Permission.manageDoctors,
      Permission.viewStaff,
      Permission.manageStaff,
      Permission.scheduleAppointment,
      Permission.cancelAppointment,
      Permission.manageBeds,
      Permission.manageBloodBank,
      Permission.manageFacilities,
      Permission.manageEmergency,
      Permission.viewReports,
      Permission.createReport,
      Permission.uploadReport,
      Permission.reviewReport,
      Permission.verifyReport,
      Permission.rejectReport,
      Permission.releaseReport,
      Permission.viewCriticalReports,
      Permission.viewPrescriptionIndex,
      Permission.viewPrescriptionMetadata,
      Permission.viewClinicalDetails,
      Permission.prescribeMedication,
      Permission.viewAuditLogs,
      Permission.manageSystemSettings,
    },
    UserRole.hospitalAdmin: {
      Permission.viewDashboard,
      Permission.manageHospital,
      Permission.viewPatients,
      Permission.admitPatient,
      Permission.dischargePatient,
      Permission.updatePatient,
      Permission.viewDoctors,
      Permission.manageDoctors,
      Permission.viewStaff,
      Permission.manageStaff,
      Permission.scheduleAppointment,
      Permission.cancelAppointment,
      Permission.manageBeds,
      Permission.manageBloodBank,
      Permission.manageFacilities,
      Permission.manageEmergency,
      Permission.viewReports,
      Permission.uploadReport,
      Permission.viewCriticalReports,
      Permission.viewPrescriptionIndex,
      Permission.viewPrescriptionMetadata,
      Permission.viewResourceMatrix,
      Permission.viewResourceAnalytics,
      Permission.createResourceRequest,
      Permission.reviewResourceRequest,
      Permission.viewRecommendations,
      Permission.reviewRecommendation,
      Permission.acceptRecommendation,
      Permission.rejectRecommendation,
      Permission.viewAIInsights,
      Permission.viewForecasts,
      Permission.viewAIModels,
      Permission.viewPredictionHistory,
      Permission.reviewAIInsight,
      Permission.acceptAIInsight,
      Permission.rejectAIInsight,
      Permission.runWhatIfSimulation,
      Permission.viewAuditLogs,
    },
    UserRole.doctor: {
      Permission.viewDashboard,
      Permission.viewPatients,
      Permission.updatePatient,
      Permission.viewDoctors,
      Permission.scheduleAppointment,
      Permission.cancelAppointment,
      Permission.manageBeds,
      Permission.manageEmergency,
      Permission.viewReports,
      Permission.createReport,
      Permission.uploadReport,
      Permission.reviewReport,
      Permission.verifyReport,
      Permission.rejectReport,
      Permission.releaseReport,
      Permission.viewCriticalReports,
      Permission.viewPrescriptionIndex,
      Permission.viewPrescriptionMetadata,
      Permission.viewClinicalDetails,
      Permission.prescribeMedication,
    },
    UserRole.nurse: {
      Permission.viewDashboard,
      Permission.viewPatients,
      Permission.admitPatient,
      Permission.dischargePatient,
      Permission.updatePatient,
      Permission.manageBeds,
      Permission.manageEmergency,
      Permission.viewReports,
      Permission.createReport,
      Permission.uploadReport,
      Permission.viewCriticalReports,
      Permission.viewPrescriptionIndex,
      Permission.viewPrescriptionMetadata,
    },
    UserRole.receptionist: {
      Permission.viewDashboard,
      Permission.viewPatients,
      Permission.admitPatient,
      Permission.viewDoctors,
      Permission.scheduleAppointment,
      Permission.cancelAppointment,
    },
    UserRole.labTechnician: {
      Permission.viewDashboard,
      Permission.viewPatients,
      Permission.viewReports,
      Permission.createReport,
      Permission.uploadReport,
      Permission.reviewReport,
      Permission.viewCriticalReports,
    },
    UserRole.pharmacist: {
      Permission.viewDashboard,
      Permission.viewPatients,
      Permission.viewReports,
      Permission.viewPrescriptionIndex,
      Permission.viewPrescriptionMetadata,
    },
    UserRole.patient: {
      Permission.viewDashboard,
      Permission.viewDoctors,
      Permission.scheduleAppointment,
      Permission.cancelAppointment,
      Permission.viewReports,
    },
  };

  /// Check if a user role has a specific permission.
  static bool hasPermission(UserRole role, Permission permission) {
    if (role == UserRole.superAdmin || role == UserRole.hospitalOwner) return true;
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Check if a user role has any of the listed permissions.
  static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
    return permissions.any((p) => hasPermission(role, p));
  }

  /// Check if a user role has all of the listed permissions.
  static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Check module view permission.
  static bool canView(UserRole role, String module) {
    if (role == UserRole.superAdmin || role == UserRole.hospitalOwner) return true;
    switch (module.toLowerCase()) {
      case 'hospital':
      case 'profile':
        return hasPermission(role, Permission.viewHospitalProfile) || hasPermission(role, Permission.manageHospital);
      case 'patients':
        return hasPermission(role, Permission.viewPatients);
      case 'doctors':
        return hasPermission(role, Permission.viewDoctors);
      case 'staff':
        return hasPermission(role, Permission.viewStaff);
      case 'beds':
      case 'icu':
        return hasPermission(role, Permission.viewBeds) || hasPermission(role, Permission.manageBeds);
      case 'blood':
        return hasPermission(role, Permission.viewBloodBank) || hasPermission(role, Permission.manageBloodBank);
      case 'emergency':
        return hasPermission(role, Permission.viewEmergency) || hasPermission(role, Permission.manageEmergency);
      case 'reports':
        return hasPermission(role, Permission.viewReports);
      case 'analytics':
        return hasPermission(role, Permission.viewAnalytics) || hasPermission(role, Permission.viewResourceAnalytics);
      case 'ai':
        return hasPermission(role, Permission.viewAIInsights);
      case 'notifications':
        return hasPermission(role, Permission.viewNotifications);
      case 'security':
      case 'audit':
        return hasPermission(role, Permission.viewAuditLogs) || hasPermission(role, Permission.manageSecurity);
      default:
        return true;
    }
  }

  static bool canCreate(UserRole role, String module) {
    if (role == UserRole.superAdmin || role == UserRole.hospitalOwner) return true;
    return hasPermission(role, Permission.manageHospital) || hasPermission(role, Permission.admitPatient);
  }

  static bool canUpdate(UserRole role, String module) {
    if (role == UserRole.superAdmin || role == UserRole.hospitalOwner) return true;
    return hasPermission(role, Permission.updatePatient) || hasPermission(role, Permission.manageBeds);
  }

  static bool canDelete(UserRole role, String module) {
    return role == UserRole.superAdmin || role == UserRole.hospitalOwner || role == UserRole.hospitalAdmin;
  }

  /// Get all permissions for a role.
  static Set<Permission> getPermissionsForRole(UserRole role) {
    if (role == UserRole.superAdmin || role == UserRole.hospitalOwner) {
      return Permission.values.toSet();
    }
    return _rolePermissions[role] ?? {};
  }
}
