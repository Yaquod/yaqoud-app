import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  static LatLngBounds computeBounds(List<LatLng> polylineCoordinates) {
    double minLat = polylineCoordinates
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = polylineCoordinates
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = polylineCoordinates
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = polylineCoordinates
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static void animateToRoute(
    GoogleMapController? controller,
    List<LatLng> coordinates,
  ) {
    if (coordinates.isEmpty || controller == null) return;

    final bounds = computeBounds(coordinates);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}
