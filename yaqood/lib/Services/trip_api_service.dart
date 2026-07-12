import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TripApiService {
  final String baseUrl =
      dotenv.env["API_BASE_URL"] ?? "http://192.168.100.5:8000/api";

  Future<Map<String, String>?> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    if (token == null) {
      return null;
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>?> requestTrip({
    required LatLng start,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/trips/request");
      final headers = await _getHeaders();

      if (headers == null) {
        return {"error_type": "auth_error"};
      }

      final body = jsonEncode({
        'startLong': start.longitude,
        'startLat': start.latitude,
        'endLong': destination.longitude,
        'endLat': destination.latitude,
      });

      final response = await http.post(url, headers: headers, body: body);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - createTrip Error: $e");
      return {"error_type": "network_error"};
    }
  }

  Future<Map<String, dynamic>?> getRequestStatus(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/status/$tripRequestId');
      final headers = await _getHeaders();

      if (headers == null) {
        return {"error_type": "auth_error"};
      }

      final response = await http.get(url, headers: headers);

      print("-------------------- status");
      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - getTripStatus Error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTripStatus(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/$tripRequestId');
      final headers = await _getHeaders();

      if (headers == null) {
        return {"error_type": "auth_error"};
      }

      final response = await http.get(url, headers: headers);

      print("-------------------- status");
      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - getTripStatus Error: $e");
    }
    return null;
  }

  Future<bool> cancelTripRequest(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/$tripRequestId');
      final headers = await _getHeaders();

      final response = await http.delete(url, headers: headers);

      if (response.body.isEmpty) {
        return response.statusCode == 200;
      }

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result["success"] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error cancelling trip: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> acceptOffer(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/$tripRequestId/accept');
      final headers = await _getHeaders();

      if (headers == null) return {"error_type": "auth_error"};

      final response = await http.post(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - acceptOffer Error: $e");
      return {"error_type": "network_error"};
    }
  }

  Future<Map<String, dynamic>?> declineOffer(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/$tripRequestId/decline');
      final headers = await _getHeaders();

      if (headers == null) return {"error_type": "auth_error"};

      final response = await http.post(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - declineOffer Error: $e");
      return {"error_type": "network_error"};
    }
  }

  Stream<Map<String, dynamic>> streamTripLiveUpdates(
    String tripRequestId,
  ) async* {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final url = Uri.parse("$baseUrl/trips/$tripRequestId/location/stream");

    final request = http.Request("GET", url);
    request.headers['Accept'] = '*/*';
    request.headers['Cache-Control'] = 'no-cache';
    request.headers['Connection'] = 'keep-alive';
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    try {
      final response = await request.send();

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data:')) {
          final dataString = line.substring(5).trim();

          if (dataString.isNotEmpty) {
            try {
              final decoded = jsonDecode(dataString) as Map<String, dynamic>;

              yield decoded;
            } catch (jsonError) {}
          }
        }
      }
    } catch (e) {
      print("SSE Stream Error: $e");
    }
  }

  Future<Map<String, dynamic>?> startTrip(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/$tripRequestId/start');
      final headers = await _getHeaders();

      if (headers == null) return {"error_type": "auth_error"};

      final response = await http.post(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - startTrip Error: $e");
      return {"error_type": "network_error"};
    }
  }

  Future<Map<String, dynamic>?> completeTrip(String tripRequestId) async {
    try {
      final url = Uri.parse('$baseUrl/trips/request/$tripRequestId/end');
      final headers = await _getHeaders();

      if (headers == null) return {"error_type": "auth_error"};

      final response = await http.post(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - completeTrip Error: $e");
      return {"error_type": "network_error"};
    }
  }

  Future<Map<String, dynamic>?> getLastTrips({required int page, required int size}) async {
    try {
      final url = Uri.parse('$baseUrl/trips/last?page=$page&size=$size');
      final headers = await _getHeaders();

      if (headers == null) {
        return {"error_type": "auth_error"};
      }

      final response = await http.get(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      print("TripApiService - getLastTrips Error: $e");
      return {"error_type": "network_error"};
    }
  }
}
