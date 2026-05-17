import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRoutingService {
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
  );

  Future<Map<String, Object>> getRouteData({
    required LatLng start,
    required LatLng destination,
  }) async {
    List<LatLng> coordinates = [];
    Set<Polyline> polylineSet = {};

    RoutesApiRequest request = RoutesApiRequest(
      origin: PointLatLng(start.latitude, start.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
      routingPreference: RoutingPreference.trafficAware,
    );

    try {
      RoutesApiResponse response = await _polylinePoints
          .getRouteBetweenCoordinatesV2(request: request);

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;
        List<PointLatLng> points = route.polylinePoints ?? [];

        coordinates = points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
      }

      if (coordinates.isNotEmpty) {
          polylineSet.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: coordinates,
              width: 5,
              color: Colors.blue,
            ),
          );
        }
    } catch (e) {
      print("MapRoutingService Error: $e");
    }

    return {
      'coordinates': coordinates,
      'polylines': polylineSet,
    };
  }
}
