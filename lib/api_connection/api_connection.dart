class API {
  static const hostConnect = "http://192.168.1.100/api_password_manager";
  static const hostConnectUser = "$hostConnect/user";

  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";
}
