import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:yaqood/Models/trip_history_model.dart';
import 'package:yaqood/Utils/string_sanitizer.dart';

class TripHistoryCard extends StatefulWidget {
  final TripItem trip;
  final LatLng? currentUserLocation;

  const TripHistoryCard({
    super.key,
    required this.trip,
    this.currentUserLocation,
  });

  @override
  State<TripHistoryCard> createState() => _TripHistoryCardState();
}

class _TripHistoryCardState extends State<TripHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.trip.status == "COMPLETED";
    final Color statusColor = isCompleted
        ? Colors.green.shade700
        : Colors.red.shade700;

    String statusText = "Cancelled";
    if (isCompleted) {
      statusText = "Completed";
    } else if (widget.trip.status == "CANCELLED_BY_SYSTEM") {
      statusText = "System Cancelled";
    } else if (widget.trip.status == "CANCELLED_BY_PASSENGER") {
      statusText = "Passenger Cancelled";
    }

    final String formattedDate = DateFormat(
      'EEEE, MMM dd, yyyy',
    ).format(widget.trip.startedAt);
    final String startTime = DateFormat(
      'hh:mm a',
    ).format(widget.trip.startedAt);
    final String endTime = widget.trip.endedAt != null
        ? DateFormat('hh:mm a').format(widget.trip.endedAt!)
        : '--:--';

    final dynamic tripRating = widget.trip.ratingValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.trip.carCompany} ${widget.trip.model}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(16),

              Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, size: 10, color: Colors.green),
                      Container(
                        width: 1.5,
                        height: 26,
                        color: Colors.grey.shade400,
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: StreetSanitizer.resolvePickupName(
                            rawName: null,
                            pickupLatLng: LatLng(
                              widget.trip.startLat,
                              widget.trip.startLong,
                            ),
                            userLatLng: widget.currentUserLocation,
                          ),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Loading pickup...",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const Gap(18),
                        FutureBuilder<String>(
                          future: StreetSanitizer.resolveDestinationName(
                            rawName: null,
                            destinationLatLng: LatLng(
                              widget.trip.endLat,
                              widget.trip.endLong,
                            ),
                          ),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Loading destination...",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const Gap(12),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.4),
                      height: 1,
                    ),
                    const Gap(12),
                    _buildDetailRow(
                      Icons.access_time_rounded,
                      "Pickup Time",
                      startTime,
                    ),
                    const Gap(8),
                    _buildDetailRow(
                      Icons.access_time_filled_rounded,
                      "Drop-off Time",
                      endTime,
                    ),
                    const Gap(8),
                    _buildDetailRow(
                      Icons.palette_outlined,
                      "Vehicle Color",
                      widget.trip.color.toLowerCase(),
                    ),

                    if (tripRating != null) ...[
                      const Gap(8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const Gap(8),
                          Text(
                            "Your Rating",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$tripRating / 5.0",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 255),
              ),

              const Gap(12),
              Divider(color: Colors.white.withValues(alpha: 0.4), height: 1),
              const Gap(12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                  ),
                  if (isCompleted && widget.trip.amount != null)
                    Row(
                      children: [
                        if (tripRating != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const Gap(2),
                          Text(
                            "$tripRating ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                              fontSize: 13,
                            ),
                          ),
                          const Gap(8),
                        ],
                        Text(
                          "${widget.trip.amount!.toStringAsFixed(1)} ${widget.trip.currency ?? 'EGP'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      "No Charge",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const Gap(8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
