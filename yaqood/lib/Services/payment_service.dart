import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' ;
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
      final response = await get(
        Uri.parse("$baseUrl/payments/saved-cards"),
        headers: await _getHeaders(),
      );

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
      final response = await post(
        Uri.parse("$baseUrl/payments/cards"),
        headers: await _getHeaders(),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result["success"]) {
        return result["data"]["checkoutUrl"];
      } else {
        throw result["message"] ;
      }
    } on SocketException {
      throw "check your internet connection";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> payWithSavedCard({required int cardId, required double amount}) async {
    try {
      final response = await post(
        Uri.parse("$baseUrl/payments/mit"), 
        headers: await _getHeaders(),
        body: jsonEncode({
          "amount": amount,
          "savedCardId": cardId
        }),
      );

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
}