import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/fragments/file_fragment_screen.dart';
import 'package:password_manager/fragments/home_fragment_screen.dart';
import 'package:password_manager/fragments/password_fragment_screen.dart';
import 'package:password_manager/fragments/settings_fragment_screen.dart';
import 'package:password_manager/fragments/team_fragment_screen.dart';
import 'package:password_manager/fragments/test_fragment_screen.dart';
import 'package:password_manager/fragments/vault_fragment_screen.dart';

class NavigationController extends GetxController {
  RxInt indexNumber = 0.obs;

  void navigateToFragment(int index) {
    if (index >= 0 && index < _fragmentScreens.length) {
      indexNumber.value = index;
    } else {
      print("Invalid fragment index: $index");
    }
  }

  final List<Widget> _fragmentScreens = [
    HomeFragmentScreen(),
    FileFragmentScreen(),
    TeamFragmentScreen(),
    VaultFragmentScreen(),
    PasswordFragmentScreen(),
    SettingsFragmentScreen(),
    Screen1(),
    Screen2(),
  ];
}
