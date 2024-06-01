import 'package:get/get.dart';
import 'package:password_manager/model/user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class CurrentUser extends GetxController {
  final Rx<User> _currentUser = User(0, '', '', '').obs;
  User get user => _currentUser.value;
  getUserInfo() async {
    User? getUserInfoFromLocalStorage = await RememberUserPrefs.readUserInfo();
    _currentUser.value = getUserInfoFromLocalStorage!;
  }
}
