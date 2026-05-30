import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class SearchingVehicleWidget extends StatelessWidget {
  const SearchingVehicleWidget({
    super.key,
    required this.onCancelSearch,
  });

  final VoidCallback onCancelSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("SearchingVehiclePanel"),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        Text(
          "Finding a Nearby Vehicle",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(6),

        const Text(
          "Locating the nearest autonomous taxi for you...",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),

        const Gap(24),
        
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            backgroundColor: PrimaryColor.withValues(alpha: 0.1),
            color: PrimaryColor,
            minHeight: 6,
            
          ),
        ),
        
        const Gap(28),
        
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent, width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onCancelSearch,
          child: const Text(
            "Cancel Search",
            style: TextStyle(
              color: Colors.redAccent,
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