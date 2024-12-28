class API {
  static const hostConnect = "http://192.168.56.1/api_password_manager";
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

  static const hostConnectDjango = "http://192.168.1.132:8000";

  static const testAI = "$hostConnectDjango/api/user/predict_login";

  static const hostConnectIntelliVault = "http://10.0.2.2:8000";
  static const registerIntelliVault =
      "$hostConnectIntelliVault/dj-rest-auth/registration/";
  static const loginIntelliVault =
      "$hostConnectIntelliVault/dj-rest-auth/login/";
  static const changePasswordIntelliVault =
      "$hostConnectIntelliVault/dj-rest-auth/password/change/";
  static const userDetailsIntelliVault =
      "$hostConnectIntelliVault/dj-rest-auth/user/";
  static const passwordInfoIntelliVault =
      "$hostConnectIntelliVault/vault/api/logininfo/";
  static const vaultInfoIntelliVault =
      "$hostConnectIntelliVault/vault/api/vault/";
  static const teamInfoIntelliVault =
      "$hostConnectIntelliVault/collaboration/api/team/";
  static const invitationInfoIntelliVault =
      "$hostConnectIntelliVault/collaboration/invitations/";
  static const invitationSendIntelliVault =
      "$hostConnectIntelliVault/collaboration/team/";
  static const fileInfoIntelliVault =
      "$hostConnectIntelliVault/vault/api/file/";
  static const downloadFileIntelliVault =
      "$hostConnectIntelliVault/vault/file/download/";
  static const sharedPasswordIntelliVault =
      "$hostConnectIntelliVault/vault/access/item/";
  static const sharePasswordIntelliVault =
      "$hostConnectIntelliVault/vault/share/logininfo/";
  static const shareFileIntelliVault =
      "$hostConnectIntelliVault/vault/share/file/";
  static const generatePasswordIntelliVault =
      "$hostConnectIntelliVault/password-management/api/generated-password/";
  static const predictLoginIntelliVault = "$hostConnectIntelliVault/vault/ai/";
  static const predictPhishingIntelliVault =
      "$hostConnectIntelliVault/vault/phishing/";
}
