import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Custom_TextFiled.dart'; 
import 'package:yaqood/Widgets/Primary_color.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.userData,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String? _selectedDob;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userData?['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userData?['lastName'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData?['phoneNumber'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData?['email'] ?? '',
    );

    final rawDob = widget.userData?['dob']?.toString();

    if (rawDob == null || rawDob.isEmpty || rawDob.startsWith('0000')) {
      _selectedDob = null;
    } else {
      try {
        final date = DateTime.parse(rawDob);
        _selectedDob =
            "${date.year.toString().padLeft(4, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')}";
      } catch (_) {
        _selectedDob = rawDob.split(' ').first;
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: PrimaryColor)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 800));

    widget.onProfileUpdated({
      ...widget.userData ?? {},
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text,
      'dob': _selectedDob,
    });

    setState(() => _isSaving = false);
    if (mounted) {
      showSnackBar(
        context: context,
        message: 'Profile updated successfully!',
        isError: false,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = widget.userData?['firstName'] ?? '';
    final String? imageUrl = widget.userData?['imageUrl'];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
            child: _isSaving
                ? Center(child: CircularProgressIndicator(color: PrimaryColor))
                : SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
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
                                'My Profile',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                          
                          const Gap(20),

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(150),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: PrimaryColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: imageUrl != null && imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  firstName.isNotEmpty
                                                      ? firstName[0].toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: PrimaryColor,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {},
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: PrimaryColor,
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Gap(30),

                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextfiled(
                                        formController: _firstNameController,
                                        hintText: "First Name",
                                      ),
                                    ),
                                    const Gap(12), 
                                    Expanded(
                                      child: CustomTextfiled(
                                        formController: _lastNameController,
                                        hintText: "Last Name",
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                CustomTextfiled(
                                  formController: _phoneController,
                                  hintText: "Phone Number",
                                  prefixIcon: Icons.phone_android_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const Gap(16),
                                CustomTextfiled(
                                  formController: _emailController,
                                  hintText: "Email Address",
                                  prefixIcon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: false,
                                ),
                                const Gap(16),

                                InkWell(
                                  onTap: _pickDate,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          color: Colors.grey[400],
                                          size: 22,
                                        ),
                                        const Gap(12),
                                        Text(
                                          _selectedDob ?? "Select your birth date",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedDob == null
                                                ? Colors.grey[400]
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Gap(32),

                                MaterialButton(
                                  color: PrimaryColor,
                                  minWidth: double.infinity,
                                  height: 48,
                                  elevation: 0,
                                  highlightElevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: _saveProfile,
                                  child: const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}