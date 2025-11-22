import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.inter(
      textStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: PrimaryColor
      )
    ));
  }
}
