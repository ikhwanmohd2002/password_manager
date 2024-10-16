import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/shared_fragment_screen.dart';
import 'package:password_manager/fragments/home_fragment_screen.dart';
import 'package:password_manager/fragments/security_fragment_screen.dart';
import 'package:password_manager/fragments/alert_fragment_screen.dart';
import 'package:password_manager/fragments/settings_fragment_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';

class DashboardOfFragments extends StatelessWidget {
  CurrentUser _rememberCurrentUser = Get.put(CurrentUser());
  final List<Widget> _fragmentScreens = [
    HomeFragmentScreen(),
    SharedFragmentScreen(),
    SecurityFragmentScreen(),
    AlertFragmentScreen(),
    SettingsFragmentScreen(),
  ];
  final List _navigationButtonsProperties = [
    {
      "active_icon": Icons.lock_open,
      "non_active_icon": Icons.lock,
      "label": "Vault"
    },
    {
      "active_icon": Icons.folder_shared,
      "non_active_icon": Icons.folder_shared_outlined,
      "label": "Shared"
    },
    {
      "active_icon": Icons.shield,
      "non_active_icon": Icons.shield_outlined,
      "label": "Security"
    },
    {
      "active_icon": Icons.notifications_active,
      "non_active_icon": Icons.notifications_outlined,
      "label": "Alerts"
    },
    {
      "active_icon": Icons.settings,
      "non_active_icon": Icons.settings_outlined,
      "label": "Settings"
    },
  ];

  RxInt _indexNumber = 0.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CurrentUser(),
      initState: (currentState) {
        _rememberCurrentUser.getUserInfo();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body:
              SafeArea(child: Obx(() => _fragmentScreens[_indexNumber.value])),
          bottomNavigationBar: Obx(() => BottomNavigationBar(
                currentIndex: _indexNumber.value,
                onTap: (value) {
                  _indexNumber.value = value;
                },
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white24,
                items: List.generate(5, (index) {
                  var navBtnProperty = _navigationButtonsProperties[index];
                  return BottomNavigationBarItem(
                      backgroundColor: primary1Color,
                      icon: Icon(
                        navBtnProperty["non_active_icon"],
                      ),
                      activeIcon: Icon(navBtnProperty["active_icon"]),
                      label: (navBtnProperty["label"]));
                }),
              )),
        );
      },
    );
  }
}
