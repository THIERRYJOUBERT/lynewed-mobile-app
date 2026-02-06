import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/actions/actions.dart' as action_blocks;
import '/backend/schema/structs/pro_details_struct.dart';
import '/backend/schema/enums/enums.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../sheets/invite_pro_sheet.dart';
import '../sheets/add_guest_sheet.dart';
import '../widgets/guest_list_summary.dart';
import '../widgets/guest_status_badge.dart';
import '../widgets/guest_status_filter.dart';
import '../widgets/send_invitation_button.dart';
import '../widgets/bulk_invite_dialog.dart';

/// People Page - Unified view of wedding team (pros) and guests
class PeoplePage extends StatefulWidget {
  const PeoplePage({
    super.key,
    required this.weddingId,
    this.initialTab = 0,
  });

  final String weddingId;
  final int initialTab;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = MyWeddingRepositoryImpl();

  // Pros state
  bool _isLoadingPros = true;
  List<WeddingTeamMember> _teamMembers = [];

  // Guests state
  bool _isLoadingGuests = true;
  List<WeddingGuest> _guests = [];
  GuestStatusFilter _currentFilter = GuestStatusFilter.all;

  List<WeddingGuest> get _filteredGuests =>
      filterGuests(_guests, _currentFilter);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadPros();
    _loadGuests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPros() async {
    if (!mounted) return;
    setState(() => _isLoadingPros = true);

    final result = await _repository.getActiveWeddingTeam(
      weddingId: widget.weddingId,
    );

    if (!mounted) return;
    setState(() {
      _teamMembers = result.isSuccess ? (result.data ?? []) : [];
      _isLoadingPros = false;
    });
  }

  Future<void> _loadGuests() async {
    if (!mounted) return;
    setState(() => _isLoadingGuests = true);

    final result =
        await _repository.getWeddingGuests(weddingId: widget.weddingId);

    if (!mounted) return;
    setState(() {
      _guests = result.isSuccess ? (result.data ?? []) : [];
      _isLoadingGuests = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProsTab(),
                  _buildGuestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'PEOPLE',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: LynewedColors.textPrimary,
        unselectedLabelColor: LynewedColors.textSecondary,
        labelStyle: LynewedTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: LynewedTextStyles.bodyMedium,
        indicatorColor: LynewedColors.primary,
        indicatorWeight: 2,
        tabs: [
          Tab(
            text:
                'Pros${_teamMembers.isNotEmpty ? ' (${_teamMembers.length})' : ''}',
          ),
          Tab(
            text:
                'Guests${_guests.isNotEmpty ? ' (${_guests.length})' : ''}',
          ),
        ],
      ),
    );
  }

  // ========== PROS TAB ==========

  Widget _buildProsTab() {
    if (_isLoadingPros) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_teamMembers.isEmpty) {
      return _buildEmptyProsState();
    }

    return RefreshIndicator(
      onRefresh: _loadPros,
      color: LynewedColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _teamMembers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildProTile(_teamMembers[index]),
      ),
    );
  }

  Widget _buildEmptyProsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No professionals yet',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite photographers, florists, and other professionals to your wedding team.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Invite Professionals',
              onPressed: _openInviteProSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProTile(WeddingTeamMember member) {
    return GestureDetector(
      onTap: () => _openProDetails(member.profileId),
      onLongPress: () => _showProOptionsModal(member),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: member.avatarUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48,
                        height: 48,
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.person, color: LynewedColors.gray300),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.person, color: LynewedColors.gray300),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.gray200,
                      child: const Icon(Icons.person, color: LynewedColors.gray300),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.profession != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.profession!,
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
            GestureDetector(
              onTap: () => _openChatWithPro(member.profileId),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== GUESTS TAB ==========

  Widget _buildGuestsTab() {
    if (_isLoadingGuests) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_guests.isEmpty) {
      return _buildEmptyGuestsState();
    }

    return RefreshIndicator(
      onRefresh: _loadGuests,
      color: LynewedColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary card
          GuestListSummary(guests: _guests),
          const SizedBox(height: 16),

          // Filter + Bulk invite row
          Row(
            children: [
              Expanded(
                child: GuestStatusFilterButton(
                  currentFilter: _currentFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _currentFilter = filter),
                ),
              ),
              const SizedBox(width: 8),
              _buildBulkInviteButton(),
            ],
          ),
          const SizedBox(height: 16),

          // Guest list
          ..._filteredGuests.map(
            (guest) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildGuestTile(guest),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGuestsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No guests added yet',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your guest list for the big day.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Add Guest',
              onPressed: () => _openAddGuestSheet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkInviteButton() {
    final pendingWithEmail = _guests
        .where((g) =>
            g.status == GuestStatus.pending &&
            g.email != null &&
            g.email!.isNotEmpty)
        .toList();

    if (pendingWithEmail.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => BulkInviteDialog(
          weddingId: widget.weddingId,
          pendingGuests: pendingWithEmail,
          onInvitationsSent: _loadGuests,
        ),
      ),
      child: Text(
        'Invite all (${pendingWithEmail.length})',
        style: LynewedTextStyles.bodySmall.copyWith(
          color: LynewedColors.textSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildGuestTile(WeddingGuest guest) {
    return GestureDetector(
      onTap: () => _openAddGuestSheet(guest: guest),
      onLongPress: () => _confirmDeleteGuest(guest),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Avatar with initials
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getInitials(guest.name ?? ''),
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          guest.name ?? 'Unknown',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (guest.role != GuestRole.guest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LynewedColors.gray200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getRoleLabel(guest.role),
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: LynewedColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (guest.email != null && guest.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      guest.email!,
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GuestStatusBadge(status: guest.status),
            if (guest.status == GuestStatus.pending &&
                guest.email != null &&
                guest.email!.isNotEmpty) ...[
              const SizedBox(width: 8),
              SendInvitationButton(
                guestId: guest.id,
                weddingId: widget.weddingId,
                guestEmail: guest.email,
                guestStatus: guest.status,
                onSuccess: _loadGuests,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========== ACTIONS ==========

  void _openInviteProSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: InviteProSheet(
          weddingId: widget.weddingId,
          onProInvited: _loadPros,
        ),
      ),
    );
  }

  void _openAddGuestSheet({WeddingGuest? guest}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AddGuestSheet(
          weddingId: widget.weddingId,
          guest: guest,
          onSaved: _loadGuests,
        ),
      ),
    );
  }

  Future<void> _openProDetails(String profileId) async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('profiles')
          .select('''
            id, full_name, avatar_url,
            professional_details (
              business_name, profession, description, portfolio_images,
              slideshow_images, instagram_url, website_url, profile_video_url,
              has_cover_video, location_label
            )
          ''')
          .eq('id', profileId)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final details = data['professional_details'] as Map<String, dynamic>?;
        final professionStr = details?['profession'] as String?;
        final profession = professionStr != null
            ? Profession.values.firstWhere(
                (e) => e.name.toUpperCase() == professionStr.toUpperCase(),
                orElse: () => Profession.OTHER,
              )
            : null;
        final proDetails = ProDetailsStruct(
          proProfileId: data['id'] as String?,
          fullName: data['full_name'] as String?,
          avatarUrl: data['avatar_url'] as String?,
          businessName: details?['business_name'] as String?,
          profession: profession,
          description: details?['description'] as String?,
          portfolioImages:
              (details?['portfolio_images'] as List?)?.cast<String>(),
          slideshowImages:
              (details?['slideshow_images'] as List?)?.cast<String>(),
          instagramUrl: details?['instagram_url'] as String?,
          websiteUrl: details?['website_url'] as String?,
          profileVideoUrl: details?['profile_video_url'] as String?,
          hasCoverVideo: details?['has_cover_video'] == true,
          locationLabel: details?['location_label'] as String?,
          isFavorited: false,
          isLive: true,
          canBeContactedByBride: true,
          canContactBride: true,
        );

        if (!mounted) return;
        context.pushNamed(
          ProDetailsWidget.routeName,
          queryParameters: {
            'proDetails': serializeParam(proDetails, ParamType.DataStruct),
          }.withoutNulls,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading profile')),
        );
      }
    }
  }

  Future<void> _openChatWithPro(String profileId) async {
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: profileId,
    );
  }

  void _showProOptionsModal(WeddingTeamMember member) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 230,
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionRow(
                    icon: Icons.person_outline,
                    label: 'View Profile',
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _openProDetails(member.profileId);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildActionRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Send Message',
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _openChatWithPro(member.profileId);
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildActionRow(
                    icon: Icons.person_remove_outlined,
                    label: 'Remove from Team',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _confirmExcludePro(member);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Icon(icon, color: color, size: 14)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: LynewedTextStyles.labelLarge.copyWith(
                color: isDestructive
                    ? LynewedColors.error
                    : LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExcludePro(WeddingTeamMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Professional'),
        content: Text(
          'Are you sure you want to remove ${member.displayName} from your wedding team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repository.excludeProFromWedding(
                weddingId: widget.weddingId,
                proProfileId: member.profileId,
              );
              _loadPros();
            },
            child: const Text('Remove',
                style: TextStyle(color: LynewedColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGuest(WeddingGuest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: Text('Are you sure you want to delete "${guest.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _repository.deleteWeddingGuest(guestId: guest.id);
    if (result.isSuccess) {
      _loadGuests();
    }
  }

  String _getRoleLabel(GuestRole role) {
    return switch (role) {
      GuestRole.bridesmaid => 'Bridesmaid',
      GuestRole.bestMan => 'Best Man',
      GuestRole.family => 'Family',
      GuestRole.witness => 'Witness',
      GuestRole.other => 'Other',
      GuestRole.guest => 'Guest',
    };
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
