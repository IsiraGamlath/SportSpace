import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

class ManagerTextField extends StatelessWidget {
  const ManagerTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    this.keyboardType,
    this.suffix,
    this.hintText,
  });

  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: ManagerColors.white,
        style: const TextStyle(
          color: ManagerColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: ManagerColors.inputBackground,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: ManagerColors.inputBorder,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: ManagerColors.inputFocusedBorder,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
