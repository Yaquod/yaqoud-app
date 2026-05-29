import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class ConfirmTripWidget extends StatelessWidget {
  final String startStreetName;
  final String? destinationStreetName;
  final double? distance;
  final double? duration;
  final VoidCallback onRequestPressed;
  final VoidCallback onCancelPressed;

  const ConfirmTripWidget({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
    required this.onRequestPressed,
    required this.onCancelPressed,
    required this.distance,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("ConfirmTripPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // const Text(
        //   "Trip Summary",
        //   style: TextStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.black87,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        // const Gap(20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.person_pin_circle_outlined,
                      color: Colors.green,
                      size: 30,
                    ),

                    Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Container(
                            width: 1.2,
                            height: 6,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    Icon(Icons.location_pin, color: Colors.red, size: 30),
                  ],
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startStreetName,
                        style: TextStyle(fontSize: 18),
                      ),

                      Divider(color: Colors.grey[400]),

                      Text(
                        destinationStreetName!,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const Gap(16),

        // Distance & Duration
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: PrimaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PrimaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color: PrimaryColor,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      '${duration!.toStringAsFixed(2)} min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car_filled,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      '${distance!.toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const Gap(24),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
          ),
          onPressed: onRequestPressed,
          child: const Text(
            "Request Yaqood",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const Gap(8),

        TextButton(
          onPressed: onCancelPressed,
          child: const Text(
            "Edit Route",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
