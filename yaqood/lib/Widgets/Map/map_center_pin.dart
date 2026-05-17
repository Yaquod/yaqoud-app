import 'package:flutter/material.dart';

class MapCenterPin extends StatelessWidget {
  final bool isMapMoving;

  const MapCenterPin({super.key, required this.isMapMoving});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isMapMoving ? 10 : 0,
        height: isMapMoving ? 40 : 0,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green.shade300, width: 1),
        ),
      ),
    );
  }
}