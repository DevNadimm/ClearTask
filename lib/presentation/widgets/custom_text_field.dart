import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    required this.validationLabel,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
  });

  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool isRequired;
  final String? suffixText;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String validationLabel;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.primaryFontColor,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(color: context.primaryFontColor),
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: effectiveHint,
            hintStyle: GoogleFonts.poppins(color: context.secondaryFontColor),
            suffixText: suffixText,
            border: const OutlineInputBorder(),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          obscureText: obscureText,
          onChanged: onChanged,
          validator: isRequired
              ? validator ??
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${validationLabel[0].toUpperCase()}${validationLabel.substring(1).toLowerCase()} is required';
                    }
                    return null;
                  }
              : null,
        ),
      ],
    );
  }
}
