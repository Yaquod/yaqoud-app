import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileApiService {
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
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/auth/me');
      final headers = await _getHeaders();

      if (headers == null) return {"error_type": "auth_error"};

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        if (decodedResponse["success"] == true) {
          return decodedResponse["data"]; 
        }
      }
      return null;
    } catch (e) {
      print("ProfileApiService - getUserProfile Error: $e");
      return {"error_type": "network_error"};
    }
  }
}