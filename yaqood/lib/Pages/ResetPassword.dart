import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Widgets/Custom_Password_Filed.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.email, required this.code});
  final String email;
  final String code;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool isLoadsing = false;

  @override
  void dispose() {
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> setData() async {
    var response = await post(
      Uri.parse("http://192.168.100.5:8000/api/auth/reset-password"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": widget.email.toString(),
        "password": password.text.toString(),
        "code": widget.code.toString(),
      }),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (password.text.isEmpty || confirmPassword.text.isEmpty) {
      showSnackBar(
        context: context,
        message: "Please fill all fields",
        isError: true,
      );

      return false;
    }

    if (password.text != confirmPassword.text) {
      showSnackBar(
        context: context,
        message: "Passwords do not match",
        isError: true,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: CustomText(text: "Yaqood"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Gap(80),
                    CustomText(text: "Reset Password"),
                    Gap(5),
                    Text(
                      "Enter your New Password",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Gap(40),
                    CustomPasswordFiled(
                      hintText: 'Create  Password',
                      passwordController: password,
                    ),
                    Gap(20),
                    CustomPasswordFiled(
                      hintText: 'Confirm Password',
                      passwordController: confirmPassword,
                    ),
                    Gap(40),
                    MaterialButton(
                      color: PrimaryColor,
                      minWidth: 250,
                      height: 40,
                      elevation: 0,
                      highlightElevation: 0,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: () async {
                        if (!validationInputs() || isLoadsing) return;

                        setState(() {
                          isLoadsing = true;
                        });

                        final result = await setData();
                        if (result["success"] == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (c) => Login()),
                          );
                        } else {
                          showSnackBar(context: context, message: result['message'] ?? 'Wrong data', isError: true);
                        }

                        setState(() {
                          isLoadsing = false;
                        });
                      },
                      child: isLoadsing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Change Password",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
