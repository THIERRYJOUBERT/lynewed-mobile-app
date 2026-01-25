/// Tests for NotificationSettingsPage
///
/// Verifies the settings page displays notification preferences
/// and allows users to toggle them.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_setting.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lynewed_beta/features/notifications/presentation/pages/notification_settings_page.dart';

// Mock repository
class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(NotificationSetting(
      id: '',
      profileId: '',
      notificationType: '',
      inAppEnabled: true,
      pushEnabled: true,
    ));
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  // Helper to create test settings
  List<NotificationSetting> createTestSettings() {
    return [
      NotificationSetting(
        id: '1',
        profileId: 'user-1',
        notificationType: 'chatMessage',
        inAppEnabled: true,
        pushEnabled: true,
      ),
      NotificationSetting(
        id: '2',
        profileId: 'user-1',
        notificationType: 'connectionRequest',
        inAppEnabled: false,
        pushEnabled: true,
      ),
    ];
  }

  // Build widget with repository
  Widget buildTestWidget({required NotificationRepository repository}) {
    return MaterialApp(
      home: NotificationSettingsPageRefactored(repository: repository),
    );
  }

  group('NotificationSettingsPage', () {
    testWidgets('should display loading indicator initially', (tester) async {
      // Arrange - use a completer to control when the future completes
      final completer = Completer<Result<List<NotificationSetting>>>();
      when(() => mockRepository.getSettings())
          .thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));

      // Assert - loading indicator should be visible immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete(Success(createTestSettings()));
      await tester.pumpAndSettle();
    });

    testWidgets('should display settings list when loaded', (tester) async {
      // Arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Success(createTestSettings()));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Assert - settings should be displayed
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('should display error state on failure', (tester) async {
      // Arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Failure(ServerFailure('Failed to load')));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load settings'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call updateSetting when switch is toggled', (tester) async {
      // Arrange
      final settings = createTestSettings();
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Success(settings));
      when(() => mockRepository.updateSetting(any()))
          .thenAnswer((_) async => const Success(null));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Toggle first switch
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRepository.updateSetting(any())).called(1);
    });

    testWidgets('should display NOTIFICATIONS header', (tester) async {
      // Arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Success(createTestSettings()));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    });

    testWidgets('should have back button in header', (tester) async {
      // Arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Success(createTestSettings()));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('should show retry button on error', (tester) async {
      // Arrange
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => Failure(ServerFailure('Failed')));

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should reload settings when retry is tapped', (tester) async {
      // Arrange
      var callCount = 0;
      when(() => mockRepository.getSettings()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return Failure(ServerFailure('Failed'));
        }
        return Success(createTestSettings());
      });

      // Act
      await tester.pumpWidget(buildTestWidget(repository: mockRepository));
      await tester.pumpAndSettle();

      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Assert - should have called getSettings twice
      verify(() => mockRepository.getSettings()).called(2);
    });
  });
}
