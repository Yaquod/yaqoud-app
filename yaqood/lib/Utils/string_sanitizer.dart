import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yaqood/Services/location_service.dart';

class StreetSanitizer {
  static const String _fallbackPickup = 'Current Location';
  static const String _fallbackDestination = 'Unknown Street';
  static const String _nearPrefix = 'Near ';
  static const List<String> _exactFallbacks = [
    _fallbackPickup,
    _fallbackDestination,
  ];
  static const double _currentLocationThreshold = 5.0;
  static const double _landmarkRadius = 50.0;

  static String _extractStreetName(List<Placemark> placemarks) {
    if (placemarks.isEmpty) return '';
    final p = placemarks[0];
    for (final field in [
      p.thoroughfare,
      p.subLocality,
      p.locality,
      p.name,
    ]) {
      if (field != null && field.isNotEmpty) return field;
    }
    return '';
  }

  static Future<String> resolvePickupName({
    required String? rawName,
    required LatLng pickupLatLng,
    LocationService? locationService,
    LatLng? userLatLng,
  }) async {
    if (rawName != null &&
        rawName.isNotEmpty &&
        rawName.toLowerCase() != 'null') {
      return rawName;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        pickupLatLng.latitude,
        pickupLatLng.longitude,
      );
      final geocoded = _extractStreetName(placemarks);
      if (geocoded.isNotEmpty) return geocoded;
    } catch (_) {}

    if (userLatLng != null) {
      final dist = Geolocator.distanceBetween(
        userLatLng.latitude,
        userLatLng.longitude,
        pickupLatLng.latitude,
        pickupLatLng.longitude,
      );
      if (dist <= _currentLocationThreshold) {
        return _fallbackPickup;
      }
    }

    final svc = locationService ?? LocationService();
    final landmark = await svc.getNearbyLandmark(
      pickupLatLng,
      radius: _landmarkRadius.round(),
    );
    if (landmark != null && landmark.isNotEmpty) {
      return '$_nearPrefix$landmark';
    }

    return _fallbackDestination;
  }

  static Future<String> resolveDestinationName({
    required String? rawName,
    required LatLng destinationLatLng,
    LocationService? locationService,
  }) async {
    if (rawName != null &&
        rawName.isNotEmpty &&
        rawName.toLowerCase() != 'null') {
      return rawName;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        destinationLatLng.latitude,
        destinationLatLng.longitude,
      );
      final geocoded = _extractStreetName(placemarks);
      if (geocoded.isNotEmpty) return geocoded;
    } catch (_) {}

    final svc = locationService ?? LocationService();
    final landmark = await svc.getNearbyLandmark(
      destinationLatLng,
      radius: _landmarkRadius.round(),
    );
    if (landmark != null && landmark.isNotEmpty) {
      return '$_nearPrefix$landmark';
    }

    return _fallbackDestination;
  }

  static bool isFallback(String value) {
    if (_exactFallbacks.contains(value)) return true;
    if (value.startsWith(_nearPrefix)) return true;
    return false;
  }

  static bool isNearLandmark(String value) {
    return value.startsWith(_nearPrefix);
  }
}
