/// Wedding Groups Page - List and manage wedding chat groups.
///
/// Displays all wedding groups (team + custom) with options to:
/// - Navigate to chat
/// - Create new groups
/// - Manage members
/// - Edit/delete custom groups
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '/features/chat/presentation/pages/chat_details_page.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/wedding_group.dart';
import '../bloc/wedding_groups_cubit.dart';
import '../bloc/wedding_groups_state.dart';
import '../sheets/create_group_sheet.dart';
import '../sheets/group_members_sheet.dart';
import '../widgets/wedding_group_tile.dart';

/// Page for managing wedding groups.
///
/// Shows default wedding team and custom groups (public/private).
class WeddingGroupsPage extends StatelessWidget {
  const WeddingGroupsPage({
    super.key,
    required this.weddingId,
  });

  final String weddingId;

  static const String routeName = 'weddingGroups';
  static const String routePath = '/weddingGroups';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeddingGroupsCubit(
        repository: MyWeddingRepositoryImpl(),
        weddingId: weddingId,
      )..loadGroups(),
      child: _WeddingGroupsPageContent(weddingId: weddingId),
    );
  }
}

class _WeddingGroupsPageContent extends StatelessWidget {
  const _WeddingGroupsPageContent({required this.weddingId});

  final String weddingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header - same style as MessagesPage
            _buildHeader(context),

            // Divider
            const Divider(height: 1, color: LynewedColors.gray200),

            // Body
            Expanded(
              child: BlocConsumer<WeddingGroupsCubit, WeddingGroupsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: LynewedColors.error,
              ),
            );
            context.read<WeddingGroupsCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<WeddingGroupsCubit>().loadGroups(),
            child: state.groups.isEmpty
                ? _buildEmptyState(context)
                : _buildGroupsList(context, state),
          );
        },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateGroupSheet(context),
        backgroundColor: LynewedColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Header with back button, title - matches MessagesPage style
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          // Back button - Standard 24x24 icon with 44px tap target
          LynewedComponentStyles.backButton(context),

          const SizedBox(width: 4),

          // Title - same style as MessagesPage
          Expanded(
            child: Text(
              'Groups',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.groups_outlined,
          size: 80,
          color: LynewedColors.textSecondary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 24),
        Text(
          'No groups',
          style: LynewedTextStyles.titleMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create groups to communicate with your guests and vendors',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGroupsList(BuildContext context, WeddingGroupsState state) {
    final defaultGroup = state.defaultGroup;
    final publicGroups = state.publicGroups;
    final privateGroups = state.privateGroups;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Default wedding team
        if (defaultGroup != null) ...[
          _buildSectionHeader('Main Group'),
          const SizedBox(height: 8),
          WeddingGroupTile(
            group: defaultGroup,
            onTap: () => _navigateToChat(context, defaultGroup),
          ),
          const SizedBox(height: 24),
        ],

        // Public groups
        if (publicGroups.isNotEmpty) ...[
          _buildSectionHeader('Public Groups', 'Accessible to all participants'),
          const SizedBox(height: 8),
          ...publicGroups.map((group) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WeddingGroupTile(
                  group: group,
                  onTap: () => _navigateToChat(context, group),
                  // Public groups auto-join, no member management needed
                  onEdit: () => _openEditGroupSheet(context, group),
                  onDelete: () => _deleteGroup(context, group),
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Private groups
        if (privateGroups.isNotEmpty) ...[
          _buildSectionHeader('Private Groups', 'Invitation only'),
          const SizedBox(height: 8),
          ...privateGroups.map((group) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WeddingGroupTile(
                  group: group,
                  onTap: () => _navigateToChat(context, group),
                  onManageMembers: () => _openMembersSheet(context, group),
                  onEdit: () => _openEditGroupSheet(context, group),
                  onDelete: () => _deleteGroup(context, group),
                ),
              )),
        ],

        // Bottom padding for FAB
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LynewedTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToChat(BuildContext context, WeddingGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: group.roomId,
          isPublicRoom: true, // true for black header
          isWeddingTeamChat: true,
          hideVideoCall: true,
          publicRoomTitle: group.name,
        ),
      ),
    );
  }

  void _openCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: CreateGroupSheet(
          weddingId: weddingId,
          onGroupCreated: () {
            context.read<WeddingGroupsCubit>().loadGroups();
          },
        ),
      ),
    );
  }

  void _openEditGroupSheet(BuildContext context, WeddingGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: CreateGroupSheet(
          weddingId: weddingId,
          existingGroup: group,
          onGroupCreated: () {
            context.read<WeddingGroupsCubit>().loadGroups();
          },
        ),
      ),
    );
  }

  void _openMembersSheet(BuildContext context, WeddingGroup group) {
    final cubit = context.read<WeddingGroupsCubit>();
    cubit.selectGroup(group);
    cubit.loadEligibleMembers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: GroupMembersSheet(
            group: group,
            onMembersChanged: () {
              cubit.loadGroups();
            },
          ),
        ),
      ),
    );
  }

  void _deleteGroup(BuildContext context, WeddingGroup group) {
    context.read<WeddingGroupsCubit>().deleteGroup(group.roomId);
  }
}
