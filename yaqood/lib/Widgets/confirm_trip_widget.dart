import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class ConfirmTripWidget extends StatelessWidget {
  final String startStreetName;
  final String? destinationStreetName;
  final VoidCallback onRequestPressed;
  final VoidCallback onCancelPressed;

  const ConfirmTripWidget({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
    required this.onRequestPressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("ConfirmTripPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Trip Summary",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.black87
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(20),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // PickUp
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.green, size: 22),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PickUp Location",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          startStreetName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              
              // Destination
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 22),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Destination",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          destinationStreetName ?? "",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Gap(24),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          ),
          onPressed: onRequestPressed,
          child: const Text(
            "Request Yaqood",
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
        
        const Gap(8),
        
        TextButton(
          onPressed: onCancelPressed,
          child: const Text(
            "Edit Route",
            style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}