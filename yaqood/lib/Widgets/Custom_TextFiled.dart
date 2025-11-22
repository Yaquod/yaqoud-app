import 'package:flutter/material.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class CustomTextfiled extends StatelessWidget {
  const CustomTextfiled({super.key, required this.hintText, this.suffixIcon, required this.formController});

  final String hintText;
  final IconData? suffixIcon;
  final TextEditingController formController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: formController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        suffixIconColor: Colors.grey[500],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PrimaryColor, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PrimaryColor, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
