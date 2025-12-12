import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '/core/utils/budget_formatter.dart';
import '/core/services/currency_service.dart';
import '/core/constants/currencies.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../sheets/add_expense_sheet.dart';

/// Budget Page - Full list of wedding expenses with CRUD and totals
class BudgetPage extends StatefulWidget {
  const BudgetPage({
    super.key,
    required this.weddingId,
    this.budgetMin,
    this.budgetMax,
    this.currency,
  });

  final String weddingId;
  final double? budgetMin;
  final double? budgetMax;
  final String? currency;

  static const String routeName = 'budget';
  static const String routePath = '/budget';

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _repository = MyWeddingRepositoryImpl();

  bool _isLoading = true;
  List<WeddingExpense> _expenses = [];
  String? _error;

  String get _displayCurrency => BudgetFormatter.userCurrency;
  String get _currencySymbol => CurrencyData.getSymbol(_displayCurrency);
  final _currencyService = CurrencyService.instance;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getWeddingExpenses(weddingId: widget.weddingId);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _expenses = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  void _openAddExpenseSheet({WeddingExpense? expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AddExpenseSheet(
          weddingId: widget.weddingId,
          currency: _currencySymbol,
          expense: expense,
          onSaved: _loadExpenses,
        ),
      ),
    );
  }

  Future<void> _deleteExpense(WeddingExpense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _repository.deleteWeddingExpense(expenseId: expense.id);

    if (!mounted) return;

    if (result.isSuccess) {
      _loadExpenses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expense deleted',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to delete expense'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  // Totals calculations (converted to user's preferred currency)
  double get _totalExpenses => _expenses.fold(0, (sum, e) => sum + _convertAmount(e.amount, sourceCurrency: e.currencyCode));
  double get _totalPaid => _expenses.fold(0, (sum, e) => sum + _convertAmount(e.paidAmount, sourceCurrency: e.currencyCode));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            if (!_isLoading && _error == null) _buildTotalsHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseSheet(),
        backgroundColor: LynewedColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Budget',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsHeader() {
    final hasBudget = widget.budgetMax != null && widget.budgetMax! > 0;
    final budgetMax = widget.budgetMax ?? 0;
    // Budget is stored on wedding in wedding currency; keep current behavior here (assume EUR if unknown)
    final budgetCurrency = widget.currency ?? 'EUR';
    final budgetMaxDisplay = _convertAmount(budgetMax.toDouble(), sourceCurrency: budgetCurrency);
    final totalExpensesDisplay = _totalExpenses;
    final totalPaidDisplay = _totalPaid;
    final totalPendingDisplay = totalExpensesDisplay - totalPaidDisplay;

    final progress = hasBudget && budgetMaxDisplay > 0
        ? (totalExpensesDisplay / budgetMaxDisplay).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = hasBudget && totalExpensesDisplay > budgetMaxDisplay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: LynewedColors.primary,
      child: Column(
        children: [
          // Main totals row
          Row(
            children: [
              Expanded(
                child: _buildTotalItem(
                  label: 'Total Expenses',
                  value: _formatAmount(totalExpensesDisplay),
                  isMain: true,
                ),
              ),
              if (hasBudget) ...[
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildTotalItem(
                    label: 'Budget',
                    value: _formatAmount(budgetMaxDisplay),
                    isMain: false,
                  ),
                ),
              ],
            ],
          ),
          if (hasBudget) ...[
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? LynewedColors.error : LynewedColors.textPrimary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            // Remaining/Over budget
            Text(
              isOverBudget
                  ? 'Over budget by ${_formatAmount(totalExpensesDisplay - budgetMaxDisplay)}'
                  : 'Remaining: ${_formatAmount(budgetMaxDisplay - totalExpensesDisplay)}',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isOverBudget
                    ? LynewedColors.error
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Paid vs Pending row
          Row(
            children: [
              Expanded(
                child: _buildSmallTotal(
                  label: 'Paid',
                  value: _formatAmount(totalPaidDisplay),
                  color: LynewedColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallTotal(
                  label: 'Pending',
                  value: _formatAmount(totalPendingDisplay),
                  color: LynewedColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem({
    required String label,
    required String value,
    required bool isMain,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: LynewedTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LynewedTextStyles.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTotal({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: LynewedColors.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: LynewedTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadExpenses,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_expenses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildExpenseTile(expense),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 24),
            Text(
              'No expenses yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your wedding expenses to stay on budget.',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Add Expense',
              onPressed: () => _openAddExpenseSheet(),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(WeddingExpense expense) {
    return GestureDetector(
      onTap: () => _openAddExpenseSheet(expense: expense),
      onLongPress: () => _showExpenseOptions(expense),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                size: 20,
                color: LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          expense.description?.isNotEmpty == true
                              ? expense.description!
                              : _formatCategory(expense.category),
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatAmount(_convertAmount(expense.amount, sourceCurrency: expense.currencyCode)),
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (expense.currencyCode != _displayCurrency) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${NumberFormat('#,##0', 'en_US').format(expense.amount.toInt())} ${CurrencyData.getSymbol(expense.currencyCode)}',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatusBadge(expense.status),
                      if (expense.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: LynewedColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(expense.dueDate!),
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (expense.status == ExpenseStatus.partial)
                        Text(
                          'Paid: ${_formatAmount(_convertAmount(expense.paidAmount, sourceCurrency: expense.currencyCode))}',
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ExpenseStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ExpenseStatus.paid:
        bgColor = LynewedColors.success.withValues(alpha: 0.1);
        textColor = LynewedColors.success;
        label = 'Paid';
        break;
      case ExpenseStatus.partial:
        bgColor = LynewedColors.warning.withValues(alpha: 0.1);
        textColor = LynewedColors.warning;
        label = 'Partial';
        break;
      case ExpenseStatus.pending:
        bgColor = LynewedColors.gray200;
        textColor = LynewedColors.textSecondary;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showExpenseOptions(WeddingExpense expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddExpenseSheet(expense: expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: LynewedColors.error),
                title: const Text('Delete', style: TextStyle(color: LynewedColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteExpense(expense);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  double _convertAmount(double amount, {required String sourceCurrency}) {
    final converted = _currencyService.convert(
      amount,
      from: sourceCurrency,
      to: _displayCurrency,
    );
    return converted ?? amount;
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount.toInt())} $_currencySymbol';
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'venue':
        return Icons.location_on_outlined;
      case 'photographer':
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'videographer':
      case 'videography':
        return Icons.videocam_outlined;
      case 'dress':
      case 'attire':
        return Icons.checkroom_outlined;
      case 'flowers':
      case 'florist':
        return Icons.local_florist_outlined;
      case 'catering':
      case 'food':
        return Icons.restaurant_outlined;
      case 'music':
      case 'dj':
      case 'band':
        return Icons.music_note_outlined;
      case 'decoration':
      case 'decor':
        return Icons.celebration_outlined;
      case 'cake':
        return Icons.cake_outlined;
      case 'makeup':
      case 'beauty':
      case 'hair':
        return Icons.face_outlined;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_outlined;
      case 'stationery':
      case 'invitations':
        return Icons.mail_outlined;
      case 'rings':
      case 'jewelry':
        return Icons.diamond_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}
