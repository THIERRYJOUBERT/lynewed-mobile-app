/// Tests for AddressFormWidget.
///
/// Verifies address form rendering, field inputs, validation,
/// country dropdown, and callback behavior when required fields are filled.
/// Full Name and Phone Number are required fields.
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

    /// Finds the phone TextField by its hint prefix.
    Finder findPhoneField() {
      return find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText != null &&
            w.decoration!.hintText!.startsWith('Phone'),
      );
    }

    group('rendering', () {
      testWidgets('should show all form fields', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Shipping Address'), findsOneWidget);
        // 6+ TextFields from LynewedTextFields (name, phone, street, city, state, postal)
        // + potentially the AddressSearchWidget's search field.
        expect(find.byType(TextField), findsAtLeast(6));
      });

      testWidgets('should show field hints with required markers',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Full Name *'), findsOneWidget);
        expect(findPhoneField(), findsOneWidget);
        expect(find.text('Street Address'), findsOneWidget);
        expect(find.text('City'), findsOneWidget);
        expect(find.text('Postal Code'), findsOneWidget);
        expect(find.text('Country'), findsOneWidget);
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
          phoneNumber: '+15551234567',
        );

        await tester.pumpWidget(buildWidget(initialAddress: initial));
        await tester.pumpAndSettle();

        expect(find.text('John Doe'), findsOneWidget);
        // Phone displayed in US format from E.164
        expect(find.text('(555) 123-4567'), findsOneWidget);
        expect(find.text('123 Main St'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('10001'), findsOneWidget);
        expect(find.text('NY'), findsOneWidget);
        expect(find.text('United States'), findsOneWidget);
      });

      testWidgets('should show FR formatted phone for FR initial address',
          (tester) async {
        final initial = ShippingAddress(
          streetLines: const ['48 Rue de la Brégère'],
          city: 'Limoges',
          postalCode: '87100',
          countryCode: 'FR',
          personName: 'Marie Dupont',
          phoneNumber: '+33612345678',
        );

        await tester.pumpWidget(buildWidget(initialAddress: initial));
        await tester.pumpAndSettle();

        expect(find.text('06.12.34.56.78'), findsOneWidget);
      });
    });

    group('address callback', () {
      testWidgets(
          'should call onAddressChanged with null when only name entered',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(TextField, 'Full Name *');
        await tester.enterText(nameField, 'John');
        await tester.pump();

        // Address should be null because phone, street, city, postal code, country are empty.
        expect(lastAddress, isNull);
      });

      testWidgets(
          'should return null when name empty but other fields filled',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Fill phone
        await tester.enterText(findPhoneField(), '5551234567');
        await tester.pump();

        // Fill street
        final streetField = find.widgetWithText(TextField, 'Street Address');
        await tester.enterText(streetField, '123 Main St');
        await tester.pump();

        // Fill city
        final cityField = find.widgetWithText(TextField, 'City');
        await tester.enterText(cityField, 'New York');
        await tester.pump();

        // Fill postal code
        final postalField = find.widgetWithText(TextField, 'Postal Code');
        await tester.ensureVisible(postalField);
        await tester.pumpAndSettle();
        await tester.enterText(postalField, '10001');
        await tester.pump();

        // Select country
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('United States').last);
        await tester.pumpAndSettle();

        // Name is empty → address should be null
        expect(lastAddress, isNull);
      });

      testWidgets(
          'should return null when phone empty but other fields filled',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Fill name
        final nameField = find.widgetWithText(TextField, 'Full Name *');
        await tester.enterText(nameField, 'Jane Doe');
        await tester.pump();

        // Fill street
        final streetField = find.widgetWithText(TextField, 'Street Address');
        await tester.enterText(streetField, '123 Main St');
        await tester.pump();

        // Fill city
        final cityField = find.widgetWithText(TextField, 'City');
        await tester.enterText(cityField, 'New York');
        await tester.pump();

        // Fill postal code
        final postalField = find.widgetWithText(TextField, 'Postal Code');
        await tester.ensureVisible(postalField);
        await tester.pumpAndSettle();
        await tester.enterText(postalField, '10001');
        await tester.pump();

        // Select country
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('United States').last);
        await tester.pumpAndSettle();

        // Phone is empty → address should be null
        expect(lastAddress, isNull);
      });

      testWidgets(
          'should call onAddressChanged with address when all required fields filled',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        // Fill name (required)
        final nameField = find.widgetWithText(TextField, 'Full Name *');
        await tester.enterText(nameField, 'Jane Doe');
        await tester.pump();

        // Fill phone (required)
        await tester.enterText(findPhoneField(), '5551234567');
        await tester.pump();

        // Fill street
        final streetField = find.widgetWithText(TextField, 'Street Address');
        await tester.enterText(streetField, '123 Main St');
        await tester.pump();

        // Fill city
        final cityField = find.widgetWithText(TextField, 'City');
        await tester.enterText(cityField, 'New York');
        await tester.pump();

        // Fill postal code
        final postalField = find.widgetWithText(TextField, 'Postal Code');
        await tester.ensureVisible(postalField);
        await tester.pumpAndSettle();
        await tester.enterText(postalField, '10001');
        await tester.pump();

        // Select country
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('United States').last);
        await tester.pumpAndSettle();

        // Address should be non-null with all fields
        expect(lastAddress, isNotNull);
        expect(lastAddress!.personName, 'Jane Doe');
        expect(lastAddress!.city, 'New York');
        expect(lastAddress!.postalCode, '10001');
        expect(lastAddress!.streetLines, ['123 Main St']);
        expect(lastAddress!.countryCode, 'US');
        // Phone should be stored in E.164 format
        expect(lastAddress!.phoneNumber, contains('+'));
      });
    });
  });
}
