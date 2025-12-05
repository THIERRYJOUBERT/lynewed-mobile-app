/// Reusable info row widget for detail sheets
/// 
/// Design System v2 compliant info row with icon, text, and optional trailing.
/// Used for displaying location, budget, and other key information.
library;

import 'package:flutter/material.dart';
import '../design.dart';
import '/core/utils/budget_formatter.dart';

/// Info row with icon, text, and optional trailing widget
/// 
/// Examples:
/// - Location: 📍 Paris (12km)
/// - Budget: 💶 1000-2000€
/// - Phone: 📞 06 12 34 56 78
class LynewedInfoRow extends StatelessWidget {
  const LynewedInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.iconSize = 16,
    this.textStyle,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;
  final double iconSize;
  final TextStyle? textStyle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? LynewedColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: textStyle ?? LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
      ],
    );
  }
}

/// Inline info rows with vertical separator
/// 
/// Used for displaying location and budget side by side:
/// 📍 Paris │ 💶 1000-2000€
class LynewedInlineInfoRow extends StatelessWidget {
  const LynewedInlineInfoRow({
    super.key,
    required this.left,
    required this.right,
    this.separatorColor,
    this.separatorHeight = 16,
    this.spacing = 10,
  });

  final Widget left;
  final Widget right;
  final Color? separatorColor;
  final double separatorHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        left,
        SizedBox(width: spacing),
        Container(
          width: 1,
          height: separatorHeight,
          color: separatorColor ?? LynewedColors.gray200,
        ),
        SizedBox(width: spacing),
        right,
      ],
    );
  }
}

/// Location info row with distance
/// 
/// Specialized for location display with optional distance:
/// 📍 Paris (12km)
class LynewedLocationRow extends StatelessWidget {
  const LynewedLocationRow({
    super.key,
    required this.location,
    this.distance,
    this.iconSize = 16,
  });

  final String location;
  final String? distance;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LynewedInfoRow(
      icon: Icons.location_on_outlined,
      text: location,
      trailing: distance != null
          ? Text(
              '($distance)',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      iconSize: iconSize,
    );
  }
}

/// Budget info row with currency
/// 
/// Specialized for budget display with dynamic currency icon:
/// 💶 1000-2000€ (or $, £, etc. based on user preference)
class LynewedBudgetRow extends StatelessWidget {
  const LynewedBudgetRow({
    super.key,
    required this.budget,
    this.iconSize = 16,
  });

  final String budget;
  final double iconSize;

  /// Get appropriate icon for user's currency
  IconData get _currencyIcon {
    final currency = BudgetFormatter.userCurrency;
    switch (currency) {
      case 'USD':
        return Icons.attach_money;
      case 'GBP':
        return Icons.currency_pound;
      case 'JPY':
      case 'CNY':
        return Icons.currency_yen;
      case 'INR':
        return Icons.currency_rupee;
      case 'RUB':
        return Icons.currency_ruble;
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'EUR':
      default:
        return Icons.euro_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedInfoRow(
      icon: _currencyIcon,
      text: budget,
      iconSize: iconSize,
    );
  }
}
