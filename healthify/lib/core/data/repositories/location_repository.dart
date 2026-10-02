import '../../models/location_model.dart';

abstract class LocationRepository {
  Future<GeoLocation> getCurrentLocation();
  Future<GeoLocation?> getLastKnownLocation();
  Future<void> setDemoLocation(GeoLocation location);
  Future<void> clearLocation();
  Stream<GeoLocation> watchLocation();
}
