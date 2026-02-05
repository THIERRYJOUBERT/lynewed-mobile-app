/// Tests for ShippingOptionsWidget.
///
/// Verifies loading state, error state, empty state, rate display,
/// and selection behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_options_widget.dart';

void main() {
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

  group('ShippingOptionsWidget', () {
    Widget buildWidget({
      List<ShippingRate> rates = const [],
      ShippingRate? selectedRate,
      bool isLoading = false,
      String? errorMessage,
      VoidCallback? onRetry,
      ValueChanged<ShippingRate>? onRateSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShippingOptionsWidget(
              rates: rates,
              selectedRate: selectedRate,
              onRateSelected: onRateSelected ?? (_) {},
              isLoading: isLoading,
              errorMessage: errorMessage,
              onRetry: onRetry,
            ),
          ),
        ),
      );
    }

    group('section title', () {
      testWidgets('should show section title', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Shipping Options'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(buildWidget(isLoading: true));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Calculating shipping rates...'), findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('should show error message', (tester) async {
        await tester.pumpWidget(buildWidget(
          errorMessage: 'Failed to calculate rates',
        ));
        await tester.pumpAndSettle();

        expect(find.text('Failed to calculate rates'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should show retry button when onRetry provided',
          (tester) async {
        var retried = false;
        await tester.pumpWidget(buildWidget(
          errorMessage: 'Failed',
          onRetry: () => retried = true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retried, isTrue);
      });
    });

    group('empty state', () {
      testWidgets('should show empty message when no rates', (tester) async {
        await tester.pumpWidget(buildWidget(rates: []));
        await tester.pumpAndSettle();

        expect(find.text('No shipping options available'), findsOneWidget);
      });
    });

    group('rates display', () {
      testWidgets('should show all rates', (tester) async {
        await tester.pumpWidget(buildWidget(rates: testRates));
        await tester.pumpAndSettle();

        expect(find.text('FedEx Ground'), findsOneWidget);
        expect(find.text('FedEx Express'), findsOneWidget);
        expect(find.text('\$12.50'), findsOneWidget);
        expect(find.text('\$25.00'), findsOneWidget);
      });

      testWidgets('should show estimated days', (tester) async {
        await tester.pumpWidget(buildWidget(rates: testRates));
        await tester.pumpAndSettle();

        expect(find.text('5 business days'), findsOneWidget);
        expect(find.text('2 business days'), findsOneWidget);
      });
    });

    group('selection', () {
      testWidgets('should highlight selected rate', (tester) async {
        await tester.pumpWidget(buildWidget(
          rates: testRates,
          selectedRate: testRates.first,
        ));
        await tester.pumpAndSettle();

        // The selected rate should have a check icon.
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should call onRateSelected when rate tapped',
          (tester) async {
        ShippingRate? selected;
        await tester.pumpWidget(buildWidget(
          rates: testRates,
          onRateSelected: (rate) => selected = rate,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('FedEx Express'));
        await tester.pump();

        expect(selected, testRates[1]);
      });
    });
  });
}
