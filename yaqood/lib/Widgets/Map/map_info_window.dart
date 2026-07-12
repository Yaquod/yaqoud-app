import 'package:flutter/material.dart';
import 'package:yaqood/Utils/string_sanitizer.dart';

class MapInfoWindow extends StatelessWidget {
  final String startStreetName;
  final bool isMapMoving;
  final double sheetSize;
  final bool showInfoWindow;
  final VoidCallback onTap;

  const MapInfoWindow({
    super.key,
    required this.startStreetName,
    required this.isMapMoving,
    required this.sheetSize,
    required this.showInfoWindow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFallback = StreetSanitizer.isFallback(startStreetName);
    if (isMapMoving || sheetSize >= 0.5 || !showInfoWindow) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: (MediaQuery.sizeOf(context).height * 0.5 + 50),
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "PickUp Location",
                        style: TextStyle(fontSize: 14, color: Color(0xffC8C7CC)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        startStreetName,
                        style: TextStyle(fontSize: 16, color: isFallback ? Colors.grey[500] : Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}