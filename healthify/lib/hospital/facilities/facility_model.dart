class FacilityModel {
  final String id;
  final String name;
  final String category;
  final String availability; // Available, Limited, Unavailable, Maintenance
  final String capacity;
  final String operatingHours;
  final String location;
  final String description;
  final bool isVisibleToPatients;
  final String lastUpdated;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.category,
    required this.availability,
    required this.capacity,
    required this.operatingHours,
    required this.location,
    required this.description,
    required this.isVisibleToPatients,
    required this.lastUpdated,
  });

  FacilityModel copyWith({
    String? id,
    String? name,
    String? category,
    String? availability,
    String? capacity,
    String? operatingHours,
    String? location,
    String? description,
    bool? isVisibleToPatients,
    String? lastUpdated,
  }) {
    return FacilityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      availability: availability ?? this.availability,
      capacity: capacity ?? this.capacity,
      operatingHours: operatingHours ?? this.operatingHours,
      location: location ?? this.location,
      description: description ?? this.description,
      isVisibleToPatients: isVisibleToPatients ?? this.isVisibleToPatients,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}