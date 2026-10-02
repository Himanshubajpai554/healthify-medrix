import 'package:flutter/material.dart';

enum DoctorStatus { available, inSurgery, busy, offDuty, onLeave }

class DoctorSchedule {
  final String doctorId;
  final String date;
  final List<String> availableSlots;
  final List<String> bookedSlots;
  final String shiftHours;

  const DoctorSchedule({
    required this.doctorId,
    required this.date,
    required this.availableSlots,
    this.bookedSlots = const [],
    this.shiftHours = '09:00 AM - 05:00 PM',
  });
}

class DoctorItem {
  final String id;
  final String name;
  final String department;
  DoctorStatus status;
  int activePatients;
  final String phone;
  final String email;
  final int experienceYears;
  final String shiftHours;

  DoctorItem({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
    required this.activePatients,
    required this.phone,
    required this.email,
    required this.experienceYears,
    required this.shiftHours,
  });

  String get specialty => department;
  DoctorStatus get availabilityStatus => status;

  String get initials {

    final cleaned = name.replaceAll(RegExp(r'^(Dr\.|Prof\.|Mr\.|Mrs\.|Ms\.)\s+'), '');
    final parts = cleaned.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'D';
  }

  Color get avatarGradientStart {
    switch (department.toLowerCase()) {
      case 'cardiology':
        return const Color(0xFF8B5CF6); // Purple
      case 'neurology':
        return const Color(0xFF6366F1); // Indigo
      case 'orthopedics':
        return const Color(0xFF3B82F6); // Blue
      case 'emergency':
        return const Color(0xFFEF4444); // Red
      case 'pediatrics':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  Color get avatarGradientEnd {
    return avatarGradientStart.withValues(alpha: 0.6);
  }
}