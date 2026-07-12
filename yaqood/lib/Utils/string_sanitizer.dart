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
