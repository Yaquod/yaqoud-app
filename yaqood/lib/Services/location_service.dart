import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const List<String> _landmarkTypes = [
    'university', 'school', 'college',
    'shopping_mall',
    'hospital',
    'place_of_worship', 'mosque', 'church',
    'bank',
    'airport', 'train_station', 'bus_station', 'subway_station',
    'stadium', 'park', 'museum', 'library',
    'city_hall', 'courthouse', 'police', 'fire_station',
    'embassy',
    'hotel', 'lodging',
  ];

  // Location Permission
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {return false;}

    return true;
  }

  // Get Street name from location (with landmark fallback)
  Future<String> getStreetName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final name = placemarks[0].thoroughfare ??
            placemarks[0].subLocality;
        if (name != null &&
            name.isNotEmpty &&
            name.toLowerCase() != 'null') {
          return name;
        }
      }
    } catch (e) {
      print("Geocoding Error: $e");
    }

    final landmark = await getNearbyLandmark(location);
    if (landmark != null && landmark.isNotEmpty) {
      return 'Near $landmark';
    }

    return '';
  }

  // Google Places Nearby Search for prominent landmarks
  Future<String?> getNearbyLandmark(LatLng location, {int radius = 100}) async {
    final apiKey = dotenv.env["GOOGLE_MAPS_API_KEY"];
    if (apiKey == null || apiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=$radius'
      '&type=establishment'
      '&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['status'] == 'OK') {
        final results = data['results'] as List?;
        if (results == null || results.isEmpty) return null;

        for (final place in results) {
          final types = (place['types'] as List?)?.cast<String>() ?? [];
          final hasLandmarkType = types.any(
            (t) => _landmarkTypes.contains(t),
          );
          if (hasLandmarkType) {
            return place['name'] as String?;
          }
        }
      }
    } catch (e) {
      print("Nearby Search Error: $e");
    }

    return null;
  }

  // get position stream
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }
}
