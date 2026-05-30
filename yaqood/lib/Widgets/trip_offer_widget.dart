import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'trip_route_card.dart';

class TripOfferWidget extends StatelessWidget {
  const TripOfferWidget({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
    required this.estimatedTime,
    required this.estimatedFare,
    required this.distance,
    required this.acceptOffer,
    required this.declineOffer,
  });

  final String startStreetName;
  final String destinationStreetName;
  final double estimatedTime;
  final double estimatedFare;
  final double distance;
  final VoidCallback acceptOffer;
  final Future<Map<String, dynamic>?> Function() declineOffer;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("TripOfferPanel"),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Best Offer Found",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const Gap(4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Offer expires in ",
              style: TextStyle(color: Colors.grey),
            ),
            TweenAnimationBuilder<Duration>(
              duration: const Duration(seconds: 20),
              tween: Tween(
                begin: const Duration(seconds: 20),
                end: Duration.zero,
              ),
              onEnd: () async {
                await declineOffer();
              },
              builder: (BuildContext context, Duration value, Widget? child) {
                final seconds = value.inSeconds;
                return Text(
                  "${seconds}s",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: seconds <= 5
                        ? Colors.red
                        : seconds <= 10
                        ? Colors.orange
                        : PrimaryColor,
                  ),
                );
              },
            ),
          ],
        ),

        const Gap(16),

        TripRouteCard(
          startStreetName: startStreetName,
          destinationStreetName: destinationStreetName,
        ),

        const Gap(16),

        Row(
          children: [
            _buildInfoCard(
              label: "${estimatedTime.toStringAsFixed(0)} min",
              icon: Icons.access_time_filled,
              color: PrimaryColor,
            ),
            const Gap(6),
            _buildInfoCard(
              label: "${distance.toStringAsFixed(2)} km",
              icon: Icons.directions_car_filled,
              color: Colors.orange,
            ),
            const Gap(6),
            _buildInfoCard(
              label: "\$${estimatedFare.toStringAsFixed(2)}",
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.green,
            ),
          ],
        ),
        const Gap(24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await declineOffer();
                },
                child: const Text(
                  "Decline",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Gap(12),

            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                onPressed: acceptOffer,
                child: const Text(
                  "Accept Offer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
