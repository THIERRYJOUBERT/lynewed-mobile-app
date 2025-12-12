import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';

/// Add/Edit Expense Sheet - Create or edit a wedding expense
class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.weddingId,
    required this.currency,
    this.expense,
    required this.onSaved,
  });

  final String weddingId;
  final String currency;
  final WeddingExpense? expense;
  final VoidCallback onSaved;

  bool get isEditing => expense != null;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _repository = MyWeddingRepositoryImpl();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _paidAmountController;

  String _selectedCategory = 'other';
  ExpenseStatus _status = ExpenseStatus.pending;
  DateTime? _dueDate;
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _categories = [
    {'value': 'venue', 'label': 'Venue', 'icon': Icons.location_on_outlined},
    {'value': 'photographer', 'label': 'Photographer', 'icon': Icons.camera_alt_outlined},
    {'value': 'videographer', 'label': 'Videographer', 'icon': Icons.videocam_outlined},
    {'value': 'dress', 'label': 'Dress & Attire', 'icon': Icons.checkroom_outlined},
    {'value': 'flowers', 'label': 'Flowers', 'icon': Icons.local_florist_outlined},
    {'value': 'catering', 'label': 'Catering', 'icon': Icons.restaurant_outlined},
    {'value': 'music', 'label': 'Music & DJ', 'icon': Icons.music_note_outlined},
    {'value': 'decoration', 'label': 'Decoration', 'icon': Icons.celebration_outlined},
    {'value': 'cake', 'label': 'Cake', 'icon': Icons.cake_outlined},
    {'value': 'beauty', 'label': 'Beauty & Hair', 'icon': Icons.face_outlined},
    {'value': 'transport', 'label': 'Transport', 'icon': Icons.directions_car_outlined},
    {'value': 'stationery', 'label': 'Stationery', 'icon': Icons.mail_outlined},
    {'value': 'rings', 'label': 'Rings & Jewelry', 'icon': Icons.diamond_outlined},
    {'value': 'other', 'label': 'Other', 'icon': Icons.receipt_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toStringAsFixed(0) : '',
    );
    _paidAmountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.paidAmount.toStringAsFixed(0) : '',
    );

    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _status = widget.expense!.status;
      _dueDate = widget.expense!.dueDate;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LynewedColors.primary,
              onPrimary: Colors.white,
              surface: LynewedColors.background,
              onSurface: LynewedColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0;

    if (widget.isEditing) {
      final result = await _repository.updateWeddingExpense(
        expenseId: widget.expense!.id,
        category: _selectedCategory,
        description: description.isNotEmpty ? description : null,
        amount: amount,
        status: _status.name,
        paidAmount: paidAmount,
        dueDate: _dueDate,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Expense updated',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update expense'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } else {
      final result = await _repository.createWeddingExpense(
        weddingId: widget.weddingId,
        category: _selectedCategory,
        amount: amount,
        description: description.isNotEmpty ? description : null,
        status: _status.name,
        paidAmount: paidAmount,
        dueDate: _dueDate,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Expense added',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to add expense'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: widget.isEditing ? 'Edit Expense' : 'Add Expense',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: widget.isEditing ? 'Save Changes' : 'Add Expense',
          onPressed: _isSaving ? null : _save,
          isLoading: _isSaving,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category
            _buildSectionTitle('Category *'),
            _buildCategorySelector(),
            const SizedBox(height: 30),

            // Amount
            _buildSectionTitle('Amount *'),
            Row(
              children: [
                Expanded(
                  child: LynewedTextField(
                    controller: _amountController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    isValueInput: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      widget.currency,
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Description
            _buildSectionTitle('Description'),
            LynewedTextField(
              controller: _descriptionController,
              hint: 'e.g., Deposit for venue, Final payment...',
            ),
            const SizedBox(height: 30),

            // Status
            _buildSectionTitle('Payment Status'),
            _buildStatusSelector(),
            const SizedBox(height: 30),

            // Paid Amount (only if partial)
            if (_status == ExpenseStatus.partial) ...[
              _buildSectionTitle('Amount Paid'),
              Row(
                children: [
                  Expanded(
                    child: LynewedTextField(
                      controller: _paidAmountController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isValueInput: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: LynewedColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        widget.currency,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],

            // Due Date
            _buildSectionTitle('Due Date'),
            _buildDateInput(
              date: _dueDate,
              placeholder: 'Select due date (optional)',
              onTap: _selectDueDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: LynewedTextStyles.sectionTitle),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['value'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? LynewedColors.primary : LynewedColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : LynewedColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  cat['label'] as String,
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : LynewedColors.textPrimary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        _buildStatusOption(ExpenseStatus.pending, 'Pending'),
        const SizedBox(width: 8),
        _buildStatusOption(ExpenseStatus.partial, 'Partial'),
        const SizedBox(width: 8),
        _buildStatusOption(ExpenseStatus.paid, 'Paid'),
      ],
    );
  }

  Widget _buildStatusOption(ExpenseStatus status, String label) {
    final isSelected = _status == status;
    Color borderColor;
    Color bgColor;

    switch (status) {
      case ExpenseStatus.paid:
        borderColor = isSelected ? LynewedColors.success : LynewedColors.gray200;
        bgColor = isSelected ? LynewedColors.success.withValues(alpha: 0.1) : Colors.transparent;
        break;
      case ExpenseStatus.partial:
        borderColor = isSelected ? LynewedColors.warning : LynewedColors.gray200;
        bgColor = isSelected ? LynewedColors.warning.withValues(alpha: 0.1) : Colors.transparent;
        break;
      case ExpenseStatus.pending:
        borderColor = isSelected ? LynewedColors.primary : LynewedColors.gray200;
        bgColor = isSelected ? LynewedColors.primary.withValues(alpha: 0.05) : Colors.transparent;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = status),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? borderColor : LynewedColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput({
    required DateTime? date,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: date != null
                  ? LynewedColors.textPrimary
                  : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? dateFormat.format(date) : placeholder,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: date != null
                      ? LynewedColors.textPrimary
                      : LynewedColors.textSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: () => setState(() => _dueDate = null),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: LynewedColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
