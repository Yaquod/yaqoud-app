import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaqood/Pages/Login.dart';
import 'package:yaqood/Pages/profile_screen.dart';
import 'package:yaqood/Pages/settings_screen.dart';
import 'package:yaqood/Pages/wallet_screen.dart';
import 'package:yaqood/Pages/trip_history_screen.dart';
import 'package:yaqood/Widgets/Custom_ListTile.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

Future<void> logout(BuildContext context) async {
  Navigator.pop(context);

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
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const AppDrawer({
    super.key,
    required this.userData,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final String firstName = userData?['firstName'] ?? '';
    final String lastName = userData?['lastName'] ?? '';
    final String fullName = '$firstName $lastName'.trim().isEmpty
        ? 'Yaqood User'
        : '$firstName $lastName'.trim();

    final String email = userData?['email'] ?? '';
    final String? imageUrl = userData?['imageUrl'];

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: PrimaryColor.withValues(alpha: 0.06),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ProfileScreen(
                          userData: userData,
                          onProfileUpdated: onProfileUpdated,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: PrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      firstName.isNotEmpty
                                          ? firstName[0].toUpperCase()
                                          : 'Y',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: PrimaryColor,
                                      ),
                                    ),
                                  ),
                            ),
                          )
                        : Center(
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'Y',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: PrimaryColor,
                              ),
                            ),
                          ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Gap(8),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                CustomListTile(
                  title: "Home",
                  icon: Icons.home_outlined,
                  onTap: () => Navigator.pop(context),
                ),
                const Gap(8),

                CustomListTile(
                  title: "Cards",
                  icon: Icons.credit_card_rounded,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const WalletScreen()),
                    );
                  },
                ),
                const Gap(8),

                CustomListTile(
                  title: "My Profile",
                  icon: Icons.person_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ProfileScreen(
                          userData: userData,
                          onProfileUpdated: onProfileUpdated,
                        ),
                      ),
                    );
                  },
                ),
                const Gap(8),

                CustomListTile(
                  title: "Rides History",
                  icon: Icons.history_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const TripHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Gap(8),
                CustomListTile(
                  title: "Notifications",
                  icon: Icons.notifications_none_rounded,
                  onTap: () {},
                ),
                const Gap(8),
                CustomListTile(
                  title: "Settings",
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => SettingsScreen(
                          userData: userData,
                          onProfileUpdated: onProfileUpdated,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade100, height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(iconTheme: IconThemeData(color: Colors.red.shade600)),
              child: CustomListTile(
                title: "Logout",
                icon: Icons.logout_rounded,
                onTap: () => logout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
