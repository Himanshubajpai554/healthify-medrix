import 'dart:async';
import '../../models/location_model.dart';
import '../repositories/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  GeoLocation _currentLocation = GeoLocation.defaultDemo();
  final _locationController = StreamController<GeoLocation>.broadcast();

  @override
  Future<GeoLocation> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _currentLocation;
  }

  @override
  Future<GeoLocation?> getLastKnownLocation() async {
    return _currentLocation;
  }

  @override
  Future<void> setDemoLocation(GeoLocation location) async {
    _currentLocation = location;
    _locationController.add(_currentLocation);
  }

  @override
  Future<void> clearLocation() async {
    _currentLocation = GeoLocation.defaultDemo();
    _locationController.add(_currentLocation);
  }

  @override
  Stream<GeoLocation> watchLocation() {
    return _locationController.stream;
  }
}
