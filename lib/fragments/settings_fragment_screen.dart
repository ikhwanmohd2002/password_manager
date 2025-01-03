import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/controllers/navigation_controller.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;
import 'package:password_strength_checker/password_strength_checker.dart';

class SettingsFragmentScreen extends StatefulWidget {
  const SettingsFragmentScreen({super.key});

  @override
  State<SettingsFragmentScreen> createState() => _SettingsFragmentScreenState();
}

class _SettingsFragmentScreenState extends State<SettingsFragmentScreen> {
  final NavigationController navController = Get.find();
  // ignore: prefer_final_fields
  CurrentUser _currentUser = Get.put(CurrentUser());
  var formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final passNotifier1 = ValueNotifier<CustomPassStrength?>(null);

  signOutUser() async {
    var resultResponse = await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Are you sure you want to logout from the app?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Logout Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back(result: "loggedOut");
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (resultResponse == "loggedOut") {
      await RememberUserPrefs.removeToken();
      navController.resetIndexNumber();
      _currentUser.reset();
      await RememberUserPrefs.removeUserInfo().then((value) {
        // Show success SnackBar
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("You have successfully logged out."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to LoginScreen
        Get.offAll(const LoginScreen());
      });
    }
  }

  changePassword() async {
    try {
      await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.password, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // New Password Field
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    onChanged: (value) {
                      passNotifier1.value =
                          CustomPassStrength.calculate(text: value);
                    },
                    validator: (value) {
                      if (value == "") {
                        return "Please write a new password";
                      } else if (CustomPassStrength.calculate(text: value!) ==
                              CustomPassStrength.weak ||
                          CustomPassStrength.calculate(text: value) ==
                              CustomPassStrength.medium) {
                        return "Please enter at least a strong password";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "New Password",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password Field
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == "") {
                        return "Please confirm your password";
                      } else if (value !=
                          newPasswordController.text.toString().trim()) {
                        return "Passwords do not match";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password Strength Checker
                  PasswordStrengthChecker(
                    strength: passNotifier1,
                  ),

                  // Instructions
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        CustomPassStrength.instructions,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                newPasswordController.clear();
                confirmPasswordController.clear();
                passNotifier1.value = CustomPassStrength.calculate(text: "");
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),

            // Confirm Button
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await changingPassword(
                    newPasswordController.text.toString().trim(),
                    confirmPasswordController.text.toString().trim(),
                  );

                  passNotifier1.value = CustomPassStrength.calculate(text: "");
                  newPasswordController.clear();
                  confirmPasswordController.clear();

                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  changingPassword(String newPassword, String confirmPassword) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse(API.changePasswordIntelliVault),
        headers: {
          'Authorization': 'Token $token',
        },
        body: {
          "new_password1": newPassword,
          "new_password2": confirmPassword,
        },
      );

      if (res.statusCode == 200) {
        // Show success SnackBar
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("New password saved successfully."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Show error SnackBar
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error saving password. Please try again."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (errorMsg) {
      // Show error SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${errorMsg.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
        backgroundColor: primary1Color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Information Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 20,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentUser.user.username,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentUser.user.email,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.perm_identity, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            "User ID: ${_currentUser.user.id}", // Hardcoded User ID
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    changePassword();
                  },
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text("Change Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    signOutUser();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
