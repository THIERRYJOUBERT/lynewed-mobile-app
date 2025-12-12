import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/features/chat/presentation/pages/chat_details_page.dart';
import '../../data/repositories/weddings_hub_repository_impl.dart';
import '../../domain/entities/wedding_client.dart';
import '../../domain/repositories/weddings_hub_repository.dart';
import '../sheets/leave_wedding_sheet.dart';
import '../sheets/wedding_actions_sheet.dart';

/// Weddings Hub Pro Page - List of weddings where pro is participant
class WeddingsHubProPage extends StatefulWidget {
  const WeddingsHubProPage({
    super.key,
    this.initialWeddingId,
  });

  static const String routeName = 'weddingsHubPro';
  static const String routePath = '/weddingsHubPro';

  final String? initialWeddingId;

  @override
  State<WeddingsHubProPage> createState() => _WeddingsHubProPageState();
}

class _WeddingsHubProPageState extends State<WeddingsHubProPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = WeddingsHubRepositoryImpl();

  bool _didAutoOpenInitialWedding = false;

  bool _isLoading = true;
  List<WeddingClient> _weddings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadWeddings();
    });
  }

  Future<void> _loadWeddings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getMyWeddingsAsPro();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _weddings = result.data ?? [];
        _isLoading = false;
      });

      // If opened from a notification, attempt to auto-open the wedding detail.
      await _maybeAutoOpenInitialWedding();
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _maybeAutoOpenInitialWedding() async {
    if (!mounted) return;
    if (_didAutoOpenInitialWedding) return;
    final weddingId = widget.initialWeddingId;
    if (weddingId == null || weddingId.isEmpty) return;

    _didAutoOpenInitialWedding = true;

    // Try to find it in the already loaded list.
    final inList = _weddings.where((w) => w.weddingId == weddingId).toList();
    if (inList.isNotEmpty) {
      _openWeddingDetail(inList.first);
      return;
    }

    // Otherwise fetch single wedding and open.
    final result = await _repository.getWeddingClient(weddingId: weddingId);
    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      _openWeddingDetail(result.data!);
    }
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
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 126.0, 20.0, 84.0),
                child: _buildContent(),
              ),
              // Bottom Navigation
              const Align(
                alignment: Alignment.bottomCenter,
                child: NavBarProWidget(number: 3),
              ),
              // Header
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
            const Icon(Icons.error_outline, size: 48.0, color: LynewedColors.error),
            const SizedBox(height: 16.0),
            Text('Something went wrong', style: LynewedTextStyles.headlineSmall),
            const SizedBox(height: 8.0),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadWeddings,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_weddings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadWeddings,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _weddings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Manage your wedding collaborations with brides who added you to their team.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: index < _weddings.length ? 12.0 : 0),
            child: _buildWeddingCard(_weddings[index - 1]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64.0, color: LynewedColors.gray300),
          const SizedBox(height: 16.0),
          Text('No Weddings Yet', style: LynewedTextStyles.headlineMedium),
          const SizedBox(height: 8.0),
          Text(
            'When brides add you to their wedding team,\nthey will appear here.',
            style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeddingCard(WeddingClient wedding) {
    return GestureDetector(
      onTap: () => _openWeddingDetail(wedding),
      onLongPress: () => _showWeddingOptionsModal(wedding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: LynewedColors.primary,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or placeholder
            if (wedding.coverImageUrl != null && wedding.coverImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                child: CachedNetworkImage(
                  imageUrl: wedding.coverImageUrl!,
                  width: double.infinity,
                  height: 120.0,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 120.0,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 120.0,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Bride avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: wedding.brideAvatarUrl != null && wedding.brideAvatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: wedding.brideAvatarUrl!,
                            width: 48.0,
                            height: 48.0,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 48.0,
                              height: 48.0,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 48.0,
                              height: 48.0,
                              color: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(Icons.person, color: Colors.white54),
                            ),
                          )
                        : Container(
                            width: 48.0,
                            height: 48.0,
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.white54),
                          ),
                  ),
                  const SizedBox(width: 12.0),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wedding.brideName,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (wedding.eventDate != null) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            DateFormat('MMMM d, yyyy').format(wedding.eventDate!),
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (wedding.venueAddress != null) ...[
                          const SizedBox(height: 2.0),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, 
                                color: Colors.white.withValues(alpha: 0.7), 
                                size: 12.0),
                              const SizedBox(width: 2.0),
                              Expanded(
                                child: Text(
                                  wedding.venueAddress!,
                                  style: LynewedTextStyles.labelSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
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
                  // Countdown badge
                  if (wedding.daysUntilWedding != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        'J-${wedding.daysUntilWedding}',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // Muted indicator
                  if (wedding.isMuted) ...[
                    const SizedBox(width: 8.0),
                    Icon(Icons.notifications_off_outlined, 
                      color: Colors.white.withValues(alpha: 0.5), 
                      size: 18.0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWeddingDetail(WeddingClient wedding) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _WeddingClientDetailPage(
          wedding: wedding,
          onChanged: _loadWeddings,
        ),
      ),
    );
  }

  void _showWeddingOptionsModal(WeddingClient wedding) {
    WeddingActionsSheet.show(
      context: context,
      wedding: wedding,
      onViewDetails: () => _openWeddingDetail(wedding),
      onToggleMute: () => _toggleMute(wedding),
      onLeaveWedding: () => _openLeaveWeddingSheet(wedding),
    );
  }

  Future<void> _toggleMute(WeddingClient wedding) async {
    final result = await _repository.toggleMuteWedding(
      weddingId: wedding.weddingId,
      isMuted: !wedding.isMuted,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      _loadWeddings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wedding.isMuted ? 'Notifications unmuted' : 'Notifications muted',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    }
  }

  void _openLeaveWeddingSheet(WeddingClient wedding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LeaveWeddingSheet(
          wedding: wedding,
          onLeft: _loadWeddings,
        ),
      ),
    );
  }

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
                    'WEDDINGS',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
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
}

/// Wedding Client Detail Page - Pro views wedding details
class _WeddingClientDetailPage extends StatefulWidget {
  const _WeddingClientDetailPage({
    required this.wedding,
    required this.onChanged,
  });

  final WeddingClient wedding;
  final VoidCallback onChanged;

  @override
  State<_WeddingClientDetailPage> createState() => _WeddingClientDetailPageState();
}

class _WeddingClientDetailPageState extends State<_WeddingClientDetailPage> {
  final _repository = WeddingsHubRepositoryImpl();
  final _moreIconKey = GlobalKey();
  TeamChatInfo? _teamChatInfo;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.wedding.isMuted;
    _loadTeamChatInfo();
  }

  Future<void> _loadTeamChatInfo() async {
    final result = await _repository.getWeddingTeamChatInfo(
      weddingId: widget.wedding.weddingId,
    );
    if (result.isSuccess && mounted) {
      setState(() => _teamChatInfo = result.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeddingInfoCard(),
                    const SizedBox(height: 30.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTeamChatSection(),
                          const SizedBox(height: 30.0),
                          _buildChatWithBrideSection(),
                          const SizedBox(height: 30.0),
                          _buildNoteSection(),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left, size: 28.0, color: LynewedColors.textPrimary),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              widget.wedding.brideName.toUpperCase(),
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isMuted)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.notifications_off_outlined,
                color: LynewedColors.textSecondary,
                size: 20.0,
              ),
            ),
          GestureDetector(
            key: _moreIconKey,
            onTap: _showActionsModal,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.more_vert,
              color: LynewedColors.textPrimary,
              size: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionsModal() {
    final RenderBox renderBox = _moreIconKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + size.height + 4.0,
              right: 20.0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 230.0,
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionRow(
                          icon: _isMuted ? Icons.notifications_outlined : Icons.notifications_off_outlined,
                          label: _isMuted ? 'Unmute Notifications' : 'Mute Notifications',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _toggleMute();
                          },
                        ),
                        const SizedBox(height: 4.0),
                        _buildActionRow(
                          icon: Icons.logout_outlined,
                          label: 'Leave Wedding',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _openLeaveSheet();
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final color = isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36.0,
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 14.0),
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: LynewedTextStyles.labelLarge.copyWith(
                color: isDestructive ? LynewedColors.error : LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeddingInfoCard() {
    final wedding = widget.wedding;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: LynewedColors.primary,
      child: Row(
        children: [
          if (wedding.daysUntilWedding != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  'J-${wedding.daysUntilWedding}',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wedding.weddingName ?? 'My Wedding',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (wedding.eventDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(wedding.eventDate!),
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
                if (wedding.venueAddress != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          wedding.venueAddress!,
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
        ],
      ),
    );
  }

  Widget _buildTeamChatSection() {
    final hasChat = _teamChatInfo != null;
    final unreadCount = _teamChatInfo?.unreadCount ?? 0;
    final avatars = _teamChatInfo?.participantAvatars ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WEDDING TEAM CHAT', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: hasChat ? _openTeamChat : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: hasChat ? LynewedColors.textPrimary : LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                // Stacked avatars (max 5)
                if (avatars.isNotEmpty)
                  _buildStackedAvatars(avatars, hasChat)
                else
                  Icon(
                    Icons.group_outlined,
                    color: hasChat ? Colors.white : LynewedColors.gray300,
                    size: 24.0,
                  ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasChat ? 'Open Team Chat' : 'No team chat available',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: hasChat ? Colors.white : LynewedColors.textSecondary,
                        ),
                      ),
                      if (hasChat && _teamChatInfo!.participantsCount > 0) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          '${_teamChatInfo!.participantsCount} participants',
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Unread badge
                if (hasChat && unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
                if (hasChat)
                  Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.5), size: 16.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedAvatars(List<String> avatars, bool isActive) {
    const double avatarSize = 28.0;
    const double overlap = 10.0;
    final displayAvatars = avatars.take(5).toList();
    final totalWidth = avatarSize + (displayAvatars.length - 1) * (avatarSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: avatarSize,
      child: Stack(
        children: List.generate(displayAvatars.length, (index) {
          return Positioned(
            left: index * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? LynewedColors.textPrimary : LynewedColors.surface,
                  width: 2.0,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: displayAvatars[index],
                  width: avatarSize - 4,
                  height: avatarSize - 4,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: LynewedColors.gray200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: LynewedColors.gray200,
                    child: const Icon(Icons.person, size: 14.0, color: LynewedColors.gray300),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChatWithBrideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CHAT WITH BRIDE', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: _openChatWithBride,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: widget.wedding.brideAvatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.wedding.brideAvatarUrl!,
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 40.0,
                          height: 40.0,
                          color: LynewedColors.gray200,
                          child: const Icon(Icons.person, color: LynewedColors.gray300),
                        ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wedding.brideName,
                        style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Send a private message',
                        style: LynewedTextStyles.labelSmall.copyWith(color: LynewedColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chat_bubble_outline, color: LynewedColors.textSecondary, size: 20.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    final hasNote = widget.wedding.noteForPros != null && widget.wedding.noteForPros!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BRIDE\'S NOTE', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: hasNote
              ? Text(
                  widget.wedding.noteForPros!,
                  style: LynewedTextStyles.bodyMedium,
                  maxLines: 20,
                  overflow: TextOverflow.ellipsis,
                )
              : Row(
                  children: [
                    const Icon(Icons.note_outlined, color: LynewedColors.gray300, size: 24.0),
                    const SizedBox(width: 12.0),
                    Text(
                      'No note from bride',
                      style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openTeamChat() async {
    if (_teamChatInfo == null) return;
    
    // Ensure pro is added as participant to the chat
    final ensureResult = await _repository.ensureProInWeddingTeamChat(
      weddingId: widget.wedding.weddingId,
    );
    
    if (!ensureResult.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ensureResult.error ?? 'Failed to join chat',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: _teamChatInfo!.roomId,
          isPublicRoom: true,
          isWeddingTeamChat: true,
          publicRoomTitle: 'Wedding Team',
          hideVideoCall: true,
        ),
      ),
    ).then((_) => _loadTeamChatInfo());
  }

  Future<void> _openChatWithBride() async {
    await action_blocks.contactChatRoom(
      context,
      targetProfileID: widget.wedding.brideProfileId,
    );
  }

  Future<void> _toggleMute() async {
    final newMutedState = !_isMuted;
    final result = await _repository.toggleMuteWedding(
      weddingId: widget.wedding.weddingId,
      isMuted: newMutedState,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isMuted = newMutedState);
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newMutedState ? 'Notifications muted' : 'Notifications unmuted',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    }
  }

  void _openLeaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: LeaveWeddingSheet(
          wedding: widget.wedding,
          onLeft: () {
            widget.onChanged();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
