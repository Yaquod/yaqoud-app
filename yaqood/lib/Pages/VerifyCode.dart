import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Pages/ResetPassword.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class VerifyCode extends StatefulWidget {
  const VerifyCode({super.key, required this.emailText, required this.purpose});
  final String emailText;
  final VerificationPurpose purpose;

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  late final TextEditingController verifyCode;

  bool isLoadsing = false;

  @override
  void initState() {
    verifyCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    verifyCode.dispose();
  }

  Future<Map<String, dynamic>> setData() async {
    var response = await post(
      Uri.parse("http://192.168.100.5:8000/api/auth/verify-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": widget.emailText,
        "code": verifyCode.text.toString(),
      }),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (verifyCode.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill the complete 6-digit verification code"),
        ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(80),
                  CustomText(text: "Verify Code"),
                  Gap(10),
                  Text.rich(
                    TextSpan(
                      text:
                          "We will send you a message to your SMS and email, if something goes wrong, please contact us.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Gap(40),
                  PinCodeTextField(
                    controller: verifyCode,
                    appContext: context,
                    length: 6,
                    cursorColor: Colors.grey,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      inactiveColor: Colors.grey[200],
                      activeColor: PrimaryColor,
                      selectedColor: Colors.grey[200],
                      fieldWidth: 50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Gap(40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive any code?  ",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        minWidth: 0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: () {},
                        child: Text(
                          "Resend Again",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: PrimaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: PrimaryColor,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Request a new code in + Counter",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Gap(50),
                  Center(
                    child: MaterialButton(
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
                          if (widget.purpose == VerificationPurpose.signup) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (c) => Login()),
                          );
                          }
                          else{
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (c) => ResetPassword(email: widget.emailText, code: verifyCode.text,)),
                          );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Verification failed.',
                              ),
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
                              "Verify Code",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
