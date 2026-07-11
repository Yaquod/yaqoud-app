import 'package:flutter/material.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class CustomTextfiled extends StatefulWidget {
  const CustomTextfiled({
    super.key,
    required this.hintText,
    required this.formController,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.isPassword = false, 
  });

  final String hintText;
  final TextEditingController formController;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool enabled;
  final TextInputType keyboardType;
  final bool isPassword;

  @override
  State<CustomTextfiled> createState() => _CustomTextfiledState();
}

class _CustomTextfiledState extends State<CustomTextfiled> {
  bool _obscureText = true; 

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: widget.formController,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        
        obscureText: widget.isPassword ? _obscureText : false,
        
        cursorColor: PrimaryColor,
        cursorHeight: 22,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.enabled ? Colors.white : Colors.grey.shade50,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          
          prefixIcon: widget.prefixIcon != null 
              ? Icon(widget.prefixIcon, color: Colors.grey[400], size: 22) 
              : null,
          
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                )
              : (widget.suffixIcon != null 
                  ? Icon(widget.suffixIcon, color: Colors.grey[400], size: 22) 
                  : null),
          
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: PrimaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}