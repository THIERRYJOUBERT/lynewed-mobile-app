/// Budget State for BudgetCubit.
///
/// Defines the state for managing wedding expenses/budget.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/wedding_expense.dart';

/// State for the budget Cubit.
///
/// Tracks the expenses list, loading state, and errors.
@immutable
class BudgetState {
  /// Creates a budget state.
  const BudgetState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of all wedding expenses.
  final List<WeddingExpense> expenses;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns the total budget (sum of all expense amounts).
  double get totalBudget =>
      expenses.fold<double>(0, (sum, e) => sum + e.amount);

  /// Returns the total amount paid.
  double get totalPaid =>
      expenses.fold<double>(0, (sum, e) => sum + e.paidAmount);

  /// Returns the total remaining to pay.
  double get totalRemaining => totalBudget - totalPaid;

  /// Returns expenses grouped by category with their totals.
  Map<String, double> get expensesByCategory {
    final result = <String, double>{};
    for (final expense in expenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  BudgetState copyWith({
    List<WeddingExpense>? expenses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BudgetState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetState &&
        listEquals(other.expenses, expenses) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(expenses),
        isLoading,
        error,
      );
}
