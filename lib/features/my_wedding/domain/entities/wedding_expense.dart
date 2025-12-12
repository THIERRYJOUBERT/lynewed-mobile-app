/// Wedding Expense entity for My Wedding Suite
///
/// Represents an expense in the wedding budget tracker.
/// Simple todo list of expenses with payment states.
library;

import 'package:flutter/foundation.dart';

/// Expense status enum
enum ExpenseStatus {
  pending,
  partial,
  paid,
}

/// Wedding Expense entity
@immutable
class WeddingExpense {
  const WeddingExpense({
    required this.id,
    required this.weddingId,
    required this.category,
    required this.amount,
    required this.currencyCode,
    this.description,
    this.status = ExpenseStatus.pending,
    this.paidAmount = 0,
    this.dueDate,
    this.linkedProId,
    this.linkedProName,
    this.createdAt,
  });

  /// UUID of the expense
  final String id;

  /// UUID of the wedding
  final String weddingId;

  /// Expense category (venue, photographer, dress, flowers, etc.)
  final String category;

  /// Expense description
  final String? description;

  /// Total amount
  final double amount;

  /// Currency code of the amount (e.g. EUR, USD)
  final String currencyCode;

  /// Payment status
  final ExpenseStatus status;

  /// Amount already paid
  final double paidAmount;

  /// Due date for payment
  final DateTime? dueDate;

  /// Linked professional ID (optional)
  final String? linkedProId;

  /// Linked professional name (for display)
  final String? linkedProName;

  /// Creation date
  final DateTime? createdAt;

  /// Remaining amount to pay
  double get remainingAmount => amount - paidAmount;

  /// Payment progress (0.0 to 1.0)
  double get paymentProgress => amount > 0 ? paidAmount / amount : 0;

  /// Check if fully paid
  bool get isFullyPaid => status == ExpenseStatus.paid || paidAmount >= amount;

  /// Factory from Supabase JSON
  factory WeddingExpense.fromJson(Map<String, dynamic> json) {
    return WeddingExpense(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: (json['currency_code'] as String?)?.toUpperCase() ?? 'EUR',
      status: _parseStatus(json['status'] as String?),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String) 
          : null,
      linkedProId: json['linked_pro_id'] as String?,
      linkedProName: json['linked_pro_name'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  static ExpenseStatus _parseStatus(String? value) {
    switch (value) {
      case 'partial':
        return ExpenseStatus.partial;
      case 'paid':
        return ExpenseStatus.paid;
      default:
        return ExpenseStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'category': category,
      'description': description,
      'amount': amount,
      'currency_code': currencyCode,
      'status': status.name,
      'paid_amount': paidAmount,
      'due_date': dueDate?.toIso8601String(),
      'linked_pro_id': linkedProId,
    };
  }

  WeddingExpense copyWith({
    String? id,
    String? weddingId,
    String? category,
    String? description,
    double? amount,
    String? currencyCode,
    ExpenseStatus? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
    String? linkedProName,
    DateTime? createdAt,
  }) {
    return WeddingExpense(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      linkedProId: linkedProId ?? this.linkedProId,
      linkedProName: linkedProName ?? this.linkedProName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingExpense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WeddingExpense($id, $category, $amount)';
}
