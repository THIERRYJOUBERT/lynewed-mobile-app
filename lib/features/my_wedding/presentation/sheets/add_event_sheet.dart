import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '/core/utils/input_validators.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';

/// Add/Edit Event Sheet - Create or edit a wedding event
class AddEventSheet extends StatefulWidget {
  const AddEventSheet({
    super.key,
    required this.weddingId,
    this.event,
    required this.onSaved,
  });

  final String weddingId;
  final WeddingEvent? event;
  final VoidCallback onSaved;

  bool get isEditing => event != null;

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _repository = MyWeddingRepositoryImpl();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  bool _isPublic = false;
  bool _isSaving = false;

  // Reminder fields (EPIC-08)
  bool _reminder1Week = false;
  bool _reminder1Day = false;
  bool _reminder1Hour = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');

    if (widget.event != null) {
      _eventDate = widget.event!.eventDate;
      _eventTime = TimeOfDay.fromDateTime(widget.event!.eventDate);
      _isPublic = widget.event!.isPublic;
      // Load reminder settings (EPIC-08)
      _reminder1Week = widget.event!.reminder1Week;
      _reminder1Day = widget.event!.reminder1Day;
      _reminder1Hour = widget.event!.reminder1Hour;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
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
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? TimeOfDay.now(),
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
      setState(() => _eventTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: LynewedColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Combine date and time
    final time = _eventTime ?? const TimeOfDay(hour: 12, minute: 0);
    final eventDateTime = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      time.hour,
      time.minute,
    );

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (widget.isEditing) {
      final result = await _repository.updateWeddingEvent(
        eventId: widget.event!.id,
        title: title,
        description: description.isNotEmpty ? description : null,
        eventDate: eventDateTime,
        location: location.isNotEmpty ? location : null,
        isPublic: _isPublic,
        reminder1Week: _reminder1Week,
        reminder1Day: _reminder1Day,
        reminder1Hour: _reminder1Hour,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event updated',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update event'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } else {
      final result = await _repository.createWeddingEvent(
        weddingId: widget.weddingId,
        title: title,
        eventDate: eventDateTime,
        description: description.isNotEmpty ? description : null,
        location: location.isNotEmpty ? location : null,
        isPublic: _isPublic,
        reminder1Week: _reminder1Week,
        reminder1Day: _reminder1Day,
        reminder1Hour: _reminder1Hour,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Event created',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to create event'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: widget.isEditing ? 'Edit Event' : 'Add Event',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: widget.isEditing ? 'Save Changes' : 'Add Event',
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
            // Title
            _buildSectionTitle('Event Title *'),
            LynewedTextField(
              controller: _titleController,
              hint: 'e.g., Venue visit, Dress fitting...',
              maxLength: InputValidators.maxNameLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.length > InputValidators.maxNameLength) {
                  return 'Title is too long';
                }
                // Check for malicious content
                if (InputValidators.containsHtmlTags(value)) {
                  return 'Title contains invalid characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Date & Time
            _buildSectionTitle('Date & Time *'),
            Row(
              children: [
                Expanded(
                  child: _buildDateInput(
                    date: _eventDate,
                    placeholder: 'Select date',
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeInput(
                    time: _eventTime,
                    placeholder: 'Select time',
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Location
            _buildSectionTitle('Location'),
            LynewedTextField(
              controller: _locationController,
              hint: 'e.g., Wedding venue, Boutique name...',
              maxLength: InputValidators.maxSearchLength,
            ),
            const SizedBox(height: 30),

            // Description
            _buildSectionTitle('Description'),
            LynewedTextField(
              controller: _descriptionController,
              hint: 'Add notes or details...',
              maxLines: 3,
              maxLength: InputValidators.maxBioLength,
              validator: InputValidators.validateBio,
            ),
            const SizedBox(height: 30),

            // Reminders section (EPIC-08)
            _buildSectionTitle('Reminders'),
            const SizedBox(height: 10),
            _buildRemindersSection(),
            const SizedBox(height: 30),

            // Visibility toggle
            _buildSectionTitle('Visibility'),
            const SizedBox(height: 10),
            _buildVisibilityToggle(),
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
            Text(
              date != null ? dateFormat.format(date) : placeholder,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: date != null
                    ? LynewedColors.textPrimary
                    : LynewedColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput({
    required TimeOfDay? time,
    required String placeholder,
    required VoidCallback onTap,
  }) {
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
              Icons.access_time,
              size: 18,
              color: time != null
                  ? LynewedColors.textPrimary
                  : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              time != null ? time.format(context) : placeholder,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: time != null
                    ? LynewedColors.textPrimary
                    : LynewedColors.textSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if reminders can be enabled (event must be in the future)
  bool get _canEnableReminders {
    if (_eventDate == null) return true; // Allow setting before date is picked
    final time = _eventTime ?? const TimeOfDay(hour: 12, minute: 0);
    final eventDateTime = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      time.hour,
      time.minute,
    );
    return eventDateTime.isAfter(DateTime.now());
  }

  Widget _buildRemindersSection() {
    final hasAnyReminder = _reminder1Week || _reminder1Day || _reminder1Hour;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: hasAnyReminder
            ? Border.all(color: LynewedColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasAnyReminder
                      ? LynewedColors.primary.withValues(alpha: 0.1)
                      : LynewedColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: hasAnyReminder
                      ? LynewedColors.primary
                      : LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasAnyReminder
                      ? 'Reminders enabled'
                      : 'Get notified before this event',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: hasAnyReminder
                        ? LynewedColors.primary
                        : LynewedColors.textSecondary,
                    fontWeight:
                        hasAnyReminder ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          if (!_canEnableReminders) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: LynewedColors.gray100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: LynewedColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reminders not available for past events',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Reminder options as chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReminderChip(
                icon: Icons.date_range_outlined,
                label: '1 week',
                value: _reminder1Week,
                onChanged: _canEnableReminders
                    ? (value) => setState(() => _reminder1Week = value)
                    : null,
              ),
              _buildReminderChip(
                icon: Icons.today_outlined,
                label: '1 day',
                value: _reminder1Day,
                onChanged: _canEnableReminders
                    ? (value) => setState(() => _reminder1Day = value)
                    : null,
              ),
              _buildReminderChip(
                icon: Icons.schedule_outlined,
                label: '1 hour',
                value: _reminder1Hour,
                onChanged: _canEnableReminders
                    ? (value) => setState(() => _reminder1Hour = value)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderChip({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isEnabled = onChanged != null;
    final isSelected = value && isEnabled;

    return GestureDetector(
      onTap: isEnabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? LynewedColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? LynewedColors.primary
                : isEnabled
                    ? LynewedColors.gray200
                    : LynewedColors.gray100,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : icon,
              size: 16,
              color: isSelected
                  ? LynewedColors.primary
                  : isEnabled
                      ? LynewedColors.textSecondary
                      : LynewedColors.gray200,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: LynewedTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? LynewedColors.primary
                    : isEnabled
                        ? LynewedColors.textPrimary
                        : LynewedColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isPublic = !_isPublic),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              _isPublic ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPublic ? 'Visible to Wedding Team' : 'Private',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isPublic
                        ? 'Professionals in your team can see this event'
                        : 'Only you can see this event',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
              activeColor: LynewedColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
