/// Alert create/edit sheet widget
/// 
/// Sheet for professionals to create or edit alerts.
/// Phase 6: 4 structured alert types (backup_needed, gear_emergency, team_member, emergency_help)
/// Uses Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design/design.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '../../domain/entities/alert_details.dart';
import '../../domain/entities/professional_details.dart';
import '../../data/datasources/supabase_map_datasource.dart';

// Design System color aliases for cleaner code
const _white = Colors.white;
const _gray100 = LynewedColors.gray100;
const _gray200 = LynewedColors.gray200;
const _gray300 = LynewedColors.gray300;
const _textPrimary = LynewedColors.textPrimary;
const _textSecondary = LynewedColors.textSecondary;
const _primary = LynewedColors.primary;

// Button text style (not in Design System yet)
const _buttonTextStyle = TextStyle(
  fontFamily: 'Haas Grot Text Trial',
  fontSize: 14.0,
  fontWeight: FontWeight.w500,
  color: Colors.white,
);

/// Alert create/edit bottom sheet
class AlertCreateSheet extends StatefulWidget {
  const AlertCreateSheet({
    super.key,
    this.existingAlert,
    this.onSaved,
    this.onDeleted,
  });

  /// Existing alert data for editing (null for create)
  final Map<String, dynamic>? existingAlert;
  
  /// Callback when alert is saved
  final VoidCallback? onSaved;
  
  /// Callback when alert is deleted
  final VoidCallback? onDeleted;

  @override
  State<AlertCreateSheet> createState() => _AlertCreateSheetState();
}

class _AlertCreateSheetState extends State<AlertCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _datasource = SupabaseMapDatasource();
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TextEditingController _locationController;
  
  // Form state
  AlertType _selectedAlertType = AlertType.backupNeeded;
  DateTime? _eventDate;
  Profession? _selectedProfession;
  bool _anyProfession = true;
  int _radiusKm = 50;
  
  // Location
  double? _locationLat;
  double? _locationLng;
  
  // UI state
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingAlert != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    if (_isEditing) {
      _loadExistingData();
    }
  }

  void _initControllers() {
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _locationController = TextEditingController();
  }

  void _loadExistingData() {
    final data = widget.existingAlert!;
    _titleController.text = data['title']?.toString() ?? '';
    _messageController.text = data['message']?.toString() ?? '';
    _locationController.text = data['locationLabel']?.toString() ?? '';
    
    _selectedAlertType = AlertType.fromString(data['alertType']?.toString());
    _eventDate = DateTime.tryParse(data['eventDate']?.toString() ?? '');
    _radiusKm = (data['radiusKm'] as num?)?.toInt() ?? 50;
    
    _locationLat = (data['locationLat'] as num?)?.toDouble();
    _locationLng = (data['locationLng'] as num?)?.toDouble();
    
    final professionStr = data['professionNeeded']?.toString();
    if (professionStr != null && professionStr.isNotEmpty) {
      _selectedProfession = Profession.fromString(professionStr);
      _anyProfession = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: LynewedSpacing.xl,
                vertical: LynewedSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlertTypeSection(),
                    const SizedBox(height: LynewedSpacing.xl),
                    _buildTitleField(),
                    const SizedBox(height: LynewedSpacing.lg),
                    _buildMessageField(),
                    const SizedBox(height: LynewedSpacing.xl),
                    _buildEventDateSection(),
                    const SizedBox(height: LynewedSpacing.xl),
                    _buildLocationField(),
                    const SizedBox(height: LynewedSpacing.xl),
                    _buildProfessionSection(),
                    const SizedBox(height: LynewedSpacing.xl),
                    _buildRadiusField(),
                    const SizedBox(height: LynewedSpacing.xxl),
                    if (_errorMessage != null) _buildErrorMessage(),
                    _buildActionButtons(),
                    const SizedBox(height: LynewedSpacing.lg),
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
      padding: const EdgeInsets.all(LynewedSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _gray200, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: _gray100),
          ),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Alert' : 'Create Alert',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildAlertTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Type',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _gray300),
            borderRadius: LynewedBorders.inputBorderRadius,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AlertType>(
              value: _selectedAlertType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: LynewedSpacing.md,
                vertical: LynewedSpacing.xs,
              ),
              borderRadius: LynewedBorders.inputBorderRadius,
              items: AlertType.values
                  .where((t) => t != AlertType.other)
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: _buildAlertTypeItem(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAlertType = value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: LynewedSpacing.xs),
        Text(
          _selectedAlertType.description,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTypeItem(AlertType type) {
    return Row(
      children: [
        Icon(
          _getAlertTypeIcon(type),
          size: 20,
          color: _textPrimary,
        ),
        const SizedBox(width: LynewedSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.displayName,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return Icons.person_search_outlined;
      case AlertType.gearEmergency:
        return Icons.camera_alt_outlined;
      case AlertType.teamMember:
        return Icons.group_add_outlined;
      case AlertType.emergencyHelp:
        return Icons.warning_amber_rounded;
      case AlertType.other:
        return Icons.help_outline_rounded;
    }
  }

  Color _getAlertTypeColor(AlertType type) => _textPrimary; // Unused but kept for interface compatibility

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Ex: Photographer needed for Dec 12',
            hintStyle: LynewedTextStyles.bodyMedium.copyWith(
              color: _gray300,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _textPrimary),
            ),
            contentPadding: const EdgeInsets.all(LynewedSpacing.md),
          ),
          style: LynewedTextStyles.bodyMedium,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.trim().length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        TextFormField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Provide more details about your request...',
            hintStyle: LynewedTextStyles.bodyMedium.copyWith(
              color: _gray300,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _textPrimary),
            ),
            contentPadding: const EdgeInsets.all(LynewedSpacing.md),
          ),
          style: LynewedTextStyles.bodyMedium,
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildEventDateSection() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date *',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        InkWell(
          onTap: _selectEventDate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(LynewedSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: _gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: _textPrimary),
                const SizedBox(width: LynewedSpacing.sm),
                Expanded(
                  child: Text(
                    _eventDate != null
                        ? dateFormat.format(_eventDate!)
                        : 'Select date',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: _eventDate != null
                          ? _textPrimary
                          : _textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: _textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectEventDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: _white,
              surface: _white,
              onSurface: _textPrimary,
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

  Widget _buildProfessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profession Needed',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildProfessionChip(
              label: 'Any Profession',
              isSelected: _anyProfession,
              onTap: () {
                setState(() {
                  _anyProfession = true;
                  _selectedProfession = null;
                });
              },
            ),
            ...Profession.values
                .where((p) => p != Profession.other)
                .map((profession) => _buildProfessionChip(
                      label: profession.displayName,
                      isSelected: !_anyProfession && _selectedProfession == profession,
                      onTap: () {
                        setState(() {
                          _anyProfession = false;
                          _selectedProfession = profession;
                        });
                      },
                    )),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: LynewedTextStyles.bodySmall.copyWith(
          color: isSelected ? _white : _textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: _gray200,
      selectedColor: _primary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        AddressSearchWidget(
          initialValue: _locationController.text,
          hintText: 'Search city or address',
          onAddressSelected: (address) {
            if (address != null && address.hasCoords()) {
              setState(() {
                _locationController.text = address.formattedAddress;
                _locationLat = address.coords?.latitude;
                _locationLng = address.coords?.longitude;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRadiusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Radius: $_radiusKm km',
          style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: LynewedSpacing.sm),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _primary,
            inactiveTrackColor: _gray200,
            thumbColor: _primary,
            overlayColor: _primary.withAlpha(32),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: _radiusKm.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            onChanged: (value) {
              setState(() => _radiusKm = value.round());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [10, 30, 50, 70, 100].map((r) => Text(
            '${r}km',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: _textSecondary,
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: LynewedSpacing.md),
      padding: const EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: LynewedBorders.cardBorderRadius,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: LynewedSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: LynewedSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveAlert,
            style: LynewedComponentStyles.primaryButton(),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_white),
                    ),
                  )
                : Text(
                    _isEditing ? 'Update Alert' : 'Create Alert',
                    style: _buttonTextStyle,
                  ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: LynewedSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: LynewedSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: _isDeleting ? null : _deleteAlert,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: LynewedBorders.buttonBorderRadius,
                ),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : Text(
                      'Delete Alert',
                      style: _buttonTextStyle.copyWith(color: Colors.red),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveAlert() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate event date
    if (_eventDate == null) {
      setState(() => _errorMessage = 'Please select an event date');
      return;
    }

    // Validate event date is in future
    if (_eventDate!.isBefore(DateTime.now())) {
      setState(() => _errorMessage = 'Event date must be in the future');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic>? result;
      
      if (_isEditing) {
        result = await _datasource.updateAlert(
          alertId: widget.existingAlert!['id'].toString(),
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          eventDate: _eventDate,
          locationLat: _locationLat,
          locationLng: _locationLng,
          locationLabel: _locationController.text.trim(),
        );
      } else {
        result = await _datasource.createAlert(
          alertType: _selectedAlertType.toBackendValue,
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          eventDate: _eventDate!,
          locationLat: _locationLat ?? 0.0,
          locationLng: _locationLng ?? 0.0,
          locationLabel: _locationController.text.trim(),
          radiusKm: _radiusKm,
          professionNeeded: _anyProfession ? null : _selectedProfession?.toRpcValue,
        );
      }

      if (result != null && result['success'] == true) {
        widget.onSaved?.call();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Alert updated!' : 'Alert created!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result?['error']?.toString() ?? 'Failed to save alert';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final result = await _datasource.deleteAlert(
        widget.existingAlert!['id'].toString(),
      );

      if (result != null && result['success'] == true) {
        widget.onDeleted?.call();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result?['error']?.toString() ?? 'Failed to delete alert';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
