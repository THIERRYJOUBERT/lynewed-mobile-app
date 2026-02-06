import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import 'wedding_groups_page.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/backend/schema/structs/pro_details_struct.dart';
import '/backend/schema/enums/enums.dart';
import '/index.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '/core/utils/budget_formatter.dart';
import '/core/services/currency_service.dart';
import '/core/constants/currencies.dart';
import '../widgets/wedding_onboarding_widget.dart';
import '../sheets/wedding_edit_sheet.dart';
import '../sheets/invite_pro_sheet.dart';
import '../sheets/note_for_pros_sheet.dart';
import 'inspirations_page.dart';
import 'guests_page.dart';
import 'guest_albums_page.dart';
import 'magazine_selection_page.dart';
import 'people_page.dart';
import 'organization_page.dart';
import '../sheets/create_album_sheet.dart';
import '../sheets/add_guest_sheet.dart';

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
  List<WeddingTeamMember> _teamMembers = [];

  // Agenda & Budget preview data
  List<WeddingEvent> _upcomingEvents = [];
  List<WeddingExpense> _expenses = [];
  double _totalExpenses = 0;
  double _totalPaid = 0;

  // Inspirations preview data
  List<InspirationAlbum> _inspirationAlbums = [];

  // Guests preview data
  List<WeddingGuest> _guests = [];

  // Magazine preview data
  List<MagazineSelection> _magazineSelections = [];
  List<MagazineOrder> _magazineOrders = [];

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

    // Load active team members, events, expenses, albums, guests and magazine in parallel
    final results = await Future.wait([
      _repository.getActiveWeddingTeam(weddingId: _wedding!.id),
      _repository.getWeddingEvents(weddingId: _wedding!.id),
      _repository.getWeddingExpenses(weddingId: _wedding!.id),
      _repository.getInspirationAlbums(weddingId: _wedding!.id),
      _repository.getWeddingGuests(weddingId: _wedding!.id),
      _repository.getMagazineSelections(weddingId: _wedding!.id),
      _repository.getMagazineOrders(weddingId: _wedding!.id),
    ]);

    final teamResult = results[0] as RepositoryResult<List<WeddingTeamMember>>;
    final eventsResult = results[1] as RepositoryResult<List<WeddingEvent>>;
    final expensesResult = results[2] as RepositoryResult<List<WeddingExpense>>;
    final albumsResult = results[3] as RepositoryResult<List<InspirationAlbum>>;
    final guestsResult = results[4] as RepositoryResult<List<WeddingGuest>>;
    final magazineResult = results[5] as RepositoryResult<List<MagazineSelection>>;
    final ordersResult = results[6] as RepositoryResult<List<MagazineOrder>>;

    if (teamResult.isSuccess) {
      _teamMembers = teamResult.data ?? [];
    }
    if (eventsResult.isSuccess) {
      // Filter upcoming events (not done, not cancelled, future or today)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      _upcomingEvents = (eventsResult.data ?? [])
          .where((e) => !e.isDone && !e.isCancelled && !e.eventDate.isBefore(today))
          .take(5)
          .toList();
    }
    if (expensesResult.isSuccess) {
      _expenses = expensesResult.data ?? [];
      final userCurrency = BudgetFormatter.userCurrency;
      final service = CurrencyService.instance;
      _totalExpenses = _expenses.fold(0, (sum, e) {
        final converted = service.convert(e.amount, from: e.currencyCode, to: userCurrency) ?? e.amount;
        return sum + converted;
      });
      _totalPaid = _expenses.fold(0, (sum, e) {
        final converted = service.convert(e.paidAmount, from: e.currencyCode, to: userCurrency) ?? e.paidAmount;
        return sum + converted;
      });
    }

    if (albumsResult.isSuccess) {
      _inspirationAlbums = albumsResult.data ?? [];
    }

    if (guestsResult.isSuccess) {
      _guests = guestsResult.data ?? [];
    }

    if (magazineResult.isSuccess) {
      _magazineSelections = magazineResult.data ?? [];
    }

    if (ordersResult.isSuccess) {
      _magazineOrders = ordersResult.data ?? [];
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
                child: NavBarBridesWidget(number: 4),
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
            const Text(
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

    // Wedding cancelled → Show cancelled view
    if (_wedding != null && _wedding!.isCancelled) {
      return _buildCancelledWeddingView();
    }

    // Wedding exists and onboarding complete → Show overview
    return _buildWeddingOverview();
  }

  Widget _buildWeddingOverview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Card - full width
          _buildOverviewCard(),
          // 2. Invite Code Banner - thin bar below hero
          _buildInviteCodeBanner(),
          const SizedBox(height: 20.0),
          // Sections with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. People - Pros + Guests horizontal scroll
                _buildPeopleSection(),
                const SizedBox(height: 30.0),
                // 4. Organization - Budget + Agenda split card
                _buildOrganizationSection(),
                const SizedBox(height: 30.0),
                // 5. Albums - unified horizontal scroll
                _buildAlbumsSection(),
                const SizedBox(height: 30.0),
                // 6. Magazine - single entry card
                _buildMagazineCard(),
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

  String _formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount.toInt())} $currency';
  }

  String _getGuestInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // QR Code global key for screenshot
  final GlobalKey _qrKey = GlobalKey();

  /// Copy invite code to clipboard
  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Code copied to clipboard',
          style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: LynewedColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Share invite code
  Future<void> _shareInviteCode(String code) async {
    try {
      final weddingName = _wedding?.name ?? 'My Wedding';
      final shareText = '''
You're invited to $weddingName!

Download the Lynewed app and use this code to join:
$code

Or scan the QR code in the app.
''';

      // Get the render box for iOS 26+ sharePositionOrigin requirement
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.share(
        shareText,
        subject: 'Wedding Invitation - $weddingName',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('Share error: $e');
      _showErrorSnackbar('Could not share invite code');
    }
  }

  /// Download QR code as image
  Future<void> _downloadQRCode(String code) async {
    // Get the render box BEFORE async operations for iOS 26+ sharePositionOrigin requirement
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showErrorSnackbar('Could not capture QR code');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showErrorSnackbar('Could not generate image');
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final weddingName = _wedding?.name?.replaceAll(RegExp(r'[^\w\s]'), '') ?? 'wedding';
      final fileName = 'lynewed_qr_${weddingName.toLowerCase().replaceAll(' ', '_')}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share the file so user can save it
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Wedding QR Code - ${_wedding?.name ?? 'My Wedding'}',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint('QR save error: $e');
      _showErrorSnackbar('Could not save QR code');
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: LynewedColors.error,
      ),
    );
  }

  /// Cancelled Wedding View - shown when wedding status is 'cancelled'
  Widget _buildCancelledWeddingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 64.0,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Wedding Cancelled',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Your wedding planning has been paused. You can resume at any time.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            LynewedButton(
              text: 'Resume Planning',
              onPressed: _resumeWedding,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // ========== NEW SECTIONS (Redesign V2) ==========

  /// Invite Code Banner - thin bar below hero card
  Widget _buildInviteCodeBanner() {
    final inviteCode = _wedding?.inviteCode;
    final hasCode = inviteCode != null && inviteCode.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: hasCode
          ? Row(
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  size: 14,
                  color: LynewedColors.textSecondary,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyInviteCode(inviteCode),
                  child: Text(
                    inviteCode,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _copyInviteCode(inviteCode),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.copy_outlined, size: 16, color: LynewedColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openQrCodeSheet,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.qr_code, size: 16, color: LynewedColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _shareInviteCode(inviteCode),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.ios_share, size: 16, color: LynewedColors.textSecondary),
                  ),
                ),
              ],
            )
          : Text(
              'Invite code generating...',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
    );
  }

  /// QR Code Sheet - shows full QR code with save/share actions
  void _openQrCodeSheet() {
    final inviteCode = _wedding?.inviteCode;
    if (inviteCode == null || inviteCode.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LynewedSheet(
        title: 'Invite Code',
        onClose: () => Navigator.pop(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            // QR Code
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: QrImageView(
                  data: 'https://lynewed.com/join/$inviteCode',
                  version: QrVersions.auto,
                  size: 180.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: LynewedColors.textPrimary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: LynewedColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Code display
            Text(
              inviteCode,
              style: LynewedTextStyles.headlineSmall.copyWith(
                letterSpacing: 4.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_wedding?.inviteCodeExpiresAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Valid until ${DateFormat('MMMM d, yyyy').format(_wedding!.inviteCodeExpiresAt!)}',
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: LynewedButton(
                    text: 'Save QR',
                    onPressed: () => _downloadQRCode(inviteCode),
                    type: LynewedButtonType.secondary,
                    icon: Icons.download,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LynewedButton(
                    text: 'Share',
                    onPressed: () => _shareInviteCode(inviteCode),
                    icon: Icons.share,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// People Section - horizontal scroll of pros + guests
  Widget _buildPeopleSection() {
    final hasNote = _wedding!.noteForPros != null && _wedding!.noteForPros!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with note icon, + Add, View all
        Row(
          children: [
            const Text('PEOPLE', style: LynewedTextStyles.sectionTitle),
            const SizedBox(width: 8),
            // Note for pros icon
            GestureDetector(
              onTap: _openNoteForProsSheet,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.note_outlined,
                      size: 18,
                      color: hasNote ? LynewedColors.textPrimary : LynewedColors.textSecondary,
                    ),
                  ),
                  if (!hasNote)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: LynewedColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            if (_teamMembers.isNotEmpty || _guests.isNotEmpty)
              GestureDetector(
                onTap: _openAddPeopleChoice,
                child: Text(
                  '+ Add',
                  style: LynewedTextStyles.labelLarge.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openPeoplePage,
              child: Text(
                'View all',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        // Subtitle with counts
        Text(
          _buildPeopleSubtitle(),
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        // Horizontal scroll of avatars
        if (_teamMembers.isEmpty && _guests.isEmpty)
          _buildEmptyPeopleState()
        else
          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _teamMembers.length + _guests.take(15).length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                // First item: Add button
                if (index == 0) {
                  return _buildAddPersonButton();
                }
                // Pros
                final proIndex = index - 1;
                if (proIndex < _teamMembers.length) {
                  return _buildCompactProAvatar(_teamMembers[proIndex]);
                }
                // Guests
                final guestIndex = proIndex - _teamMembers.length;
                final guestsToShow = _guests.take(15).toList();
                return _buildCompactGuestAvatar(guestsToShow[guestIndex]);
              },
            ),
          ),
      ],
    );
  }

  String _buildPeopleSubtitle() {
    final parts = <String>[];
    if (_teamMembers.isNotEmpty) {
      parts.add('${_teamMembers.length} pro${_teamMembers.length > 1 ? 's' : ''}');
    }
    if (_guests.isNotEmpty) {
      parts.add('${_guests.length} guest${_guests.length > 1 ? 's' : ''}');
    }
    if (parts.isEmpty) return 'Your wedding team & guests';
    return parts.join(' \u00b7 ');
  }

  Widget _buildEmptyPeopleState() {
    return GestureDetector(
      onTap: _openPeoplePage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          children: [
            const Icon(Icons.people_outline, size: 32.0, color: LynewedColors.gray300),
            const SizedBox(height: 8.0),
            Text(
              'Add your professionals and guests',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
            ),
            const SizedBox(height: 12.0),
            LynewedButton(
              text: 'Add People',
              onPressed: _openAddPeopleChoice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPersonButton() {
    return GestureDetector(
      onTap: _openAddPeopleChoice,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LynewedColors.surface,
                border: Border.all(color: LynewedColors.gray200, width: 1),
              ),
              child: const Icon(Icons.add, size: 22, color: LynewedColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactProAvatar(WeddingTeamMember member) {
    return GestureDetector(
      onTap: () => _openProDetails(member.profileId),
      onLongPress: () => _showProOptionsModal(member),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LynewedColors.primary, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: member.avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: LynewedColors.gray200,
                          child: const Icon(Icons.person, size: 20, color: LynewedColors.gray300),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: LynewedColors.gray200,
                          child: const Icon(Icons.person, size: 20, color: LynewedColors.gray300),
                        ),
                      )
                    : Container(
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.person, size: 20, color: LynewedColors.gray300),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.displayName.split(' ').first,
              style: LynewedTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactGuestAvatar(WeddingGuest guest) {
    return GestureDetector(
      onTap: _openGuestsPage,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: LynewedColors.gray200,
              ),
              child: Center(
                child: Text(
                  _getGuestInitials(guest.name ?? ''),
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: LynewedColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              (guest.name ?? '?').split(' ').first,
              style: LynewedTextStyles.labelSmall.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Organization Section - Budget + Agenda side by side
  Widget _buildOrganizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ORGANIZATION', style: LynewedTextStyles.sectionTitle),
            GestureDetector(
              onTap: _openOrganizationPage,
              child: Text(
                'View all',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          _buildOrganizationSubtitle(),
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        _buildOrganizationCard(),
      ],
    );
  }

  String _buildOrganizationSubtitle() {
    final parts = <String>[];
    if (_upcomingEvents.isNotEmpty) {
      parts.add('${_upcomingEvents.length} upcoming');
    }
    final hasBudget = _wedding!.budgetMax != null && _wedding!.budgetMax! > 0;
    if (hasBudget || _expenses.isNotEmpty) {
      final userCurrency = BudgetFormatter.userCurrency;
      final service = CurrencyService.instance;
      final budgetMaxDisplay = _wedding!.budgetMax != null
          ? (service.convert(_wedding!.budgetMax!.toDouble(), from: _wedding!.currency, to: userCurrency) ?? _wedding!.budgetMax!.toDouble())
          : 0.0;
      if (hasBudget && budgetMaxDisplay > 0) {
        final pct = ((_totalExpenses / budgetMaxDisplay) * 100).round();
        parts.add('$pct% budget spent');
      }
    }
    if (parts.isEmpty) return 'Budget & upcoming events';
    return parts.join(' \u00b7 ');
  }

  Widget _buildOrganizationCard() {
    final hasBudget = _wedding!.budgetMax != null && _wedding!.budgetMax! > 0;
    final hasEvents = _upcomingEvents.isNotEmpty;
    final hasExpenses = _expenses.isNotEmpty;

    if (!hasBudget && !hasExpenses && !hasEvents) {
      return GestureDetector(
        onTap: _openOrganizationPage,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Column(
            children: [
              const Icon(Icons.dashboard_customize_outlined, size: 32.0, color: LynewedColors.gray300),
              const SizedBox(height: 8.0),
              Text(
                'Plan your budget and schedule',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
              const SizedBox(height: 12.0),
              LynewedButton(
                text: 'Get Started',
                onPressed: _openOrganizationPage,
              ),
            ],
          ),
        ),
      );
    }

    final userCurrency = BudgetFormatter.userCurrency;
    final currencySymbol = CurrencyData.getSymbol(userCurrency);
    final service = CurrencyService.instance;
    final budgetMaxDisplay = _wedding!.budgetMax != null
        ? (service.convert(_wedding!.budgetMax!.toDouble(), from: _wedding!.currency, to: userCurrency) ?? _wedding!.budgetMax!.toDouble())
        : 0.0;
    final progress = hasBudget && budgetMaxDisplay > 0
        ? (_totalExpenses / budgetMaxDisplay).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = hasBudget && _totalExpenses > budgetMaxDisplay;

    return GestureDetector(
      onTap: _openOrganizationPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Budget
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasBudget || hasExpenses) ...[
                      Text(
                        '${_formatAmount(_totalExpenses, currencySymbol)} / ${_formatAmount(budgetMaxDisplay, currencySymbol)}',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isOverBudget ? LynewedColors.error : LynewedColors.textPrimary,
                        ),
                      ),
                      if (hasBudget) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: LynewedColors.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget ? LynewedColors.error : LynewedColors.textPrimary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOverBudget
                              ? 'Over by ${_formatAmount(_totalExpenses - budgetMaxDisplay, currencySymbol)}'
                              : '${_formatAmount(budgetMaxDisplay - _totalExpenses, currencySymbol)} left',
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: isOverBudget ? LynewedColors.error : LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Mini paid/pending
                      Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: LynewedColors.success, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatAmount(_totalPaid, currencySymbol),
                              style: LynewedTextStyles.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: LynewedColors.warning, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formatAmount(_totalExpenses - _totalPaid, currencySymbol),
                              style: LynewedTextStyles.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        'Set budget',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: LynewedColors.gray200,
              ),
              // Right: Next Up (Agenda)
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next up',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasEvents)
                      ..._upcomingEvents.take(3).map((event) {
                        final dateFormat = DateFormat('MMM d');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: const BoxDecoration(
                                  color: LynewedColors.textPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dateFormat.format(event.eventDate),
                                style: LynewedTextStyles.labelSmall.copyWith(
                                  color: LynewedColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  event.title,
                                  style: LynewedTextStyles.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      Text(
                        'No upcoming events',
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
      ),
    );
  }

  /// Albums Section - unified horizontal scroll (inspiration + guest albums)
  Widget _buildAlbumsSection() {
    final hasAlbums = _inspirationAlbums.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ALBUMS', style: LynewedTextStyles.sectionTitle),
            GestureDetector(
              onTap: _openInspirationsPage,
              child: Text(
                'View all',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          _buildAlbumsSubtitle(),
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        if (!hasAlbums)
          _buildEmptyAlbumsState()
        else
          SizedBox(
            height: 145,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _inspirationAlbums.length + 2, // +1 for new, +1 for guest albums
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) return _buildNewAlbumCard();
                if (index <= _inspirationAlbums.length) {
                  return _buildAlbumPreviewCard(_inspirationAlbums[index - 1]);
                }
                return _buildGuestAlbumsCard();
              },
            ),
          ),
      ],
    );
  }

  String _buildAlbumsSubtitle() {
    final parts = <String>[];
    if (_inspirationAlbums.isNotEmpty) {
      parts.add('${_inspirationAlbums.length} inspiration');
    }
    // Guest albums are always available
    parts.add('guest albums');
    if (parts.isEmpty) return 'Your moodboards and memories';
    return parts.join(' \u00b7 ');
  }

  Widget _buildEmptyAlbumsState() {
    return GestureDetector(
      onTap: _openInspirationsPage,
      child: Container(
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
              'Create moodboards and view guest photos',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            LynewedButton(
              text: 'Create Album',
              onPressed: _openCreateAlbumSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAlbumCard() {
    return GestureDetector(
      onTap: _openCreateAlbumSheet,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: LynewedColors.gray200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 28, color: LynewedColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              'New',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumPreviewCard(InspirationAlbum album) {
    return GestureDetector(
      onTap: _openInspirationsPage,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: album.coverImageUrl != null && album.coverImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: album.coverImageUrl!,
                      width: 120,
                      height: 85,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 120, height: 85,
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.photo_library_outlined, color: LynewedColors.gray300, size: 24),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 120, height: 85,
                        color: LynewedColors.gray200,
                        child: const Icon(Icons.photo_library_outlined, color: LynewedColors.gray300, size: 24),
                      ),
                    )
                  : Container(
                      width: 120, height: 85,
                      color: LynewedColors.gray200,
                      child: const Icon(Icons.photo_library_outlined, color: LynewedColors.gray300, size: 24),
                    ),
            ),
            const SizedBox(height: 6),
            // Name
            Row(
              children: [
                Flexible(
                  child: Text(
                    album.name,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (album.isPrivate) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_outline, size: 10, color: LynewedColors.textSecondary),
                ],
              ],
            ),
            const SizedBox(height: 2),
            // Count
            Text(
              '${album.imagesCount} image${album.imagesCount != 1 ? 's' : ''}',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestAlbumsCard() {
    return GestureDetector(
      onTap: _openGuestAlbumsPage,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: LynewedColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LynewedColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo_album_outlined, color: LynewedColors.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Guest Photos',
              style: LynewedTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'View albums',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Magazine Card - single entry point
  Widget _buildMagazineCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MAGAZINE', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: _openMagazineSelectionPage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: LynewedColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    color: LynewedColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo Magazine',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        _buildMagazineSubtitle(),
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: LynewedColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildMagazineSubtitle() {
    final parts = <String>[];
    if (_magazineSelections.isNotEmpty) {
      parts.add('${_magazineSelections.length} photo${_magazineSelections.length > 1 ? 's' : ''} selected');
    }
    if (_magazineOrders.isNotEmpty) {
      parts.add('${_magazineOrders.length} order${_magazineOrders.length > 1 ? 's' : ''}');
    }
    if (parts.isEmpty) return 'Create your wedding magazine';
    return parts.join(' \u00b7 ');
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

  void _openWeddingMessages() {
    if (_wedding?.id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeddingGroupsPage(
          weddingId: _wedding!.id,
        ),
      ),
    ).then((_) => _loadWedding());
  }

  void _openInviteProSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: InviteProSheet(
          weddingId: _wedding!.id,
          onProInvited: _loadWedding,
        ),
      ),
    );
  }

  void _openNoteForProsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.70,
        child: NoteForProsSheet(
          wedding: _wedding!,
          onSaved: _loadWedding,
        ),
      ),
    );
  }

  void _openInspirationsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InspirationsPage(weddingId: _wedding!.id),
      ),
    ).then((_) => _loadWedding());
  }

  void _openGuestsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuestsPage(weddingId: _wedding!.id),
      ),
    ).then((_) => _loadWedding());
  }

  void _openGuestAlbumsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GuestAlbumsPage(weddingId: _wedding!.id),
      ),
    );
  }

  void _openPeoplePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PeoplePage(
          weddingId: _wedding!.id,
        ),
      ),
    ).then((_) => _loadWedding());
  }

  void _openOrganizationPage({int initialTab = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrganizationPage(
          weddingId: _wedding!.id,
          budgetMin: _wedding!.budgetMin,
          budgetMax: _wedding!.budgetMax,
          currency: _wedding!.currency,
          initialTab: initialTab,
        ),
      ),
    ).then((_) => _loadWedding());
  }

  void _openAddPeopleChoice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.business_center_outlined),
                title: const Text('Add Professional'),
                subtitle: const Text('Invite a wedding professional'),
                onTap: () {
                  Navigator.pop(context);
                  _openInviteProSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Add Guest'),
                subtitle: const Text('Add a guest to your wedding'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddGuestSheet();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddGuestSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AddGuestSheet(
          weddingId: _wedding!.id,
          onSaved: _loadWedding,
        ),
      ),
    );
  }

  void _openCreateAlbumSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: CreateAlbumSheet(
          weddingId: _wedding!.id,
          onCreated: _loadWedding,
        ),
      ),
    );
  }

  void _openMagazineSelectionPage() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || _wedding == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MagazineSelectionPage(
          weddingId: _wedding!.id,
          userId: currentUserId,
          weddingTitle: _wedding!.name ?? 'My Wedding',
          weddingDate: _wedding!.eventDate ?? DateTime.now(),
        ),
      ),
    ).then((_) => _loadWedding());
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
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
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
                    const SizedBox(height: 4.0),
                    _buildActionRow(
                      icon: Icons.chat_bubble_outline,
                      label: 'Send Message',
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _openChatWithPro(member.profileId);
                      },
                    ),
                    const SizedBox(height: 4.0),
                    _buildActionRow(
                      icon: Icons.person_remove_outlined,
                      label: 'Remove from Team',
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _confirmExcludePro(member);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
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

  Future<void> _resumeWedding() async {
    final result = await _repository.updateWeddingStatus(
      weddingId: _wedding!.id,
      status: 'planning',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      _loadWedding();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wedding resumed',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to resume wedding',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
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
                  // Wedding groups - opens MessagesPage on Wedding tab
                  GestureDetector(
                    onTap: _openWeddingMessages,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      Icons.groups_outlined,
                      color: LynewedColors.textPrimary,
                      size: 26.0,
                    ),
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
