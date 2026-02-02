/// Sheet for managing wedding group members.
///
/// Displays current members and allows bride to:
/// - View all members
/// - Add new members (for private groups)
/// - Remove members (except bride)
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_group.dart';
import '../bloc/wedding_groups_cubit.dart';
import '../bloc/wedding_groups_state.dart';
import '../widgets/member_selector_widget.dart';

/// Sheet for managing group members.
class GroupMembersSheet extends StatefulWidget {
  const GroupMembersSheet({
    super.key,
    required this.group,
    required this.onMembersChanged,
  });

  /// The group to manage.
  final WeddingGroup group;

  /// Callback when members are changed.
  final VoidCallback onMembersChanged;

  @override
  State<GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends State<GroupMembersSheet> {
  bool _showAddMembers = false;
  Set<String> _selectedNewMembers = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingGroupsCubit, WeddingGroupsState>(
      builder: (context, state) {
        if (_showAddMembers) {
          return _buildAddMembersSheet(context, state);
        }
        return _buildMembersListSheet(context, state);
      },
    );
  }

  Widget _buildMembersListSheet(BuildContext context, WeddingGroupsState state) {
    return LynewedSheet(
      title: 'Members of ${widget.group.name}',
      onClose: () => Navigator.pop(context),
      bottomAction: !widget.group.isPublic
          ? SizedBox(
              width: double.infinity,
              child: LynewedButton(
                text: 'Add members',
                icon: Icons.person_add_outlined,
                type: LynewedButtonType.secondary,
                onPressed: () => setState(() => _showAddMembers = true),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Public group notice
          if (widget.group.isPublic) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LynewedColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: LynewedColors.info,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This group is public. All wedding participants are automatically added.',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Loading state
          if (state.isLoadingMembers) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (state.groupMembers.isEmpty) ...[
            // Empty state
            _buildEmptyMembersList(),
          ] else ...[
            // Members list
            const LynewedSectionTitle('Group Members'),
            const SizedBox(height: 10),
            ...state.groupMembers.map(
              (member) => _buildMemberTile(context, member, state.isSaving),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddMembersSheet(BuildContext context, WeddingGroupsState state) {
    // Get IDs of current members to exclude
    final currentMemberIds = state.groupMembers.map((m) => m.profileId).toList();

    return LynewedSheet(
      title: 'Add Members',
      onClose: () {
        setState(() {
          _showAddMembers = false;
          _selectedNewMembers = {};
        });
      },
      action: IconButton(
        icon: const Icon(Icons.arrow_back, size: 24),
        onPressed: () {
          setState(() {
            _showAddMembers = false;
            _selectedNewMembers = {};
          });
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: _selectedNewMembers.isEmpty
              ? 'Select members'
              : 'Add ${_selectedNewMembers.length} member${_selectedNewMembers.length > 1 ? 's' : ''}',
          onPressed: _selectedNewMembers.isEmpty || state.isSaving
              ? null
              : () => _addMembers(context),
          isLoading: state.isSaving,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select wedding participants to add to this group',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          MemberSelectorWidget(
            eligibleMembers: state.eligibleMembers,
            selectedIds: _selectedNewMembers,
            excludeIds: currentMemberIds,
            onSelectionChanged: (ids) => setState(() => _selectedNewMembers = ids),
            maxHeight: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembersList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: LynewedColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No members yet',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add members to start the group conversation',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, GroupMember member, bool isSaving) {
    final canRemove = !member.isBride && !widget.group.isPublic;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray100),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: member.avatarUrl != null
                ? CachedNetworkImageProvider(member.avatarUrl!)
                : null,
            backgroundColor: LynewedColors.gray100,
            child: member.avatarUrl == null
                ? Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildMemberTypeBadge(member.memberType),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Since ${_formatDate(member.joinedAt)}',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          if (canRemove)
            IconButton(
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.remove_circle_outline, color: LynewedColors.error),
              onPressed: isSaving ? null : () => _removeMember(context, member),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberTypeBadge(GroupMemberType type) {
    final (label, color) = switch (type) {
      GroupMemberType.bride => ('Bride', LynewedColors.primary),
      GroupMemberType.pro => ('Pro', LynewedColors.info),
      GroupMemberType.guest => ('Guest', LynewedColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _removeMember(BuildContext context, GroupMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.fullName} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WeddingGroupsCubit>().removeMember(member.profileId).then((success) {
                if (success) {
                  widget.onMembersChanged();
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMembers(BuildContext context) async {
    final cubit = context.read<WeddingGroupsCubit>();
    final success = await cubit.addMembers(_selectedNewMembers.toList());

    if (success && mounted) {
      setState(() {
        _showAddMembers = false;
        _selectedNewMembers = {};
      });
      widget.onMembersChanged();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
