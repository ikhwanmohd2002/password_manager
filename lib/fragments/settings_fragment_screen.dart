import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
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
  final CurrentUser _currentUser = Get.put(CurrentUser());
  var formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final passNotifier1 = ValueNotifier<CustomPassStrength?>(null);

  signOutUser() async {
    var resultResponse = await Get.dialog(AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        "Logout",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: const Text("Are you sure?\nYou want to logout from app?"),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "No",
              style: TextStyle(color: Colors.blue),
            )),
        TextButton(
            onPressed: () {
              Get.back(result: "loggedOut");
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.red),
            ))
      ],
    ));

    if (resultResponse == "loggedOut") {
      await RememberUserPrefs.removeToken();
      await RememberUserPrefs.removeUserInfo().then((value) {
        Get.off(const LoginScreen());
      });
    }
  }

  changePassword() async {
    try {
      await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Change Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: newPasswordController,
                onChanged: (value) {
                  passNotifier1.value =
                      CustomPassStrength.calculate(text: value);
                },
                validator: (value) {
                  if (value == "") {
                    return "Please write new password";
                  } else if (CustomPassStrength.calculate(text: value!) ==
                      CustomPassStrength.weak) {
                    return "Please enter at least strong password";
                  } else if (CustomPassStrength.calculate(text: value) ==
                      CustomPassStrength.medium) {
                    return "Please enter at least strong password";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(hintText: "New Password"),
              ),
              TextFormField(
                controller: confirmPasswordController,
                validator: (value) {
                  if (value == "") {
                    return "Please rewrite password";
                  } else if (value !=
                      newPasswordController.text.toString().trim()) {
                    return "Please repeat password";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(hintText: "Repeat Password"),
              ),
              const SizedBox(
                height: 10,
              ),
              PasswordStrengthChecker(
                strength: passNotifier1,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    CustomPassStrength.instructions,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                newPasswordController.clear();
                confirmPasswordController.clear();
                passNotifier1.value = CustomPassStrength.calculate(text: "");
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    changingPassword(
                        newPasswordController.text.toString().trim(),
                        confirmPasswordController.text.toString().trim());
                    passNotifier1.value =
                        CustomPassStrength.calculate(text: "");
                    newPasswordController.clear();
                    confirmPasswordController.clear();

                    Get.back();
                  });
                }
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.green),
              ))
        ],
      ));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  changingPassword(String new_password, String confirm_password) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(Uri.parse(API.changePasswordIntelliVault),
          headers: {
            'Authorization': 'Token $token'
          },
          body: {
            "new_password1": new_password,
            'new_password2': confirm_password
          });

      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "New password saved");
      } else {
        Fluttertoast.showToast(msg: "Error accesing shared password");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(32),
      children: [
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.person, _currentUser.user.username),
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.email, _currentUser.user.email),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  changePassword();
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "Change Password",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Material(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  signOutUser();
                },
                borderRadius: BorderRadius.circular(32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget userInfoItemProfile(IconData iconData, String userData) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.grey),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 30,
            color: Colors.black,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            userData,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
