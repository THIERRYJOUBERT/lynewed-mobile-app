/// Home page for brides.
///
/// The main landing page for bride users, displaying:
/// - Header with LYNEWED logo and notification badge
/// - Wedding summary card with countdown
/// - Quick action buttons for navigation
/// - Feed preview section
/// - Map preview section
/// - Pull-to-refresh functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '/features/auth/presentation/bloc/auth_state.dart';
import '/features/notifications/presentation/bloc/notifications_cubit.dart';
import '/features/notifications/presentation/widgets/notification_badge.dart';
import '/features/my_wedding/domain/entities/wedding_overview.dart';
import '/features/my_wedding/data/repositories/my_wedding_repository_impl.dart';
import '/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import '../widgets/wedding_summary_card.dart';
import '../widgets/quick_actions_row.dart';
import '/features/chat/presentation/pages/messages_page.dart';

/// The main home page for bride users.
///
/// Displays personalized content including wedding countdown,
/// quick navigation actions, and content previews.
class HomeBridesPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'homeBrides';

  /// Route path for navigation.
  static const String routePath = '/home-brides';

  /// Optional wedding repository for testing.
  final MyWeddingRepository? weddingRepository;

  /// Creates a home brides page.
  const HomeBridesPage({
    super.key,
    this.weddingRepository,
  });

  @override
  State<HomeBridesPage> createState() => _HomeBridesPageState();
}

class _HomeBridesPageState extends State<HomeBridesPage> {
  late MyWeddingRepository _weddingRepository;

  bool _isLoadingWedding = true;
  WeddingOverview? _wedding;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weddingRepository = widget.weddingRepository ?? MyWeddingRepositoryImpl();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadWedding();
    });
  }

  Future<void> _loadWedding() async {
    if (!mounted) return;

    setState(() {
      _isLoadingWedding = true;
      _error = null;
    });

    final result = await _weddingRepository.getMyWedding();

    if (!mounted) return;

    setState(() {
      _isLoadingWedding = false;
      if (result.isSuccess) {
        _wedding = result.data;
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _onRefresh() async {
    await _loadWedding();
    // Add any other refresh logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            Authenticated(:final profile) when profile != null =>
              _buildAuthenticatedContent(context, profile.displayName),
            Authenticated() => _buildLoadingContent(),
            AuthLoading() => _buildLoadingContent(),
            AuthInitial() => _buildLoadingContent(),
            Unauthenticated() => _buildUnauthenticatedContent(),
            AuthError(:final message) => _buildErrorContent(message),
          };
        },
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
      ),
    );
  }

  Widget _buildUnauthenticatedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            size: 64.0,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Please sign in to continue',
            style: LynewedTextStyles.headlineSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
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
            message,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent(BuildContext context, String? displayName) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(height: 1.0, color: LynewedColors.gray200),
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: LynewedColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    // Wedding Summary Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _error != null
                          ? _buildWeddingErrorCard()
                          : WeddingSummaryCard(
                              wedding: _wedding,
                              isLoading: _isLoadingWedding,
                              onTap: _navigateToMyWedding,
                              onCreateWeddingTap: _navigateToMyWedding,
                            ),
                    ),
                    const SizedBox(height: 24.0),
                    // Quick Actions
                    QuickActionsRow(
                      onFindProsTap: _navigateToFindPros,
                      onFavoritesTap: _navigateToFavorites,
                      onMessagesTap: _navigateToMessages,
                      onInspirationsTap: _navigateToInspirations,
                    ),
                    const SizedBox(height: 30.0),
                    // Feed Section
                    _buildSectionHeader('DISCOVER', onViewAll: _navigateToFeed),
                    const SizedBox(height: 12.0),
                    _buildFeedPreview(),
                    const SizedBox(height: 30.0),
                    // Map Section
                    _buildSectionHeader('NEARBY PROS', onViewAll: _navigateToMap),
                    const SizedBox(height: 12.0),
                    _buildMapPreview(),
                    const SizedBox(height: 100.0), // Bottom padding for nav bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Text(
            'LYNEWED',
            style: LynewedTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 10.0),
          // Notification icon with badge (centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _navigateToNotifications,
                behavior: HitTestBehavior.opaque,
                child: Consumer<NotificationsNotifier>(
                  builder: (context, notifier, _) {
                    return NotificationCountBadge(
                      count: notifier.unreadCount,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: LynewedColors.textPrimary,
                          size: 24.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: LynewedTextStyles.sectionTitle,
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedPreview() {
    return Container(
      height: 180.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 32.0,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Wedding inspiration coming soon',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return GestureDetector(
      onTap: _navigateToMap,
      child: Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: LynewedColors.gray200,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 32.0,
                color: LynewedColors.gray300,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Find professionals near you',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeddingErrorCard() {
    return GestureDetector(
      onTap: _loadWedding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: LynewedColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: LynewedColors.error,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to load wedding',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Tap to retry',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.refresh,
              color: LynewedColors.textSecondary,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToMyWedding() {
    // TODO: Navigate to My Wedding page
  }

  void _navigateToFindPros() {
    // TODO: Navigate to Find Pros / Map page
  }

  void _navigateToFavorites() {
    // TODO: Navigate to Favorites page
  }

  void _navigateToMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MessagesPage()),
    );
  }

  void _navigateToInspirations() {
    // TODO: Navigate to Inspirations page
  }

  void _navigateToNotifications() {
    // TODO: Navigate to Notifications page
  }

  void _navigateToFeed() {
    // TODO: Navigate to Feed page
  }

  void _navigateToMap() {
    // TODO: Navigate to Map page
  }
}
