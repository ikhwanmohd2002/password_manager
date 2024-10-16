import 'package:flutter/material.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

var primary1Color = Color(0xffF86668);
var primary2Color = Color(0xffF2167B);

enum CustomPassStrength implements PasswordStrengthItem {
  weak,
  medium,
  strong,
  secure;

  @override
  Color get statusColor {
    switch (this) {
      case CustomPassStrength.weak:
        return Colors.red;
      case CustomPassStrength.medium:
        return Colors.orange;
      case CustomPassStrength.strong:
        return Colors.green;
      case CustomPassStrength.secure:
        return const Color.fromARGB(255, 14, 102, 17);
    }
  }

  @override
  Widget? get statusWidget {
    switch (this) {
      case CustomPassStrength.weak:
        return const Text('Weak');
      case CustomPassStrength.medium:
        return const Text('Medium');
      case CustomPassStrength.strong:
        return const Text('Strong');
      case CustomPassStrength.secure:
        return const Text('Secure');
      default:
        return null;
    }
  }

  @override
  double get widthPerc {
    switch (this) {
      case CustomPassStrength.weak:
        return 0.15;
      case CustomPassStrength.medium:
        return 0.4;
      case CustomPassStrength.strong:
        return 0.75;
      case CustomPassStrength.secure:
        return 1.00;
      default:
        return 0.0;
    }
  }

  static String get instructions {
    return 'Enter a password that contains:\n\n'
        '• At least 8 characters\n'
        '• At least 1 lowercase letter\n'
        '• At least 1 uppercase letter\n'
        '• At least 1 digit\n'
        '• At least 1 special character';
  }

  static CustomPassStrength? calculate({required String text}) {
    // Implement your custom logic here
    if (text.isEmpty) {
      return null;
    }
    // Use the [commonDictionary] to see if a password
    // is in 10,000 common exposed password list.
    if (commonDictionary[text] == true) {
      return CustomPassStrength.weak;
    }

    if (text.length < 8) {
      return CustomPassStrength.weak;
    }

    var counter = 0;
    if (text.contains(RegExp(r'[a-z]'))) counter++;
    if (text.contains(RegExp(r'[A-Z]'))) counter++;
    if (text.contains(RegExp(r'[0-9]'))) counter++;
    if (text.contains(RegExp(r'[!@#\$%&*()?£\-_=]'))) counter++;

    switch (counter) {
      case 1:
        return CustomPassStrength.weak;
      case 2:
        return CustomPassStrength.medium;
      case 3:
        return CustomPassStrength.strong;
      case 4:
        return CustomPassStrength.secure;
      default:
        return CustomPassStrength.weak;
    }
  }
}
