import 'package:flutter/material.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import '../Models/saved_card_model.dart';
import '../services/payment_service.dart';
import '../Widgets/Paymob_WebView.dart';

class WalletScreen extends StatefulWidget {
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final PaymentService _paymentService = PaymentService();

  Future<void> _handleAddNewCard() async {
    try {
      String? url = await _paymentService.getCheckoutUrl();

      if (url != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymobWebView(url: url)),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context: context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Wallet")),
      body: FutureBuilder<List<SavedCard>?>(
        future: _paymentService.getSavedCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: PrimaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: ${snapshot.error}"),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final cards = snapshot.data ?? [];

          return Column(
            children: [
              if (cards.isEmpty)
                const Expanded(child: Center(child: Text("No saved cards")))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(
                        Icons.credit_card,
                        color: Colors.blue,
                      ),
                      title: Text(cards[index].maskedPan),
                      subtitle: Text(cards[index].cardSubtype),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: _handleAddNewCard,
                    child: const Text("Add new card"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
