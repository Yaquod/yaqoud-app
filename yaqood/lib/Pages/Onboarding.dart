import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Models/Onboarding_Data.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Onboarding extends StatefulWidget {
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemBuilder: (context, index) => Column(
                children: [
                  Gap(140),
                  Image.asset(onboardingData[index].image, width: 278),
                  Gap(60),
                  CustomText(text: onboardingData[index].tittle),
                  Gap(40),
                  Container(
                    width: 283,
                    child: Text(
                      onboardingData[index].text,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(40),
                  if (_currentPage == onboardingData.length - 1)
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (c) => Login()),
                        );
                      },
                      color: PrimaryColor,
                      minWidth: 190,
                      height: 45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      child: Text(
                        "GET STARTED!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Container(
            height: 6,
            width: 90,
            margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  height: 6,
                  width: 30,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? PrimaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
