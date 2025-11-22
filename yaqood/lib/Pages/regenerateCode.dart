import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:yaqood/Widgets/Custom_Text.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class Regeneratecode extends StatefulWidget {
  const Regeneratecode({super.key});

  @override
  State<Regeneratecode> createState() => _Regeneratecode();
}

class _Regeneratecode extends State<Regeneratecode> {
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
                      onPressed: () {},
                      child: Text(
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
