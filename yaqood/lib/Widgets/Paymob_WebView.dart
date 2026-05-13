import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yaqood/Models/saved_card_model.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';

class PaymobWebView extends StatefulWidget {
  const PaymobWebView({super.key, required this.url});
  final String url;

  @override
  State<PaymobWebView> createState() => _PaymobWebViewState();
}

class _PaymobWebViewState extends State<PaymobWebView> {
  late final WebViewController controller;

  int? id;
  String? maskedPan;
  String? cardSubtype;
  String? cardholderName;

  Future<List<SavedCard>?> getSavedCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString("accessToken");

      if (accessToken == null) {
        if (mounted)
          showSnackBar(context: context, message: "You must login again");
        return null;
      }

      final response = await get(
        Uri.parse("${dotenv.env["API_BASE_URL"]}/payments/saved-cards"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result["success"] && result["data"] != null) {
          List<dynamic> cardsData = result["data"];

          print(result["data"]);

          return cardsData.map((json) => SavedCard.fromJson(json)).toList();
        } else {
          if (mounted) {
            showSnackBar(context: context, message: result["message"]);
          }
          return null;
        }
      } else {
        if (mounted) {
          showSnackBar(
            context: context,
            message: "Server error: ${response.statusCode}",
          );
        }
        print("Response Body: ${response.body}");
        return null;
      }
    } catch (e) {
      if (mounted) showSnackBar(context: context, message: "Network error: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains('https://www.google.com/')) {
              print(
                "*************** Patment done & Redirercting *************",
              );

              List<SavedCard>? cards = await getSavedCards();

              if (cards != null && cards.isNotEmpty) {
                print("Card Saved Successfully!");
                for (var card in cards) {
                  print("Card ID: ${card.id}");
                  print("Card Masked PAN: ${card.maskedPan}");
                }

                if (mounted) {
                  Navigator.pop(context, cards);
                }
              } else {
                print("No cards found or error occurred");
                if (mounted) Navigator.pop(context, null);
              }

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: WebViewWidget(controller: controller),
    );
  }
}
