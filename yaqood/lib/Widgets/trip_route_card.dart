import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TripRouteCard extends StatelessWidget {
  final String startStreetName;
  final String destinationStreetName;

  const TripRouteCard({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Icon(Icons.person_pin_circle_outlined, color: Colors.green, size: 26),
                Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Container(width: 1.2, height: 5, color: Colors.grey[400]),
                    ),
                  ),
                ),
                const Icon(Icons.location_pin, color: Colors.red, size: 26),
              ],
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    startStreetName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 16),
                  Text(
                    destinationStreetName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}