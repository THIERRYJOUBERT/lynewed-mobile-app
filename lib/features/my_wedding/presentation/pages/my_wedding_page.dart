import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/backend/schema/structs/pro_details_struct.dart';
import '/backend/schema/enums/enums.dart';
import '/index.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../widgets/wedding_onboarding_widget.dart';
import '../sheets/wedding_edit_sheet.dart';
import '../sheets/invite_pro_sheet.dart';
import '../sheets/note_for_pros_sheet.dart';

/// My Wedding Page - Main page for brides to manage their wedding
///
/// Routing logic:
/// - No wedding → Show onboarding
/// - onboarding_step not null → Resume onboarding at that step
/// - onboarding_step null → Show wedding overview (Sprint 3)
class MyWeddingPage extends StatefulWidget {
  const MyWeddingPage({super.key});

  static const String routeName = 'myWedding';
  static const String routePath = '/myWedding';

  @override
  State<MyWeddingPage> createState() => _MyWeddingPageState();
}

class _MyWeddingPageState extends State<MyWeddingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late MyWeddingRepository _repository;

  // State
  bool _isLoading = true;
  WeddingOverview? _wedding;
  String? _error;

  // Wedding Team data
  WeddingTeamChatInfo? _teamChatInfo;
  List<WeddingTeamMember> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadWedding();
    });
  }

  Future<void> _loadWedding() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getMyWedding();

    if (!mounted) return;

    if (result.isSuccess) {
      _wedding = result.data;
      
      // Load wedding team data if wedding exists and onboarding is complete
      if (_wedding != null && _wedding!.isOnboardingComplete) {
        await _loadWeddingTeamData();
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeddingTeamData() async {
    if (_wedding == null) return;

    // Load team chat info and active team members in parallel
    final results = await Future.wait([
      _repository.getWeddingTeamChat(weddingId: _wedding!.id),
      _repository.getActiveWeddingTeam(weddingId: _wedding!.id),
    ]);

    final chatResult = results[0] as RepositoryResult<WeddingTeamChatInfo?>;
    final teamResult = results[1] as RepositoryResult<List<WeddingTeamMember>>;

    if (chatResult.isSuccess) {
      _teamChatInfo = chatResult.data;
    }
    if (teamResult.isSuccess) {
      _teamMembers = teamResult.data ?? [];
    }
  }

  bool get _shouldShowOnboarding {
    return _wedding == null || !_wedding!.isOnboardingComplete;
  }

  void _onOnboardingComplete() {
    _loadWedding();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: LynewedColors.background,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main content - different layout for onboarding vs overview
              if (_shouldShowOnboarding && !_isLoading && _error == null)
                // Onboarding: no header, content starts from top, navbar visible
                Padding(
                  padding: const EdgeInsets.only(bottom: 84.0),
                  child: WeddingOnboardingWidget(
                    resumeAtStep: _wedding?.onboardingStep,
                    weddingId: _wedding?.id,
                    onComplete: _onOnboardingComplete,
                  ),
                )
              else
                // Overview: standard layout with header
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 110.0, 0.0, 84.0),
                  child: _buildContent(),
                ),
              // Bottom Navigation - always visible
              const Align(
                alignment: Alignment.bottomCenter,
                child: NavBarBridesWidget(number: 3),
              ),
              // Header - only for overview, not during onboarding
              if (!_shouldShowOnboarding || _isLoading || _error != null)
                _buildHeader(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48.0,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Something went wrong',
              style: LynewedTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadWedding,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    // Wedding exists and onboarding complete → Show overview
    return _buildWeddingOverview();
  }

  Widget _buildWeddingOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wedding Overview Card - full width, no margins, touches divider
          _buildOverviewCard(),
          const SizedBox(height: 30.0),
          // Sections with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wedding Team Chat Item
                if (_teamChatInfo != null) ...[
                  _buildWeddingTeamChatItem(),
                  const SizedBox(height: 30.0),
                ],
                // Wedding Team Section
                _buildWeddingTeamSection(),
                const SizedBox(height: 30.0),
                // Agenda Section
                _buildAgendaSection(),
                const SizedBox(height: 30.0),
                // Budget Section
                _buildBudgetSection(),
                const SizedBox(height: 30.0),
                // Inspirations Section
                _buildInspirationsSection(),
                const SizedBox(height: 30.0),
                // Guests Section
                _buildGuestsSection(),
                const SizedBox(height: 30.0),
                // Note for Pros Section
                _buildNoteForProsSection(),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wedding Overview Card - compact horizontal design
  Widget _buildOverviewCard() {
    return GestureDetector(
      onTap: _openEditSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: LynewedColors.primary,
        child: Row(
          children: [
            // Left: Countdown badge
            if (_wedding!.daysUntilWedding != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'J-${_wedding!.daysUntilWedding}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Center: Wedding info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _wedding!.name ?? 'My Wedding',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (_wedding!.eventDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_wedding!.eventDate!),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (_wedding!.venueAddress != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, 
                          color: Colors.white.withValues(alpha: 0.7), 
                          size: 13),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _wedding!.venueAddress!,
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Right: Edit icon
            Icon(
              Icons.edit_outlined,
              color: Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Wedding Team Chat Item - style similar to public chat room tiles
  Widget _buildWeddingTeamChatItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TEAM CHAT', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: _openTeamChat,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: LynewedColors.textPrimary,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                // Avatars stack
                SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: _buildAvatarsStack(),
                ),
                const SizedBox(width: 12.0),
                // Chat info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wedding Team',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: LynewedColors.gray300,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '${_teamChatInfo!.participantsCount} participants',
                            style: LynewedTextStyles.labelLarge.copyWith(
                              color: LynewedColors.gray300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Unread badge
                if (_teamChatInfo!.unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: LynewedColors.error,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      _teamChatInfo!.unreadCount > 99 
                          ? '99+' 
                          : _teamChatInfo!.unreadCount.toString(),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: LynewedColors.gray300,
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build avatars stack for team chat item
  Widget _buildAvatarsStack() {
    final avatars = _teamChatInfo?.participantAvatars ?? [];
    if (avatars.isEmpty) {
      return Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          color: LynewedColors.gray200,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: const Icon(Icons.group, color: LynewedColors.gray300, size: 24.0),
      );
    }

    // Show up to 4 avatars in a 2x2 grid
    if (avatars.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: CachedNetworkImage(
          imageUrl: avatars[0],
          width: 48.0,
          height: 48.0,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: LynewedColors.gray200),
          errorWidget: (_, __, ___) => Container(
            color: LynewedColors.gray200,
            child: const Icon(Icons.person, color: LynewedColors.gray300),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: SizedBox(
        width: 48.0,
        height: 48.0,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            avatars.length.clamp(0, 4),
            (index) => CachedNetworkImage(
              imageUrl: avatars[index],
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: LynewedColors.gray200),
              errorWidget: (_, __, ___) => Container(color: LynewedColors.gray200),
            ),
          ),
        ),
      ),
    );
  }

  /// Wedding Team Section - list of professionals
  Widget _buildWeddingTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('WEDDING TEAM', style: LynewedTextStyles.sectionTitle),
            if (_teamMembers.isNotEmpty)
              GestureDetector(
                onTap: _openInviteProSheet,
                child: Text(
                  '+ Add',
                  style: LynewedTextStyles.labelLarge.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10.0),
        if (_teamMembers.isEmpty)
          _buildEmptyTeamState()
        else
          _buildTeamMembersList(),
      ],
    );
  }

  /// Empty state for wedding team
  Widget _buildEmptyTeamState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline,
            size: 32.0,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 8.0),
          Text(
            'No professionals yet',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0),
          LynewedButton(
            text: 'Invite Professionals',
            onPressed: _openInviteProSheet,
          ),
        ],
      ),
    );
  }

  /// List of team members
  Widget _buildTeamMembersList() {
    return Column(
      children: _teamMembers.map((member) => Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: _buildProTile(member),
      )).toList(),
    );
  }

  /// Pro tile - photo, name, profession, chat icon
  Widget _buildProTile(WeddingTeamMember member) {
    return GestureDetector(
      onTap: () => _openProDetails(member.profileId),
      onLongPress: () => _showProOptionsModal(member),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: member.avatarUrl!,
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48.0,
                        height: 48.0,
                        color: LynewedColors.gray200,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 48.0,
                        height: 48.0,
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.person, color: LynewedColors.gray300),
                      ),
                    )
                  : Container(
                      width: 48.0,
                      height: 48.0,
                      color: LynewedColors.gray200,
                      child: const Icon(Icons.person, color: LynewedColors.gray300),
                    ),
            ),
            const SizedBox(width: 12.0),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (member.profession != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      member.profession!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Chat icon
            GestureDetector(
              onTap: () => _openChatWithPro(member.profileId),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: LynewedColors.textSecondary,
                  size: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Agenda Section
  Widget _buildAgendaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AGENDA', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4.0),
        Text(
          'Your upcoming events and tasks',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Column(
            children: [
              const Icon(Icons.event_outlined, size: 32.0, color: LynewedColors.gray300),
              const SizedBox(height: 8.0),
              Text(
                'No events yet',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
              const SizedBox(height: 12.0),
              LynewedButton(
                text: 'Add Event',
                onPressed: () {
                  // TODO: Sprint 7 - Add event sheet
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Budget Section
  Widget _buildBudgetSection() {
    final hasBudget = _wedding!.budgetMax != null && _wedding!.budgetMax! > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BUDGET', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4.0),
        Text(
          'Track your wedding expenses',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: hasBudget
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Budget',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_wedding!.budgetMax!.toInt()} ${_wedding!.currency}',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    LynewedButton(
                      text: 'View Budget',
                      onPressed: () {
                        // TODO: Sprint 7 - Budget page
                      },
                      width: double.infinity,
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 32.0, color: LynewedColors.gray300),
                    const SizedBox(height: 8.0),
                    Text(
                      'No budget set',
                      style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
                    ),
                    const SizedBox(height: 12.0),
                    LynewedButton(
                      text: 'Set Budget',
                      onPressed: _openEditSheet,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Inspirations Section
  Widget _buildInspirationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INSPIRATIONS', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4.0),
        Text(
          'Your moodboards and saved ideas',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Column(
            children: [
              const Icon(Icons.photo_library_outlined, size: 32.0, color: LynewedColors.gray300),
              const SizedBox(height: 8.0),
              Text(
                'No albums yet',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
              const SizedBox(height: 12.0),
              LynewedButton(
                text: 'Create Album',
                onPressed: () {
                  // TODO: Sprint 6 - Create album sheet
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Guests Section
  Widget _buildGuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GUESTS', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4.0),
        Text(
          'Manage your guest list',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Column(
            children: [
              const Icon(Icons.groups_outlined, size: 32.0, color: LynewedColors.gray300),
              const SizedBox(height: 8.0),
              Text(
                _wedding!.guestCount != null && _wedding!.guestCount! > 0
                    ? '${_wedding!.guestCount} guests expected'
                    : 'No guests added yet',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
              const SizedBox(height: 12.0),
              LynewedButton(
                text: 'Manage Guests',
                onPressed: () {
                  // TODO: Sprint 7 - Guests page
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Note for Pros Section
  Widget _buildNoteForProsSection() {
    final hasNote = _wedding!.noteForPros != null && _wedding!.noteForPros!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NOTE FOR PROS', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4.0),
        Text(
          'A message visible to all your professionals',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: _openNoteForProsSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: hasNote
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _wedding!.noteForPros!,
                        style: LynewedTextStyles.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Tap to edit',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.note_outlined, size: 32.0, color: LynewedColors.gray300),
                      const SizedBox(height: 8.0),
                      Text(
                        'Add a note for your professionals',
                        style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
                      ),
                      const SizedBox(height: 12.0),
                      LynewedButton(
                        text: 'Add Note',
                        onPressed: _openNoteForProsSheet,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ========== ACTIONS ==========

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeddingEditSheet(
        wedding: _wedding!,
        onSaved: _loadWedding,
      ),
    );
  }

  void _openTeamChat() {
    if (_teamChatInfo == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: _teamChatInfo!.roomId,
          isPublicRoom: true,
          publicRoomTitle: 'Wedding Team',
          hideVideoCall: true,
        ),
      ),
    ).then((_) => _loadWedding());
  }

  void _openInviteProSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteProSheet(
        weddingId: _wedding!.id,
        onProInvited: _loadWedding,
      ),
    );
  }

  void _openNoteForProsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteForProsSheet(
        wedding: _wedding!,
        onSaved: _loadWedding,
      ),
    );
  }

  Future<void> _openProDetails(String profileId) async {
    try {
      // Fetch pro details from Supabase
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
          portfolioImages: (details?['portfolio_images'] as List?)?.cast<String>(),
          slideshowImages: (details?['slideshow_images'] as List?)?.cast<String>(),
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

        context.pushNamed(
          ProDetailsWidget.routeName,
          queryParameters: {
            'proDetails': serializeParam(proDetails, ParamType.DataStruct),
          }.withoutNulls,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not found')),
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
    // Use the existing action block to navigate to chat
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: profileId,
    );
  }

  void _showProOptionsModal(WeddingTeamMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              member.displayName,
              style: LynewedTextStyles.headlineSmall,
            ),
            const SizedBox(height: 20.0),
            LynewedButton(
              text: 'View Profile',
              onPressed: () {
                Navigator.pop(context);
                _openProDetails(member.profileId);
              },
              type: LynewedButtonType.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: 10.0),
            LynewedButton(
              text: 'Send Message',
              onPressed: () {
                Navigator.pop(context);
                _openChatWithPro(member.profileId);
              },
              type: LynewedButtonType.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: 10.0),
            LynewedButton(
              text: 'Remove from Team',
              onPressed: () {
                Navigator.pop(context);
                _confirmExcludePro(member);
              },
              type: LynewedButtonType.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: 20.0),
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
        content: Text('Are you sure you want to remove ${member.displayName} from your wedding team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repository.excludeProFromWedding(
                weddingId: _wedding!.id,
                proProfileId: member.profileId,
              );
              _loadWedding();
            },
            child: const Text('Remove', style: TextStyle(color: LynewedColors.error)),
          ),
        ],
      ),
    );
  }

  /// Header with title and action icons - same style as home_brides
  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 110.0,
        decoration: const BoxDecoration(color: LynewedColors.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'WEDDING',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Settings
                      _buildHeaderIcon(
                        icon: Icons.settings_outlined,
                        onTap: () {
                          // TODO: Navigate to wedding settings
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            const Divider(height: 1.0, thickness: 1.0, color: LynewedColors.gray200),
          ],
        ),
      ),
    );
  }

  /// Header icon without badge - fixed 32x32 size for uniform alignment
  Widget _buildHeaderIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32.0,
        height: 32.0,
        child: Center(
          child: Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
        ),
      ),
    );
  }
}
