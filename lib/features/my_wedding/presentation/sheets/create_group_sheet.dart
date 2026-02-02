/// Sheet for creating or editing a wedding group.
///
/// Allows bride to:
/// - Set group name
/// - Choose visibility (public/private)
/// - Select initial members (for private groups)
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/wedding_group.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../widgets/member_selector_widget.dart';

/// Sheet for creating or editing a wedding group.
class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({
    super.key,
    required this.weddingId,
    this.existingGroup,
    required this.onGroupCreated,
  });

  /// The wedding ID.
  final String weddingId;

  /// Existing group to edit (null for creation).
  final WeddingGroup? existingGroup;

  /// Callback when group is created/updated.
  final VoidCallback onGroupCreated;

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repository = MyWeddingRepositoryImpl();

  bool _isPublic = false;
  bool _isLoading = false;
  bool _isLoadingMembers = false;
  Set<String> _selectedMemberIds = {};
  Set<String> _initialMemberIds = {}; // Track initial members for edit mode
  List<EligibleGroupMember> _eligibleMembers = [];

  bool get _isEditing => widget.existingGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingGroup!.name;
      _isPublic = widget.existingGroup!.isPublic;
      _loadCurrentMembers();
    }
    _loadEligibleMembers();
  }

  Future<void> _loadCurrentMembers() async {
    if (!_isEditing) return;

    final result = await _repository.getWeddingGroupMembers(
      roomId: widget.existingGroup!.roomId,
    );

    if (mounted && result.isSuccess && result.data != null) {
      setState(() {
        // Exclude bride from editable members
        final memberIds = result.data!
            .where((m) => m.memberType != GroupMemberType.bride)
            .map((m) => m.profileId)
            .toSet();
        _selectedMemberIds = Set<String>.from(memberIds);
        _initialMemberIds = Set<String>.from(memberIds);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadEligibleMembers() async {
    setState(() => _isLoadingMembers = true);

    final result = await _repository.getEligibleGroupMembers(
      weddingId: widget.weddingId,
    );

    if (mounted) {
      setState(() {
        _eligibleMembers = result.data ?? [];
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      RepositoryResult<dynamic> result;

      if (_isEditing) {
        // Update group name/visibility
        result = await _repository.updateWeddingGroup(
          roomId: widget.existingGroup!.roomId,
          name: _nameController.text.trim(),
          isPublic: _isPublic,
        );

        // Sync members if private group
        if (result.isSuccess && !_isPublic) {
          await _syncMembers();
        }
      } else {
        result = await _repository.createWeddingGroup(
          weddingId: widget.weddingId,
          name: _nameController.text.trim(),
          isPublic: _isPublic,
          memberProfileIds: _isPublic ? null : _selectedMemberIds.toList(),
        );
      }

      if (mounted) {
        if (result.isSuccess) {
          widget.onGroupCreated();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'An error occurred'),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Synchronize members when editing - add new and remove deleted.
  Future<void> _syncMembers() async {
    final roomId = widget.existingGroup!.roomId;

    // Members to add (in selected but not in initial)
    final toAdd = _selectedMemberIds.difference(_initialMemberIds);
    // Members to remove (in initial but not in selected)
    final toRemove = _initialMemberIds.difference(_selectedMemberIds);

    // Add new members
    if (toAdd.isNotEmpty) {
      await _repository.addGroupMembers(
        roomId: roomId,
        profileIds: toAdd.toList(),
      );
    }

    // Remove deleted members
    if (toRemove.isNotEmpty) {
      await _repository.removeGroupMembers(
        roomId: roomId,
        profileIds: toRemove.toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: _isEditing ? 'Edit Group' : 'New Group',
      onClose: () => Navigator.pop(context),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: _isEditing ? 'Save' : 'Create Group',
          onPressed: _isLoading ? null : _saveGroup,
          isLoading: _isLoading,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name
            LynewedTextField(
              controller: _nameController,
              label: 'Group Name',
              hint: 'e.g., Bridesmaids',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),

            const SizedBox(height: 30), // Design System: 30px inter-section

            // Visibility toggle
            const LynewedSectionTitle('Visibility'),
            const SizedBox(height: 10), // Design System: 10px label→content

            // Public option
            _buildVisibilityOption(
              title: 'Public',
              subtitle: 'All wedding participants can join automatically',
              icon: Icons.public,
              isSelected: _isPublic,
              onTap: () => setState(() => _isPublic = true),
            ),
            const SizedBox(height: 8),

            // Private option
            _buildVisibilityOption(
              title: 'Private',
              subtitle: 'Only invited members can access the group',
              icon: Icons.lock_outline,
              isSelected: !_isPublic,
              onTap: () => setState(() => _isPublic = false),
            ),

            // Member selection (for private groups)
            if (!_isPublic) ...[
              const SizedBox(height: 30), // Design System: 30px inter-section
              Row(
                children: [
                  const Expanded(
                    child: LynewedSectionTitle('Members'),
                  ),
                  SelectedMembersCounter(
                    count: _selectedMemberIds.length,
                    onClear: () => setState(() => _selectedMemberIds = {}),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _isEditing
                    ? 'Manage group members'
                    : 'Select members to add to the group',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoadingMembers)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                MemberSelectorWidget(
                  eligibleMembers: _eligibleMembers,
                  selectedIds: _selectedMemberIds,
                  onSelectionChanged: (ids) => setState(() => _selectedMemberIds = ids),
                  maxHeight: 250,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent, // Always transparent background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected ? LynewedColors.primary : LynewedColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
