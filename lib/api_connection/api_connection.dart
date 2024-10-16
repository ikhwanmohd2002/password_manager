class API {
  static const hostConnect = "http://192.168.1.118/api_password_manager";
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectPassword = "$hostConnect/password";
  static const hostConnectSharedPassword = "$hostConnect/shared_password";
  static const hostConnectAlert = "$hostConnect/alert";

  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";

  static const addPassword = "$hostConnectPassword/add.php";
  static const editPassword = "$hostConnectPassword/edit.php";
  static const readPassword = "$hostConnectPassword/read.php";
  static const deletePassword = "$hostConnectPassword/delete.php";
  static const updatePasswordRetrieved =
      "$hostConnectPassword/update_last_retrieved.php";

  static const addSharedPassword = "$hostConnectSharedPassword/add.php";
  static const readSharedPassword = "$hostConnectSharedPassword/read.php";
  static const deleteSharedPassword = "$hostConnectSharedPassword/delete.php";
  static const validateSharedPasswordEmail =
      "$hostConnectSharedPassword/validate_email.php";
  static const getPendingSharedPassword =
      "$hostConnectSharedPassword/get_pending.php";
  static const updateRequest = "$hostConnectSharedPassword/update_request.php";

  static const addAlert = "$hostConnectAlert/add.php";
  static const readAlert = "$hostConnectAlert/read.php";
  static const updateAlert = "$hostConnectAlert/update.php";

  static const hostConnectAPI = "http://192.168.1.127:8000/api";
  static const hostConnectUserAPI = "$hostConnectAPI/user";
}
