// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/controllers/navigation_controller.dart';
import 'package:password_manager/fragments/file_fragment_screen.dart';
import 'package:password_manager/fragments/home_fragment_screen.dart';
import 'package:password_manager/fragments/password_fragment_screen.dart';
import 'package:password_manager/fragments/settings_fragment_screen.dart';
import 'package:password_manager/fragments/team_fragment_screen.dart';
import 'package:password_manager/fragments/vault_fragment_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';

// ignore: must_be_immutable
class DashboardOfFragments extends StatelessWidget {
  final CurrentUser _rememberCurrentUser = Get.put(CurrentUser());
  final NavigationController navController = Get.put(NavigationController());
  final List<Widget> _fragmentScreens = [
    const Home1FragmentScreen(),
    File1FragmentScreen(),
    const Vault1FragmentScreen(),
    const TeamsInfoFragmentScreen(),
    const PasswordFragmentScreen(),
    const SettingsFragmentScreen(),
  ];
  final List _navigationButtonsProperties = [
    {
      "active_icon": Icons.lock,
      "non_active_icon": Icons.lock_outline,
      "label": "Item", // Represents stored passwords
    },
    {
      "active_icon": Icons.folder,
      "non_active_icon": Icons.folder_open_outlined,
      "label": "File", // Represents files and folders
    },
    {
      "active_icon": Icons.shield_rounded,
      "non_active_icon": Icons.shield_outlined,
      "label": "Vault", // Represents vault/security features
    },
    {
      "active_icon": Icons.group,
      "non_active_icon": Icons.group_outlined,
      "label": "Team", // Represents team collaboration
    },
    {
      "active_icon": Icons.widgets_rounded,
      "non_active_icon": Icons.widgets_outlined,
      "label": "Misc", // Represents miscellaneous items
    },
    {
      "active_icon": Icons.tune_rounded,
      "non_active_icon": Icons.tune_outlined,
      "label": "Setting", // Represents settings/preferences
    },
  ];

  @override
  Widget build(BuildContext context) {
    int lastValidIndex = 0; // Initialize to the first index as default
    return GetBuilder(
      init: CurrentUser(),
      initState: (currentState) {
        _rememberCurrentUser.getUserInfo();
        _rememberCurrentUser.getToken();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Obx(() {
              if (navController.indexNumber.value >= 0 &&
                  navController.indexNumber.value < _fragmentScreens.length) {
                return _fragmentScreens[navController.indexNumber.value];
              } else {
                return const Center(child: Text("Invalid screen index"));
              }
            }),
          ),
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              currentIndex: (navController.indexNumber.value >= 0 &&
                      navController.indexNumber.value <
                          _navigationButtonsProperties.length)
                  ? (lastValidIndex = navController
                      .indexNumber.value) // Update last valid index
                  : lastValidIndex, // Use last valid index if out of bounds
              onTap: (value) {
                if (value < _navigationButtonsProperties.length) {
                  navController.navigateToFragment(value);
                }
              },
              backgroundColor: Colors.white, // Set background color to white
              selectedItemColor: Colors.blue, // Set color for the selected item
              unselectedItemColor:
                  Colors.grey, // Set color for unselected items
              showSelectedLabels: true, // Show labels for selected items
              showUnselectedLabels: true, // Show labels for unselected items
              items:
                  List.generate(_navigationButtonsProperties.length, (index) {
                var navBtnProperty = _navigationButtonsProperties[index];
                return BottomNavigationBarItem(
                  icon: Icon(
                    navBtnProperty["non_active_icon"],
                  ),
                  activeIcon: Icon(navBtnProperty["active_icon"]),
                  label: (navBtnProperty["label"]),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
