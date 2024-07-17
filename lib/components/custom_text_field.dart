import 'package:flutter/material.dart';
import 'package:video_repo/styles/styles.dart';
import 'package:video_repo/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Icon? icon;
  final TextEditingController? controller;

  const CustomTextField(
      {required this.hintText, super.key, required this.icon, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.hintStyle,
        filled: true,
        fillColor: AppColors.lightGray,
        suffixIcon: icon,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(AppBorders.radius),
        ),
      ),
    );
  }
}
