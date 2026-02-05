import 'package:flutter/material.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key, required this.text, this.fontSize = 45});
  final String text;
  final double fontSize ;
  
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontFamily: 'AppFont',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: PrimaryColor
      )
    );
  }
}
