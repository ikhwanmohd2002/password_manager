import 'dart:convert';

import 'package:password_manager/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberUserPrefs {
  static Future<void> storeUserInfo(User userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);
  }

  static Future<void> storeToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("token", token);
  }

  static Future<User?> readUserInfo() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser");
    if (userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo = User.fromJson(userDataMap);
    }

    return currentUserInfo;
  }

  static Future<String?> readToken() async {
    String? currentToken;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    currentToken = token;
    return currentToken;
  }

  static Future<User?> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
  }

  static Future<User?> removeToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("token");
  }
}
