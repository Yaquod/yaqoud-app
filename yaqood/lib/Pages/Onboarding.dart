import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Models/Onboarding_Data.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Onboarding extends StatefulWidget {
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  Gap(120),
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Color(0xff9fcdf9),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Image.asset(
                        onboardingData[index].image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Gap(50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      onboardingData[index].tittle,
                      style: TextStyle(
                        fontFamily: 'AppFont',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: PrimaryColor,
                      ),
                    ),
                  ),
                  Gap(15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      onboardingData[index].text,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Gap(40),

                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    child: MaterialButton(
                      onPressed: () {
                        _currentPage == (onboardingData.length - 1)
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (c) => Login()),
                              )
                            : _controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                      },
                      color: PrimaryColor,
                      minWidth: 250,
                      height: 48,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      child: Text(
                        _currentPage == (onboardingData.length - 1)
                            ?
                        "GET STARTED!" : "NEXT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 6,
            width: 75,
            margin: EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  height: 8,
                  width: _currentPage == index ? 35 : 20,
                  duration: Duration(milliseconds: 300),
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
