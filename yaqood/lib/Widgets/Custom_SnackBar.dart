import 'package:flutter/material.dart';
void showSnackBar({required context ,required String message, bool isError = true}){
  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isError ? Colors.red.shade600 : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline_outlined, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text(message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)),
            ],
          ),
        ),
      );
}