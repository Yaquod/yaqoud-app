import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import '../Models/saved_card_model.dart';
import '../services/payment_service.dart';
import '../Widgets/Paymob_WebView.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final PaymentService _paymentService = PaymentService();

  List<SavedCard> _cards = [];
  bool _isLoadingCards = false;
  bool _isAddingCard = false;

  @override
  void initState() {
    super.initState();
    _fetchUserCards();
  }

  Future<void> _fetchUserCards() async {
    if (!mounted) return;
    setState(() => _isLoadingCards = true);
    try {
      final List<SavedCard>? fetchedCards = await _paymentService
          .getSavedCards();
      if (mounted) {
        setState(() {
          _cards = fetchedCards ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context: context, message: "Error loading cards: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCards = false);
      }
    }
  }

  Future<void> _handleAddNewCardFlow() async {
    if (!mounted) return;
    setState(() => _isAddingCard = true);
    try {
      String? url = await _paymentService.getCheckoutUrl();

      if (url != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymobWebView(url: url)),
        );
        await _fetchUserCards();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context: context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingCard = false);
      }
    }
  }

  Future<void> _handleDeleteCard(SavedCard card) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Card",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove the card ending in ${card.maskedPan.substring(card.maskedPan.length - 4)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _paymentService.deleteSavedCard(card.id);
        if (success && mounted) {
          showSnackBar(
            context: context,
            message: "Card removed successfully",
            isError: false,
          );
          _fetchUserCards();
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context: context, message: e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Wallet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(12),
            const Text(
              "Saved Payment Methods",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Gap(6),
            Text(
              "Safely manage your credit and debit cards for seamless rides.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
            const Gap(24),

            Expanded(
              child: _isLoadingCards
                  ? Center(
                      child: CircularProgressIndicator(color: PrimaryColor),
                    )
                  : _cards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card_off_rounded,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const Gap(16),
                          const Text(
                            "No Saved Cards Found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Gap(6),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                            ),
                            child: Text(
                              "You haven't linked any cards yet. Add a card to start enjoying faster checkout.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const Gap(16),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: PrimaryColor,
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text(
                              "Tap to Refresh",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _fetchUserCards,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _cards.length,
                      separatorBuilder: (context, index) => const Gap(12),
                      itemBuilder: (context, index) {
                        final card = _cards[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PrimaryColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.credit_card_rounded,
                                color: PrimaryColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              card.maskedPan,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                card.cardSubtype.toUpperCase(),
                                style: TextStyle(
                                  color: PrimaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              onPressed: () => _handleDeleteCard(card),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isAddingCard || _isLoadingCards
                      ? null
                      : _handleAddNewCardFlow,
                  child: _isAddingCard
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Add New Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
