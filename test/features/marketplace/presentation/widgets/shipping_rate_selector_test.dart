/// Tests for ShippingRateSelector widget.
///
/// Verifies rate display, selection highlighting, callback, and empty state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_rate_selector.dart';

void main() {
  group('ShippingRateSelector', () {
    final testRates = [
      const ShippingRate(
        serviceType: 'FEDEX_GROUND',
        serviceName: 'FedEx Ground',
        rateCents: 1250,
        currency: 'USD',
        estimatedDays: 5,
      ),
      const ShippingRate(
        serviceType: 'FEDEX_EXPRESS',
        serviceName: 'FedEx Express',
        rateCents: 2500,
        currency: 'USD',
        estimatedDays: 2,
      ),
    ];

    Widget buildWidget({
      List<ShippingRate> rates = const [],
      ShippingRate? selectedRate,
      ValueChanged<ShippingRate>? onRateSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ShippingRateSelector(
            rates: rates,
            selectedRate: selectedRate,
            onRateSelected: onRateSelected ?? (_) {},
          ),
        ),
      );
    }

    group('display', () {
      testWidgets('should display all rates', (tester) async {
        await tester.pumpWidget(buildWidget(rates: testRates));

        expect(find.text('FedEx Ground'), findsOneWidget);
        expect(find.text('FedEx Express'), findsOneWidget);
      });

      testWidgets('should display price for each rate', (tester) async {
        await tester.pumpWidget(buildWidget(rates: testRates));

        expect(find.text('\$12.50'), findsOneWidget);
        expect(find.text('\$25.00'), findsOneWidget);
      });

      testWidgets('should display estimated days', (tester) async {
        await tester.pumpWidget(buildWidget(rates: testRates));

        expect(find.textContaining('5'), findsWidgets);
        expect(find.textContaining('2'), findsWidgets);
      });
    });

    group('selection', () {
      testWidgets('should call onRateSelected when rate is tapped',
          (tester) async {
        ShippingRate? selected;
        await tester.pumpWidget(
          buildWidget(
            rates: testRates,
            onRateSelected: (rate) => selected = rate,
          ),
        );

        await tester.tap(find.text('FedEx Ground'));
        await tester.pump();

        expect(selected, testRates[0]);
      });
    });

    group('empty state', () {
      testWidgets('should show empty message when no rates', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(
          find.text('No shipping options available'),
          findsOneWidget,
        );
      });
    });
  });
}
