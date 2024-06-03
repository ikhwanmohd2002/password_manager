class API {
  static const hostConnect = "http://172.20.10.2/api_password_manager";
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectPassword = "$hostConnect/password";

  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";

  static const addPassword = "$hostConnectPassword/add.php";
  static const editPassword = "$hostConnectPassword/edit.php";
  static const readPassword = "$hostConnectPassword/read.php";
  static const deletePassword = "$hostConnectPassword/delete.php";
  static const updatePasswordRetrieved =
      "$hostConnectPassword/update_last_retrieved.php";
}
