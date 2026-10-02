import 'package:flutter/material.dart';
import '../../core/enums/domain_enums.dart';

export '../../core/enums/domain_enums.dart' show BedStatus;

class BedItem {
  final String id;
  final String type; // General, ICU, Emergency, Private, Pediatric, NICU
  final String ward;
  final int floor;
  BedStatus status;
  final String? patientId;
  final List<String> equipment;
  final String lastUpdated;
  bool isVisibleToPatientApp;

  BedItem({
    required this.id,
    required this.type,
    required this.ward,
    required this.floor,
    required this.status,
    this.patientId,
    required this.equipment,
    required this.lastUpdated,
    this.isVisibleToPatientApp = true,
  });
}

class WardCapacityItem {
  final String name;
  final int occupied;
  final int total;
  final String status;

  const WardCapacityItem({
    required this.name,
    required this.occupied,
    required this.total,
    required this.status,
  });

  double get percentage => total > 0 ? (occupied / total) * 100 : 0;
}

class LiveActivityItem {
  final String timeAgo;
  final String description;
  final IconData icon;
  final Color iconColor;

  const LiveActivityItem({
    required this.timeAgo,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}