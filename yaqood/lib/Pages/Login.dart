import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Pages/ForgetPassword.dart';
import 'package:yaqood/Pages/Home.dart';
import 'package:yaqood/Pages/Signup.dart';
import 'package:yaqood/Widgets/Custom_Password_Filed.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Custom_TextFiled.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  String? token;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("rememberMe", value);
  }

  Future<void> saveToken(String tokenString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", tokenString);
  }

  Future<Map<String, dynamic>> loginRequest() async {
    var response = await post(
      Uri.parse("http://192.168.100.5:8000/api/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email.text,
        "password": password.text,
        "fcmToken": "..",
      }),
    );
    return jsonDecode(response.body);
  }

  bool validationInputs() {
    if (email.text.isEmpty || password.text.isEmpty) {
      showSnackBar(
        context: context,
        message: "Please fill all fields",
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
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                Container(
                  width: 500,
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          "assets/images/Top1.png",
                          color: PrimaryColor,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          "assets/images/Top2.png",
                          color: Color.fromARGB(97, 76, 229, 178),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      CustomText(text: "Welcom back!"),
                      Text("Login", style: TextStyle(fontSize: 16)),
                      Gap(20),

                      Image.asset("assets/images/login.png", width: 270),
                      Gap(40),

                      CustomTextfiled(
                        hintText: "Email",
                        suffixIcon: Icons.email_outlined,
                        formController: email,
                      ),
                      Gap(20),

                      CustomPasswordFiled(
                        hintText: "Password",
                        passwordController: password,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  setState(() => rememberMe = value!);
                                },
                                activeColor: PrimaryColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text("Remember me"),
                            ],
                          ),
                          MaterialButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (c) => ForgetPassword(),
                                ),
                              );
                            },
                            child: Text(
                              "Forget Password?",
                              style: TextStyle(
                                fontSize: 12,
                                color: PrimaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: PrimaryColor,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          if (!validationInputs() || isLoading) return;

                          setState(() {
                            isLoading = true;
                          });

                          final result = await loginRequest();
                          if (result["success"] == true) {
                            token = result["data"]["accessToken"];
                            await saveRememberMe(rememberMe);
                            await saveToken(token!);

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (c) => Home()),
                            );
                          } else {
                            showSnackBar(
                              context: context,
                              message:
                                  "The email or password you entered is incorrect. Please check your credentials and try again.",
                              isError: true,
                            );
                          }

                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                      Gap(10),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Text(
                            " Or login with Google ",
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
                            "Don't have Account? ",
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
                                MaterialPageRoute(builder: (c) => Signup()),
                              );
                            },
                            child: Text(
                              "Signup",
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
