import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  String? clientId = Platform.isIOS ? dotenv.env["GOOGLE_SERVER_IOS_ID"] : dotenv.env["GOOGLE_SERVER_ANDROID_ID"] ;
  String? serverClientId = dotenv.env["GOOGLE_SERVER_CLIENT_ID"];

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
      Uri.parse("${dotenv.env["API_BASE_URL"]}/auth/login"),
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

  // Google Signin
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        await sendIdToken(idToken);
      }
    } catch (e) {
      showSnackBar(context: context, message: "$e");
    }
  }

  // Send idToken To Backend
  Future<void> sendIdToken(String idToken) async {
    final response = await post(
      Uri.parse("${dotenv.env["API_BASE_URL"]}/auth/google"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"idToken": idToken}),
    );

    print(response);
  }

  @override
  void initState() {
    super.initState();

    GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
      clientId: clientId,
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

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

                                CustomText(text: "Login"),

                                Text(
                                  "Enter your email and password to log in",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),

                                Gap(24),

                                CustomTextfiled(
                                  hintText: "Email",
                                  suffixIcon: Icons.email_outlined,
                                  formController: email,
                                ),
                                Gap(10),

                                CustomPasswordFiled(
                                  hintText: "Password",
                                  passwordController: password,
                                ),

                                Gap(10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: rememberMe,

                                          onChanged: (value) {
                                            setState(() => rememberMe = value!);
                                          },
                                          activeColor: PrimaryColor,

                                          side: BorderSide(
                                            color: Colors.grey,
                                            width: 2,
                                          ),

                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        Text(
                                          "Remember me",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
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
                                          fontSize: 14,
                                          color: PrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Gap(10),

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
                                    if (!validationInputs() || isLoading)
                                      return;

                                    setState(() {
                                      isLoading = true;
                                    });

                                    final result = await loginRequest();
                                    if (result["success"] == true) {
                                      token = result["data"]["accessToken"];
                                      await saveRememberMe(rememberMe);
                                      if (rememberMe) {
                                        await saveToken(token!);
                                      }

                                      if (!mounted) return;

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => Home(),
                                        ),
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

                                Gap(24),

                                Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Text(
                                      "   Or login with Google   ",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
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
                                    await signInWithGoogle();
                                  },
                                  child: Text(
                                    "Continue with Google",
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
                                      "Don't have Account? ",
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => Signup(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Signup",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
    );
  }
}
