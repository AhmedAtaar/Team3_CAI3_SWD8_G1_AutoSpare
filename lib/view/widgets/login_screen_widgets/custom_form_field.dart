import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const CustomFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldTextColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[200] : Colors.grey[800];
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final fillColor = isDark
        ? const Color(0xFF0B1120)
        : const Color(0xFFF5F5F5);
    final borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final focusedBorderCol = const Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText!.isNotEmpty) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(color: fieldTextColor, fontSize: 14),
          cursorColor: focusedBorderCol,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fillColor,
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor, fontSize: 13),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  )
                : null,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: focusedBorderCol, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
