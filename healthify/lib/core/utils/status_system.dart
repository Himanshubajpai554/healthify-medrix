import 'package:flutter/material.dart';
import '../enums/domain_enums.dart';
import '../models/core_models.dart';

class MedrixStatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const MedrixStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class MedrixStatusSystem {
  // Patient Status Mapping
  static MedrixStatusConfig patientStatus(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return const MedrixStatusConfig(
          label: 'Admitted',
          color: Color(0xFF3B82F6),
          icon: Icons.local_hospital_rounded,
        );
      case PatientStatus.icu:
        return const MedrixStatusConfig(
          label: 'ICU (Critical)',
          color: Color(0xFFEF4444),
          icon: Icons.warning_amber_rounded,
        );
      case PatientStatus.observation:
        return const MedrixStatusConfig(
          label: 'Observation',
          color: Color(0xFFF59E0B),
          icon: Icons.remove_red_eye_rounded,
        );
      case PatientStatus.discharged:
        return const MedrixStatusConfig(
          label: 'Discharged',
          color: Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      default:
        return MedrixStatusConfig(
          label: status.name,
          color: const Color(0xFF6B7280),
          icon: Icons.info_outline,
        );
    }
  }

  // Doctor Status Mapping
  static MedrixStatusConfig doctorStatus(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.available:
        return const MedrixStatusConfig(
          label: 'Available',
          color: Color(0xFF10B981),
          icon: Icons.check_circle_outline_rounded,
        );
      case DoctorStatus.inSurgery:
        return const MedrixStatusConfig(
          label: 'In Surgery',
          color: Color(0xFF8B5CF6),
          icon: Icons.medical_information_rounded,
        );
      case DoctorStatus.busy:
        return const MedrixStatusConfig(
          label: 'Busy',
          color: Color(0xFFF59E0B),
          icon: Icons.access_time_filled_rounded,
        );
      case DoctorStatus.offDuty:
        return const MedrixStatusConfig(
          label: 'Off Duty',
          color: Color(0xFF6B7280),
          icon: Icons.nightlight_round,
        );
      default:
        return MedrixStatusConfig(
          label: status.name,
          color: const Color(0xFF6B7280),
          icon: Icons.info_outline,
        );
    }
  }

  // Bed Status Mapping
  static MedrixStatusConfig bedStatus(BedStatus status) {
    switch (status) {
      case BedStatus.available:
        return const MedrixStatusConfig(
          label: 'Available',
          color: Color(0xFF10B981),
          icon: Icons.king_bed_outlined,
        );
      case BedStatus.occupied:
        return const MedrixStatusConfig(
          label: 'Occupied',
          color: Color(0xFFEF4444),
          icon: Icons.airline_seat_flat_rounded,
        );
      case BedStatus.cleaning:
        return const MedrixStatusConfig(
          label: 'Sanitizing',
          color: Color(0xFF06B6D4),
          icon: Icons.cleaning_services_rounded,
        );
      case BedStatus.reserved:
        return const MedrixStatusConfig(
          label: 'Reserved',
          color: Color(0xFF3B82F6),
          icon: Icons.bookmark_added_rounded,
        );
      case BedStatus.maintenance:
        return const MedrixStatusConfig(
          label: 'Maintenance',
          color: Color(0xFFF59E0B),
          icon: Icons.build_rounded,
        );
    }
  }

  // Appointment Status Mapping
  static MedrixStatusConfig appointmentStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return const MedrixStatusConfig(
          label: 'Scheduled',
          color: Color(0xFF3B82F6),
          icon: Icons.event_rounded,
        );
      case AppointmentStatus.checkedIn:
        return const MedrixStatusConfig(
          label: 'Checked-In',
          color: Color(0xFF06B6D4),
          icon: Icons.how_to_reg_rounded,
        );
      case AppointmentStatus.inConsultation:
      case AppointmentStatus.inProgress:
        return const MedrixStatusConfig(
          label: 'In Consultation',
          color: Color(0xFF8B5CF6),
          icon: Icons.medical_services_rounded,
        );
      case AppointmentStatus.completed:
        return const MedrixStatusConfig(
          label: 'Completed',
          color: Color(0xFF10B981),
          icon: Icons.verified_rounded,
        );
      case AppointmentStatus.cancelled:
        return const MedrixStatusConfig(
          label: 'Cancelled',
          color: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );
      case AppointmentStatus.noShow:
      case AppointmentStatus.missed:
        return const MedrixStatusConfig(
          label: 'No-Show',
          color: Color(0xFF6B7280),
          icon: Icons.person_off_rounded,
        );
    }
  }

  // Blood Unit Status Mapping
  static MedrixStatusConfig bloodStatus(InventoryUnitStatus status) {
    switch (status) {
      case InventoryUnitStatus.available:
        return const MedrixStatusConfig(
          label: 'Available',
          color: Color(0xFF10B981),
          icon: Icons.bloodtype_rounded,
        );
      case InventoryUnitStatus.reserved:
        return const MedrixStatusConfig(
          label: 'Reserved',
          color: Color(0xFF3B82F6),
          icon: Icons.lock_rounded,
        );
      case InventoryUnitStatus.quarantine:
        return const MedrixStatusConfig(
          label: 'Quarantined',
          color: Color(0xFF8B5CF6),
          icon: Icons.shield_rounded,
        );
      case InventoryUnitStatus.expiringSoon:
        return const MedrixStatusConfig(
          label: 'Expiring Soon',
          color: Color(0xFFF59E0B),
          icon: Icons.hourglass_top_rounded,
        );
      case InventoryUnitStatus.expired:
        return const MedrixStatusConfig(
          label: 'Expired',
          color: Color(0xFFEF4444),
          icon: Icons.warning_rounded,
        );
      case InventoryUnitStatus.discarded:
        return const MedrixStatusConfig(
          label: 'Discarded',
          color: Color(0xFF6B7280),
          icon: Icons.delete_rounded,
        );
    }
  }

  // Emergency Case Status Mapping
  static MedrixStatusConfig emergencyStatus(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.triaged:
        return const MedrixStatusConfig(
          label: 'Triaged',
          color: Color(0xFF06B6D4),
          icon: Icons.fact_check_rounded,
        );
      case EmergencyStatus.inTreatment:
        return const MedrixStatusConfig(
          label: 'In Treatment',
          color: Color(0xFFEF4444),
          icon: Icons.medical_services_rounded,
        );
      case EmergencyStatus.transferred:
        return const MedrixStatusConfig(
          label: 'Transferred',
          color: Color(0xFF8B5CF6),
          icon: Icons.transfer_within_a_station_rounded,
        );
      case EmergencyStatus.discharged:
        return const MedrixStatusConfig(
          label: 'Discharged',
          color: Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      default:
        return MedrixStatusConfig(
          label: status.name,
          color: const Color(0xFF6B7280),
          icon: Icons.info_outline,
        );
    }
  }
}
