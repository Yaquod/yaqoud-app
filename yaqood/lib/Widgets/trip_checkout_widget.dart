import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class TripCheckoutWidget extends StatelessWidget {
  final VoidCallback onEndTripPressed;

  const TripCheckoutWidget({super.key, required this.onEndTripPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("TripCheckoutPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "You Have Arrived!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const Gap(16),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orange, size: 22),
              const Gap(10),
              Expanded(
                child: Text(
                  "Please ensure you are safely outside the vehicle and have collected all your personal belongings.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Gap(20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: onEndTripPressed,
          child: const Text(
            "End Trip",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Gap(15),
      ],
    );
  }
}
