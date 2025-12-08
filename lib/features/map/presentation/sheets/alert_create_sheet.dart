/// Alert create/edit sheet widget
/// 
/// Sheet for professionals to create or edit alerts.
/// Phase 6: 4 structured alert types (backup_needed, gear_emergency, team_member, emergency_help)
/// Refactored to use Lynewed Design System Widgets (v2.0).
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '/core/utils/distance_formatter.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/backend/schema/structs/index.dart';
import '../../domain/entities/alert_details.dart';
import '../../domain/entities/professional_details.dart';
import '../../data/datasources/supabase_map_datasource.dart';

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

  // Allowed radius steps for the slider
  static const List<int> _allowedRadii = [10, 20, 30, 50, 100];

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: _isEditing ? 'Edit Alert' : 'Create Alert',
      onClose: () => Navigator.of(context).pop(),
      bottomAction: Column(
        children: [
          LynewedButton(
            text: _isEditing ? 'Update Alert' : 'Create Alert',
            onPressed: _isLoading ? null : _saveAlert,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            LynewedButton(
              text: 'Delete Alert',
              onPressed: _isDeleting ? null : _deleteAlert,
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

            // Alert Type Section
            _buildSectionTitle('Alert Type *'),
            _buildAlertTypeDropdown(),
            const SizedBox(height: 30),

            // Title Section
            LynewedTextField(
              controller: _titleController,
              label: 'Title *',
              hint: 'Ex: Photographer needed for Dec 12',
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
            const SizedBox(height: 30),

            // Description Section
            LynewedTextField(
              controller: _messageController,
              label: 'Description *',
              hint: 'Provide more details about your request (min 3 characters)...',
              maxLines: 4,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                if (value.trim().length < 3) {
                  return 'Description must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Event Date Section
            _buildSectionTitle('Event Date *'),
            _buildDateInput(
              date: _eventDate,
              placeholder: 'Select date',
              onTap: _selectEventDate,
            ),
            const SizedBox(height: 30),

            // Location Section
            _buildSectionTitle('Location *'),
            AddressSearchWidget(
              hintText: 'Search city or address...',
              initialValue: _locationController.text,
              locale: 'fr',
              useOverlay: true,
              suggestionsPosition: SuggestionsPosition.below,
              onAddressSelected: (PlaceDetailsDataStruct details) {
                setState(() {
                  _locationController.text = details.formattedAddress;
                  if (details.coords != null) {
                    _locationLat = details.coords!.latitude;
                    _locationLng = details.coords!.longitude;
                  }
                });
              },
              onAddressCleared: () {
                setState(() {
                  _locationController.clear();
                  _locationLat = null;
                  _locationLng = null;
                });
              },
            ),
            if (_locationController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildLocationStatus(),
            ],
            const SizedBox(height: 30),

            // Profession Section
            _buildSectionTitle('Profession Needed'),
            _buildProfessionSelection(),
            const SizedBox(height: 30),

            // Search Radius Section (uses user's preferred unit: km or miles)
            _buildSectionTitle('Search Radius'),
            LynewedSlider(
              value: _radiusKm,
              steps: _allowedRadii,
              suffix: ' ${DistanceFormatter.unitAbbreviation}',
              formatValue: (value) {
                // Convert km to user's unit for display
                final converted = DistanceFormatter.convertFromKm(value.toDouble());
                return '${converted.round()} ${DistanceFormatter.unitAbbreviation}';
              },
              onChanged: (value) => setState(() => _radiusKm = value),
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

  Widget _buildAlertTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: LynewedColors.gray200),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AlertType>(
              value: _selectedAlertType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(4),
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w300,
              ),
              items: AlertType.values
                  .where((t) => t != AlertType.other)
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getAlertTypeIcon(type), size: 20, color: LynewedColors.textPrimary),
                            const SizedBox(width: 8),
                            Text(
                              type.displayName,
                              style: LynewedTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
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
        const SizedBox(height: 8),
        Text(
          _selectedAlertType.description,
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
            fontWeight: FontWeight.w300,
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

  Widget _buildDateInput({
    required DateTime? date,
    required String placeholder,
    required VoidCallback? onTap,
  }) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
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

  Widget _buildLocationStatus() {
    final hasLocation = _locationLat != null && _locationLng != null;
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
                ? 'Location confirmed - alert will appear on map'
                : 'Please select an address from suggestions',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: hasLocation ? LynewedColors.success : LynewedColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_anyProfession && _selectedProfession != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '1 selected',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LynewedChip(
              label: 'Any Profession',
              selected: _anyProfession,
              onSelected: (selected) {
                setState(() {
                  _anyProfession = true;
                  _selectedProfession = null;
                });
              },
            ),
            ...Profession.values.where((p) => p != Profession.other).map((profession) {
              return LynewedChip(
                label: profession.displayName,
                selected: !_anyProfession && _selectedProfession == profession,
                onSelected: (selected) {
                  setState(() {
                    _anyProfession = false;
                    _selectedProfession = profession;
                  });
                },
              );
            }),
          ],
        ),
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
