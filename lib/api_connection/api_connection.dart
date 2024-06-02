class API {
  static const hostConnect = "http://192.168.1.112/api_password_manager";
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectPassword = "$hostConnect/password";

  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";

  static const addPassword = "$hostConnectPassword/add.php";
}
