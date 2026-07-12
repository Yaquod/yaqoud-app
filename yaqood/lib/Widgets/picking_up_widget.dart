import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:yaqood/Utils/string_sanitizer.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class PickingUpWidget extends StatelessWidget {
  final String startStreetName;
  final double? distance;
  final double? duration;

  const PickingUpWidget({
    super.key,
    required this.startStreetName,
    required this.distance,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("PickingUpPanel"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Yaqood is on the way!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        Lottie.asset(
          'assets/animations/vehicle.json',
          height: 90,
          fit: BoxFit.contain,
          repeat: true, 
          animate: true,
        ),
        
        const Gap(10),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                label: '${(duration ?? 0).toStringAsFixed(0)} min away',
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
        const Gap(20),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.hail, color: PrimaryColor),

              const Gap(10),
              
              Expanded(
                child: Text(
                  "Pickup Location: $startStreetName",
                  style: TextStyle(
                    fontSize: 14,
                    color: StreetSanitizer.isFallback(startStreetName) ? Colors.grey[500] : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Gap(15),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
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