import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/wedding_overview.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../widgets/wedding_onboarding_widget.dart';

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
      setState(() {
        _wedding = result.data;
        _isLoading = false;
      });

      // State updated, UI will show onboarding or overview based on _shouldShowOnboarding
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
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

    // Wedding exists and onboarding complete → Show overview
    return _buildWeddingOverview();
  }

  Widget _buildWeddingOverview() {
    // Sprint 3: Full wedding overview implementation
    // For now, show a placeholder with wedding info
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wedding Overview Card - full width, no margins, touches divider
          Container(
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
          const SizedBox(height: 30.0),
          // Sections with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEDDING TEAM',
                  style: LynewedTextStyles.sectionTitle,
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
                        onPressed: () {
                          // TODO: Sprint 3 - Invite pros sheet
                        },
                        type: LynewedButtonType.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'AGENDA',
                  style: LynewedTextStyles.sectionTitle,
                ),
                const SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'Coming in Sprint 3',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Text(
                  'BUDGET',
                  style: LynewedTextStyles.sectionTitle,
                ),
                const SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'Coming in Sprint 3',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
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
