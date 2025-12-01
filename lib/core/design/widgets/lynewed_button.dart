import 'package:flutter/material.dart';
import '../design.dart';

enum LynewedButtonType {
  primary,    // Black background, white text
  secondary,  // Transparent background, border
  ghost,      // Text only, no background/border
  destructive // Red text, ghost style usually
}

class LynewedButton extends StatelessWidget {
  const LynewedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = LynewedButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final LynewedButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final style = _getButtonStyle();
    final textStyle = _getTextStyle();

    Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == LynewedButtonType.primary ? Colors.white : LynewedColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: textStyle.color),
                const SizedBox(width: 8),
              ],
              Text(text, style: textStyle),
            ],
          );

    Widget button;
    
    switch (type) {
      case LynewedButtonType.primary:
        button = ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: content,
        );
        break;
      case LynewedButtonType.secondary:
        button = OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: content,
        );
        break;
      case LynewedButtonType.ghost:
      case LynewedButtonType.destructive:
        button = TextButton(
          onPressed: onPressed,
          style: style,
          child: content,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, height: LynewedSpacing.buttonHeight, child: button);
    }

    return SizedBox(height: LynewedSpacing.buttonHeight, child: button);
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case LynewedButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: LynewedColors.primary,
          foregroundColor: LynewedColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Square buttons as requested
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        );
      case LynewedButtonType.secondary:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: LynewedColors.textPrimary,
          side: const BorderSide(color: LynewedColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        );
      case LynewedButtonType.ghost:
        return TextButton.styleFrom(
          foregroundColor: LynewedColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
      case LynewedButtonType.destructive:
        return TextButton.styleFrom(
          foregroundColor: LynewedColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (type) {
      case LynewedButtonType.primary:
        return LynewedTextStyles.bodyMedium.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: LynewedColors.textOnPrimary,
        );
      case LynewedButtonType.secondary:
      case LynewedButtonType.ghost:
        return LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w400);
      case LynewedButtonType.destructive:
        return LynewedTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: LynewedColors.error,
        );
    }
  }
}
