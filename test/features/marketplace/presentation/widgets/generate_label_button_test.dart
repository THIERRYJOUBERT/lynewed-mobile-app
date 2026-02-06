/// Tests for GenerateLabelButton.
///
/// Verifies generate button display, loading state, error handling with retry,
/// and success callback invocation.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_label.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/generate_shipping_label_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/generate_label_button.dart';

/// Mock FedExRepository for testing.
class _MockFedExRepository implements FedExRepository {
  @override
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelShipment(String transactionId) async {
    throw UnimplementedError();
  }
}

/// Mock use case that returns a configurable result.
class _MockGenerateShippingLabelUseCase extends GenerateShippingLabelUseCase {
  _MockGenerateShippingLabelUseCase({
    this.result,
    this.error,
  }) : super(_MockFedExRepository());

  ShippingLabel? result;
  Object? error;

  @override
  Future<ShippingLabel> call({
    required String transactionId,
    required String serviceType,
  }) async {
    if (error != null) {
      throw error!;
    }
    return result!;
  }
}

/// Mock use case that resolves via a Completer (for loading state tests).
class _MockCompleterGenerateUseCase extends GenerateShippingLabelUseCase {
  _MockCompleterGenerateUseCase(this._completer) : super(_MockFedExRepository());

  final Completer<ShippingLabel> _completer;

  @override
  Future<ShippingLabel> call({
    required String transactionId,
    required String serviceType,
  }) {
    return _completer.future;
  }
}

void main() {
  const testLabel = ShippingLabel(
    trackingNumber: '794644790138',
    labelUrl: 'https://example.com/label.pdf',
    serviceType: 'FEDEX_GROUND',
  );

  group('GenerateLabelButton', () {
    Widget buildWidget({
      String transactionId = 'txn-1',
      GenerateShippingLabelUseCase? useCase,
      void Function(ShippingLabel)? onSuccess,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GenerateLabelButton(
            transactionId: transactionId,
            generateLabelUseCase: useCase ??
                _MockGenerateShippingLabelUseCase(result: testLabel),
            onSuccess: onSuccess ?? (_) {},
          ),
        ),
      );
    }

    group('initial state', () {
      testWidgets('should show generate button initially', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Generate Shipping Label'), findsOneWidget);
      });

      testWidgets('should show description text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(
          find.textContaining('Generate a FedEx shipping label'),
          findsOneWidget,
        );
      });

      testWidgets('should show shipping icon', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('should show loading indicator during generation',
          (tester) async {
        // Use a completer to control when the future resolves.
        final completer = Completer<ShippingLabel>();
        final useCase = _MockCompleterGenerateUseCase(completer);

        await tester.pumpWidget(buildWidget(useCase: useCase));

        // Tap generate button.
        await tester.tap(find.text('Generate Shipping Label'));
        await tester.pump();

        // Should show loading indicator while future is pending.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the future to clean up.
        completer.complete(testLabel);
        await tester.pumpAndSettle();
      });
    });

    group('error state', () {
      testWidgets('should show error message on failure', (tester) async {
        final useCase = _MockGenerateShippingLabelUseCase(
          error: Exception('FedEx API unavailable'),
        );

        await tester.pumpWidget(buildWidget(useCase: useCase));

        await tester.tap(find.text('Generate Shipping Label'));
        await tester.pumpAndSettle();

        expect(find.textContaining('FedEx API unavailable'), findsOneWidget);
      });

      testWidgets('should show retry button after error', (tester) async {
        final useCase = _MockGenerateShippingLabelUseCase(
          error: Exception('Network error'),
        );

        await tester.pumpWidget(buildWidget(useCase: useCase));

        await tester.tap(find.text('Generate Shipping Label'));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry on retry button tap', (tester) async {
        final useCase = _MockGenerateShippingLabelUseCase(
          error: Exception('Temporary error'),
        );

        await tester.pumpWidget(buildWidget(useCase: useCase));

        await tester.tap(find.text('Generate Shipping Label'));
        await tester.pumpAndSettle();

        // Now fix the useCase to succeed.
        useCase.error = null;
        useCase.result = testLabel;

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Error should be gone, success callback fired.
        expect(find.text('Retry'), findsNothing);
      });
    });

    group('success', () {
      testWidgets('should call onSuccess callback after successful generation',
          (tester) async {
        ShippingLabel? receivedLabel;
        final useCase = _MockGenerateShippingLabelUseCase(result: testLabel);

        await tester.pumpWidget(
          buildWidget(
            useCase: useCase,
            onSuccess: (label) => receivedLabel = label,
          ),
        );

        await tester.tap(find.text('Generate Shipping Label'));
        await tester.pumpAndSettle();

        expect(receivedLabel, equals(testLabel));
      });
    });
  });
}
