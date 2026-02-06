/// IBAN input widget with validation.
///
/// Provides a text field for IBAN entry with real-time formatting,
/// country-aware validation, and MOD 97 checksum verification.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/design/design.dart';

/// Validates and formats IBAN input.
///
/// Displays the IBAN in groups of 4 characters and validates
/// using the MOD 97 algorithm per ISO 13616.
class IbanInputWidget extends StatefulWidget {
  /// Called when the IBAN value changes. The value is the raw IBAN
  /// with all spaces removed, or null if the current input is invalid.
  final ValueChanged<String?> onChanged;

  /// Pre-filled IBAN value.
  final String? initialValue;

  const IbanInputWidget({
    required this.onChanged,
    this.initialValue,
    super.key,
  });

  /// Validates an IBAN using the MOD 97 algorithm (ISO 13616).
  static bool isValidIban(String iban) {
    final cleaned = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Min length: 15 (Norway), Max: 34 (various)
    if (cleaned.length < 15 || cleaned.length > 34) return false;

    // Must start with 2 letters (country) + 2 digits (check)
    if (!RegExp(r'^[A-Z]{2}\d{2}').hasMatch(cleaned)) return false;

    // MOD 97 check: move first 4 chars to end, convert letters to numbers
    final rearranged = cleaned.substring(4) + cleaned.substring(0, 4);
    final numericString = StringBuffer();
    for (final char in rearranged.runes) {
      final c = String.fromCharCode(char);
      if (RegExp(r'[A-Z]').hasMatch(c)) {
        numericString.write(char - 55); // A=10, B=11, ..., Z=35
      } else {
        numericString.write(c);
      }
    }

    // Calculate MOD 97 on the numeric string (can be very long, use BigInt)
    var remainder = BigInt.zero;
    for (final digit in numericString.toString().runes) {
      remainder =
          (remainder * BigInt.from(10) + BigInt.from(digit - 48)) %
              BigInt.from(97);
    }

    return remainder == BigInt.one;
  }

  @override
  State<IbanInputWidget> createState() => _IbanInputWidgetState();
}

class _IbanInputWidgetState extends State<IbanInputWidget> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatIban(widget.initialValue ?? ''),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Formats an IBAN string into groups of 4 characters.
  static String _formatIban(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final buffer = StringBuffer();
    for (var i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  void _onChanged(String value) {
    final raw = value.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // Re-format with spaces every 4 chars
    final formatted = _formatIban(raw);
    if (formatted != value) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }

    if (raw.isEmpty) {
      setState(() => _errorText = null);
      widget.onChanged(null);
      return;
    }

    if (raw.length >= 15 && IbanInputWidget.isValidIban(raw)) {
      setState(() => _errorText = null);
      widget.onChanged(raw);
    } else if (raw.length >= 15) {
      setState(() => _errorText = 'Invalid IBAN');
      widget.onChanged(null);
    } else {
      setState(() => _errorText = null);
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('IBAN', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
            LengthLimitingTextInputFormatter(42), // 34 chars + 8 spaces
          ],
          onChanged: _onChanged,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            hintText: 'FR76 3000 6000 0112 3456 7890 189',
            hintStyle: LynewedTextStyles.inputHint,
            prefixIcon: const Icon(
              Icons.account_balance_outlined,
              size: 20,
              color: LynewedColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
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
              borderSide:
                  const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: LynewedColors.error),
            ),
            errorText: _hasInteracted ? _errorText : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your IBAN is used to receive payouts from sales.',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
