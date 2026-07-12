import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Primary_color.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>)? onProfileUpdated;

  const SettingsScreen({super.key, this.userData, this.onProfileUpdated});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final String _selectedLanguage = "English";
  double _defaultAC = 22.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD9ECFF), Color(0xFFCFE5FF), Color(0xFFE9E3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Gap(24),

                  _buildSectionTitle("Account & Security"),
                  const Gap(10),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: "Change Email",
                        subtitle:
                            widget.userData?['email'] ??
                            "Update your email address",
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 45),
                      _buildSettingsTile(
                        icon: Icons.lock_open_rounded,
                        title: "Change Password",
                        subtitle: "Update your login password",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const Gap(24),

                  _buildSectionTitle("Autonomous Ride Preferences"),
                  const Gap(10),
                  _buildSettingsCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.ac_unit_rounded,
                                  color: PrimaryColor,
                                  size: 22,
                                ),
                                const Gap(12),
                                const Expanded(
                                  child: Text(
                                    "Default Vehicle AC",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${_defaultAC.toInt()}°C",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: PrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            SizedBox(
                              width: double.infinity,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  trackShape: _CustomTrackShape(),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: Slider(
                                  value: _defaultAC,
                                  min: 18,
                                  max: 28,
                                  activeColor: PrimaryColor,
                                  inactiveColor: PrimaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  onChanged: (val) {
                                    setState(() => _defaultAC = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),

                  _buildSectionTitle("App Settings"),
                  const Gap(10),
                  _buildSettingsCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: PrimaryColor,
                                  size: 22,
                                ),
                                const Gap(12),
                                const Text(
                                  "Push Notifications",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _notificationsEnabled,
                              activeThumbColor: PrimaryColor,
                              onChanged: (val) {
                                setState(() => _notificationsEnabled = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 45),
                      _buildSettingsTile(
                        icon: Icons.language_rounded,
                        title: "App Language",
                        subtitle: _selectedLanguage,
                        onTap: () {
                          // عرض قائمة اختيار اللغة الافتراضية
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: PrimaryColor, size: 22),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class PadlessSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
