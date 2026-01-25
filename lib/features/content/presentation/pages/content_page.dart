/// Content page.
///
/// Main landing page for content features including:
/// - Wedding of the Week
/// - Replays
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/replay.dart';
import 'wedding_of_the_week_page.dart';
import 'replay_player_page.dart';

/// The content page.
///
/// Displays a list of available content including:
/// - Featured Wedding of the Week
/// - List of replays
class ContentPage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'content';

  /// Route path for navigation.
  static const String routePath = '/content';

  /// Creates the content page.
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wedding of the Week section
                    _buildSectionTitle('Wedding of the Week'),
                    const SizedBox(height: 12.0),
                    _buildWeddingOfTheWeekCard(context),
                    const SizedBox(height: 32.0),

                    // Replays section
                    _buildSectionTitle('Replays'),
                    const SizedBox(height: 12.0),
                    _buildReplaysPlaceholder(context),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: LynewedColors.textPrimary,
          ),
          const SizedBox(width: 4.0),
          Text(
            'Content',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: LynewedTextStyles.sectionTitle,
      ),
    );
  }

  Widget _buildWeddingOfTheWeekCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToWeddingOfTheWeek(context),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: LynewedColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.favorite,
                color: LynewedColors.primary,
                size: 28.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wedding of the Week',
                    style: LynewedTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Discover this week\'s featured wedding',
                    style: LynewedTextStyles.labelMedium.copyWith(
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
    );
  }

  Widget _buildReplaysPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: LynewedColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.video_library_outlined,
            size: 48.0,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 12.0),
          Text(
            'No replays available',
            style: LynewedTextStyles.titleSmall,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Check back later for wedding ceremony replays',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToWeddingOfTheWeek(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WeddingOfTheWeekPage(),
      ),
    );
  }

  /// Navigate to a replay player.
  ///
  /// This is a utility method that can be called from elsewhere
  /// to navigate to a specific replay.
  static void navigateToReplay(BuildContext context, Replay replay) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReplayPlayerPage(replay: replay),
      ),
    );
  }
}
