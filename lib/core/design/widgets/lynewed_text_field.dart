import 'package:flutter/material.dart';
import '../design.dart';

class LynewedTextField extends StatelessWidget {
  const LynewedTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.isValueInput = false, // If true, transparent bg + border. If false, grey bg + no border.
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isValueInput;

  @override
  Widget build(BuildContext context) {
    // Base style: Address Search style (Grey bg, no visible border unless error)
    // Value Input style: Transparent bg, border (for budget, etc.)
    
    final fillColor = isValueInput 
        ? Colors.transparent 
        : (enabled ? const Color(0xFFF2F2F2) : const Color(0xFFE8E8E8)); // Matches AddressSearch

    final borderSide = isValueInput
        ? const BorderSide(color: LynewedColors.gray200)
        : BorderSide.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: LynewedTextStyles.inputHint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: borderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: borderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: isValueInput 
                  ? const BorderSide(color: LynewedColors.textPrimary, width: 1)
                  : const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: LynewedColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
