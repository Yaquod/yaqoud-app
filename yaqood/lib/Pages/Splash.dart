import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Pages/Home.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Pages/Onboarding.dart';

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

  Future<void> navigateUser() async {
    RemoteMessage? initilMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("accessToken");

    final bool isFirstTime = prefs.getBool("isFirstTime") ?? true;

    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => Onboarding()),
      );
    } else if (token != null && token.isNotEmpty) {
      if (initilMessage != null) {
        // String? tripId = initilMessage.data['tripId'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => Home()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => Home()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset("assets/images/logo.png", width: 250)),
    );
  }
}
