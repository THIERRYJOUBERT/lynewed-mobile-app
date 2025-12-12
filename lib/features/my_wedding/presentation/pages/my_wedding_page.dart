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
import '/core/utils/budget_formatter.dart';
import '/core/services/currency_service.dart';
import '/core/constants/currencies.dart';
import '../widgets/wedding_onboarding_widget.dart';
import '../sheets/wedding_edit_sheet.dart';
import '../sheets/invite_pro_sheet.dart';
import '../sheets/note_for_pros_sheet.dart';
import 'agenda_page.dart';
import 'budget_page.dart';

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

  // Agenda & Budget preview data
  List<WeddingEvent> _upcomingEvents = [];
  List<WeddingExpense> _expenses = [];
  double _totalExpenses = 0;
  double _totalPaid = 0;

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

    // Load team chat info, active team members, events and expenses in parallel
    final results = await Future.wait([
      _repository.getWeddingTeamChat(weddingId: _wedding!.id),
      _repository.getActiveWeddingTeam(weddingId: _wedding!.id),
      _repository.getWeddingEvents(weddingId: _wedding!.id),
      _repository.getWeddingExpenses(weddingId: _wedding!.id),
    ]);

    final chatResult = results[0] as RepositoryResult<WeddingTeamChatInfo?>;
    final teamResult = results[1] as RepositoryResult<List<WeddingTeamMember>>;
    final eventsResult = results[2] as RepositoryResult<List<WeddingEvent>>;
    final expensesResult = results[3] as RepositoryResult<List<WeddingExpense>>;

    if (chatResult.isSuccess) {
      _teamChatInfo = chatResult.data;
    }
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
          // Wedding Overview Card - full width, no margins, touches divider
          _buildOverviewCard(),
          const SizedBox(height: 30.0),
          // Sections with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
    final hasEvents = _upcomingEvents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('AGENDA', style: LynewedTextStyles.sectionTitle),
            GestureDetector(
              onTap: _openAgendaPage,
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
          hasEvents ? '${_upcomingEvents.length} upcoming event${_upcomingEvents.length > 1 ? 's' : ''}' : 'Your upcoming events and tasks',
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        if (hasEvents)
          // Show upcoming events list
          Column(
            children: [
              ..._upcomingEvents.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildEventPreviewTile(event),
              )),
              const SizedBox(height: 4.0),
              GestureDetector(
                onTap: _openAgendaPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: LynewedColors.gray200),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      'View all events',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // Empty state
          GestureDetector(
            onTap: _openAgendaPage,
            child: Container(
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
                    'No upcoming events',
                    style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
                  ),
                  const SizedBox(height: 12.0),
                  LynewedButton(
                    text: 'Add Event',
                    onPressed: _openAgendaPage,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Event preview tile for agenda section
  Widget _buildEventPreviewTile(WeddingEvent event) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: _openAgendaPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: LynewedColors.primary,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateFormat.format(event.eventDate).split(' ')[0].toUpperCase(),
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    dateFormat.format(event.eventDate).split(' ')[1],
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    timeFormat.format(event.eventDate),
                    style: LynewedTextStyles.labelMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Public indicator
            if (event.isPublic)
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: LynewedColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  /// Budget Section
  Widget _buildBudgetSection() {
    final hasBudget = _wedding!.budgetMax != null && _wedding!.budgetMax! > 0;
    final hasExpenses = _expenses.isNotEmpty;
    final weddingCurrency = _wedding!.currency;
    final userCurrency = BudgetFormatter.userCurrency;
    final currencySymbol = CurrencyData.getSymbol(userCurrency);

    final service = CurrencyService.instance;
    final totalExpensesDisplay = service.convert(_totalExpenses, from: weddingCurrency, to: userCurrency) ?? _totalExpenses;
    final totalPaidDisplay = service.convert(_totalPaid, from: weddingCurrency, to: userCurrency) ?? _totalPaid;
    final budgetMaxDisplay = _wedding!.budgetMax != null
        ? (service.convert(_wedding!.budgetMax!.toDouble(), from: weddingCurrency, to: userCurrency) ?? _wedding!.budgetMax!.toDouble())
        : 0.0;

    final progress = hasBudget && budgetMaxDisplay > 0
        ? (totalExpensesDisplay / budgetMaxDisplay).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = hasBudget && totalExpensesDisplay > budgetMaxDisplay;

    String subtitle;
    if (hasExpenses) {
      subtitle = '${_expenses.length} expense${_expenses.length > 1 ? 's' : ''} tracked';
    } else {
      subtitle = 'Track your wedding expenses';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('BUDGET', style: LynewedTextStyles.sectionTitle),
            GestureDetector(
              onTap: _openBudgetPage,
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
          subtitle,
          style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
        ),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: _openBudgetPage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: hasExpenses || hasBudget
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total spent row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Spent',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatAmount(totalExpensesDisplay, currencySymbol),
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isOverBudget ? LynewedColors.error : LynewedColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (hasBudget) ...[
                        const SizedBox(height: 12.0),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: LynewedColors.gray200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget ? LynewedColors.error : LynewedColors.textPrimary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Budget info row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOverBudget
                                  ? 'Over by ${_formatAmount(totalExpensesDisplay - budgetMaxDisplay, currencySymbol)}'
                                  : 'Remaining: ${_formatAmount(budgetMaxDisplay - totalExpensesDisplay, currencySymbol)}',
                              style: LynewedTextStyles.labelMedium.copyWith(
                                color: isOverBudget ? LynewedColors.error : LynewedColors.textSecondary,
                              ),
                            ),
                            Text(
                              'of ${_formatAmount(budgetMaxDisplay, currencySymbol)}',
                              style: LynewedTextStyles.labelMedium.copyWith(
                                color: LynewedColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12.0),
                      // Paid vs Pending mini stats
                      Row(
                        children: [
                          _buildBudgetMiniStat('Paid', _formatAmount(totalPaidDisplay, currencySymbol), LynewedColors.success),
                          const SizedBox(width: 12.0),
                          _buildBudgetMiniStat('Pending', _formatAmount(totalExpensesDisplay - totalPaidDisplay, currencySymbol), LynewedColors.warning),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 32.0, color: LynewedColors.gray300),
                      const SizedBox(height: 8.0),
                      Text(
                        'No expenses yet',
                        style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
                      ),
                      const SizedBox(height: 12.0),
                      LynewedButton(
                        text: 'Add Expense',
                        onPressed: _openBudgetPage,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text(
                '$label: $value',
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
                        maxLines: 20,
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
            Text(
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
          isWeddingTeamChat: true,
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

  void _openAgendaPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AgendaPage(weddingId: _wedding!.id),
      ),
    ).then((_) => _loadWedding());
  }

  void _openBudgetPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetPage(
          weddingId: _wedding!.id,
          budgetMin: _wedding!.budgetMin,
          budgetMax: _wedding!.budgetMax,
          currency: _wedding!.currency,
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
      status: 'active',
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
                  // Team Chat - group icon with unread badge
                  if (_teamChatInfo != null)
                    GestureDetector(
                      onTap: _openTeamChat,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.groups_outlined,
                            color: LynewedColors.textPrimary,
                            size: 26.0,
                          ),
                          if (_teamChatInfo!.unreadCount > 0)
                            Positioned(
                              top: -6,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: LynewedColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(minWidth: 18),
                                child: Text(
                                  _teamChatInfo!.unreadCount > 99 ? '99+' : '${_teamChatInfo!.unreadCount}',
                                  style: LynewedTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
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
