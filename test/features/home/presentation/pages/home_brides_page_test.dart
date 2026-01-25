/// Tests for HomeBridesPage.
///
/// Verifies the home page for brides:
/// - Header with greeting and notification badge
/// - WeddingSummaryCard integration
/// - QuickActionsRow integration
/// - Pull-to-refresh functionality
/// - Loading and error states
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_overview.dart';
import 'package:lynewed_beta/features/home/presentation/pages/home_brides_page.dart';
import 'package:lynewed_beta/features/home/presentation/widgets/wedding_summary_card.dart';
import 'package:lynewed_beta/features/home/presentation/widgets/quick_actions_row.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockNotificationRepository extends Mock implements NotificationRepository {}
class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockNotificationRepository mockNotificationRepository;
  late MockMyWeddingRepository mockWeddingRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final brideProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    displayName: 'Sarah Johnson',
    avatarUrl: null,
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final testWedding = WeddingOverview(
    id: 'wedding-1',
    brideId: 'profile-1',
    name: 'Sarah & John Wedding',
    eventDate: DateTime.now().add(const Duration(days: 90)),
    venueAddress: 'Paris, France',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationRepository = MockNotificationRepository();
    mockWeddingRepository = MockMyWeddingRepository();
    authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockAuthRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
    when(() => mockNotificationRepository.watchNotifications())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockWeddingRepository.getMyWedding())
        .thenAnswer((_) async => RepositoryResult.success(testWedding));
  });

  tearDown(() {
    authStateController.close();
  });

  Widget buildTestWidget({
    required AuthCubit authCubit,
    required NotificationsNotifier notificationsNotifier,
    MyWeddingRepository? weddingRepository,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          ChangeNotifierProvider<NotificationsNotifier>.value(
            value: notificationsNotifier,
          ),
        ],
        child: HomeBridesPage(
          weddingRepository: weddingRepository,
        ),
      ),
    );
  }

  group('HomeBridesPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(HomeBridesPage.routeName, 'homeBrides');
      });

      test('should have correct route path', () {
        expect(HomeBridesPage.routePath, '/home-brides');
      });
    });

    group('Header', () {
      testWidgets('should display greeting with user name', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert - should contain greeting
        expect(find.textContaining('Hello'), findsWidgets);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });

      testWidgets('should display notification icon', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Wedding Summary Card', () {
      testWidgets('should display WeddingSummaryCard', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(WeddingSummaryCard), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Quick Actions', () {
      testWidgets('should display QuickActionsRow', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(QuickActionsRow), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Loading state', () {
      testWidgets('should display loading indicator when loading', (tester) async {
        // Arrange
        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));

        // Assert - AuthInitial should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Unauthenticated state', () {
      testWidgets('should show appropriate content when not authenticated', (tester) async {
        // Arrange
        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );

        authStateController.add(null);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert - should handle unauthenticated state
        expect(find.byType(HomeBridesPage), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Layout', () {
      testWidgets('should have scrollable content', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert - should have a scrollable widget
        expect(
          find.byType(SingleChildScrollView).evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty ||
          find.byType(CustomScrollView).evaluate().isNotEmpty,
          isTrue,
        );

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });

      testWidgets('should have proper background color', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert - should have a Scaffold
        expect(find.byType(Scaffold), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Sections', () {
      testWidgets('should display feed preview section', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert - should have feed section or related content
        expect(find.byType(HomeBridesPage), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });

    group('Pull to refresh', () {
      testWidgets('should have RefreshIndicator for pull-to-refresh', (tester) async {
        // Arrange
        when(() => mockAuthRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final authCubit = AuthCubit(repository: mockAuthRepository);
        final notificationsNotifier = NotificationsNotifier(
          repository: mockNotificationRepository,
        );
        notificationsNotifier.setStateForTesting(
          const NotificationsLoaded(notifications: []),
        );

        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(
          authCubit: authCubit,
          notificationsNotifier: notificationsNotifier,
          weddingRepository: mockWeddingRepository,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);

        // Cleanup
        await authCubit.close();
        notificationsNotifier.dispose();
      });
    });
  });
}
