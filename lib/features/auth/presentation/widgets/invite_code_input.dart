/// Widget for entering wedding invitation codes.
///
/// Provides a formatted text input for 8-character invitation codes
/// with automatic uppercase conversion and visual feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/design.dart';

/// Input field for wedding invitation codes.
///
/// Features:
/// - Auto uppercase conversion
/// - 8 character limit
/// - Alphanumeric only
/// - Visual helper text for character count
/// - Centered, large text for easy reading
class InviteCodeInput extends StatelessWidget {
  /// Creates an invite code input field.
  const InviteCodeInput({
    required this.controller,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  /// Controller for the text field.
  final TextEditingController controller;

  /// Callback when the code changes.
  final ValueChanged<String>? onChanged;

  /// Error text to display below the input.
  final String? errorText;

  /// Whether the input is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          maxLength: 8,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            _UpperCaseTextFormatter(),
          ],
          style: LynewedTextStyles.displaySmall.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '_ _ _ _ _ _ _ _',
            hintStyle: LynewedTextStyles.displaySmall.copyWith(
              letterSpacing: 8,
              fontWeight: FontWeight.w300,
              color: LynewedColors.gray300,
            ),
            counterText: '', // Hide the default counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
              borderSide: BorderSide(color: LynewedColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
              borderSide: BorderSide(color: LynewedColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
              borderSide: BorderSide(color: LynewedColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LynewedSpacing.md),
              borderSide: BorderSide(color: LynewedColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.lg,
              vertical: LynewedSpacing.xl,
            ),
          ),
          onChanged: onChanged,
        ),
        SizedBox(height: LynewedSpacing.sm),
        // Helper or error text
        _HelperText(
          characterCount: controller.text.length,
          errorText: errorText,
        ),
      ],
    );
  }
}

/// Text formatter that converts input to uppercase.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Helper text widget showing character count or error.
class _HelperText extends StatelessWidget {
  const _HelperText({
    required this.characterCount,
    this.errorText,
  });

  final int characterCount;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    if (errorText != null) {
      return Text(
        errorText!,
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.error,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (characterCount < 8) {
      return Text(
        '8 characters required ($characterCount/8)',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      'Code complete ✓',
      style: LynewedTextStyles.bodySmall.copyWith(
        color: LynewedColors.success,
      ),
      textAlign: TextAlign.center,
    );
  }
}
