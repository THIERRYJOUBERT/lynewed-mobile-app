/// Tests for AddressFormWidget.
///
/// Verifies address form rendering, field inputs, validation,
/// and callback behavior when required fields are filled.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/address_form_widget.dart';

void main() {
  group('AddressFormWidget', () {
    late ShippingAddress? lastAddress;

    Widget buildWidget({ShippingAddress? initialAddress}) {
      lastAddress = null;
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AddressFormWidget(
              initialAddress: initialAddress,
              onAddressChanged: (address) {
                lastAddress = address;
              },
            ),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('should show all form fields', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Shipping Address'), findsOneWidget);
        expect(find.byType(TextField), findsAtLeast(6));
      });

      testWidgets('should show field hints', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Street Address'), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
        expect(find.text('Postal Code'), findsOneWidget);
        expect(find.text('Country Code'), findsOneWidget);
      });
    });

    group('initial address', () {
      testWidgets('should pre-fill fields when initial address provided',
          (tester) async {
        final initial = ShippingAddress(
          streetLines: const ['123 Main St'],
          city: 'New York',
          postalCode: '10001',
          countryCode: 'US',
          stateOrProvinceCode: 'NY',
          personName: 'John Doe',
          phoneNumber: '555-1234',
        );

        await tester.pumpWidget(buildWidget(initialAddress: initial));
        await tester.pumpAndSettle();

        // Check that text fields contain pre-filled values.
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('555-1234'), findsOneWidget);
        expect(find.text('123 Main St'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('10001'), findsOneWidget);
        expect(find.text('US'), findsOneWidget);
        expect(find.text('NY'), findsOneWidget);
      });
    });

    group('address callback', () {
      testWidgets('should call onAddressChanged with null when required fields empty',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Enter only name (not a required field for address)
        final nameField = find.byType(TextField).first;
        await tester.enterText(nameField, 'John');
        await tester.pump();

        // Address should be null because street, city, postal code are empty.
        expect(lastAddress, isNull);
      });

      testWidgets(
          'should call onAddressChanged with address when all required fields filled',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Fill required fields.
        // Fields order: Name, Phone, Street, City, State, Postal, Country
        final textFields = find.byType(TextField);

        // Street Address (index 2)
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();

        // City (index 3)
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();

        // Postal Code (index 5)
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();

        // Country Code (index 6) - already has default "US"
        // The default is set in initState, should already be "US"

        // The address should now be non-null.
        expect(lastAddress, isNotNull);
        expect(lastAddress!.city, 'New York');
        expect(lastAddress!.postalCode, '10001');
        expect(lastAddress!.streetLines, ['123 Main St']);
      });
    });
  });
}
