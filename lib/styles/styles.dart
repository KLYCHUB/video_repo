import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Colors.black;
  static const Color black38 = Colors.black38;
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFDF0D0B);
  static const Color lightRed = Color(0xFFfce2e2);
  static const Color white = Colors.white;
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 24,
    color: AppColors.black,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hintStyle = TextStyle(
    color: AppColors.black38,
  );

  static const TextStyle modalTitle = TextStyle(
    fontSize: 18,
    color: AppColors.black,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle modalButtonText = TextStyle(
    fontSize: 16,
    color: AppColors.white,
  );

  static const TextStyle selectVideoText = TextStyle(
    fontSize: 16,
    color: AppColors.red,
    fontWeight: FontWeight.bold,
  );
}
