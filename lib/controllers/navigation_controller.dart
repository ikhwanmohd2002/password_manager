import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/fragments/file_fragment_screen.dart';
import 'package:password_manager/fragments/home_fragment_screen.dart';
import 'package:password_manager/fragments/password_fragment_screen.dart';
import 'package:password_manager/fragments/settings_fragment_screen.dart';
import 'package:password_manager/fragments/team_fragment_screen.dart';
import 'package:password_manager/fragments/vault_fragment_screen.dart';

class NavigationController extends GetxController {
  RxInt indexNumber = 0.obs;

  void navigateToFragment(int index, {dynamic arguments}) {
    if (index >= 0 && index < _fragmentScreens.length) {
      print("Navigating to fragment: $index with arguments: $arguments");
      // Logic to pass arguments to the fragment
      indexNumber.value = index; // Update the current fragment index
    } else {
      print("Invalid fragment index: $index");
    }
  }

  void resetIndexNumber() {
    indexNumber.value = 0; // Reset to the default value
    print("Index number reset to: ${indexNumber.value}");
  }

  final List<Widget> _fragmentScreens = [
    const Home1FragmentScreen(),
    File1FragmentScreen(),
    TeamsInfoFragmentScreen(),
    Vault1FragmentScreen(),
    const PasswordFragmentScreen(),
    const SettingsFragmentScreen(),
  ];
}
