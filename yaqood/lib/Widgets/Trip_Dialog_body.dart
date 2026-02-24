import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class TripDialogBody extends StatefulWidget {
  const TripDialogBody({
    super.key,
    required this.startStreetName,
    required this.destinationStreetName,
    required this.estimatedTime,
    required this.estimatedFare,
    required this.declineOffer,
  });
  final String startStreetName;
  final String destinationStreetName;
  final double estimatedTime;
  final double estimatedFare;
  final Future<Map<String, dynamic>?> Function() declineOffer;

  @override
  State<TripDialogBody> createState() => _TripDialogBodyState();
}

class _TripDialogBodyState extends State<TripDialogBody> {
  int counter = 20;
  Timer? timer;

  void startCounter() {
    timer = Timer.periodic(Duration(seconds: 1), (t) async{
      if (counter == 0) {
        t.cancel();

        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();

          await widget.declineOffer();
        }
      } else {
        if (mounted) {
          setState(() => counter--);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startCounter();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "There is your best offer",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: PrimaryColor,
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Offer expires in ", style: TextStyle(color: Colors.grey)),

            Text(
              "$counter s",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: counter <= 5
                    ? Colors.red
                    : counter <= 10
                    ? Colors.orange
                    : PrimaryColor,
              ),
            ),
          ],
        ),

        Divider(color: Colors.grey[400], height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        widget.startStreetName,
                        style: TextStyle(fontSize: 18),
                      ),

                      Divider(color: Colors.grey[400]),

                      Text(
                        widget.destinationStreetName,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Divider(color: Colors.grey[400], height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/images/car.png",
                width: 60,
                color: PrimaryColor,
              ),

              Column(
                children: [
                  Text(
                    "Time",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  Gap(6),

                  Text(
                    "${widget.estimatedTime} min",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    "Cost",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  Gap(6),

                  Text(
                    "\$${widget.estimatedFare}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        Gap(12),
      ],
    );
  }
}
