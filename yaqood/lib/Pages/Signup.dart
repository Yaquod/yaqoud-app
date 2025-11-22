import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:yaqood/Enums/VerificationPurpose.dart';
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
      Uri.parse("http://192.168.100.5:8000/api/auth/client/signup"),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return false;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 500,
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          "images/Top1.png",
                          color: PrimaryColor,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          "images/Top2.png",
                          color: Color.fromARGB(97, 76, 229, 178),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      CustomText(text: "Create Account"),
                      Text(
                        "Enter your Personal Data",
                        style: TextStyle(fontSize: 16),
                      ),
                      Gap(20),

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
                      Gap(20),

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
                                builder: (c) =>
                                    VerifyCode(emailText: email.text,purpose: VerificationPurpose.signup,),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'Signup failed.',
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
                                "Signup",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                      Gap(10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "By continuing you are agreeing our ",
                                  style: GoogleFonts.poppins(fontSize: 10),
                                ),
                                MaterialButton(
                                  padding: EdgeInsets.zero,
                                  height: 10,
                                  minWidth: 0,
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => Signup(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "terms & conditions",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
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
                          ),
                          Text(
                            "and our privacy polices",
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                        ],
                      ),
                      Gap(10),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Text(
                            " Or signup with Google ",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      Gap(10),
                      MaterialButton(
                        color: PrimaryColor,
                        minWidth: 250,
                        height: 40,
                        elevation: 0,
                        highlightElevation: 0,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Continue with Google",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an Account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
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
                                MaterialPageRoute(builder: (c) => Login()),
                              );
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
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
                      Gap(20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
