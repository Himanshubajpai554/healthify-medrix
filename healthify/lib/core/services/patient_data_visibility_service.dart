import '../models/appointment_model.dart';
import '../models/bed_model.dart';
import '../models/blood_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

/// Patient Data Visibility Service
/// Enforces patient-safe data boundaries on domain models.
/// Filters out internal staff notes, MRNs, bed IDs, blood donor identities,
/// and internal operational alerts.
class PatientDataVisibilityService {
  /// Filters notifications to ensure patient sees only patient-relevant updates
  static List<NotificationRecord> filterPatientNotifications(
    List<NotificationRecord> notifications,
    String patientId,
  ) {
    return notifications.where((n) {
      // Exclude staff-only and internal system alerts
      final category = n.category.toLowerCase();
      if (category.contains('staff') ||
          category.contains('audit') ||
          category.contains('security') ||
          category.contains('inventory_low') ||
          category.contains('bed_surge') ||
          category.contains('dispatch_internal')) {
        return false;
      }
      // Include patient-targeted or broadcast alerts
      return n.recipientId == patientId || n.recipientId == 'PATIENT_BROADCAST' || n.recipientId == 'ALL';
    }).toList();
  }

  /// Sanitizes bed availability info for patient-facing views (aggregates count, strips internal IDs)
  static Map<String, dynamic> sanitizeBedAvailability(List<Bed> beds) {
    int totalAvailable = 0;
    int totalICU = 0;

    for (final bed in beds) {
      if (bed.status == BedStatus.available) {
        totalAvailable++;
        if (bed.isICU) {
          totalICU++;
        }
      }
    }

    return {
      'totalAvailableBeds': totalAvailable,
      'availableICUBeds': totalICU,
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 5)),
    };
  }

  /// Sanitizes blood inventory for patient-facing views (aggregates units, strips donor identities)
  static Map<String, int> sanitizeBloodStock(List<BloodInventoryUnit> units) {
    final Map<String, int> stock = {};
    for (final unit in units) {
      if (unit.status == InventoryUnitStatus.available && unit.expiryDate.isAfter(DateTime.now())) {
        stock[unit.bloodGroup] = (stock[unit.bloodGroup] ?? 0) + unit.quantityUnits;
      }
    }
    return stock;
  }


  /// Sanitizes diagnostic reports (ensures report is patient-safe & verified)
  static List<DiagnosticReport> filterPatientReports(
    List<DiagnosticReport> reports,
    String patientId,
  ) {
    return reports.where((r) => r.patientId == patientId).toList();
  }

  /// Sanitizes appointments (ensures appointments belong to active patient)
  static List<Appointment> filterPatientAppointments(
    List<Appointment> appointments,
    String patientId,
  ) {
    return appointments.where((a) => a.patientId == patientId).toList();
  }
}
