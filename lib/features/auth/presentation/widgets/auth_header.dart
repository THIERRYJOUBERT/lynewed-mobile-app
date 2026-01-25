/// Header widget for authentication pages.
///
/// Displays a title, optional subtitle, and optional background image.
/// Used at the top of sign in, sign up, and welcome pages.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// A styled header for authentication pages.
///
/// Example usage:
/// ```dart
/// AuthHeader(
///   title: 'Welcome Back',
///   subtitle: 'Sign in to continue',
/// )
/// ```
class AuthHeader extends StatelessWidget {
  /// Creates an auth header.
  const AuthHeader({
    required this.title,
    this.subtitle,
    this.backgroundImage,
    this.textAlign = TextAlign.left,
    this.useLightText = false,
    super.key,
  });

  /// The main title text.
  final String title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional background image asset path.
  final String? backgroundImage;

  /// Text alignment for the title and subtitle.
  final TextAlign textAlign;

  /// Whether to use light (white) text for dark backgrounds.
  final bool useLightText;

  @override
  Widget build(BuildContext context) {
    final titleColor = useLightText
        ? LynewedColors.textOnDark
        : LynewedColors.textPrimary;
    final subtitleColor = useLightText
        ? LynewedColors.textOnDark.withValues(alpha: 0.8)
        : LynewedColors.textSecondary;

    Widget content = Column(
      crossAxisAlignment: _getCrossAxisAlignment(),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: LynewedTextStyles.headlineLarge.copyWith(
            color: titleColor,
          ),
          textAlign: textAlign,
        ),
        if (subtitle != null) ...[
          SizedBox(height: LynewedSpacing.sm),
          Text(
            subtitle!,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: subtitleColor,
            ),
            textAlign: textAlign,
          ),
        ],
      ],
    );

    // Wrap in container with background image if provided
    if (backgroundImage != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: content,
      );
    }

    return content;
  }

  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (textAlign) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return CrossAxisAlignment.end;
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
        return CrossAxisAlignment.start;
    }
  }
}
