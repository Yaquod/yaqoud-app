import 'package:flutter/material.dart';
import 'package:yaqood/Pages/Onboarding.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (x) => Onboarding()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Image.asset("images/logo.png"),
                ),
                Text(
                  "Yaqood",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset("images/buildings.png", fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
