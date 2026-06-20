import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'package:yaqood/Widgets/trip_route_card.dart';

class ConfirmTripWidget extends StatelessWidget {
  final String startStreetName;
  final String? destinationStreetName;
  final double? distance;
  final double? duration;
  final VoidCallback onRequestPressed;
  final VoidCallback onEditPressed;

  const ConfirmTripWidget({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
    required this.onRequestPressed,
    required this.onEditPressed,
    required this.distance,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("ConfirmTripPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Trip Summary",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: PrimaryColor),textAlign: TextAlign.center,
        ),
        const Gap(12),


        TripRouteCard(
          startStreetName: startStreetName,
          destinationStreetName: destinationStreetName!,
        ),

        const Gap(16),

        // Distance & Duration
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                label: '${(duration ?? 0).toStringAsFixed(0)} min',
                icon: Icons.access_time_filled,
                color: PrimaryColor,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildInfoCard(
                label: '${(distance ?? 0).toStringAsFixed(2)} km',
                icon: Icons.directions_car_filled,
                color: Colors.orange,
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
          onPressed: onEditPressed,
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

  Widget _buildInfoCard({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
