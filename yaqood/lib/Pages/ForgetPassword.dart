import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
import 'package:yaqood/Pages/VerifyCode.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Custom_TextFiled.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController email = TextEditingController();

  bool isLoadsing = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> setData() async {
    var response = await post(
      Uri.parse("http://192.168.100.5:8000/api/auth/regenerate-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email.text}),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (email.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill email field")));
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
                    CustomText(text: "Forget Password"),
                    Gap(5),
                    Text(
                      "Enter your email below to\n receive a reset Code",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Gap(40),
                    CustomTextfiled(
                      hintText: "Email",
                      suffixIcon: Icons.email_outlined,
                      formController: email,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => VerifyCode(emailText: email.text,purpose: VerificationPurpose.resetPassword,),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? 'Wrong data'),
                            ),
                          );
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
                              "Send Code",
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
