/// Budget Cubit for managing wedding expenses state.
///
/// Handles loading expenses, adding expenses, updating expenses,
/// and deleting expenses.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wedding_expense.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'budget_state.dart';

/// Cubit for managing wedding expenses/budget state.
///
/// Provides methods for loading expenses, adding/updating/deleting expenses.
class BudgetCubit extends Cubit<BudgetState> {
  /// Creates a BudgetCubit with the given repository, wedding ID, and currency.
  BudgetCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
    required this.currency,
  })  : _repository = repository,
        super(const BudgetState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// The currency code for expenses.
  final String currency;

  /// Loads all expenses for this wedding.
  ///
  /// Emits loading state first, then the loaded expenses or error.
  Future<void> loadExpenses() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getWeddingExpenses(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        expenses: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to load expenses',
      ));
    }
  }

  /// Adds a new expense.
  ///
  /// On success, adds the new expense to the list.
  /// On failure, emits an error state.
  Future<void> addExpense({
    required String category,
    required double amount,
    String? description,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.createWeddingExpense(
      weddingId: weddingId,
      category: category,
      amount: amount,
      currencyCode: currency,
      description: description,
      status: status,
      paidAmount: paidAmount,
      dueDate: dueDate,
      linkedProId: linkedProId,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        isLoading: false,
        expenses: [...state.expenses, result.data!],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to add expense',
      ));
    }
  }

  /// Updates an existing expense.
  ///
  /// On success, updates the expense in the list locally.
  /// On failure, emits an error state.
  Future<void> updateExpense({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    String? currencyCode,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.updateWeddingExpense(
      expenseId: expenseId,
      category: category,
      description: description,
      amount: amount,
      currencyCode: currencyCode,
      status: status,
      paidAmount: paidAmount,
      dueDate: dueDate,
      linkedProId: linkedProId,
    );

    if (result.isSuccess) {
      // Update the expense locally
      final updatedExpenses = state.expenses.map((e) {
        if (e.id == expenseId) {
          return e.copyWith(
            category: category ?? e.category,
            description: description ?? e.description,
            amount: amount ?? e.amount,
            currencyCode: currencyCode ?? e.currencyCode,
            status: status != null ? _parseStatus(status) : e.status,
            paidAmount: paidAmount ?? e.paidAmount,
            dueDate: dueDate ?? e.dueDate,
            linkedProId: linkedProId ?? e.linkedProId,
          );
        }
        return e;
      }).toList();

      emit(state.copyWith(
        isLoading: false,
        expenses: updatedExpenses,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to update expense',
      ));
    }
  }

  /// Parses expense status string to enum.
  ExpenseStatus _parseStatus(String status) {
    switch (status) {
      case 'partial':
        return ExpenseStatus.partial;
      case 'paid':
        return ExpenseStatus.paid;
      default:
        return ExpenseStatus.pending;
    }
  }

  /// Deletes an expense.
  ///
  /// On success, removes the expense from the list.
  /// On failure, emits an error state.
  Future<void> deleteExpense(String expenseId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.deleteWeddingExpense(expenseId: expenseId);

    if (result.isSuccess) {
      final updatedExpenses =
          state.expenses.where((e) => e.id != expenseId).toList();

      emit(state.copyWith(
        isLoading: false,
        expenses: updatedExpenses,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to delete expense',
      ));
    }
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
