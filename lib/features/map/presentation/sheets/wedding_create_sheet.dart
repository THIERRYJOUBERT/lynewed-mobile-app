/// Wedding create/edit sheet widget
/// 
/// Sheet for brides to create or edit their wedding.
/// Phase 5: Hub central per bride - 1 wedding per bride.
/// Phase 5.1: AddressSearch integration + validation improvements.
/// Uses Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design/design.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/structs/index.dart';
import '../../domain/entities/wedding_details.dart';
import '../../domain/entities/professional_details.dart';
import '../../data/datasources/supabase_map_datasource.dart';

/// Wedding create/edit bottom sheet
class WeddingCreateSheet extends StatefulWidget {
  const WeddingCreateSheet({
    super.key,
    this.existingWedding,
    this.onSaved,
    this.onDeleted,
  });

  /// Existing wedding data for editing (null for create)
  final Map<String, dynamic>? existingWedding;
  
  /// Callback when wedding is saved
  final VoidCallback? onSaved;
  
  /// Callback when wedding is deleted
  final VoidCallback? onDeleted;

  @override
  State<WeddingCreateSheet> createState() => _WeddingCreateSheetState();
}

class _WeddingCreateSheetState extends State<WeddingCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _datasource = SupabaseMapDatasource();
  
  // Form controllers
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
    
    // Parse professions
    final profs = data['professionsNeeded'];
    if (profs is List) {
      _selectedProfessions = profs
          .map((p) => Profession.fromString(p?.toString()))
          .toList();
    }
  }
  
  /// Normalize radius to nearest allowed value (DB constraint: 5, 10, 20, 50, 100)
  int _normalizeRadius(int value) {
    const allowed = [5, 10, 20, 50, 100];
    if (allowed.contains(value)) return value;
    
    // Find closest allowed value
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
            colorScheme: ColorScheme.light(
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
          // Reset end date if it's before start date
          if (_eventEndDate != null && _eventEndDate!.isBefore(picked)) {
            _eventEndDate = null;
          }
        }
      });
    }
  }

  /// Validates all form fields and returns error message if invalid
  String? _validateForm() {
    // 1. Event date is required and must be in the future
    if (_eventDate == null) {
      return 'Please select a wedding date';
    }
    if (_eventDate!.isBefore(DateTime.now())) {
      return 'Wedding date must be in the future';
    }
    
    // 2. Venue with coordinates is required for map display
    if (_venueLat == null || _venueLng == null) {
      return 'Please select a venue from the address suggestions to get coordinates';
    }
    
    // 3. At least one profession must be selected
    if (_selectedProfessions.isEmpty) {
      return 'Please select at least one profession you need';
    }
    
    // 4. Budget validation: min must be less than max if both provided
    final budgetMin = int.tryParse(_budgetMinController.text);
    final budgetMax = int.tryParse(_budgetMaxController.text);
    if (budgetMin != null && budgetMax != null && budgetMin > budgetMax) {
      return 'Minimum budget cannot be greater than maximum budget';
    }
    
    return null; // All validations passed
  }

  Future<void> _saveWedding() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Run custom validations
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
        content: const Text('This action cannot be undone. Your wedding information will be removed.'),
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(LynewedSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) _buildErrorBanner(),
                    _buildNameField(),
                    LynewedGap.verticalLg,
                    _buildDateFields(),
                    LynewedGap.verticalLg,
                    _buildVenueField(),
                    LynewedGap.verticalLg,
                    _buildBudgetFields(),
                    LynewedGap.verticalLg,
                    _buildProfessionsField(),
                    LynewedGap.verticalLg,
                    _buildRadiusField(),
                    LynewedGap.verticalLg,
                    _buildVisibilityField(),
                    LynewedGap.verticalXl,
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.lg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: LynewedColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Wedding' : 'Create Wedding',
              style: LynewedTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: LynewedSpacing.lg),
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
          LynewedGap.horizontalSm,
          Expanded(
            child: Text(
              _errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Wedding Name (optional)',
        hintText: 'e.g., Sophie & Thomas Wedding',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDateFields() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wedding Date *',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        LynewedGap.verticalSm,
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: EdgeInsets.all(LynewedSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: LynewedColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: LynewedColors.textSecondary),
                      LynewedGap.horizontalSm,
                      Text(
                        _eventDate != null 
                            ? dateFormat.format(_eventDate!)
                            : 'Select date',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: _eventDate != null 
                              ? LynewedColors.textPrimary 
                              : LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LynewedGap.horizontalMd,
            Expanded(
              child: InkWell(
                onTap: _eventDate != null ? () => _selectDate(true) : null,
                child: Container(
                  padding: EdgeInsets.all(LynewedSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _eventDate != null 
                          ? LynewedColors.border 
                          : LynewedColors.gray200,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: _eventDate != null 
                            ? LynewedColors.textSecondary 
                            : LynewedColors.gray300,
                      ),
                      LynewedGap.horizontalSm,
                      Text(
                        _eventEndDate != null 
                            ? dateFormat.format(_eventEndDate!)
                            : 'End date (opt)',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: _eventEndDate != null 
                              ? LynewedColors.textPrimary 
                              : LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVenueField() {
    final hasLocation = _venueLat != null && _venueLng != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue / Location *',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        LynewedGap.verticalSm,
        // AddressSearch widget for venue selection
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
        // Show location status indicator
        if (_venueController.text.isNotEmpty) ...[
          LynewedGap.verticalSm,
          Row(
            children: [
              Icon(
                hasLocation ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 16,
                color: hasLocation ? LynewedColors.success : LynewedColors.warning,
              ),
              LynewedGap.horizontalXs,
              Expanded(
                child: Text(
                  hasLocation 
                      ? 'Location confirmed - will appear on map'
                      : 'Please select an address from suggestions to get coordinates',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: hasLocation ? LynewedColors.success : LynewedColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Range',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        LynewedGap.verticalSm,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _budgetMinController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min',
                  prefixText: _currency == 'EUR' ? '€ ' : '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
              child: Text('-', style: LynewedTextStyles.titleMedium),
            ),
            Expanded(
              child: TextFormField(
                controller: _budgetMaxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max',
                  prefixText: _currency == 'EUR' ? '€ ' : '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            LynewedGap.horizontalMd,
            DropdownButton<String>(
              value: _currency,
              items: ['EUR', 'USD', 'GBP'].map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              )).toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'EUR'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Professionals Needed *',
              style: LynewedTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedProfessions.isNotEmpty) ...[
              LynewedGap.horizontalSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: LynewedColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedProfessions.length}',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        LynewedGap.verticalSm,
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: Profession.values.where((p) => p != Profession.other).map((profession) {
            final isSelected = _selectedProfessions.contains(profession);
            // Design System: black background, white text, no border
            return FilterChip(
              label: Text(
                profession.displayName,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: isSelected ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedProfessions.add(profession);
                  } else {
                    _selectedProfessions.remove(profession);
                  }
                });
              },
              backgroundColor: LynewedColors.gray200,
              selectedColor: LynewedColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Allowed radius values (must match DB CHECK constraint)
  static const _allowedRadii = [5, 10, 20, 50, 100];
  
  Widget _buildRadiusField() {
    // Find current index in allowed values
    final currentIndex = _allowedRadii.indexOf(_searchRadius);
    final sliderIndex = currentIndex >= 0 ? currentIndex : 3; // Default to 50km (index 3)
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Radius: $_searchRadius km',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: sliderIndex.toDouble(),
          min: 0,
          max: (_allowedRadii.length - 1).toDouble(),
          divisions: _allowedRadii.length - 1,
          label: '$_searchRadius km',
          activeColor: LynewedColors.primary,
          onChanged: (v) => setState(() => _searchRadius = _allowedRadii[v.round()]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _allowedRadii.map((r) => Text(
            '${r}km',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildVisibilityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        LynewedGap.verticalSm,
        Row(
          children: [
            Expanded(
              child: _buildVisibilityOption(
                WeddingVisibility.private,
                Icons.visibility_off,
                'Private',
                'Only you can see',
              ),
            ),
            LynewedGap.horizontalMd,
            Expanded(
              child: _buildVisibilityOption(
                WeddingVisibility.visibleToPros,
                Icons.visibility,
                'Visible',
                'Premium pros can see',
              ),
            ),
          ],
        ),
      ],
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
        padding: EdgeInsets.all(LynewedSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary,
            ),
            LynewedGap.verticalSm,
            Text(
              title,
              style: LynewedTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? LynewedColors.primary : LynewedColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveWedding,
            style: LynewedComponentStyles.primaryButton(),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save Changes' : 'Create Wedding'),
          ),
        ),
        if (_isEditing) ...[
          LynewedGap.verticalMd,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isDeleting ? null : _deleteWedding,
              style: TextButton.styleFrom(
                foregroundColor: LynewedColors.error,
              ),
              child: _isDeleting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete Wedding'),
            ),
          ),
        ],
      ],
    );
  }
}
