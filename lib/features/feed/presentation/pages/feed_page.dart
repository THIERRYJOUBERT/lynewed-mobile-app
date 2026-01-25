/// Feed Page - Main feed listing professionals' portfolios
///
/// Displays a grid of portfolio images with profession filters.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '../../domain/entities/feed_professional.dart';
import '../../domain/entities/portfolio_item.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/profession_filter_chips.dart';
import 'feed_detail_page.dart';

/// Feed Page
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  static const String routeName = 'feed';
  static const String routePath = '/feed';

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    // Load feed when page mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedCubit>().loadFeed();
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
            _buildFilters(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            'Discover',
            style: LynewedTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: LynewedColors.textPrimary),
            onPressed: () {
              // Search not implemented in this story
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<FeedCubit, FeedState>(
      buildWhen: (prev, curr) =>
          prev.availableProfessions != curr.availableProfessions ||
          prev.filter != curr.filter,
      builder: (context, state) {
        if (state.availableProfessions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ProfessionFilterChips(
            professions: state.availableProfessions,
            selectedProfessions: state.filter.professions,
            onProfessionToggled: (profession) {
              context.read<FeedCubit>().toggleProfessionFilter(profession);
            },
            showAllChip: true,
            onAllSelected: () {
              context.read<FeedCubit>().applyFilter(state.filter.reset());
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
            ),
          );
        }

        if (state.hasError) {
          return _buildErrorState(state.error!);
        }

        if (state.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => context.read<FeedCubit>().refresh(),
          color: LynewedColors.primary,
          child: _buildPortfolioGrid(state),
        );
      },
    );
  }

  Widget _buildPortfolioGrid(FeedState state) {
    // Flatten all portfolio items from all professionals
    final allItems = <_PortfolioItemWithProfessional>[];
    for (final pro in state.professionals) {
      for (final item in pro.portfolioItems) {
        allItems.add(_PortfolioItemWithProfessional(
          item: item,
          professional: pro,
        ));
      }
    }

    if (allItems.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final itemWithPro = allItems[index];
        return PortfolioCard(
          item: itemWithPro.item,
          onTap: () => _openProfessionalDetail(itemWithPro.professional),
          showSaveButton: true,
          onSave: () {
            context.read<FeedCubit>().toggleFavorite(
                  itemWithPro.professional.profileId,
                );
          },
          isSaved: itemWithPro.professional.isFavorited,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No portfolios yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back later to discover amazing wedding professionals.',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to load',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: () => context.read<FeedCubit>().loadFeed(),
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _openProfessionalDetail(FeedProfessional professional) {
    final cubit = context.read<FeedCubit>();
    cubit.selectProfessional(professional);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeedDetailPage(
          professional: professional,
          onFavoriteToggle: () {
            cubit.toggleFavorite(professional.profileId);
          },
        ),
      ),
    );
  }
}

/// Helper class to link portfolio items with their professional
class _PortfolioItemWithProfessional {
  const _PortfolioItemWithProfessional({
    required this.item,
    required this.professional,
  });

  final PortfolioItem item;
  final FeedProfessional professional;
}
