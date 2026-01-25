import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_expense.dart';

void main() {
  group('WeddingExpense', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WeddingExpense with required fields', () {
        const expense = WeddingExpense(
          id: 'expense-123',
          weddingId: 'wedding-456',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
        );

        expect(expense.id, 'expense-123');
        expect(expense.weddingId, 'wedding-456');
        expect(expense.category, 'photographer');
        expect(expense.amount, 3000);
        expect(expense.currencyCode, 'EUR');
        expect(expense.description, isNull);
        expect(expense.status, ExpenseStatus.pending);
        expect(expense.paidAmount, 0);
        expect(expense.dueDate, isNull);
        expect(expense.linkedProId, isNull);
        expect(expense.linkedProName, isNull);
        expect(expense.createdAt, isNull);
      });

      test('should create WeddingExpense with all optional fields', () {
        final dueDate = DateTime(2025, 6, 15);
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final expense = WeddingExpense(
          id: 'expense-123',
          weddingId: 'wedding-456',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
          description: 'Photographe principal',
          status: ExpenseStatus.partial,
          paidAmount: 1500,
          dueDate: dueDate,
          linkedProId: 'pro-789',
          linkedProName: 'Studio Photo',
          createdAt: createdAt,
        );

        expect(expense.description, 'Photographe principal');
        expect(expense.status, ExpenseStatus.partial);
        expect(expense.paidAmount, 1500);
        expect(expense.dueDate, dueDate);
        expect(expense.linkedProId, 'pro-789');
        expect(expense.linkedProName, 'Studio Photo');
        expect(expense.createdAt, createdAt);
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES TESTS
    // ==============================================================

    group('computed properties', () {
      group('remainingAmount', () {
        test('should calculate correctly when partially paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 2000,
          );

          expect(expense.remainingAmount, 3000);
        });

        test('should return full amount when nothing paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 0,
          );

          expect(expense.remainingAmount, 5000);
        });

        test('should return 0 when fully paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 5000,
          );

          expect(expense.remainingAmount, 0);
        });

        test('should handle overpayment (negative remaining)', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 6000,
          );

          expect(expense.remainingAmount, -1000);
        });
      });

      group('paymentProgress', () {
        test('should return 0.0 when nothing paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 0,
          );

          expect(expense.paymentProgress, 0.0);
        });

        test('should return 0.5 when half paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 2500,
          );

          expect(expense.paymentProgress, 0.5);
        });

        test('should return 1.0 when fully paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 5000,
          );

          expect(expense.paymentProgress, 1.0);
        });

        test('should return 0.0 when amount is 0', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 0,
            currencyCode: 'EUR',
            paidAmount: 0,
          );

          expect(expense.paymentProgress, 0.0);
        });

        test('should handle overpayment (greater than 1.0)', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            paidAmount: 7500,
          );

          expect(expense.paymentProgress, 1.5);
        });
      });

      group('isFullyPaid', () {
        test('should be true when status is paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            status: ExpenseStatus.paid,
            paidAmount: 0,
          );

          expect(expense.isFullyPaid, true);
        });

        test('should be true when paidAmount >= amount', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            status: ExpenseStatus.partial,
            paidAmount: 5000,
          );

          expect(expense.isFullyPaid, true);
        });

        test('should be true when paidAmount > amount (overpaid)', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            status: ExpenseStatus.partial,
            paidAmount: 6000,
          );

          expect(expense.isFullyPaid, true);
        });

        test('should be false when pending and not fully paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            status: ExpenseStatus.pending,
            paidAmount: 0,
          );

          expect(expense.isFullyPaid, false);
        });

        test('should be false when partial and not fully paid', () {
          const expense = WeddingExpense(
            id: 'exp-1',
            weddingId: 'wed-1',
            category: 'venue',
            amount: 5000,
            currencyCode: 'EUR',
            status: ExpenseStatus.partial,
            paidAmount: 2500,
          );

          expect(expense.isFullyPaid, false);
        });
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse expense with all fields', () {
        final json = {
          'id': 'expense-123',
          'wedding_id': 'wedding-456',
          'category': 'photographer',
          'description': 'Photographe principal',
          'amount': 3000.0,
          'currency_code': 'EUR',
          'status': 'partial',
          'paid_amount': 1500.0,
          'due_date': '2025-06-15T00:00:00Z',
          'linked_pro_id': 'pro-789',
          'linked_pro_name': 'Studio Photo',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final expense = WeddingExpense.fromJson(json);

        expect(expense.id, 'expense-123');
        expect(expense.weddingId, 'wedding-456');
        expect(expense.category, 'photographer');
        expect(expense.description, 'Photographe principal');
        expect(expense.amount, 3000.0);
        expect(expense.currencyCode, 'EUR');
        expect(expense.status, ExpenseStatus.partial);
        expect(expense.paidAmount, 1500.0);
        expect(expense.dueDate?.year, 2025);
        expect(expense.dueDate?.month, 6);
        expect(expense.dueDate?.day, 15);
        expect(expense.linkedProId, 'pro-789');
        expect(expense.linkedProName, 'Studio Photo');
        expect(expense.createdAt?.year, 2025);
      });

      test('should parse expense with minimal fields', () {
        final json = {
          'id': 'expense-123',
          'wedding_id': 'wedding-456',
          'category': 'venue',
          'amount': 10000,
        };

        final expense = WeddingExpense.fromJson(json);

        expect(expense.id, 'expense-123');
        expect(expense.weddingId, 'wedding-456');
        expect(expense.category, 'venue');
        expect(expense.amount, 10000);
        expect(expense.currencyCode, 'EUR'); // default
        expect(expense.description, isNull);
        expect(expense.status, ExpenseStatus.pending);
        expect(expense.paidAmount, 0);
        expect(expense.dueDate, isNull);
        expect(expense.linkedProId, isNull);
        expect(expense.linkedProName, isNull);
        expect(expense.createdAt, isNull);
      });

      test('should parse status "pending" correctly', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'status': 'pending',
        };

        expect(WeddingExpense.fromJson(json).status, ExpenseStatus.pending);
      });

      test('should parse status "partial" correctly', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'status': 'partial',
        };

        expect(WeddingExpense.fromJson(json).status, ExpenseStatus.partial);
      });

      test('should parse status "paid" correctly', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'status': 'paid',
        };

        expect(WeddingExpense.fromJson(json).status, ExpenseStatus.paid);
      });

      test('should default to pending for invalid status', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'status': 'invalid_status',
        };

        expect(WeddingExpense.fromJson(json).status, ExpenseStatus.pending);
      });

      test('should default to pending for null status', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'status': null,
        };

        expect(WeddingExpense.fromJson(json).status, ExpenseStatus.pending);
      });

      test('should uppercase currency_code', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'currency_code': 'eur',
        };

        expect(WeddingExpense.fromJson(json).currencyCode, 'EUR');
      });

      test('should default to EUR when currency_code is null', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
          'currency_code': null,
        };

        expect(WeddingExpense.fromJson(json).currencyCode, 'EUR');
      });

      test('should parse integer amount as double', () {
        final json = {
          'id': 'exp-1',
          'wedding_id': 'wed-1',
          'category': 'venue',
          'amount': 5000,
        };

        final parsedAmount = WeddingExpense.fromJson(json).amount;
        expect(parsedAmount, 5000.0);
        // Verify that integer input is converted to double
        expect(parsedAmount.runtimeType, double);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final dueDate = DateTime(2025, 6, 15);
        final expense = WeddingExpense(
          id: 'expense-123',
          weddingId: 'wedding-456',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
          description: 'Photographe principal',
          status: ExpenseStatus.partial,
          paidAmount: 1500,
          dueDate: dueDate,
          linkedProId: 'pro-789',
        );

        final json = expense.toJson();

        expect(json['wedding_id'], 'wedding-456');
        expect(json['category'], 'photographer');
        expect(json['description'], 'Photographe principal');
        expect(json['amount'], 3000);
        expect(json['currency_code'], 'EUR');
        expect(json['status'], 'partial');
        expect(json['paid_amount'], 1500);
        expect(json['due_date'], dueDate.toIso8601String());
        expect(json['linked_pro_id'], 'pro-789');
        // id, linked_pro_name, created_at are not serialized
        expect(json.containsKey('id'), false);
        expect(json.containsKey('linked_pro_name'), false);
        expect(json.containsKey('created_at'), false);
      });

      test('should serialize null optional fields', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );

        final json = expense.toJson();

        expect(json['description'], isNull);
        expect(json['due_date'], isNull);
        expect(json['linked_pro_id'], isNull);
      });

      test('should serialize pending status correctly', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          status: ExpenseStatus.pending,
        );

        expect(expense.toJson()['status'], 'pending');
      });

      test('should serialize paid status correctly', () {
        const expense = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          status: ExpenseStatus.paid,
        );

        expect(expense.toJson()['status'], 'paid');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final dueDate = DateTime(2025, 6, 15);
        final createdAt = DateTime(2025, 1, 24);
        final original = WeddingExpense(
          id: 'expense-123',
          weddingId: 'wedding-456',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'EUR',
          description: 'Original description',
          status: ExpenseStatus.partial,
          paidAmount: 1500,
          dueDate: dueDate,
          linkedProId: 'pro-789',
          linkedProName: 'Studio Photo',
          createdAt: createdAt,
        );

        final copied = original.copyWith(paidAmount: 2000);

        expect(copied.id, 'expense-123');
        expect(copied.weddingId, 'wedding-456');
        expect(copied.category, 'photographer');
        expect(copied.amount, 3000);
        expect(copied.currencyCode, 'EUR');
        expect(copied.description, 'Original description');
        expect(copied.status, ExpenseStatus.partial);
        expect(copied.paidAmount, 2000);
        expect(copied.dueDate, dueDate);
        expect(copied.linkedProId, 'pro-789');
        expect(copied.linkedProName, 'Studio Photo');
        expect(copied.createdAt, createdAt);
      });

      test('should update multiple fields at once', () {
        const original = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          status: ExpenseStatus.pending,
          paidAmount: 0,
        );

        final copied = original.copyWith(
          status: ExpenseStatus.paid,
          paidAmount: 5000,
        );

        expect(copied.status, ExpenseStatus.paid);
        expect(copied.paidAmount, 5000);
      });

      test('should not modify original', () {
        const original = WeddingExpense(
          id: 'exp-1',
          weddingId: 'wed-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 1000,
        );

        original.copyWith(paidAmount: 3000);

        expect(original.paidAmount, 1000);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        const expense1 = WeddingExpense(
          id: 'exp-123',
          weddingId: 'wed-456',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        const expense2 = WeddingExpense(
          id: 'exp-123',
          weddingId: 'wed-456',
          category: 'photographer',
          amount: 3000,
          currencyCode: 'USD',
        );

        expect(expense1, equals(expense2));
        expect(expense1.hashCode, equals(expense2.hashCode));
      });

      test('should not be equal when id differs', () {
        const expense1 = WeddingExpense(
          id: 'exp-123',
          weddingId: 'wed-456',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        const expense2 = WeddingExpense(
          id: 'exp-789',
          weddingId: 'wed-456',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );

        expect(expense1, isNot(equals(expense2)));
      });

      test('should return identical for same instance', () {
        const expense = WeddingExpense(
          id: 'exp-123',
          weddingId: 'wed-456',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );

        expect(expense == expense, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const expense = WeddingExpense(
          id: 'exp-123',
          weddingId: 'wed-456',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );

        final result = expense.toString();

        expect(result, contains('exp-123'));
        expect(result, contains('venue'));
        expect(result, contains('5000'));
      });
    });
  });

  // ==============================================================
  // EXPENSESTATUS ENUM TESTS
  // ==============================================================

  group('ExpenseStatus', () {
    test('should have all expected values', () {
      expect(ExpenseStatus.values, contains(ExpenseStatus.pending));
      expect(ExpenseStatus.values, contains(ExpenseStatus.partial));
      expect(ExpenseStatus.values, contains(ExpenseStatus.paid));
      expect(ExpenseStatus.values.length, 3);
    });
  });
}
