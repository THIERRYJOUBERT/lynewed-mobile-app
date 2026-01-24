import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/utils/input_validators.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';

/// Add/Edit Guest Sheet - Create or edit a wedding guest
class AddGuestSheet extends StatefulWidget {
  const AddGuestSheet({
    super.key,
    required this.weddingId,
    this.guest,
    required this.onSaved,
  });

  final String weddingId;
  final WeddingGuest? guest;
  final VoidCallback onSaved;

  bool get isEditing => guest != null;

  @override
  State<AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<AddGuestSheet> {
  final _repository = MyWeddingRepositoryImpl();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  GuestRole _selectedRole = GuestRole.guest;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.guest?.name ?? '');
    _emailController = TextEditingController(text: widget.guest?.email ?? '');
    _phoneController = TextEditingController(text: widget.guest?.phone ?? '');
    _notesController = TextEditingController(text: widget.guest?.notes ?? '');

    if (widget.guest != null) {
      _selectedRole = widget.guest!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final notes = _notesController.text.trim();

    if (widget.isEditing) {
      final result = await _repository.updateWeddingGuest(
        guestId: widget.guest!.id,
        name: name,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        role: _roleToString(_selectedRole),
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Guest updated',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update guest'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } else {
      final result = await _repository.createWeddingGuest(
        weddingId: widget.weddingId,
        name: name,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        role: _roleToString(_selectedRole),
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result.isSuccess) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Guest added',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.textPrimary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to add guest'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    }
  }

  String _roleToString(GuestRole role) {
    switch (role) {
      case GuestRole.bridesmaid:
        return 'bridesmaid';
      case GuestRole.bestMan:
        return 'best_man';
      case GuestRole.family:
        return 'family';
      case GuestRole.witness:
        return 'witness';
      case GuestRole.other:
        return 'other';
      case GuestRole.guest:
        return 'guest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: widget.isEditing ? 'Edit Guest' : 'Add Guest',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: widget.isEditing ? 'Save Changes' : 'Add Guest',
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
            // Name
            _buildSectionTitle('Name *'),
            LynewedTextField(
              controller: _nameController,
              hint: 'e.g., John Smith',
              maxLength: InputValidators.maxNameLength,
              validator: InputValidators.validateName,
            ),
            const SizedBox(height: 30),

            // Role
            _buildSectionTitle('Role'),
            _buildRoleSelector(),
            const SizedBox(height: 30),

            // Email
            _buildSectionTitle('Email'),
            LynewedTextField(
              controller: _emailController,
              hint: 'e.g., john@example.com',
              keyboardType: TextInputType.emailAddress,
              maxLength: InputValidators.maxEmailLength,
              validator: (value) {
                // Email is optional for guests
                if (value == null || value.trim().isEmpty) return null;
                return InputValidators.validateEmail(value);
              },
            ),
            const SizedBox(height: 30),

            // Phone
            _buildSectionTitle('Phone'),
            LynewedTextField(
              controller: _phoneController,
              hint: 'e.g., +33 6 12 34 56 78',
              keyboardType: TextInputType.phone,
              maxLength: InputValidators.maxPhoneLength,
              validator: InputValidators.validatePhone,
            ),
            const SizedBox(height: 30),

            // Notes
            _buildSectionTitle('Notes'),
            LynewedTextField(
              controller: _notesController,
              hint: 'Add any notes about this guest...',
              maxLines: 3,
              maxLength: InputValidators.maxBioLength,
              validator: InputValidators.validateBio,
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

  Widget _buildRoleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GuestRole.values.map((role) {
        final isSelected = _selectedRole == role;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? LynewedColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? LynewedColors.primary : LynewedColors.gray200,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getRoleLabel(role),
              style: LynewedTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : LynewedColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getRoleLabel(GuestRole role) {
    switch (role) {
      case GuestRole.guest:
        return 'Guest';
      case GuestRole.bridesmaid:
        return 'Bridesmaid';
      case GuestRole.bestMan:
        return 'Best Man';
      case GuestRole.family:
        return 'Family';
      case GuestRole.witness:
        return 'Witness';
      case GuestRole.other:
        return 'Other';
    }
  }
}
