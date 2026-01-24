import 'package:flutter/material.dart';
import '/core/constants/currencies.dart';
import '/core/design/design.dart';

/// A searchable dropdown for selecting currencies
/// Use this widget anywhere currency selection is needed
class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.showSymbol = true,
    this.compact = false,
    this.filled = false,
  });

  /// Current selected currency code (e.g., 'EUR', 'USD')
  final String value;

  /// Callback when currency is selected
  final ValueChanged<String> onChanged;

  /// Optional label above the dropdown
  final String? label;

  /// Show currency symbol next to code
  final bool showSymbol;

  /// Compact mode for inline usage
  final bool compact;

  /// Filled mode: grey background instead of border (for Preferences page)
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactDropdown(context);
    }
    return _buildFullDropdown(context);
  }

  Widget _buildCompactDropdown(BuildContext context) {
    final currency = CurrencyData.getByCode(value);
    return InkWell(
      onTap: () => _showCurrencyPicker(context),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: LynewedColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showSymbol && currency != null
                  ? '${currency.symbol} ${currency.code}'
                  : value,
              style: LynewedTextStyles.bodyMedium,
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: LynewedColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDropdown(BuildContext context) {
    final currency = CurrencyData.getByCode(value);
    
    // Display text: shorter for filled mode
    final displayText = currency != null
        ? (filled 
            ? '${currency.symbol} ${currency.code}' 
            : '${currency.symbol} ${currency.code} - ${currency.name}')
        : value;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: LynewedTextStyles.labelMedium),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _showCurrencyPicker(context),
          borderRadius: BorderRadius.circular(filled ? 4 : 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: filled ? const Color(0xFFF2F2F2) : null,
              border: filled ? null : Border.all(color: LynewedColors.border),
              borderRadius: BorderRadius.circular(filled ? 4 : 8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: filled ? FontWeight.w300 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  filled ? Icons.keyboard_arrow_down : Icons.arrow_drop_down, 
                  color: LynewedColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CurrencyPickerSheet(
        selectedCode: value,
        onSelected: (code) {
          onChanged(code);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.selectedCode,
    required this.onSelected,
  });

  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  List<CurrencyData> _filteredCurrencies = CurrencyData.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredCurrencies = CurrencyData.search(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LynewedColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Currency',
              style: LynewedTextStyles.titleMedium,
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: false,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Currency list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected = currency.code == widget.selectedCode;
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LynewedColors.primary.withValues(alpha: 0.1)
                          : LynewedColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currency.symbol,
                      style: LynewedTextStyles.titleSmall.copyWith(
                        color: isSelected ? LynewedColors.primary : LynewedColors.textPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    currency.code,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    currency.name,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: LynewedColors.primary)
                      : null,
                  onTap: () => widget.onSelected(currency.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
