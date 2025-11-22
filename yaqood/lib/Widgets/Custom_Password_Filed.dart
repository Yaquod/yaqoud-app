import 'package:flutter/material.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class CustomPasswordFiled extends StatefulWidget {
  final String hintText;
  final TextEditingController passwordController;
  const CustomPasswordFiled({super.key, required this.hintText, required this.passwordController});

  @override
  State<CustomPasswordFiled> createState() => _CustomPasswordFiledState();
}

class _CustomPasswordFiledState extends State<CustomPasswordFiled> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.passwordController,
      obscureText: !_isVisible,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
          icon: Icon(
            _isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
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
