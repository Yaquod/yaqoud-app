import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
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
      Uri.parse("${dotenv.env["API_BASE_URL"]}/auth/regenerate-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email.text}),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (email.text.isEmpty) {
      showSnackBar(
        context: context,
        message: "Please fill email field",
        isError: true,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          padding: EdgeInsets.only(top: 35, left: 5),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD9ECFF), Color(0xFFCFE5FF), Color(0xFFE9E3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),

            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),

                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),

                          child: Container(
                            padding: const EdgeInsets.all(24),

                            constraints: BoxConstraints(maxWidth: 420),

                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(150),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/logo.png",
                                  height: 100,
                                ),

                                Gap(12),

                                CustomText(text: "Forget Password?", fontSize: 32,),

                                Text(
                                  "Enter your email to receive a verification\n code to reset your password.",

                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),

                                  textAlign: TextAlign.center,
                                ),

                                Gap(24),

                                CustomTextfiled(
                                  hintText: "Email",
                                  suffixIcon: Icons.email_outlined,
                                  formController: email,
                                ),

                                Gap(24),

                                MaterialButton(
                                  color: PrimaryColor,
                                    minWidth: 320,
                                    height: 48,
                                    elevation: 0,
                                    highlightElevation: 0,
                                    shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: () async {
                                    if (!validationInputs() || isLoadsing)
                                      return;

                                    setState(() {
                                      isLoadsing = true;
                                    });

                                    final result = await setData();
                                    if (result["success"] == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => VerifyCode(
                                            emailText: email.text,
                                            purpose: VerificationPurpose
                                                .resetPassword,
                                          ),
                                        ),
                                      );
                                    } else {
                                      showSnackBar(
                                        context: context,
                                        message:
                                            result['message'] ?? 'Wrong data',
                                        isError: true,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
