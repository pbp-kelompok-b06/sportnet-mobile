import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final IconData? icon;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],

        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            
            // Styling Border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: Color(0xFFFF7F50), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}