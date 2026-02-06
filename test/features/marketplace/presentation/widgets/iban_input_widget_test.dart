/// Tests for IbanInputWidget.
///
/// Verifies IBAN formatting, MOD 97 validation, error display,
/// and callback behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/iban_input_widget.dart';

void main() {
  group('IbanInputWidget.isValidIban', () {
    test('should accept valid French IBAN', () {
      expect(
        IbanInputWidget.isValidIban('FR7630006000011234567890189'),
        isTrue,
      );
    });

    test('should accept valid German IBAN', () {
      expect(
        IbanInputWidget.isValidIban('DE89370400440532013000'),
        isTrue,
      );
    });

    test('should accept valid UK IBAN', () {
      expect(
        IbanInputWidget.isValidIban('GB29NWBK60161331926819'),
        isTrue,
      );
    });

    test('should accept IBAN with spaces', () {
      expect(
        IbanInputWidget.isValidIban('FR76 3000 6000 0112 3456 7890 189'),
        isTrue,
      );
    });

    test('should accept lowercase IBAN', () {
      expect(
        IbanInputWidget.isValidIban('fr7630006000011234567890189'),
        isTrue,
      );
    });

    test('should reject too-short IBAN', () {
      expect(IbanInputWidget.isValidIban('FR761234'), isFalse);
    });

    test('should reject too-long IBAN', () {
      expect(
        IbanInputWidget.isValidIban(
            'FR7630006000011234567890189012345678'),
        isFalse,
      );
    });

    test('should reject IBAN with invalid check digits', () {
      // Changed check digit from 76 to 00.
      expect(
        IbanInputWidget.isValidIban('FR0030006000011234567890189'),
        isFalse,
      );
    });

    test('should reject IBAN not starting with letters', () {
      expect(IbanInputWidget.isValidIban('12345678901234567'), isFalse);
    });

    test('should reject empty string', () {
      expect(IbanInputWidget.isValidIban(''), isFalse);
    });
  });

  group('IbanInputWidget widget', () {
    Widget buildWidget({ValueChanged<String?>? onChanged, String? initial}) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: IbanInputWidget(
              onChanged: onChanged ?? (_) {},
              initialValue: initial,
            ),
          ),
        ),
      );
    }

    testWidgets('should show IBAN label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('IBAN'), findsOneWidget);
    });

    testWidgets('should show hint text', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('FR76 3000 6000 0112 3456 7890 189'),
        findsOneWidget,
      );
    });

    testWidgets('should show helper text about payouts', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Your IBAN is used to receive payouts from sales.'),
        findsOneWidget,
      );
    });

    testWidgets('should show bank icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
    });

    testWidgets('should call onChanged with valid IBAN', (tester) async {
      String? lastValue;
      await tester.pumpWidget(buildWidget(
        onChanged: (v) => lastValue = v,
      ));
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(
          textField, 'FR7630006000011234567890189');
      await tester.pump();

      expect(lastValue, 'FR7630006000011234567890189');
    });

    testWidgets('should call onChanged with null for invalid IBAN',
        (tester) async {
      String? lastValue = 'initial';
      await tester.pumpWidget(buildWidget(
        onChanged: (v) => lastValue = v,
      ));
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'FR0030006000011234567890189');
      await tester.pump();

      expect(lastValue, isNull);
    });

    testWidgets('should show error text for invalid IBAN >=15 chars',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'FR0030006000011234567890189');
      await tester.pump();

      expect(find.text('Invalid IBAN'), findsOneWidget);
    });

    testWidgets('should not show error for partial input', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'FR76');
      await tester.pump();

      expect(find.text('Invalid IBAN'), findsNothing);
    });

    testWidgets('should pre-fill initial value', (tester) async {
      await tester.pumpWidget(buildWidget(
        initial: 'DE89370400440532013000',
      ));
      await tester.pumpAndSettle();

      // Check the formatted version is in the field.
      expect(find.text('DE89 3704 0044 0532 0130 00'), findsOneWidget);
    });
  });
}
