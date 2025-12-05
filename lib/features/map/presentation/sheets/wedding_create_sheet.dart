/// Wedding create/edit sheet widget
/// 
/// Sheet for brides to create or edit their wedding.
/// Phase 5: Hub central per bride - 1 wedding per bride.
/// Refactored to use Lynewed Design System Widgets (v2.0).
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '/core/constants/currencies.dart';
import '/core/utils/distance_formatter.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/structs/index.dart';
import '../../domain/entities/wedding_details.dart';
import '../../domain/entities/professional_details.dart';
import '../../data/datasources/supabase_map_datasource.dart';

class WeddingCreateSheet extends StatefulWidget {
  const WeddingCreateSheet({
    super.key,
    this.existingWedding,
    this.onSaved,
    this.onDeleted,
  });

  final Map<String, dynamic>? existingWedding;
  final VoidCallback? onSaved;
  final VoidCallback? onDeleted;

  @override
  State<WeddingCreateSheet> createState() => _WeddingCreateSheetState();
}

class _WeddingCreateSheetState extends State<WeddingCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _datasource = SupabaseMapDatasource();
  
  // Form controllers ! 
  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  
  // Form state
  DateTime? _eventDate;
  DateTime? _eventEndDate;
  int _searchRadius = 50;
  String _currency = 'EUR';
  WeddingVisibility _visibility = WeddingVisibility.private;
  List<Profession> _selectedProfessions = [];
  
  // Location
  double? _venueLat;
  double? _venueLng;
  
  // UI state
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingWedding != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    if (_isEditing) {
      _loadExistingData();
    }
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _venueController = TextEditingController();
    _budgetMinController = TextEditingController();
    _budgetMaxController = TextEditingController();
  }

  void _loadExistingData() {
    final data = widget.existingWedding!;
    _nameController.text = data['weddingName']?.toString() ?? '';
    _venueController.text = data['venueLabel']?.toString() ?? '';
    _budgetMinController.text = data['budgetMin']?.toString() ?? '';
    _budgetMaxController.text = data['budgetMax']?.toString() ?? '';
    
    _eventDate = DateTime.tryParse(data['eventDate']?.toString() ?? '');
    _eventEndDate = DateTime.tryParse(data['eventEndDate']?.toString() ?? '');
    _searchRadius = _normalizeRadius((data['searchRadiusKm'] as num?)?.toInt() ?? 50);
    _currency = data['currency']?.toString() ?? 'EUR';
    _visibility = WeddingVisibility.fromString(data['visibility']?.toString());
    
    _venueLat = (data['venueLat'] as num?)?.toDouble();
    _venueLng = (data['venueLng'] as num?)?.toDouble();
    
    final profs = data['professionsNeeded'];
    if (profs is List) {
      _selectedProfessions = profs
          .map((p) => Profession.fromString(p?.toString()))
          .toList();
    }
  }
  
  int _normalizeRadius(int value) {
    const allowed = [5, 10, 20, 50, 100];
    if (allowed.contains(value)) return value;
    int closest = allowed.first;
    int minDiff = (value - closest).abs();
    for (final r in allowed) {
      final diff = (value - r).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = r;
      }
    }
    return closest;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isEndDate) async {
    final initialDate = isEndDate 
        ? (_eventEndDate ?? _eventDate ?? DateTime.now().add(const Duration(days: 365)))
        : (_eventDate ?? DateTime.now().add(const Duration(days: 365)));
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LynewedColors.primary,
              onPrimary: LynewedColors.textOnPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _eventEndDate = picked;
        } else {
          _eventDate = picked;
          if (_eventEndDate != null && _eventEndDate!.isBefore(picked)) {
            _eventEndDate = null;
          }
        }
      });
    }
  }

  String? _validateForm() {
    if (_eventDate == null) return 'Please select a wedding date';
    if (_eventDate!.isBefore(DateTime.now())) return 'Wedding date must be in the future';
    if (_venueLat == null || _venueLng == null) return 'Please select a venue from suggestions';
    if (_selectedProfessions.isEmpty) return 'Select at least one profession';
    
    final budgetMin = int.tryParse(_budgetMinController.text);
    final budgetMax = int.tryParse(_budgetMaxController.text);
    if (budgetMin != null && budgetMax != null && budgetMin > budgetMax) {
      return 'Min budget cannot be greater than Max budget';
    }
    return null;
  }

  Future<void> _saveWedding() async {
    if (!_formKey.currentState!.validate()) return;
    
    final validationError = _validateForm();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _datasource.upsertWedding(
        weddingName: _nameController.text.isNotEmpty ? _nameController.text : null,
        eventDate: _eventDate!,
        eventEndDate: _eventEndDate,
        venueLat: _venueLat,
        venueLng: _venueLng,
        venueLabel: _venueController.text.isNotEmpty ? _venueController.text : null,
        searchRadiusKm: _searchRadius,
        budgetMin: int.tryParse(_budgetMinController.text),
        budgetMax: int.tryParse(_budgetMaxController.text),
        currency: _currency,
        professionsNeeded: _selectedProfessions.map((p) => p.toRpcValue).toList(),
        visibility: _visibility == WeddingVisibility.visibleToPros ? 'visible_to_pros' : 'private',
      );

      if (result?['error'] != null) {
        setState(() => _errorMessage = result!['error'].toString());
      } else {
        widget.onSaved?.call();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save wedding: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteWedding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wedding?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final success = await _datasource.deleteMyWedding();
      if (success) {
        widget.onDeleted?.call();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _errorMessage = 'Failed to delete wedding');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to delete wedding: $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: _isEditing ? 'Edit Wedding' : 'Create Wedding',
      onClose: () => Navigator.of(context).pop(),
      bottomAction: Column(
        children: [
          LynewedButton(
            text: _isEditing ? 'Save Changes' : 'Create Wedding',
            onPressed: _isLoading ? null : _saveWedding,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            LynewedButton(
              text: 'Delete Wedding',
              onPressed: _isDeleting ? null : _deleteWedding,
              isLoading: _isDeleting,
              type: LynewedButtonType.destructive,
              width: double.infinity,
            ),
          ],
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) _buildErrorBanner(),
            
            // Wedding Name
            LynewedTextField(
              controller: _nameController,
              label: 'Wedding Name (optional)',
              hint: 'e.g., Sophie & Thomas Wedding',
            ),
            const SizedBox(height: 30),

            // Date Section
            _buildSectionTitle('Wedding Date *'),
            Row(
              children: [
                Expanded(
                  child: _buildDateInput(
                    date: _eventDate,
                    placeholder: 'Select date',
                    onTap: () => _selectDate(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateInput(
                    date: _eventEndDate,
                    placeholder: 'End date (opt)',
                    onTap: _eventDate != null ? () => _selectDate(true) : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Venue Section
            _buildSectionTitle('Venue / Location *'),
            AddressSearchWidget(
              hintText: 'Search venue address...',
              initialValue: _venueController.text,
              locale: 'fr',
              useOverlay: true,
              suggestionsPosition: SuggestionsPosition.below,
              onAddressSelected: (PlaceDetailsDataStruct details) {
                setState(() {
                  _venueController.text = details.formattedAddress;
                  if (details.coords != null) {
                    _venueLat = details.coords!.latitude;
                    _venueLng = details.coords!.longitude;
                  }
                });
              },
              onAddressCleared: () {
                setState(() {
                  _venueController.clear();
                  _venueLat = null;
                  _venueLng = null;
                });
              },
            ),
            if (_venueController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildLocationStatus(),
            ],
            const SizedBox(height: 30),

            // Budget Section
            _buildSectionTitle('Budget Range'),
            Row(
              children: [
                Expanded(
                  child: LynewedTextField(
                    controller: _budgetMinController,
                    hint: 'Min',
                    keyboardType: TextInputType.number,
                    isValueInput: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(_getCurrencySymbol(_currency)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('-', style: TextStyle(fontSize: 20, color: LynewedColors.gray300)),
                ),
                Expanded(
                  child: LynewedTextField(
                    controller: _budgetMaxController,
                    hint: 'Max',
                    keyboardType: TextInputType.number,
                    isValueInput: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(_getCurrencySymbol(_currency)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildCurrencySelector(),
              ],
            ),
            const SizedBox(height: 30),

            // Professions Section
            _buildSectionTitle('Professionals Needed *'),
            if (_selectedProfessions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${_selectedProfessions.length} selected',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Profession.values.where((p) => p != Profession.other).map((profession) {
                return LynewedChip(
                  label: profession.displayName,
                  selected: _selectedProfessions.contains(profession),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProfessions.add(profession);
                      } else {
                        _selectedProfessions.remove(profession);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Radius Section (uses user's preferred unit: km or miles)
            _buildSectionTitle('Search Radius'),
            LynewedSlider(
              value: _searchRadius,
              steps: _allowedRadii,
              suffix: ' ${DistanceFormatter.unitAbbreviation}',
              formatValue: (value) {
                // Convert km to user's unit for display
                final converted = DistanceFormatter.convertFromKm(value.toDouble());
                return '${converted.round()} ${DistanceFormatter.unitAbbreviation}';
              },
              onChanged: (value) => setState(() => _searchRadius = value),
            ),
            const SizedBox(height: 30),

            // Visibility Section
            _buildSectionTitle('Visibility'),
            Row(
              children: [
                Expanded(
                  child: _buildVisibilityOption(
                    WeddingVisibility.private,
                    Icons.visibility_off_outlined,
                    'Private',
                    'Only you can see',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVisibilityOption(
                    WeddingVisibility.visibleToPros,
                    Icons.visibility_outlined,
                    'Visible',
                    'Premium pros can see',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _allowedRadii = [5, 10, 20, 50, 100];

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: LynewedTextStyles.sectionTitle),
    );
  }

  Widget _buildDateInput({
    required DateTime? date,
    required String placeholder,
    required VoidCallback? onTap,
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
              color: date != null ? LynewedColors.textPrimary : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              date != null ? dateFormat.format(date) : placeholder,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: date != null ? LynewedColors.textPrimary : LynewedColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    final hasLocation = _venueLat != null && _venueLng != null;
    return Row(
      children: [
        Icon(
          hasLocation ? Icons.check_circle : Icons.warning_amber_rounded,
          size: 16,
          color: hasLocation ? LynewedColors.success : LynewedColors.warning,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hasLocation 
                ? 'Location confirmed - will appear on map'
                : 'Please select an address from suggestions',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: hasLocation ? LynewedColors.success : LynewedColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    final currency = CurrencyData.getByCode(_currency);
    return InkWell(
      onTap: _showCurrencyPicker,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency?.symbol ?? _currency,
              style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(
    WeddingVisibility value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _visibility == value;
    return InkWell(
      onTap: () => setState(() => _visibility = value),
      child: Container(
        height: 80, // Fixed height for alignment
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : LynewedColors.gray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : LynewedColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: LynewedTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : LynewedColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: LynewedComponentStyles.errorBannerDecoration(),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    return CurrencyData.getSymbolPrefix(currency);
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CurrencyPickerSheet(
        selectedCode: _currency,
        onSelected: (code) {
          setState(() => _currency = code);
          Navigator.pop(ctx);
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
    return LynewedSheet(
      title: 'Select Currency',
      onClose: () => Navigator.pop(context),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            LynewedTextField(
              controller: _searchController,
              hint: 'Search currency...',
              prefixIcon: const Icon(Icons.search),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredCurrencies.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  final isSelected = currency.code == widget.selectedCode;
                  return ListTile(
                    title: Text('${currency.name} (${currency.code})', style: LynewedTextStyles.bodyMedium),
                    trailing: isSelected ? const Icon(Icons.check, color: LynewedColors.primary) : null,
                    onTap: () => widget.onSelected(currency.code),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
