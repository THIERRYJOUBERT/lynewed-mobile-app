import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '/core/widgets/currency_dropdown.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as custom_actions;
import '/features/map/domain/entities/wedding_details.dart' show WeddingVisibility;
import '../../domain/entities/wedding_overview.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';

/// Wedding Edit Sheet - Edit wedding details
/// Full-featured version with date picker and Google Places address search
class WeddingEditSheet extends StatefulWidget {
  const WeddingEditSheet({
    super.key,
    required this.wedding,
    required this.onSaved,
  });

  final WeddingOverview wedding;
  final VoidCallback onSaved;

  @override
  State<WeddingEditSheet> createState() => _WeddingEditSheetState();
}

class _WeddingEditSheetState extends State<WeddingEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repository = MyWeddingRepositoryImpl();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressSearchController;
  late TextEditingController _guestCountController;
  late TextEditingController _budgetController;

  // State
  DateTime? _eventDate;
  String? _venueAddress;
  double? _venueLat;
  double? _venueLng;
  String? _countryCode;
  late String _currencyCode;
  late WeddingVisibility _visibility;
  bool _isSaving = false;
  bool _isSearchingAddress = false;
  List<PlaceSuggestionStruct> _addressSuggestions = [];
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wedding.name ?? '');
    _addressSearchController = TextEditingController();
    _guestCountController = TextEditingController(
      text: widget.wedding.guestCount?.toString() ?? '',
    );
    final initialBudget = widget.wedding.budgetMax ?? widget.wedding.budgetMin;
    _budgetController = TextEditingController(
      text: initialBudget?.toInt().toString() ?? '',
    );
    
    // Initialize from existing wedding data
    _eventDate = widget.wedding.eventDate;
    _venueAddress = widget.wedding.venueAddress;
    _venueLat = widget.wedding.position?.latitude;
    _venueLng = widget.wedding.position?.longitude;
    _countryCode = widget.wedding.countryCode;
    _currencyCode = widget.wedding.currency;
    _visibility = widget.wedding.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressSearchController.dispose();
    _guestCountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initialDate = _eventDate ?? DateTime.now().add(const Duration(days: 365));
    
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
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      setState(() => _addressSuggestions = []);
      return;
    }

    setState(() => _isSearchingAddress = true);

    try {
      final result = await custom_actions.getPlacePredictions(
        query,
        _sessionToken,
        'fr',
      );
      
      if (mounted) {
        setState(() {
          _addressSuggestions = result.suggestions;
          _sessionToken = result.newSessionToken;
          _isSearchingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  Future<void> _selectAddress(PlaceSuggestionStruct suggestion) async {
    setState(() => _isSearchingAddress = true);

    try {
      final latLng = await custom_actions.getPlaceDetails(
        suggestion.placeId,
        _sessionToken ?? '',
        'fr',
      );
      
      if (mounted && latLng != null) {
        setState(() {
          _venueAddress = '${suggestion.primaryText}, ${suggestion.secondaryText}';
          _venueLat = latLng.latitude;
          _venueLng = latLng.longitude;
          _addressSuggestions = [];
          _addressSearchController.clear();
          _sessionToken = null;
          _isSearchingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = await _repository.updateWedding(
      weddingId: widget.wedding.id,
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      eventDate: _eventDate,
      lat: _venueLat,
      lng: _venueLng,
      venueAddress: _venueAddress,
      countryCode: _countryCode,
      guestCount: int.tryParse(_guestCountController.text),
      budgetMin: int.tryParse(_budgetController.text),
      budgetMax: int.tryParse(_budgetController.text),
      currency: _currencyCode,
      visibility: _visibility.name == 'visibleToPros' ? 'visible_to_pros' : 'private',
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to save',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Edit Wedding',
      onClose: () => Navigator.pop(context),
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LynewedButton(
            text: 'Save Changes',
            onPressed: _isSaving ? null : _save,
            isLoading: _isSaving,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _confirmCancelWedding,
            child: Text(
              'Cancel Wedding',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wedding Name
            const Text('Wedding Name', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            LynewedTextField(
              controller: _nameController,
              hint: 'e.g., Sophie & Thomas Wedding',
            ),
            const SizedBox(height: 30),
            
            // Date - Editable with date picker
            const Text('Date', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LynewedColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: LynewedColors.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _eventDate != null
                            ? DateFormat('MMMM d, yyyy').format(_eventDate!)
                            : 'Select date',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: _eventDate != null 
                              ? LynewedColors.textPrimary 
                              : LynewedColors.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: LynewedColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Location - Editable with Google Places search
            const Text('Location', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            // Current address display
            if (_venueAddress != null && _venueAddress!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LynewedColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: LynewedColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _venueAddress!,
                        style: LynewedTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _venueAddress = null;
                        _venueLat = null;
                        _venueLng = null;
                      }),
                      child: const Icon(Icons.close, color: LynewedColors.textSecondary, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Search field
            LynewedTextField(
              controller: _addressSearchController,
              hint: 'Search for a new address...',
              prefixIcon: _isSearchingAddress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, color: LynewedColors.textSecondary),
              onChanged: _searchAddress,
            ),
            // Address suggestions
            if (_addressSuggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: LynewedColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: LynewedColors.gray200),
                ),
                child: Column(
                  children: _addressSuggestions.map((suggestion) {
                    return InkWell(
                      onTap: () => _selectAddress(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, 
                              color: LynewedColors.textSecondary, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.primaryText,
                                    style: LynewedTextStyles.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (suggestion.secondaryText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      suggestion.secondaryText,
                                      style: LynewedTextStyles.bodySmall.copyWith(
                                        color: LynewedColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 30),
            
            // Guest Count
            const Text('Expected Guests', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            LynewedTextField(
              controller: _guestCountController,
              hint: 'e.g., 150',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            
            // Budget
            const Text('Budget', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LynewedTextField(
                    controller: _budgetController,
                    hint: 'e.g., 20000',
                    keyboardType: TextInputType.number,
                    isValueInput: true,
                  ),
                ),
                const SizedBox(width: 12),
                CurrencyDropdown(
                  value: _currencyCode,
                  onChanged: (code) => setState(() => _currencyCode = code),
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Visibility
            const Text('Visibility', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            _buildVisibilityOption(
              WeddingVisibility.private,
              Icons.lock_outline,
              'Private',
              'Only you can see',
            ),
            const SizedBox(height: 12),
            _buildVisibilityOption(
              WeddingVisibility.visibleToPros,
              Icons.visibility_outlined,
              'Visible to Pros',
              'Professionals can see your wedding',
            ),
            const SizedBox(height: 20),
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
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : LynewedColors.gray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : LynewedColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : LynewedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  void _confirmCancelWedding() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Wedding?'),
        content: const Text(
          'Your wedding planning will be paused. You can resume at any time. '
          'All your data and team members will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Planning'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _cancelWedding();
            },
            child: const Text('Cancel Wedding', style: TextStyle(color: LynewedColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelWedding() async {
    final result = await _repository.updateWeddingStatus(
      weddingId: widget.wedding.id,
      status: 'cancelled',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to cancel wedding',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }
}
