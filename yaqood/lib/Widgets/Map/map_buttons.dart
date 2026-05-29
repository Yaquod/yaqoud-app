import 'package:flutter/material.dart';
import 'package:yaqood/Constants/constants.dart';

// 1. Drawer Button
class MapDrawerButton extends StatelessWidget {
  final bool isMapMoving;
  final double sheetSize;
  final VoidCallback onPressed;

  const MapDrawerButton({
    super.key,
    required this.isMapMoving,
    required this.sheetSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double offset = isMapMoving ? 60 : (((sheetSize - 0.8) / (Constants.maxSheetSize - 0.8)).clamp(0.0, 1.0) * 60);
    double opacity = isMapMoving ? 0 : (1 - ((sheetSize - 0.8) / (Constants.maxSheetSize - 0.8)).clamp(0.0, 1.0));

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      top: 30 - offset,
      left: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        opacity: opacity,
        child: IgnorePointer(
          ignoring: sheetSize >= Constants.maxSheetSize || isMapMoving,
          child: IconButton(
            onPressed: onPressed,
            icon: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.menu, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Location GPS Button
class MapLocationButton extends StatelessWidget {
  final bool isMapMoving;
  final double sheetSize;
  final bool hasRoute;
  final VoidCallback onPressed;

  const MapLocationButton({
    super.key,
    required this.isMapMoving,
    required this.sheetSize,
    required this.hasRoute,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double bottomOffset = isMapMoving ? -20 : (MediaQuery.sizeOf(context).height * sheetSize);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      bottom: 20 + bottomOffset,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        opacity: isMapMoving ? 0 : (sheetSize >= 0.8 ? 0 : 1),
        child: IgnorePointer(
          ignoring: sheetSize >= 0.8 || isMapMoving,
          child: FloatingActionButton.small(
            heroTag: "hero-1",
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: onPressed,
            child: Icon(
              Icons.location_searching,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Focus Route Button
class MapFocusRouteButton extends StatelessWidget {
  final bool hasRoute;
  final List<dynamic> polylineCoordinates;
  final bool isMapMoving;
  final double sheetSize;
  final VoidCallback onPressed;

  const MapFocusRouteButton({
    super.key,
    required this.hasRoute,
    required this.polylineCoordinates,
    required this.isMapMoving,
    required this.sheetSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasRoute || polylineCoordinates.isEmpty) return const SizedBox.shrink();

    double bottomOffset = isMapMoving ? -20 : (MediaQuery.sizeOf(context).height * sheetSize);

    return Positioned(
      bottom: 20 + bottomOffset,
      left: 20,
      child: FloatingActionButton.small(
        heroTag: "hero-2",
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: onPressed,
        child: const Icon(Icons.route, size: 20, color: Colors.black),
      ),
    );
  }
}