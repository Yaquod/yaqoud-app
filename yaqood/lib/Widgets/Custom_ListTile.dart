import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({super.key, required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xff242E42),
        ),
      ),
      leading: Icon(icon, color: Color(0xffC1C0C9), size: 30),
      onTap: onTap,
    );
  }
}
