import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class SafetyCheckWidget extends StatelessWidget {
  final VoidCallback onStartRidePressed;

  const SafetyCheckWidget({super.key, required this.onStartRidePressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("SafetyCheckPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Safety Check!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const Gap(16),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: PrimaryColor, size: 20),
              const Gap(8),
              const Expanded(
                child: Text(
                  "Please make sure your luggage is secured and you are wearing your seatbelt.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Gap(16),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: onStartRidePressed,
          child: const Text(
            "Start Ride Now",
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
