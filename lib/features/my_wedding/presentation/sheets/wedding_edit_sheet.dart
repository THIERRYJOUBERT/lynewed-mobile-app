import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as custom_actions;
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
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;

  // State
  DateTime? _eventDate;
  String? _venueAddress;
  double? _venueLat;
  double? _venueLng;
  String? _countryCode;
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
    _budgetMinController = TextEditingController(
      text: widget.wedding.budgetMin?.toInt().toString() ?? '',
    );
    _budgetMaxController = TextEditingController(
      text: widget.wedding.budgetMax?.toInt().toString() ?? '',
    );
    
    // Initialize from existing wedding data
    _eventDate = widget.wedding.eventDate;
    _venueAddress = widget.wedding.venueAddress;
    _venueLat = widget.wedding.position?.latitude;
    _venueLng = widget.wedding.position?.longitude;
    _countryCode = widget.wedding.countryCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressSearchController.dispose();
    _guestCountController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
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
      budgetMin: int.tryParse(_budgetMinController.text),
      budgetMax: int.tryParse(_budgetMaxController.text),
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
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: 'Save Changes',
          onPressed: _isSaving ? null : _save,
          isLoading: _isSaving,
        ),
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
            const Text('Budget Range', style: LynewedTextStyles.labelMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LynewedTextField(
                    controller: _budgetMinController,
                    hint: 'Min',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '-',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LynewedTextField(
                    controller: _budgetMaxController,
                    hint: 'Max',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.wedding.currency,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
