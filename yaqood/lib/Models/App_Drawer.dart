import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Widgets/Custom_ListTile.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("rememberMe");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 270,
              color: PrimaryColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),

                    Gap(15),

                    Text(
                      "User Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    Gap(15),

                    Container(
                      width: 128,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Cash",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          Text("2000\$"),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xffC1C0C9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomListTile(title: "Home", icon: Icons.home, onTap: () {}),

                  Gap(10),

                  CustomListTile(
                    title: "My Wallet",
                    icon: Icons.wallet_rounded,
                    onTap: () {},
                  ),

                  Gap(10),

                  CustomListTile(
                    title: "History",
                    icon: Icons.history_outlined,
                    onTap: () {},
                  ),

                  Gap(10),

                  CustomListTile(
                    title: "Notifications",
                    icon: Icons.notifications,
                    onTap: () {},
                  ),

                  Gap(10),

                  CustomListTile(
                    title: "Invite Friends",
                    icon: Icons.card_giftcard_rounded,
                    onTap: () {},
                  ),

                  Gap(10),

                  CustomListTile(
                    title: "Settings",
                    icon: Icons.settings,
                    onTap: () {},
                  ),

                  Gap(10),

                  CustomListTile(
                    title: "Logout",
                    icon: Icons.logout,
                    onTap: () {
                      logout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )
      ;
  }
}