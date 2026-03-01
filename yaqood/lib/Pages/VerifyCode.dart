import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
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
  bool isResendEnabled = true;
  int counter = 0;
  Timer? timer;

  @override
  void initState() {
    verifyCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    verifyCode.dispose();
    timer?.cancel();
  }

  Future<Map<String, dynamic>> setData() async {
    var response = await post(
      Uri.parse("${dotenv.env["API_BASE_URL"]}/auth/verify-code"),
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
      showSnackBar(
        context: context,
        message: "Please fill the complete 6-digit verification code",
        isError: true,
      );
      return false;
    }

    return true;
  }

  void startCounter() {
    counter = 60;
    isResendEnabled = false;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (counter == 0) {
        t.cancel();
        setState(() => isResendEnabled = true);
      } else {
        setState(() => counter--);
      }
    });
  }

  Future resendCode() async {
    if (!isResendEnabled) return;

    startCounter();
    verifyCode.clear();
    showSnackBar(
      context: context,
      message: "A new verification code has been sent.",
      isError: false,
    );

    await post(
      Uri.parse("${dotenv.env["API_BASE_URL"]}/auth/regenerate-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": widget.emailText}),
    );
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

                                CustomText(text: "Verify Code", ),

                                Text(
                                  "We will send a verification code to  your email. If you don't receive it, please\n contact support",

                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),

                                  textAlign: TextAlign.center,
                                ),

                                Gap(24),

                                PinCodeTextField(
                                  controller: verifyCode,
                                  appContext: context,
                                  length: 6,
                                  cursorColor: PrimaryColor,
                                  enableActiveFill: true,
                                  
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(10),

                                    
                                    inactiveColor: Colors.white,
                                    inactiveFillColor: Colors.white,

                                    activeColor: PrimaryColor,
                                    activeFillColor: Colors.white,

                                    selectedColor: Colors.white,
                                    selectedFillColor: Colors.white,

                                    
                                    fieldWidth: 50,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),

                                Gap(24),

                                Center(
                                  child: Text(
                                    "Didn't receive any code?  ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Center(
                                  child: MaterialButton(
                                    padding: EdgeInsets.zero,
                                    minWidth: 0,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onPressed: isResendEnabled
                                        ? resendCode
                                        : null,
                                    child: Text(
                                      isResendEnabled
                                          ? "Resend Again"
                                          : "Request a new code in $counter s",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isResendEnabled
                                            ? PrimaryColor
                                            : Colors.grey,
                                        decoration: isResendEnabled
                                            ? TextDecoration.underline
                                            : TextDecoration.none,
                                        decorationColor: PrimaryColor,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ),
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
                                      if (widget.purpose ==
                                          VerificationPurpose.signup) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => Login(),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => ResetPassword(
                                              email: widget.emailText,
                                              code: verifyCode.text,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      showSnackBar(
                                        context: context,
                                        message:
                                            result['message'] ??
                                            "Verification failed. Please check the code and try again.",
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
                                          "Verify Code",
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
