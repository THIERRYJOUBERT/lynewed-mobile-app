/// Widget for selecting members to add to a wedding group.
///
/// Displays a list of eligible members (joined guests + active pros)
/// with search, multi-select, and chips for selected members.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_group.dart';

/// Widget for selecting group members with search and multi-select.
///
/// Shows eligible members grouped by type (guests, pros).
class MemberSelectorWidget extends StatefulWidget {
  const MemberSelectorWidget({
    super.key,
    required this.eligibleMembers,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.excludeIds = const [],
    this.maxHeight = 300,
  });

  /// List of eligible members to choose from.
  final List<EligibleGroupMember> eligibleMembers;

  /// Currently selected member profile IDs.
  final Set<String> selectedIds;

  /// Callback when selection changes.
  final ValueChanged<Set<String>> onSelectionChanged;

  /// Profile IDs to exclude from the list (e.g., already in group).
  final List<String> excludeIds;

  /// Maximum height of the member list.
  final double maxHeight;

  @override
  State<MemberSelectorWidget> createState() => _MemberSelectorWidgetState();
}

class _MemberSelectorWidgetState extends State<MemberSelectorWidget> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<EligibleGroupMember> get _filteredMembers {
    var members = widget.eligibleMembers
        .where((m) => !widget.excludeIds.contains(m.profileId))
        .toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      members = members.where((m) {
        return m.fullName.toLowerCase().contains(query);
      }).toList();
    }

    return members;
  }

  List<EligibleGroupMember> get _guests =>
      _filteredMembers.where((m) => m.memberType == GroupMemberType.guest).toList();

  List<EligibleGroupMember> get _pros =>
      _filteredMembers.where((m) => m.memberType == GroupMemberType.pro).toList();

  void _toggleMember(String profileId) {
    final newSelection = Set<String>.from(widget.selectedIds);
    if (newSelection.contains(profileId)) {
      newSelection.remove(profileId);
    } else {
      newSelection.add(profileId);
    }
    widget.onSelectionChanged(newSelection);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected members chips
        if (widget.selectedIds.isNotEmpty) ...[
          _buildSelectedChips(),
          const SizedBox(height: 12),
        ],

        // Search field - unified style (grey bg, no blue focus)
        LynewedTextField(
          controller: _searchController,
          hint: 'Search...',
          prefixIcon: const Icon(Icons.search, color: LynewedColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: LynewedColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),

        const SizedBox(height: 12),

        // Member list
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: _filteredMembers.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_guests.isNotEmpty) ...[
                        _buildSectionHeader('Guests', _guests.length),
                        ..._guests.map(_buildMemberTile),
                      ],
                      if (_pros.isNotEmpty) ...[
                        if (_guests.isNotEmpty) const SizedBox(height: 16),
                        _buildSectionHeader('Professionals', _pros.length),
                        ..._pros.map(_buildMemberTile),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSelectedChips() {
    final selectedMembers = widget.eligibleMembers
        .where((m) => widget.selectedIds.contains(m.profileId))
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedMembers.map((member) {
        return Chip(
          avatar: CircleAvatar(
            radius: 12,
            backgroundColor: LynewedColors.gray100, // Neutral gray instead of blue
            backgroundImage: member.avatarUrl != null
                ? CachedNetworkImageProvider(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  )
                : null,
          ),
          label: Text(
            member.fullName,
            style: LynewedTextStyles.labelMedium,
          ),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => _toggleMember(member.profileId),
          backgroundColor: LynewedColors.surface,
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title ($count)',
        style: LynewedTextStyles.labelLarge.copyWith(
          color: LynewedColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMemberTile(EligibleGroupMember member) {
    final isSelected = widget.selectedIds.contains(member.profileId);

    return InkWell(
      onTap: () => _toggleMember(member.profileId),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Checkbox - using black (primary) color for selection
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleMember(member.profileId),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return LynewedColors.primary; // Black
                  }
                  return Colors.transparent;
                }),
                checkColor: LynewedColors.textOnPrimary, // White check
                side: BorderSide(
                  color: isSelected ? LynewedColors.primary : LynewedColors.gray300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundImage: member.avatarUrl != null
                  ? CachedNetworkImageProvider(member.avatarUrl!)
                  : null,
              backgroundColor: LynewedColors.surface,
              child: member.avatarUrl == null
                  ? Text(
                      member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                      style: LynewedTextStyles.bodyLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name and type badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (member.memberType == GroupMemberType.pro)
                    Text(
                      'Professional',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            // Check icon when selected
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: LynewedColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search,
              size: 48,
              color: LynewedColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No members available',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple widget showing selected members count.
class SelectedMembersCounter extends StatelessWidget {
  const SelectedMembersCounter({
    super.key,
    required this.count,
    this.onClear,
  });

  final int count;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LynewedColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count selected',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                size: 16,
                color: LynewedColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
