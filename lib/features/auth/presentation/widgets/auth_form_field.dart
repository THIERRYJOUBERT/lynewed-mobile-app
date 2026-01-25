/// Reusable form field widget for authentication pages.
///
/// Provides a consistent styled text field with:
/// - Optional label above the field
/// - Hint text
/// - Password visibility toggle
/// - Validation support
/// - Suffix icon support
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// A styled form field for authentication pages.
///
/// Example usage:
/// ```dart
/// AuthFormField(
///   controller: _emailController,
///   label: 'Email',
///   hint: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
/// )
/// ```
class AuthFormField extends StatefulWidget {
  /// Creates an auth form field.
  const AuthFormField({
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofillHints,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The label displayed above the text field.
  final String? label;

  /// The hint text displayed inside the text field.
  final String? hint;

  /// Whether to obscure the text (for passwords).
  ///
  /// When true, a visibility toggle icon is automatically added.
  final bool obscureText;

  /// A suffix icon to display at the end of the text field.
  ///
  /// Note: If [obscureText] is true, a visibility toggle will be shown instead.
  final Widget? suffixIcon;

  /// Validator function for the form field.
  final String? Function(String?)? validator;

  /// The keyboard type for the text field.
  final TextInputType? keyboardType;

  /// The action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Callback when the user submits the field.
  final void Function(String)? onFieldSubmitted;

  /// Focus node for this field.
  final FocusNode? focusNode;

  /// Autofill hints for the field.
  final Iterable<String>? autofillHints;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: LynewedTextStyles.sectionTitle,
          ),
          SizedBox(height: LynewedSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          autofillHints: widget.autofillHints,
          style: LynewedTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: LynewedTextStyles.inputHint,
            filled: true,
            fillColor: LynewedColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: LynewedColors.border,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: LynewedColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: LynewedColors.error),
            ),
            suffixIcon: _buildSuffixIcon(),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // If obscureText is enabled, show visibility toggle
    if (widget.obscureText) {
      return GestureDetector(
        onTap: _toggleObscureText,
        child: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: LynewedColors.gray100,
          size: 20,
        ),
      );
    }
    // Otherwise return the provided suffix icon
    return widget.suffixIcon;
  }
}
