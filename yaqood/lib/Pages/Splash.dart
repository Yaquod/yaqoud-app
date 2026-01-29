import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Pages/Home.dart';
import 'package:yaqood/Pages/Onboarding.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  Future<void> navigateUser () async {
    await Future.delayed(Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("accessToken") ;

    if(!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Home()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Onboarding()));
    }
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
                  child: Image.asset("assets/images/logo.png"),
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
            child: Image.asset("assets/images/buildings.png", fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
