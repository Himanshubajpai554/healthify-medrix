import '../models/patient_portal_models.dart';

class BloodDiscoveryService {
  static final List<BloodBankData> _bloodBanks = [
    BloodBankData(
      id: 'bb-101',
      name: 'City Care Hospital Blood Bank',
      type: 'Multi-Specialty Hospital',
      rating: 4.8,
      reviewCount: 342,
      distance: '3.2 km',
      distanceKm: 3.2,
      travelTime: '~9 min',
      address: '742 Healthcare Ave, Central District',
      phone: '+91 98765 10001',
      is24x7: true,
      acceptsDonations: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
      stocks: [
        BloodGroupStockDetail(
          bloodGroup: 'O+',
          unitsAvailable: 14,
          status: 'Available',
          componentUnits: {'Whole Blood': 5, 'PRBC': 6, 'Platelets': 2, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'O-',
          unitsAvailable: 4,
          status: 'Limited',
          componentUnits: {'Whole Blood': 1, 'PRBC': 2, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A+',
          unitsAvailable: 18,
          status: 'Available',
          componentUnits: {'Whole Blood': 6, 'PRBC': 8, 'Platelets': 3, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A-',
          unitsAvailable: 2,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 0, 'PRBC': 2, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B+',
          unitsAvailable: 12,
          status: 'Available',
          componentUnits: {'Whole Blood': 4, 'PRBC': 5, 'Platelets': 2, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B-',
          unitsAvailable: 0,
          status: 'Unavailable',
          componentUnits: {'Whole Blood': 0, 'PRBC': 0, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB+',
          unitsAvailable: 8,
          status: 'Available',
          componentUnits: {'Whole Blood': 2, 'PRBC': 4, 'Platelets': 1, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB-',
          unitsAvailable: 1,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 0, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ],
    ),
    BloodBankData(
      id: 'bb-102',
      name: 'Metro Red Cross Blood Center',
      type: 'Standalone Blood Bank',
      rating: 4.9,
      reviewCount: 520,
      distance: '4.5 km',
      distanceKm: 4.5,
      travelTime: '~12 min',
      address: '108 Relief Road, Near Rotary Club',
      phone: '+91 98765 20002',
      is24x7: true,
      acceptsDonations: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
      stocks: [
        BloodGroupStockDetail(
          bloodGroup: 'O+',
          unitsAvailable: 22,
          status: 'Available',
          componentUnits: {'Whole Blood': 8, 'PRBC': 10, 'Platelets': 3, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'O-',
          unitsAvailable: 6,
          status: 'Available',
          componentUnits: {'Whole Blood': 2, 'PRBC': 3, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A+',
          unitsAvailable: 15,
          status: 'Available',
          componentUnits: {'Whole Blood': 5, 'PRBC': 7, 'Platelets': 2, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A-',
          unitsAvailable: 3,
          status: 'Limited',
          componentUnits: {'Whole Blood': 1, 'PRBC': 2, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B+',
          unitsAvailable: 20,
          status: 'Available',
          componentUnits: {'Whole Blood': 7, 'PRBC': 9, 'Platelets': 3, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B-',
          unitsAvailable: 2,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 1, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB+',
          unitsAvailable: 10,
          status: 'Available',
          componentUnits: {'Whole Blood': 3, 'PRBC': 5, 'Platelets': 1, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB-',
          unitsAvailable: 3,
          status: 'Limited',
          componentUnits: {'Whole Blood': 1, 'PRBC': 2, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
    BloodBankData(
      id: 'bb-103',
      name: 'Apex Superspecialty Blood Bank',
      type: 'Multi-Specialty Hospital',
      rating: 4.6,
      reviewCount: 189,
      distance: '6.8 km',
      distanceKm: 6.8,
      travelTime: '~18 min',
      address: '45 Tech Park Way, Westside',
      phone: '+91 98765 30003',
      is24x7: true,
      acceptsDonations: false,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)), // Stale example (> 60 min)
      stocks: [
        BloodGroupStockDetail(
          bloodGroup: 'O+',
          unitsAvailable: 8,
          status: 'Limited',
          componentUnits: {'Whole Blood': 3, 'PRBC': 4, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'O-',
          unitsAvailable: 1,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 0, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A+',
          unitsAvailable: 10,
          status: 'Available',
          componentUnits: {'Whole Blood': 4, 'PRBC': 5, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A-',
          unitsAvailable: 0,
          status: 'Unavailable',
          componentUnits: {'Whole Blood': 0, 'PRBC': 0, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B+',
          unitsAvailable: 7,
          status: 'Limited',
          componentUnits: {'Whole Blood': 2, 'PRBC': 4, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B-',
          unitsAvailable: 1,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 0, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB+',
          unitsAvailable: 5,
          status: 'Limited',
          componentUnits: {'Whole Blood': 2, 'PRBC': 2, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB-',
          unitsAvailable: 0,
          status: 'Unavailable',
          componentUnits: {'Whole Blood': 0, 'PRBC': 0, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 75)),
        ),
      ],
    ),
    BloodBankData(
      id: 'bb-104',
      name: 'St. Jude General Hospital Blood Bank',
      type: 'Multi-Specialty Hospital',
      rating: 4.5,
      reviewCount: 210,
      distance: '8.1 km',
      distanceKm: 8.1,
      travelTime: '~22 min',
      address: '12 Mission Blvd, North Suburbs',
      phone: '+91 98765 40004',
      is24x7: false,
      acceptsDonations: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
      stocks: [
        BloodGroupStockDetail(
          bloodGroup: 'O+',
          unitsAvailable: 16,
          status: 'Available',
          componentUnits: {'Whole Blood': 6, 'PRBC': 7, 'Platelets': 2, 'FFP': 1},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'O-',
          unitsAvailable: 5,
          status: 'Available',
          componentUnits: {'Whole Blood': 2, 'PRBC': 2, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A+',
          unitsAvailable: 12,
          status: 'Available',
          componentUnits: {'Whole Blood': 4, 'PRBC': 6, 'Platelets': 2, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'A-',
          unitsAvailable: 2,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 1, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B+',
          unitsAvailable: 14,
          status: 'Available',
          componentUnits: {'Whole Blood': 5, 'PRBC': 7, 'Platelets': 2, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'B-',
          unitsAvailable: 0,
          status: 'Unavailable',
          componentUnits: {'Whole Blood': 0, 'PRBC': 0, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB+',
          unitsAvailable: 6,
          status: 'Limited',
          componentUnits: {'Whole Blood': 2, 'PRBC': 3, 'Platelets': 1, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        BloodGroupStockDetail(
          bloodGroup: 'AB-',
          unitsAvailable: 2,
          status: 'Critical / Low',
          componentUnits: {'Whole Blood': 1, 'PRBC': 1, 'Platelets': 0, 'FFP': 0},
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
  ];

  static final List<BloodRequestModel> _userRequests = [
    BloodRequestModel(
      id: 'REQ-901',
      patientName: 'Alex Rivera',
      patientId: 'PAT-8842',
      bloodGroup: 'O-',
      unitsNeeded: 2,
      componentType: 'PRBC',
      hospitalName: 'City Care Hospital',
      urgencyLevel: 'Urgent',
      status: 'Matched',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      contactPhone: '+91 98765 43210',
      matchedBankName: 'Metro Red Cross Blood Center',
    ),
  ];

  static final List<DonationCenter> _donationCenters = [
    DonationCenter(
      id: 'don-1',
      name: 'Central Red Cross Blood Donor Station',
      address: '108 Relief Road, Near Rotary Club',
      distance: '4.5 km',
      distanceKm: 4.5,
      operatingHours: '8:00 AM - 8:00 PM (Mon-Sat)',
      phone: '+91 98765 20002',
      openToday: true,
      perks: ['Free Health Checkup', 'Digital Donor Card', 'Healthy Snacks & Juice'],
    ),
    DonationCenter(
      id: 'don-2',
      name: 'City Care Hospital Voluntary Donor Wing',
      address: '742 Healthcare Ave, Ground Floor Block B',
      distance: '3.2 km',
      distanceKm: 3.2,
      operatingHours: '24 Hours Open',
      phone: '+91 98765 10001',
      openToday: true,
      perks: ['Free Hemoglobin Test', 'Recognition Certificate', 'Priority Donor Credit'],
    ),
    DonationCenter(
      id: 'don-3',
      name: 'Lions Youth Voluntary Blood Camp',
      address: 'Community Center Plaza, Sector 4',
      distance: '5.6 km',
      distanceKm: 5.6,
      operatingHours: '9:00 AM - 5:00 PM (Sunday Special)',
      phone: '+91 98765 77777',
      openToday: true,
      perks: ['Community Donor Medal', 'Free Refreshment Pack'],
    ),
  ];

  /// Get list of blood banks based on filters and sorting
  static List<BloodBankData> getBloodBanks({
    required String selectedGroup,
    double maxDistanceKm = 25.0,
    String facilityType = 'All', // 'All', 'Hospital', 'Standalone Blood Bank'
    bool open24x7Only = false,
    bool availableOnly = false,
    String searchQuery = '',
    String sortBy = 'Nearest', // 'Nearest', 'Most Available', 'Recently Updated', 'Highest Rated'
  }) {
    var filtered = _bloodBanks.where((bank) {
      // Distance filter
      if (bank.distanceKm > maxDistanceKm) return false;

      // Facility Type
      if (facilityType == 'Hospital' && !bank.type.contains('Hospital')) return false;
      if (facilityType == 'Standalone Blood Bank' && bank.type.contains('Hospital')) return false;

      // 24x7 filter
      if (open24x7Only && !bank.is24x7) return false;

      // Availability filter
      if (availableOnly) {
        final stock = bank.getStockForGroup(selectedGroup);
        if (stock == null || stock.unitsAvailable == 0) return false;
      }

      // Search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final nameMatch = bank.name.toLowerCase().contains(q);
        final addressMatch = bank.address.toLowerCase().contains(q);
        final typeMatch = bank.type.toLowerCase().contains(q);
        if (!nameMatch && !addressMatch && !typeMatch) return false;
      }

      return true;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      if (sortBy == 'Nearest') {
        return a.distanceKm.compareTo(b.distanceKm);
      } else if (sortBy == 'Most Available') {
        final stockA = a.getStockForGroup(selectedGroup)?.unitsAvailable ?? 0;
        final stockB = b.getStockForGroup(selectedGroup)?.unitsAvailable ?? 0;
        return stockB.compareTo(stockA);
      } else if (sortBy == 'Recently Updated') {
        return b.lastUpdated.compareTo(a.lastUpdated);
      } else if (sortBy == 'Highest Rated') {
        return b.rating.compareTo(a.rating);
      }
      return 0;
    });

    return filtered;
  }

  /// Get current patient blood requests
  static List<BloodRequestModel> getUserRequests() {
    return List.unmodifiable(_userRequests);
  }

  /// Create a new blood request
  static BloodRequestModel createBloodRequest({
    required String patientName,
    required String patientId,
    required String bloodGroup,
    required int unitsNeeded,
    required String componentType,
    required String hospitalName,
    required String urgencyLevel,
    required String contactPhone,
  }) {
    final newReq = BloodRequestModel(
      id: 'REQ-${100 + _userRequests.length + 1}',
      patientName: patientName,
      patientId: patientId,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      componentType: componentType,
      hospitalName: hospitalName,
      urgencyLevel: urgencyLevel,
      status: 'Pending',
      createdAt: DateTime.now(),
      contactPhone: contactPhone,
    );
    _userRequests.insert(0, newReq);
    return newReq;
  }

  /// Get donation centers
  static List<DonationCenter> getDonationCenters() {
    return List.unmodifiable(_donationCenters);
  }

  /// AI Blood availability matcher logic
  static List<Map<String, dynamic>> findBestAIMatches({
    required String bloodGroup,
    required String componentType,
    required int unitsNeeded,
    required String urgencyLevel,
  }) {
    final List<Map<String, dynamic>> matches = [];

    for (var bank in _bloodBanks) {
      final stock = bank.getStockForGroup(bloodGroup);
      if (stock == null) continue;

      int totalUnits = stock.unitsAvailable;
      int componentCount = stock.componentUnits[componentType] ?? 0;

      // Score calculation
      double score = 100.0;
      score -= (bank.distanceKm * 4.0); // Prefer closer
      if (totalUnits >= unitsNeeded) score += 30;
      if (componentCount >= unitsNeeded) score += 20;
      if (bank.is24x7) score += 15;
      if (bank.isStale) score -= 25;

      matches.add({
        'bank': bank,
        'stock': stock,
        'score': score.clamp(10.0, 99.0),
        'totalUnits': totalUnits,
        'componentCount': componentCount,
        'hasFullRequirement': totalUnits >= unitsNeeded,
      });
    }

    matches.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return matches;
  }
}