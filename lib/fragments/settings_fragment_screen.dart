import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class SettingsFragmentScreen extends StatelessWidget {
  final CurrentUser _currentUser = Get.put(CurrentUser());

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
      await RememberUserPrefs.removeUserInfo().then((value) {
        Get.off(LoginScreen());
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(32),
      children: [
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.person, _currentUser.user.user_name),
        const SizedBox(
          height: 20,
        ),
        userInfoItemProfile(Icons.email, _currentUser.user.user_email),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Material(
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
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
