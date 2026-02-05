/// CGVU acceptance widget for marketplace checkout.
///
/// Displays the marketplace buyer terms and conditions with a checkbox
/// for the buyer to accept. Handles already-accepted state.
library;

import 'package:flutter/material.dart';

import '/core/constants/cgvu_texts.dart';
import '/core/design/design.dart';

/// Displays marketplace buyer CGVU terms with acceptance checkbox.
///
/// If the buyer has already accepted, shows a green checkmark.
/// Otherwise, shows the full CGVU text and a checkbox.
class CgvuAcceptanceWidget extends StatelessWidget {
  /// Creates a CGVU acceptance widget.
  const CgvuAcceptanceWidget({
    required this.hasAccepted,
    required this.isChecked,
    required this.onCheckedChanged,
    this.alreadyAccepted = false,
    super.key,
  });

  /// Whether the user has checked the acceptance checkbox.
  final bool hasAccepted;

  /// Whether the checkbox is currently checked.
  final bool isChecked;

  /// Called when the checkbox value changes.
  final ValueChanged<bool> onCheckedChanged;

  /// Whether the user has already accepted in a previous session.
  final bool alreadyAccepted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Terms and Conditions'),
        const SizedBox(height: 10),
        if (alreadyAccepted) _buildAlreadyAccepted() else _buildCgvuForm(),
      ],
    );
  }

  Widget _buildAlreadyAccepted() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have already accepted the marketplace buyer terms.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCgvuForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scrollable CGVU text
        Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LynewedColors.gray200),
          ),
          child: SingleChildScrollView(
            child: Text(
              marketplaceBuyerCgvuText,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textPrimary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Acceptance checkbox
        GestureDetector(
          onTap: () => onCheckedChanged(!isChecked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (value) => onCheckedChanged(value ?? false),
                  activeColor: LynewedColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I have read and accept the Marketplace Buyer Terms and Conditions',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
