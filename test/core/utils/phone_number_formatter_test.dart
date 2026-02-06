/// Tests for PhoneNumberFormatter.
///
/// Verifies country-aware phone formatting, E.164 conversion,
/// digit extraction, and edge cases for all marketplace countries.
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/phone_number_formatter.dart';

void main() {
  group('PhoneCountryConfig', () {
    test('should have correct config for FR', () {
      final config = PhoneNumberFormatter.configFor('FR');
      expect(config.dialCode, '+33');
      expect(config.maxDigits, 10);
      expect(config.separator, '.');
      expect(config.trunkPrefix, '0');
      expect(config.groupPattern, [2, 2, 2, 2, 2]);
    });

    test('should have correct config for US', () {
      final config = PhoneNumberFormatter.configFor('US');
      expect(config.dialCode, '+1');
      expect(config.maxDigits, 10);
      expect(config.trunkPrefix, isNull);
      expect(config.wrapFirstGroup, true);
    });

    test('should have correct config for CA', () {
      final config = PhoneNumberFormatter.configFor('CA');
      expect(config.dialCode, '+1');
      expect(config.maxDigits, 10);
      expect(config.wrapFirstGroup, true);
    });

    test('should have correct config for GB', () {
      final config = PhoneNumberFormatter.configFor('GB');
      expect(config.dialCode, '+44');
      expect(config.maxDigits, 11);
      expect(config.trunkPrefix, '0');
    });

    test('should have correct config for DE', () {
      final config = PhoneNumberFormatter.configFor('DE');
      expect(config.dialCode, '+49');
      expect(config.maxDigits, 11);
      expect(config.trunkPrefix, '0');
    });

    test('should have correct config for ES', () {
      final config = PhoneNumberFormatter.configFor('ES');
      expect(config.dialCode, '+34');
      expect(config.maxDigits, 9);
      expect(config.trunkPrefix, isNull);
    });

    test('should have correct config for PT', () {
      final config = PhoneNumberFormatter.configFor('PT');
      expect(config.dialCode, '+351');
      expect(config.maxDigits, 9);
    });

    test('should return generic config for unknown country', () {
      final config = PhoneNumberFormatter.configFor('ZZ');
      expect(config.dialCode, '+');
      expect(config.maxDigits, 15);
    });

    test('should have exampleHint for each country', () {
      expect(
        PhoneNumberFormatter.configFor('FR').exampleHint,
        isNotEmpty,
      );
      expect(
        PhoneNumberFormatter.configFor('US').exampleHint,
        isNotEmpty,
      );
    });
  });

  group('PhoneNumberFormatter formatting', () {
    TextEditingValue format(String countryCode, String input) {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor(countryCode),
      );
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: input,
          selection: TextSelection.collapsed(offset: input.length),
        ),
      );
    }

    group('France (FR)', () {
      test('should format full number with dots', () {
        final result = format('FR', '0612345678');
        expect(result.text, '06.12.34.56.78');
      });

      test('should format partial number', () {
        final result = format('FR', '0612');
        expect(result.text, '06.12');
      });

      test('should format single group', () {
        final result = format('FR', '06');
        expect(result.text, '06');
      });

      test('should handle single digit', () {
        final result = format('FR', '0');
        expect(result.text, '0');
      });

      test('should truncate excess digits', () {
        final result = format('FR', '06123456789999');
        expect(result.text, '06.12.34.56.78');
      });

      test('should strip non-digit characters', () {
        final result = format('FR', '06.12.34');
        expect(result.text, '06.12.34');
      });
    });

    group('United States (US)', () {
      test('should format full number with parens', () {
        final result = format('US', '5551234567');
        expect(result.text, '(555) 123-4567');
      });

      test('should format partial number', () {
        final result = format('US', '555123');
        expect(result.text, '(555) 123');
      });

      test('should format area code only', () {
        final result = format('US', '555');
        expect(result.text, '(555) ');
      });

      test('should handle partial area code', () {
        final result = format('US', '55');
        expect(result.text, '(55');
      });

      test('should truncate excess digits', () {
        final result = format('US', '55512345679999');
        expect(result.text, '(555) 123-4567');
      });
    });

    group('United Kingdom (GB)', () {
      test('should format full number', () {
        final result = format('GB', '07911123456');
        expect(result.text, '07911 123456');
      });

      test('should format partial number', () {
        final result = format('GB', '07911');
        expect(result.text, '07911');
      });
    });

    group('Germany (DE)', () {
      test('should format full number', () {
        final result = format('DE', '01711234567');
        expect(result.text, '0171 1234567');
      });
    });

    group('Spain (ES)', () {
      test('should format full number', () {
        final result = format('ES', '612345678');
        expect(result.text, '612 345 678');
      });
    });

    group('Italy (IT)', () {
      test('should format full number', () {
        final result = format('IT', '3331234567');
        expect(result.text, '333 123 4567');
      });
    });

    group('empty and edge cases', () {
      test('should handle empty input', () {
        final result = format('FR', '');
        expect(result.text, '');
      });

      test('should handle only non-digit input', () {
        final result = format('FR', '+++---');
        expect(result.text, '');
      });
    });
  });

  group('PhoneNumberFormatter.rawDigits', () {
    test('should extract digits from formatted FR number', () {
      expect(PhoneNumberFormatter.rawDigits('06.12.34.56.78'), '0612345678');
    });

    test('should extract digits from formatted US number', () {
      expect(PhoneNumberFormatter.rawDigits('(555) 123-4567'), '5551234567');
    });

    test('should extract digits from E.164', () {
      expect(PhoneNumberFormatter.rawDigits('+33612345678'), '33612345678');
    });

    test('should return empty for empty input', () {
      expect(PhoneNumberFormatter.rawDigits(''), '');
    });

    test('should return empty for non-digit input', () {
      expect(PhoneNumberFormatter.rawDigits('abc'), '');
    });
  });

  group('PhoneNumberFormatter.toE164', () {
    test('should convert FR formatted to E.164', () {
      expect(
        PhoneNumberFormatter.toE164('06.12.34.56.78', 'FR'),
        '+33612345678',
      );
    });

    test('should convert FR raw digits to E.164', () {
      expect(
        PhoneNumberFormatter.toE164('0612345678', 'FR'),
        '+33612345678',
      );
    });

    test('should convert US formatted to E.164', () {
      expect(
        PhoneNumberFormatter.toE164('(555) 123-4567', 'US'),
        '+15551234567',
      );
    });

    test('should convert GB formatted to E.164', () {
      expect(
        PhoneNumberFormatter.toE164('07911 123456', 'GB'),
        '+447911123456',
      );
    });

    test('should convert DE formatted to E.164', () {
      expect(
        PhoneNumberFormatter.toE164('0171 1234567', 'DE'),
        '+491711234567',
      );
    });

    test('should convert ES formatted to E.164 (no trunk prefix)', () {
      expect(
        PhoneNumberFormatter.toE164('612 345 678', 'ES'),
        '+34612345678',
      );
    });

    test('should convert IT formatted to E.164 (no trunk prefix)', () {
      expect(
        PhoneNumberFormatter.toE164('333 123 4567', 'IT'),
        '+393331234567',
      );
    });

    test('should handle already E.164 number', () {
      // If user somehow has a +33 prefixed number, pass through
      expect(
        PhoneNumberFormatter.toE164('+33612345678', 'FR'),
        '+33612345678',
      );
    });

    test('should return raw digits with + prefix for unknown country', () {
      final result = PhoneNumberFormatter.toE164('1234567890', 'ZZ');
      expect(result, '+1234567890');
    });

    test('should return empty for empty input', () {
      expect(PhoneNumberFormatter.toE164('', 'FR'), '');
    });
  });

  group('PhoneNumberFormatter.fromE164', () {
    test('should convert FR E.164 to display format', () {
      expect(
        PhoneNumberFormatter.fromE164('+33612345678', 'FR'),
        '06.12.34.56.78',
      );
    });

    test('should convert US E.164 to display format', () {
      expect(
        PhoneNumberFormatter.fromE164('+15551234567', 'US'),
        '(555) 123-4567',
      );
    });

    test('should convert GB E.164 to display format', () {
      expect(
        PhoneNumberFormatter.fromE164('+447911123456', 'GB'),
        '07911 123456',
      );
    });

    test('should return input if not E.164', () {
      expect(
        PhoneNumberFormatter.fromE164('0612345678', 'FR'),
        '06.12.34.56.78',
      );
    });

    test('should return empty for empty input', () {
      expect(PhoneNumberFormatter.fromE164('', 'FR'), '');
    });
  });

  group('PhoneNumberFormatter.isComplete', () {
    test('should return true for complete FR number', () {
      expect(
        PhoneNumberFormatter.isComplete('06.12.34.56.78', 'FR'),
        true,
      );
    });

    test('should return false for incomplete FR number', () {
      expect(
        PhoneNumberFormatter.isComplete('06.12.34', 'FR'),
        false,
      );
    });

    test('should return true for complete US number', () {
      expect(
        PhoneNumberFormatter.isComplete('(555) 123-4567', 'US'),
        true,
      );
    });

    test('should return false for incomplete US number', () {
      expect(
        PhoneNumberFormatter.isComplete('(555) 123', 'US'),
        false,
      );
    });

    test('should return true for complete ES number (9 digits)', () {
      expect(
        PhoneNumberFormatter.isComplete('612 345 678', 'ES'),
        true,
      );
    });

    test('should return false for empty input', () {
      expect(PhoneNumberFormatter.isComplete('', 'FR'), false);
    });
  });

  group('PhoneNumberFormatter.maxFormattedLength', () {
    test('should calculate correct length for FR', () {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor('FR'),
      );
      // 06.12.34.56.78 = 10 digits + 4 dots = 14
      expect(formatter.maxFormattedLength, 14);
    });

    test('should calculate correct length for US', () {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor('US'),
      );
      // (555) 123-4567 = 10 digits + () + space + - = 14
      expect(formatter.maxFormattedLength, 14);
    });

    test('should calculate correct length for GB', () {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor('GB'),
      );
      // 07911 123456 = 11 digits + 1 space = 12
      expect(formatter.maxFormattedLength, 12);
    });
  });

  group('cursor position', () {
    test('should place cursor at end after formatting', () {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor('FR'),
      );
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '0612',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      // 06.12 -> cursor at end = 5
      expect(result.selection.baseOffset, 5);
    });

    test('should handle cursor in middle of text', () {
      final formatter = PhoneNumberFormatter(
        PhoneNumberFormatter.configFor('FR'),
      );
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '06.12.34',
          selection: TextSelection.collapsed(offset: 5),
        ),
        const TextEditingValue(
          text: '06.125.34',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      // After inserting '5' at position 5, digits become 0612534
      // Formatted: 06.12.53.4 -> cursor after the '5' = position 6
      expect(result.text, '06.12.53.4');
    });
  });
}
