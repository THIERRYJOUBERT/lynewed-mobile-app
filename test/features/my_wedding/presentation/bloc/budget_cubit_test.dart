/// Tests for BudgetCubit and BudgetState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - All cubit methods (loadExpenses, addExpense, updateExpense, deleteExpense)
/// - Computed properties (totalBudget, totalPaid, totalRemaining, expensesByCategory)
/// - Error handling
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_expense.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/budget_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/budget_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('BudgetState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = BudgetState();

        expect(state.expenses, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        final expense = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );

        final state = BudgetState(
          expenses: [expense],
          isLoading: true,
          error: 'Some error',
        );

        expect(state.expenses, [expense]);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('totalBudget should return sum of all expense amounts', () {
        final expense1 = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final expense2 = WeddingExpense(
          id: 'expense-2',
          weddingId: 'wedding-1',
          category: 'photographer',
          amount: 2000,
          currencyCode: 'EUR',
        );

        final state = BudgetState(expenses: [expense1, expense2]);

        expect(state.totalBudget, 7000);
      });

      test('totalPaid should return sum of all paid amounts', () {
        final expense1 = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 2000,
        );
        final expense2 = WeddingExpense(
          id: 'expense-2',
          weddingId: 'wedding-1',
          category: 'photographer',
          amount: 2000,
          currencyCode: 'EUR',
          paidAmount: 500,
        );

        final state = BudgetState(expenses: [expense1, expense2]);

        expect(state.totalPaid, 2500);
      });

      test('totalRemaining should return difference between budget and paid', () {
        final expense1 = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 2000,
        );
        final expense2 = WeddingExpense(
          id: 'expense-2',
          weddingId: 'wedding-1',
          category: 'photographer',
          amount: 2000,
          currencyCode: 'EUR',
          paidAmount: 500,
        );

        final state = BudgetState(expenses: [expense1, expense2]);

        expect(state.totalRemaining, 4500);
      });

      test('expensesByCategory should group amounts by category', () {
        final expense1 = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final expense2 = WeddingExpense(
          id: 'expense-2',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 1000,
          currencyCode: 'EUR',
        );
        final expense3 = WeddingExpense(
          id: 'expense-3',
          weddingId: 'wedding-1',
          category: 'photographer',
          amount: 2000,
          currencyCode: 'EUR',
        );

        final state = BudgetState(expenses: [expense1, expense2, expense3]);

        expect(state.expensesByCategory, {
          'venue': 6000,
          'photographer': 2000,
        });
      });

      test('should return zero values when no expenses', () {
        const state = BudgetState();

        expect(state.totalBudget, 0);
        expect(state.totalPaid, 0);
        expect(state.totalRemaining, 0);
        expect(state.expensesByCategory, isEmpty);
      });

      test('totalPaid should handle expenses with zero paidAmount', () {
        final expense = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
          paidAmount: 0,
        );

        final state = BudgetState(expenses: [expense]);

        expect(state.totalPaid, 0);
        expect(state.totalRemaining, 5000);
      });
    });

    group('copyWith', () {
      test('should copy with new expenses', () {
        const original = BudgetState();
        final expense = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final copied = original.copyWith(expenses: [expense]);

        expect(copied.expenses, [expense]);
        expect(copied.isLoading, false);
        expect(copied.error, isNull);
      });

      test('should copy with new isLoading', () {
        const original = BudgetState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new error', () {
        const original = BudgetState();
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should clear error with clearError flag', () {
        const original = BudgetState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        final expense = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final state = BudgetState(
          expenses: [expense],
          isLoading: true,
        );
        final copied = state.copyWith(error: 'New error');

        expect(copied.expenses, [expense]);
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final expense = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final state1 = BudgetState(expenses: [expense]);
        final state2 = BudgetState(expenses: [expense]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different expenses', () {
        final expense1 = WeddingExpense(
          id: 'expense-1',
          weddingId: 'wedding-1',
          category: 'venue',
          amount: 5000,
          currencyCode: 'EUR',
        );
        final expense2 = WeddingExpense(
          id: 'expense-2',
          weddingId: 'wedding-1',
          category: 'photographer',
          amount: 2000,
          currencyCode: 'EUR',
        );
        final state1 = BudgetState(expenses: [expense1]);
        final state2 = BudgetState(expenses: [expense2]);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isLoading', () {
        const state1 = BudgetState(isLoading: true);
        const state2 = BudgetState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different error', () {
        const state1 = BudgetState(error: 'Error 1');
        const state2 = BudgetState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('BudgetCubit', () {
    late MockMyWeddingRepository mockRepository;
    const testWeddingId = 'wedding-123';
    const testCurrency = 'EUR';

    final testExpenses = [
      WeddingExpense(
        id: 'expense-1',
        weddingId: testWeddingId,
        category: 'venue',
        amount: 5000,
        currencyCode: testCurrency,
        paidAmount: 1000,
      ),
      WeddingExpense(
        id: 'expense-2',
        weddingId: testWeddingId,
        category: 'photographer',
        amount: 2000,
        currencyCode: testCurrency,
        paidAmount: 2000,
        status: ExpenseStatus.paid,
      ),
    ];

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = BudgetCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
          currency: testCurrency,
        );

        expect(cubit.state.expenses, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
        expect(cubit.weddingId, testWeddingId);
        expect(cubit.currency, testCurrency);

        cubit.close();
      });
    });

    group('loadExpenses', () {
      blocTest<BudgetCubit, BudgetState>(
        'should emit loading state then loaded state on success',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testExpenses));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          BudgetState(
            isLoading: false,
            expenses: testExpenses,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .called(1);
        },
      );

      blocTest<BudgetCubit, BudgetState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Network error'));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          const BudgetState(isLoading: false, error: 'Network error'),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle empty expenses list',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          const BudgetState(isLoading: false, expenses: []),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should clear error when reloading expenses',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testExpenses));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => const BudgetState(error: 'Previous error'),
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          BudgetState(isLoading: false, expenses: testExpenses),
        ],
      );
    });

    group('addExpense', () {
      blocTest<BudgetCubit, BudgetState>(
        'should add expense and add it to the list',
        build: () {
          final newExpense = WeddingExpense(
            id: 'expense-3',
            weddingId: testWeddingId,
            category: 'flowers',
            amount: 800,
            currencyCode: testCurrency,
          );
          when(() => mockRepository.createWeddingExpense(
                weddingId: testWeddingId,
                category: 'flowers',
                amount: 800,
                currencyCode: testCurrency,
                description: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer((_) async => RepositoryResult.success(newExpense));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.addExpense(
          category: 'flowers',
          amount: 800,
        ),
        expect: () => [
          const BudgetState(isLoading: true),
          isA<BudgetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.expenses.length, 'expenses.length', 1)
              .having((s) => s.expenses.first.category, 'expenses.first.category', 'flowers'),
        ],
        verify: (_) {
          verify(() => mockRepository.createWeddingExpense(
                weddingId: testWeddingId,
                category: 'flowers',
                amount: 800,
                currencyCode: testCurrency,
                description: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).called(1);
        },
      );

      blocTest<BudgetCubit, BudgetState>(
        'should add expense with all optional parameters',
        build: () {
          final dueDate = DateTime(2025, 8, 15);
          final newExpense = WeddingExpense(
            id: 'expense-3',
            weddingId: testWeddingId,
            category: 'flowers',
            description: 'Wedding bouquets',
            amount: 800,
            currencyCode: testCurrency,
            status: ExpenseStatus.partial,
            paidAmount: 200,
            dueDate: dueDate,
            linkedProId: 'pro-1',
          );
          when(() => mockRepository.createWeddingExpense(
                weddingId: testWeddingId,
                category: 'flowers',
                amount: 800,
                currencyCode: testCurrency,
                description: 'Wedding bouquets',
                status: 'partial',
                paidAmount: 200.0,
                dueDate: dueDate,
                linkedProId: 'pro-1',
              )).thenAnswer((_) async => RepositoryResult.success(newExpense));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.addExpense(
          category: 'flowers',
          amount: 800,
          description: 'Wedding bouquets',
          status: 'partial',
          paidAmount: 200,
          dueDate: DateTime(2025, 8, 15),
          linkedProId: 'pro-1',
        ),
        expect: () => [
          const BudgetState(isLoading: true),
          isA<BudgetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.expenses.first.description, 'description', 'Wedding bouquets')
              .having((s) => s.expenses.first.paidAmount, 'paidAmount', 200),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should emit error state on add failure',
        build: () {
          when(() => mockRepository.createWeddingExpense(
                weddingId: testWeddingId,
                category: 'flowers',
                amount: 800,
                currencyCode: testCurrency,
                description: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Creation failed'));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.addExpense(
          category: 'flowers',
          amount: 800,
        ),
        expect: () => [
          const BudgetState(isLoading: true),
          const BudgetState(isLoading: false, error: 'Creation failed'),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should add expense to existing list',
        build: () {
          final newExpense = WeddingExpense(
            id: 'expense-3',
            weddingId: testWeddingId,
            category: 'flowers',
            amount: 800,
            currencyCode: testCurrency,
          );
          when(() => mockRepository.createWeddingExpense(
                weddingId: testWeddingId,
                category: 'flowers',
                amount: 800,
                currencyCode: testCurrency,
                description: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer((_) async => RepositoryResult.success(newExpense));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.addExpense(
          category: 'flowers',
          amount: 800,
        ),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          isA<BudgetState>()
              .having((s) => s.expenses.length, 'expenses.length', 3)
              .having((s) => s.expenses.last.category, 'expenses.last.category', 'flowers'),
        ],
      );
    });

    group('updateExpense', () {
      blocTest<BudgetCubit, BudgetState>(
        'should update expense amount',
        build: () {
          when(() => mockRepository.updateWeddingExpense(
                expenseId: 'expense-1',
                amount: 6000.0,
                category: null,
                description: null,
                currencyCode: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.updateExpense(
          expenseId: 'expense-1',
          amount: 6000,
        ),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          isA<BudgetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.expenses.firstWhere((e) => e.id == 'expense-1').amount,
                'expense-1 amount',
                6000,
              ),
        ],
        verify: (_) {
          verify(() => mockRepository.updateWeddingExpense(
                expenseId: 'expense-1',
                amount: 6000.0,
                category: null,
                description: null,
                currencyCode: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).called(1);
        },
      );

      blocTest<BudgetCubit, BudgetState>(
        'should update expense paidAmount',
        build: () {
          when(() => mockRepository.updateWeddingExpense(
                expenseId: 'expense-1',
                paidAmount: 3000.0,
                category: null,
                description: null,
                amount: null,
                currencyCode: null,
                status: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.updateExpense(
          expenseId: 'expense-1',
          paidAmount: 3000,
        ),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          isA<BudgetState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.expenses.firstWhere((e) => e.id == 'expense-1').paidAmount,
                'expense-1 paidAmount',
                3000,
              ),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should emit error state on update failure',
        build: () {
          when(() => mockRepository.updateWeddingExpense(
                expenseId: 'expense-1',
                amount: 6000.0,
                category: null,
                description: null,
                currencyCode: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Update failed'));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.updateExpense(
          expenseId: 'expense-1',
          amount: 6000,
        ),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          BudgetState(
            expenses: testExpenses,
            isLoading: false,
            error: 'Update failed',
          ),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle updating non-existent expense gracefully',
        build: () {
          when(() => mockRepository.updateWeddingExpense(
                expenseId: 'non-existent',
                amount: 6000.0,
                category: null,
                description: null,
                currencyCode: null,
                status: null,
                paidAmount: null,
                dueDate: null,
                linkedProId: null,
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.updateExpense(
          expenseId: 'non-existent',
          amount: 6000,
        ),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          BudgetState(expenses: testExpenses, isLoading: false),
        ],
      );
    });

    group('deleteExpense', () {
      blocTest<BudgetCubit, BudgetState>(
        'should delete expense and remove it from list',
        build: () {
          when(() => mockRepository.deleteWeddingExpense(expenseId: 'expense-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.deleteExpense('expense-1'),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          BudgetState(
            expenses: [testExpenses[1]],
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteWeddingExpense(expenseId: 'expense-1'))
              .called(1);
        },
      );

      blocTest<BudgetCubit, BudgetState>(
        'should emit error state on deletion failure',
        build: () {
          when(() => mockRepository.deleteWeddingExpense(expenseId: 'expense-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Deletion failed'));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.deleteExpense('expense-1'),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          BudgetState(
            expenses: testExpenses,
            isLoading: false,
            error: 'Deletion failed',
          ),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle deleting non-existent expense gracefully',
        build: () {
          when(() => mockRepository.deleteWeddingExpense(expenseId: 'non-existent'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: testExpenses),
        act: (cubit) => cubit.deleteExpense('non-existent'),
        expect: () => [
          BudgetState(expenses: testExpenses, isLoading: true),
          BudgetState(expenses: testExpenses, isLoading: false),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle deleting last expense',
        build: () {
          when(() => mockRepository.deleteWeddingExpense(expenseId: 'expense-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        seed: () => BudgetState(expenses: [testExpenses.first]),
        act: (cubit) => cubit.deleteExpense('expense-1'),
        expect: () => [
          BudgetState(expenses: [testExpenses.first], isLoading: true),
          const BudgetState(expenses: [], isLoading: false),
        ],
      );
    });

    group('clearError', () {
      blocTest<BudgetCubit, BudgetState>(
        'should clear error state',
        build: () => BudgetCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
          currency: testCurrency,
        ),
        seed: () => const BudgetState(error: 'Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const BudgetState(error: null),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should preserve other state when clearing error',
        build: () => BudgetCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
          currency: testCurrency,
        ),
        seed: () => BudgetState(
          expenses: testExpenses,
          isLoading: false,
          error: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          BudgetState(
            expenses: testExpenses,
            isLoading: false,
            error: null,
          ),
        ],
      );
    });

    group('edge cases', () {
      blocTest<BudgetCubit, BudgetState>(
        'should handle null data from repository',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          const BudgetState(isLoading: false, expenses: []),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle very large amounts',
        build: () {
          final largeExpense = WeddingExpense(
            id: 'expense-large',
            weddingId: testWeddingId,
            category: 'venue',
            amount: 1000000000, // 1 billion
            currencyCode: testCurrency,
            paidAmount: 500000000,
          );
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success([largeExpense]));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const BudgetState(isLoading: true),
          isA<BudgetState>()
              .having((s) => s.totalBudget, 'totalBudget', 1000000000)
              .having((s) => s.totalPaid, 'totalPaid', 500000000)
              .having((s) => s.totalRemaining, 'totalRemaining', 500000000),
        ],
      );

      blocTest<BudgetCubit, BudgetState>(
        'should handle sequential operations',
        build: () {
          when(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testExpenses));
          return BudgetCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
            currency: testCurrency,
          );
        },
        act: (cubit) async {
          await cubit.loadExpenses();
          await cubit.loadExpenses();
        },
        expect: () => [
          const BudgetState(isLoading: true),
          BudgetState(isLoading: false, expenses: testExpenses),
          BudgetState(isLoading: true, expenses: testExpenses),
          BudgetState(isLoading: false, expenses: testExpenses),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingExpenses(weddingId: testWeddingId))
              .called(2);
        },
      );
    });
  });
}
