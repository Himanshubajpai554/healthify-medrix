import '../models/patient_portal_models.dart';
import '../symptom_checker/symptom_checker_service.dart';

class BedDiscoveryService {
  static List<HospitalBedData> getHospitalBedDataList() {
    final hospitals = SymptomCheckerService.getNearbyHospitals();
    final now = DateTime.now();

    return [
      HospitalBedData(
        hospital: hospitals[0], // St. Jude Memorial Hospital (1.2 km)
        estimatedTravelTime: '~5 min',
        lastUpdated: now.subtract(const Duration(minutes: 8)),
        emergencyDoctorAvailable: true,
        ctScanAvailable: true,
        categories: [
          BedCategoryDetail(
            name: 'ICU',
            icon: '❤️',
            available: 3,
            total: 10,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 8)),
            relatedFacilities: ['Ventilator support', 'Level-1 ICU', 'Central Monitoring', 'Cath Lab'],
          ),
          BedCategoryDetail(
            name: 'Emergency',
            icon: '🚨',
            available: 6,
            total: 20,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 5)),
            relatedFacilities: ['24/7 ER & Trauma', 'Ambulance Dock', 'CT Scan 128-Slice', 'Blood Bank Access'],
          ),
          BedCategoryDetail(
            name: 'General',
            icon: '🛏️',
            available: 18,
            total: 60,
            status: 'Limited',
            lastUpdated: now.subtract(const Duration(minutes: 15)),
            relatedFacilities: ['Nursing Station', 'Pharmacy Access', 'Nutritional Care'],
          ),
          BedCategoryDetail(
            name: 'Private',
            icon: '🏥',
            available: 7,
            total: 25,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 10)),
            relatedFacilities: ['Ensuite Bathroom', 'Attendant Bed', 'Private AC'],
          ),
          BedCategoryDetail(
            name: 'Pediatric',
            icon: '👶',
            available: 2,
            total: 8,
            status: 'Limited',
            lastUpdated: now.subtract(const Duration(minutes: 12)),
            relatedFacilities: ['PICU Unit', 'Pediatrician On Call', 'Infant Warmer'],
          ),
          BedCategoryDetail(
            name: 'Maternity',
            icon: '🤰',
            available: 4,
            total: 10,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 20)),
            relatedFacilities: ['Labor Delivery Suite', 'NICU Nursery', 'Obstetrician 24/7'],
          ),
        ],
        timeline: [
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 8)), categoryName: 'ICU', availableCount: 3),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 48)), categoryName: 'ICU', availableCount: 4),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 90)), categoryName: 'ICU', availableCount: 2),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 150)), categoryName: 'ICU', availableCount: 5),
        ],
      ),

      HospitalBedData(
        hospital: hospitals[1], // City Health Heart & General Hospital (3.5 km)
        estimatedTravelTime: '~9 min',
        lastUpdated: now.subtract(const Duration(minutes: 25)),
        emergencyDoctorAvailable: true,
        ctScanAvailable: true,
        categories: [
          BedCategoryDetail(
            name: 'ICU',
            icon: '❤️',
            available: 2,
            total: 20,
            status: 'Limited',
            lastUpdated: now.subtract(const Duration(minutes: 25)),
            relatedFacilities: ['Cardiac Care Unit', 'Central Monitoring'],
          ),
          BedCategoryDetail(
            name: 'Emergency',
            icon: '🚨',
            available: 4,
            total: 15,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 18)),
            relatedFacilities: ['24/7 ER', 'Digital X-Ray'],
          ),
          BedCategoryDetail(
            name: 'General',
            icon: '🛏️',
            available: 12,
            total: 80,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 30)),
            relatedFacilities: ['General Ward Nursing', '24/7 Pharmacy'],
          ),
          BedCategoryDetail(
            name: 'Private',
            icon: '🏥',
            available: 0,
            total: 15,
            status: 'Full',
            lastUpdated: now.subtract(const Duration(minutes: 40)),
            relatedFacilities: ['Private AC Room'],
          ),
          BedCategoryDetail(
            name: 'Pediatric',
            icon: '👶',
            available: 1,
            total: 6,
            status: 'Limited',
            lastUpdated: now.subtract(const Duration(minutes: 35)),
            relatedFacilities: ['Children Ward'],
          ),
          BedCategoryDetail(
            name: 'Maternity',
            icon: '🤰',
            available: 3,
            total: 8,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 22)),
            relatedFacilities: ['Maternity Wing'],
          ),
        ],
        timeline: [
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 25)), categoryName: 'ICU', availableCount: 2),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 75)), categoryName: 'ICU', availableCount: 1),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 120)), categoryName: 'ICU', availableCount: 3),
        ],
      ),

      HospitalBedData(
        hospital: hospitals[2], // Apex Care Multi-Specialty Medical Center (5.8 km)
        estimatedTravelTime: '~14 min',
        lastUpdated: now.subtract(const Duration(minutes: 4)),
        emergencyDoctorAvailable: true,
        ctScanAvailable: true,
        categories: [
          BedCategoryDetail(
            name: 'ICU',
            icon: '❤️',
            available: 8,
            total: 45,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 4)),
            relatedFacilities: ['Neuro ICU', 'Robotic Surgery Unit', 'Helipad', 'Advanced Ventilator'],
          ),
          BedCategoryDetail(
            name: 'Emergency',
            icon: '🚨',
            available: 10,
            total: 30,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 2)),
            relatedFacilities: ['Pediatric ER', 'Trauma Bay 1', 'Blood Bank Station'],
          ),
          BedCategoryDetail(
            name: 'General',
            icon: '🛏️',
            available: 45,
            total: 200,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 10)),
            relatedFacilities: ['Multi-specialty Wards'],
          ),
          BedCategoryDetail(
            name: 'Private',
            icon: '🏥',
            available: 12,
            total: 40,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 6)),
            relatedFacilities: ['Deluxe Suite', 'Attendant Lounge'],
          ),
          BedCategoryDetail(
            name: 'Pediatric',
            icon: '👶',
            available: 5,
            total: 12,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 8)),
            relatedFacilities: ['Pediatric ICU'],
          ),
          BedCategoryDetail(
            name: 'Maternity',
            icon: '🤰',
            available: 6,
            total: 15,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 15)),
            relatedFacilities: ['Advanced Delivery Suite'],
          ),
        ],
        timeline: [
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 4)), categoryName: 'ICU', availableCount: 8),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 30)), categoryName: 'ICU', availableCount: 9),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 60)), categoryName: 'ICU', availableCount: 7),
        ],
      ),

      HospitalBedData(
        hospital: hospitals[3], // Green Valley Community Hospital (8.4 km) - STALE DATA EXAMPLE
        estimatedTravelTime: '~18 min',
        lastUpdated: now.subtract(const Duration(minutes: 135)), // 2h 15m ago -> STALE
        emergencyDoctorAvailable: false,
        ctScanAvailable: false,
        categories: [
          BedCategoryDetail(
            name: 'ICU',
            icon: '❤️',
            available: 0,
            total: 10,
            status: 'Full',
            lastUpdated: now.subtract(const Duration(minutes: 135)),
            relatedFacilities: ['Basic ICU'],
          ),
          BedCategoryDetail(
            name: 'Emergency',
            icon: '🚨',
            available: 1,
            total: 10,
            status: 'Limited',
            lastUpdated: now.subtract(const Duration(minutes: 135)),
            relatedFacilities: ['Basic ER'],
          ),
          BedCategoryDetail(
            name: 'General',
            icon: '🛏️',
            available: 8,
            total: 50,
            status: 'Available',
            lastUpdated: now.subtract(const Duration(minutes: 135)),
            relatedFacilities: ['Community Wards'],
          ),
        ],
        timeline: [
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 135)), categoryName: 'ICU', availableCount: 0),
          BedAvailabilityTimelineEntry(timestamp: now.subtract(const Duration(minutes: 240)), categoryName: 'ICU', availableCount: 1),
        ],
      ),
    ];
  }
}