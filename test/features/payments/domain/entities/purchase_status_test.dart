import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/payments/domain/entities/purchase_status.dart';

void main() {
  group('PurchaseStatus', () {
    group('fromString', () {
      test('should return pending for "pending"', () {
        expect(PurchaseStatus.fromString('pending'), PurchaseStatus.pending);
      });

      test('should return processing for "processing"', () {
        expect(
            PurchaseStatus.fromString('processing'), PurchaseStatus.processing);
      });

      test('should return requiresAction for "requires_action"', () {
        expect(PurchaseStatus.fromString('requires_action'),
            PurchaseStatus.requiresAction);
      });

      test('should return succeeded for "succeeded"', () {
        expect(
            PurchaseStatus.fromString('succeeded'), PurchaseStatus.succeeded);
      });

      test('should return failed for "failed"', () {
        expect(PurchaseStatus.fromString('failed'), PurchaseStatus.failed);
      });

      test('should return canceled for "canceled"', () {
        expect(PurchaseStatus.fromString('canceled'), PurchaseStatus.canceled);
      });

      test('should return refunded for "refunded"', () {
        expect(PurchaseStatus.fromString('refunded'), PurchaseStatus.refunded);
      });

      test('should return partiallyRefunded for "partially_refunded"', () {
        expect(PurchaseStatus.fromString('partially_refunded'),
            PurchaseStatus.partiallyRefunded);
      });

      test('should return disputed for "disputed"', () {
        expect(PurchaseStatus.fromString('disputed'), PurchaseStatus.disputed);
      });

      test('should return pending for unknown value', () {
        expect(PurchaseStatus.fromString('unknown'), PurchaseStatus.pending);
      });
    });

    group('toJson', () {
      test('should return "pending" for pending', () {
        expect(PurchaseStatus.pending.toJson(), 'pending');
      });

      test('should return "processing" for processing', () {
        expect(PurchaseStatus.processing.toJson(), 'processing');
      });

      test('should return "requires_action" for requiresAction', () {
        expect(PurchaseStatus.requiresAction.toJson(), 'requires_action');
      });

      test('should return "succeeded" for succeeded', () {
        expect(PurchaseStatus.succeeded.toJson(), 'succeeded');
      });

      test('should return "failed" for failed', () {
        expect(PurchaseStatus.failed.toJson(), 'failed');
      });

      test('should return "canceled" for canceled', () {
        expect(PurchaseStatus.canceled.toJson(), 'canceled');
      });

      test('should return "refunded" for refunded', () {
        expect(PurchaseStatus.refunded.toJson(), 'refunded');
      });

      test('should return "partially_refunded" for partiallyRefunded', () {
        expect(PurchaseStatus.partiallyRefunded.toJson(), 'partially_refunded');
      });

      test('should return "disputed" for disputed', () {
        expect(PurchaseStatus.disputed.toJson(), 'disputed');
      });
    });

    group('isTerminal', () {
      test('should return true for succeeded', () {
        expect(PurchaseStatus.succeeded.isTerminal, true);
      });

      test('should return true for failed', () {
        expect(PurchaseStatus.failed.isTerminal, true);
      });

      test('should return true for canceled', () {
        expect(PurchaseStatus.canceled.isTerminal, true);
      });

      test('should return true for refunded', () {
        expect(PurchaseStatus.refunded.isTerminal, true);
      });

      test('should return false for pending', () {
        expect(PurchaseStatus.pending.isTerminal, false);
      });

      test('should return false for processing', () {
        expect(PurchaseStatus.processing.isTerminal, false);
      });

      test('should return false for disputed', () {
        expect(PurchaseStatus.disputed.isTerminal, false);
      });
    });

    group('isSuccessful', () {
      test('should return true for succeeded', () {
        expect(PurchaseStatus.succeeded.isSuccessful, true);
      });

      test('should return false for pending', () {
        expect(PurchaseStatus.pending.isSuccessful, false);
      });

      test('should return false for failed', () {
        expect(PurchaseStatus.failed.isSuccessful, false);
      });
    });

    group('requiresUserAction', () {
      test('should return true for requiresAction', () {
        expect(PurchaseStatus.requiresAction.requiresUserAction, true);
      });

      test('should return false for other statuses', () {
        expect(PurchaseStatus.pending.requiresUserAction, false);
        expect(PurchaseStatus.succeeded.requiresUserAction, false);
      });
    });

    group('isPending', () {
      test('should return true for pending', () {
        expect(PurchaseStatus.pending.isPending, true);
      });

      test('should return true for processing', () {
        expect(PurchaseStatus.processing.isPending, true);
      });

      test('should return false for succeeded', () {
        expect(PurchaseStatus.succeeded.isPending, false);
      });
    });
  });
}
