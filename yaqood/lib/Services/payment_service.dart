import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/saved_card_model.dart';

class PaymentService {
  final String? baseUrl = dotenv.env["API_BASE_URL"];

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<SavedCard>?> getSavedCards() async {
    try {
      final url = Uri.parse("$baseUrl/payments/saved-cards");
      final headers = await _getHeaders();

      final response = await get(url, headers: headers);

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result["success"]) {
        List data = result["data"];
        return data.map((e) => SavedCard.fromJson(e)).toList();
      } else {
        throw result["message"] ?? "Failed to load cards";
      }
    } on SocketException {
      throw "check your internet connection";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> getCheckoutUrl() async {
    try {
      final url = Uri.parse("$baseUrl/payments/cards");
      final headers = await _getHeaders();

      final response = await post(url, headers: headers);

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result["success"]) {
        return result["data"]["checkoutUrl"];
      } else {
        throw result["message"];
      }
    } on SocketException {
      throw "check your internet connection";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> payWithSavedCard({
    required int cardId,
    required double amount,
    required String tripRequestId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/payments/mit");
      final headers = await _getHeaders();
      final body = jsonEncode({
        "amount": amount,
        "savedCardId": cardId,
        "requestId": tripRequestId,
      });

      final response = await post(url, headers: headers, body: body);

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result["success"] == true) {
        return true;
      } else {
        throw result["message"] ?? "Payment processing failed";
      }
    } on SocketException {
      throw "check your internet connection";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> deleteSavedCard(int cardId) async {
    try {
      final url = Uri.parse("$baseUrl/payments/saved-cards/$cardId");
      final headers = await _getHeaders();

      final response = await delete(
        url,
        headers: headers,
      );

      final result = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 204) &&
          result["success"] == true) {
        return true;
      } else {
        throw result["message"] ?? "Failed to delete card";
      }
    } on SocketException {
      throw "Check your internet connection";
    } catch (e) {
      throw e.toString();
    }
  }
}
