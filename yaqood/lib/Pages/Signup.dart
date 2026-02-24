import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:yaqood/Constants/constants.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Pages/VerifyCode.dart';
import 'package:yaqood/Widgets/Custom_Password_Filed.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Custom_TextFiled.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  bool isLoadsing = false;

  @override
  void dispose() {
    super.dispose();
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phoneNumber.dispose();
    password.dispose();
    confirmPassword.dispose();
  }

  Future<Map<String, dynamic>> setData() async {
    var response = await post(
      Uri.parse("${Constants.baseUrl}/auth/client/signup"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email.text,
        "password": password.text,
        "firstName": firstName.text,
        "lastName": lastName.text,
        "phoneNumber": phoneNumber.text,
      }),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (firstName.text.isEmpty ||
        lastName.text.isEmpty ||
        email.text.isEmpty ||
        phoneNumber.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
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
        message: "Your passwords don’t match. Please check and try again.",
        isError: true,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,

          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,),
            padding: EdgeInsets.only(top:35, left: 5),
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
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

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
                                  CustomText(text: "Sign Up"),

                                  Text(
                                    "Create an account to continue!",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  Gap(24),

                                  CustomTextfiled(
                                    hintText: "First Name",
                                    formController: firstName,
                                  ),

                                  Gap(10),

                                  CustomTextfiled(
                                    hintText: "Last Name",
                                    formController: lastName,
                                  ),

                                  Gap(10),

                                  CustomTextfiled(
                                    hintText: "Email",
                                    suffixIcon: Icons.email_outlined,
                                    formController: email,
                                  ),

                                  Gap(10),

                                  CustomTextfiled(
                                    hintText: "Phone Number",
                                    suffixIcon: Icons.phone_android,
                                    formController: phoneNumber,
                                  ),

                                  Gap(10),

                                  CustomPasswordFiled(
                                    hintText: "Create Password",
                                    passwordController: password,
                                  ),

                                  Gap(10),

                                  CustomPasswordFiled(
                                    hintText: "Confirm Password",
                                    passwordController: confirmPassword,
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
                                              purpose:
                                                  VerificationPurpose.signup,
                                            ),
                                          ),
                                        );
                                      } else {
                                        showSnackBar(
                                          context: context,
                                          message:
                                              result['message'] ??
                                              'Something went wrong during sign up. Please try again.',
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
                                            "Register",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),

                                  Gap(12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an Account? ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      MaterialButton(
                                        padding: EdgeInsets.zero,
                                        minWidth: 0,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) => Login(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Login",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: PrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }
}
