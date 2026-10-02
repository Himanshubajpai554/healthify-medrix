import 'package:flutter/material.dart';
import '../../core/enums/domain_enums.dart';

export '../../core/enums/domain_enums.dart' show PatientStatus;

class PatientItem {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  String ward;
  final DateTime admissionDate;
  PatientStatus status;
  final String doctorName;
  final Map<String, String> vitals;

  PatientItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.ward,
    required this.admissionDate,
    required this.status,
    required this.doctorName,
    required this.vitals,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'P';
  }

  Color get avatarGradientStart {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }

  Color get avatarGradientEnd {
    return avatarGradientStart.withValues(alpha: 0.6);
  }
}