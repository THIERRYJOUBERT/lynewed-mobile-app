import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_filter.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_professional.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';
import 'package:lynewed_beta/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:lynewed_beta/features/feed/presentation/bloc/feed_state.dart';
import 'package:lynewed_beta/features/feed/presentation/pages/feed_page.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_card.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/profession_filter_chips.dart';

// Mock Cubit for testing
class MockFeedCubit extends Cubit<FeedState> implements FeedCubit {
  MockFeedCubit(super.initialState);

  bool loadFeedCalled = false;
  bool refreshCalled = false;
  String? toggledProfession;
  String? toggledFavorite;
  FeedProfessional? selectedProfessional;

  @override
  Future<void> loadFeed({int? limit}) async {
    loadFeedCalled = true;
  }

  @override
  Future<void> refresh() async {
    refreshCalled = true;
  }

  @override
  Future<void> toggleProfessionFilter(String profession) async {
    toggledProfession = profession;
  }

  @override
  Future<void> toggleFavorite(String profileId) async {
    toggledFavorite = profileId;
  }

  @override
  void selectProfessional(FeedProfessional professional) {
    selectedProfessional = professional;
  }

  @override
  void clearSelection() {
    selectedProfessional = null;
  }

  @override
  void clearError() {}

  @override
  Future<void> applyFilter(FeedFilter newFilter) async {}

  @override
  Future<void> loadMore() async {}
}

void main() {
  group('FeedPage', () {
    setUp(() {
      // Cubit instances created inline in each test
    });

    testWidgets('should render loading indicator when loading', (tester) async {
      final loadingCubit = MockFeedCubit(const FeedState(isLoading: true));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeedCubit>.value(
            value: loadingCubit,
            child: const FeedPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render filter chips', (tester) async {
      final cubitWithProfessions = MockFeedCubit(
        const FeedState(
          availableProfessions: ['photographer', 'florist'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeedCubit>.value(
            value: cubitWithProfessions,
            child: const FeedPage(),
          ),
        ),
      );

      expect(find.byType(ProfessionFilterChips), findsOneWidget);
    });

    testWidgets('should render portfolio cards when data loaded', (tester) async {
      final cubitWithData = MockFeedCubit(
        FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
              portfolioItems: [
                PortfolioItem(
                  id: 'item-1',
                  imageUrl: 'https://example.com/1.jpg',
                  professionalId: 'pro-1',
                  createdAt: DateTime(2025, 1, 24),
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeedCubit>.value(
            value: cubitWithData,
            child: const FeedPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PortfolioCard), findsWidgets);
    });

    testWidgets('should show empty state when no professionals', (tester) async {
      final emptyCubit = MockFeedCubit(const FeedState());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeedCubit>.value(
            value: emptyCubit,
            child: const FeedPage(),
          ),
        ),
      );

      expect(find.textContaining('No'), findsWidgets);
    });

    testWidgets('should show error message when error present', (tester) async {
      final errorCubit = MockFeedCubit(
        const FeedState(error: 'Failed to load feed'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeedCubit>.value(
            value: errorCubit,
            child: const FeedPage(),
          ),
        ),
      );

      expect(find.textContaining('Failed'), findsWidgets);
    });

    testWidgets('should have correct route name', (tester) async {
      expect(FeedPage.routeName, 'feed');
      expect(FeedPage.routePath, '/feed');
    });
  });
}
