/// Country-aware phone number formatter for marketplace checkout.
///
/// Formats phone numbers as the user types based on the selected country:
/// - FR: 06.12.34.56.78
/// - US/CA: (555) 123-4567
/// - GB: 07911 123456
/// - DE: 0171 1234567
/// - ES/PT: 612 345 678
///
/// Provides [toE164] to convert display format to E.164 for storage/API,
/// and [fromE164] to convert E.164 back to display format.
library;

import 'package:flutter/services.dart';

/// Configuration for phone number formatting per country.
class PhoneCountryConfig {
  /// Creates a phone country config.
  const PhoneCountryConfig({
    required this.countryCode,
    required this.dialCode,
    required this.maxDigits,
    required this.groupPattern,
    required this.separator,
    required this.exampleHint,
    this.trunkPrefix,
    this.wrapFirstGroup = false,
  });

  /// ISO 3166-1 alpha-2 country code.
  final String countryCode;

  /// International dialing code (e.g., '+33').
  final String dialCode;

  /// Maximum number of digits (including trunk prefix if applicable).
  final int maxDigits;

  /// Digit group sizes for formatting (e.g., [2,2,2,2,2] for FR).
  final List<int> groupPattern;

  /// Separator between groups (e.g., '.' for FR, '-' for US).
  final String separator;

  /// Example hint shown in the text field (e.g., '06.XX.XX.XX.XX').
  final String exampleHint;

  /// Trunk prefix stripped when converting to E.164 (e.g., '0' for FR).
  final String? trunkPrefix;

  /// Whether to wrap the first group in parentheses (US style).
  final bool wrapFirstGroup;
}

/// Country-aware phone number TextInputFormatter.
///
/// Formats digits as the user types and provides static helpers
/// for E.164 conversion and digit extraction.
class PhoneNumberFormatter extends TextInputFormatter {
  /// Creates a formatter with the given country config.
  PhoneNumberFormatter(this.config);

  /// The country configuration for formatting.
  final PhoneCountryConfig config;

  /// Known country configs for marketplace countries.
  static const Map<String, PhoneCountryConfig> _configs = {
    'FR': PhoneCountryConfig(
      countryCode: 'FR',
      dialCode: '+33',
      maxDigits: 10,
      groupPattern: [2, 2, 2, 2, 2],
      separator: '.',
      trunkPrefix: '0',
      exampleHint: '06.XX.XX.XX.XX',
    ),
    'US': PhoneCountryConfig(
      countryCode: 'US',
      dialCode: '+1',
      maxDigits: 10,
      groupPattern: [3, 3, 4],
      separator: '-',
      wrapFirstGroup: true,
      exampleHint: '(555) 123-4567',
    ),
    'CA': PhoneCountryConfig(
      countryCode: 'CA',
      dialCode: '+1',
      maxDigits: 10,
      groupPattern: [3, 3, 4],
      separator: '-',
      wrapFirstGroup: true,
      exampleHint: '(555) 123-4567',
    ),
    'GB': PhoneCountryConfig(
      countryCode: 'GB',
      dialCode: '+44',
      maxDigits: 11,
      groupPattern: [5, 6],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '07XXX XXXXXX',
    ),
    'DE': PhoneCountryConfig(
      countryCode: 'DE',
      dialCode: '+49',
      maxDigits: 11,
      groupPattern: [4, 7],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '0XXX XXXXXXX',
    ),
    'IT': PhoneCountryConfig(
      countryCode: 'IT',
      dialCode: '+39',
      maxDigits: 10,
      groupPattern: [3, 3, 4],
      separator: ' ',
      exampleHint: '3XX XXX XXXX',
    ),
    'ES': PhoneCountryConfig(
      countryCode: 'ES',
      dialCode: '+34',
      maxDigits: 9,
      groupPattern: [3, 3, 3],
      separator: ' ',
      exampleHint: '6XX XXX XXX',
    ),
    'AU': PhoneCountryConfig(
      countryCode: 'AU',
      dialCode: '+61',
      maxDigits: 10,
      groupPattern: [4, 3, 3],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '0XXX XXX XXX',
    ),
    'NL': PhoneCountryConfig(
      countryCode: 'NL',
      dialCode: '+31',
      maxDigits: 10,
      groupPattern: [2, 4, 4],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '06 XXXX XXXX',
    ),
    'BE': PhoneCountryConfig(
      countryCode: 'BE',
      dialCode: '+32',
      maxDigits: 10,
      groupPattern: [4, 2, 2, 2],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '04XX XX XX XX',
    ),
    'CH': PhoneCountryConfig(
      countryCode: 'CH',
      dialCode: '+41',
      maxDigits: 10,
      groupPattern: [3, 3, 2, 2],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '0XX XXX XX XX',
    ),
    'AT': PhoneCountryConfig(
      countryCode: 'AT',
      dialCode: '+43',
      maxDigits: 11,
      groupPattern: [4, 7],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '0XXX XXXXXXX',
    ),
    'PT': PhoneCountryConfig(
      countryCode: 'PT',
      dialCode: '+351',
      maxDigits: 9,
      groupPattern: [3, 3, 3],
      separator: ' ',
      exampleHint: '9XX XXX XXX',
    ),
    'IE': PhoneCountryConfig(
      countryCode: 'IE',
      dialCode: '+353',
      maxDigits: 10,
      groupPattern: [3, 3, 4],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '08X XXX XXXX',
    ),
    'SE': PhoneCountryConfig(
      countryCode: 'SE',
      dialCode: '+46',
      maxDigits: 10,
      groupPattern: [3, 3, 2, 2],
      separator: ' ',
      trunkPrefix: '0',
      exampleHint: '07X XXX XX XX',
    ),
  };

  /// Generic config for unknown countries.
  static const PhoneCountryConfig _genericConfig = PhoneCountryConfig(
    countryCode: '',
    dialCode: '+',
    maxDigits: 15,
    groupPattern: [3, 3, 4, 5],
    separator: ' ',
    exampleHint: 'XXX XXX XXXX',
  );

  /// Returns the config for a given country code, or generic if unknown.
  static PhoneCountryConfig configFor(String countryCode) {
    return _configs[countryCode.toUpperCase()] ?? _genericConfig;
  }

  /// Extracts only digit characters from a string.
  static String rawDigits(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Converts a display-formatted phone to E.164 format.
  ///
  /// Example: `'06.12.34.56.78'` with country `'FR'` → `'+33612345678'`.
  static String toE164(String formattedPhone, String countryCode) {
    if (formattedPhone.isEmpty) return '';

    final config = configFor(countryCode);
    var digits = rawDigits(formattedPhone);

    if (digits.isEmpty) return '';

    // If already starts with the dial code digits, pass through with +
    final dialDigits = rawDigits(config.dialCode);
    if (dialDigits.isNotEmpty && digits.startsWith(dialDigits)) {
      return '+$digits';
    }

    // Strip trunk prefix if present
    if (config.trunkPrefix != null && digits.startsWith(config.trunkPrefix!)) {
      digits = digits.substring(config.trunkPrefix!.length);
    }

    // For generic config, just prepend +
    if (config.dialCode == '+') {
      return '+$digits';
    }

    return '${config.dialCode}$digits';
  }

  /// Converts an E.164 number to display format for a given country.
  ///
  /// Example: `'+33612345678'` with country `'FR'` → `'06.12.34.56.78'`.
  static String fromE164(String e164Phone, String countryCode) {
    if (e164Phone.isEmpty) return '';

    final config = configFor(countryCode);
    var digits = rawDigits(e164Phone);

    if (digits.isEmpty) return '';

    // Strip dial code digits if present at start
    final dialDigits = rawDigits(config.dialCode);
    if (dialDigits.isNotEmpty && digits.startsWith(dialDigits)) {
      digits = digits.substring(dialDigits.length);
      // Re-add trunk prefix for display
      if (config.trunkPrefix != null) {
        digits = '${config.trunkPrefix}$digits';
      }
    }

    // Clamp to max digits
    if (digits.length > config.maxDigits) {
      digits = digits.substring(0, config.maxDigits);
    }

    // Format using the config
    return _applyFormat(digits, config);
  }

  /// Checks if a formatted phone number has the expected digit count.
  static bool isComplete(String formattedPhone, String countryCode) {
    final config = configFor(countryCode);
    final digits = rawDigits(formattedPhone);
    return digits.length == config.maxDigits;
  }

  /// Maximum formatted string length (digits + separators + parens).
  int get maxFormattedLength {
    if (config.wrapFirstGroup) {
      // (###) ###-#### → parens(2) + space(1) + separators between remaining groups
      final separatorCount = config.groupPattern.length - 2; // -1 for groups, -1 because first group uses () space
      return config.maxDigits + 2 + 1 + (separatorCount > 0 ? separatorCount : 0);
    }
    // Regular: digits + separators between groups
    return config.maxDigits + config.groupPattern.length - 1;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract raw digits from the new input
    var digits = rawDigits(newValue.text);

    // Clamp to max digits
    if (digits.length > config.maxDigits) {
      digits = digits.substring(0, config.maxDigits);
    }

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Count digits before cursor in new value to preserve position
    final cursorOffset = newValue.selection.baseOffset;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < cursorOffset && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }
    // Clamp to actual digit count
    if (digitsBeforeCursor > digits.length) {
      digitsBeforeCursor = digits.length;
    }

    // Apply formatting
    final formatted = _applyFormat(digits, config);

    // Calculate new cursor position: walk through formatted text
    // counting digits until we reach digitsBeforeCursor
    int newCursorOffset = formatted.length; // default: end
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
        if (digitCount == digitsBeforeCursor) {
          newCursorOffset = i + 1;
          break;
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorOffset.clamp(0, formatted.length),
      ),
    );
  }

  /// Applies the group pattern formatting to raw digits.
  static String _applyFormat(String digits, PhoneCountryConfig config) {
    if (digits.isEmpty) return '';

    if (config.wrapFirstGroup) {
      return _applyUSFormat(digits, config);
    }

    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int groupIdx = 0; groupIdx < config.groupPattern.length; groupIdx++) {
      if (digitIndex >= digits.length) break;

      // Add separator between groups
      if (groupIdx > 0) {
        buffer.write(config.separator);
      }

      final groupSize = config.groupPattern[groupIdx];
      final end = (digitIndex + groupSize).clamp(0, digits.length);
      buffer.write(digits.substring(digitIndex, end));
      digitIndex = end;
    }

    return buffer.toString();
  }

  /// Applies US-style formatting: (###) ###-####
  static String _applyUSFormat(String digits, PhoneCountryConfig config) {
    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int groupIdx = 0; groupIdx < config.groupPattern.length; groupIdx++) {
      if (digitIndex >= digits.length) break;

      final groupSize = config.groupPattern[groupIdx];
      final end = (digitIndex + groupSize).clamp(0, digits.length);
      final groupText = digits.substring(digitIndex, end);

      if (groupIdx == 0) {
        // First group: wrap in parens
        buffer.write('($groupText');
        if (end - digitIndex == groupSize) {
          buffer.write(') ');
        }
      } else {
        // Subsequent groups: use separator
        if (groupIdx > 1) {
          buffer.write(config.separator);
        }
        buffer.write(groupText);
      }

      digitIndex = end;
    }

    return buffer.toString();
  }
}
