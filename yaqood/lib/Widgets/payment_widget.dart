import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Models/saved_card_model.dart';
import 'package:yaqood/Services/payment_service.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Paymob_WebView.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class PaymentWidget extends StatefulWidget {
  const PaymentWidget({
    super.key,
    required this.estimatedFare,
    required this.onPaymentSuccess,
    required this.tripRequestId,
  });

  final String tripRequestId;
  final double estimatedFare;
  final VoidCallback onPaymentSuccess;

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  final PaymentService _paymentService = PaymentService();

  List<SavedCard> _cards = [];
  SavedCard? _selectedCard;
  bool _isLoadingCards = false;
  bool _isProcessingPayment = false;
  bool _isOpeningWebView = false;

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
          _cards = fetchedCards ?? <SavedCard>[];
          if (_cards.isNotEmpty &&
              (_selectedCard == null ||
                  !_cards.any((c) => c.id == _selectedCard!.id))) {
            _selectedCard = _cards.first;
          }
        });
      }
    } catch (e) {
      if (mounted)
        showSnackBar(context: context, message: "Error loading cards: $e");
    } finally {
      if (mounted) setState(() => _isLoadingCards = false);
    }
  }

  Future<void> _handleAddNewCardFlow() async {
    if (_isOpeningWebView) return;
    setState(() => _isOpeningWebView = true);

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
      if (mounted) showSnackBar(context: context, message: e.toString());
    } finally {
      if (mounted) setState(() => _isOpeningWebView = false);
    }
  }

  Future<void> _processPaymentAndConfirmTrip() async {
    if (_selectedCard == null) {
      showSnackBar(
        context: context,
        message: "Please select a payment card first",
      );
      return;
    }

    if (mounted) setState(() => _isProcessingPayment = true);

    try {
      bool isPaid = await _paymentService.payWithSavedCard(
        cardId: _selectedCard!.id,
        amount: widget.estimatedFare,
        tripRequestId: widget.tripRequestId,
      );

      if (isPaid && mounted) {
        showSnackBar(
          context: context,
          message: "Payment successful!",
          isError: false,
        );
        widget.onPaymentSuccess();
      }
    } catch (e) {
      if (mounted)
        showSnackBar(context: context, message: "Payment Failed: $e");
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("PaymentPanel"),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Payment Method",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(6),
        Text(
          "Total Trip Fare: \$${widget.estimatedFare.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Select Saved Card",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: PrimaryColor, size: 22),
              onPressed: _isLoadingCards || _isProcessingPayment
                  ? null
                  : _fetchUserCards,
            ),
          ],
        ),
        const Gap(8),

        if (_isLoadingCards)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_cards.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.credit_card_off_outlined,
                  size: 44,
                  color: Colors.grey.shade400,
                ),
                const Gap(12),
                const Text(
                  "No Saved Cards Found",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Gap(6),
                Text(
                  "Please add a credit or debit card to complete your Yaqood trip registration.",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 190),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isSelected = _selectedCard?.id == card.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PrimaryColor.withValues(alpha: 0.02)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? PrimaryColor : Colors.grey.shade200,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    onTap: _isProcessingPayment
                        ? null
                        : () {
                            setState(() => _selectedCard = card);
                          },
                    leading: Icon(
                      Icons.credit_card_rounded,
                      color: isSelected ? PrimaryColor : Colors.grey.shade600,
                    ),
                    title: Text(
                      card.maskedPan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                    subtitle: Text(
                      card.cardSubtype.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? PrimaryColor : Colors.grey.shade500,
                      ),
                    ),

                    trailing: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? PrimaryColor
                              : Colors.grey.shade400,
                          width: isSelected ? 6 : 2,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        const Gap(12),

        TextButton.icon(
          onPressed:
              _isLoadingCards || _isProcessingPayment || _isOpeningWebView
              ? null
              : _handleAddNewCardFlow,
          icon: _isOpeningWebView
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: PrimaryColor,
                  ),
                )
              : Icon(Icons.add_rounded, color: PrimaryColor),
          label: Text(
            "Add New Card",
            style: TextStyle(color: PrimaryColor, fontWeight: FontWeight.bold),
          ),
        ),

        const Gap(12),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed:
              _isLoadingCards || _isProcessingPayment || _selectedCard == null
              ? null
              : _processPaymentAndConfirmTrip,
          child: _isProcessingPayment
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Confirm & Pay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const Gap(12),
      ],
    );
  }
}
