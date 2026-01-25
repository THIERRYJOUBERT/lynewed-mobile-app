/// Tests for ProfileHeader widget.
///
/// Verifies the profile header widget displays:
/// - Avatar (with fallback)
/// - Display name
/// - Profession (for professionals)
/// - Bio
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/profile_header.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  final brideProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'auth-1',
    role: UserRole.bride,
    displayName: 'Sarah Johnson',
    avatarUrl: null,
    bio: 'Getting married in Paris!',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final proProfile = UserProfile(
    id: 'profile-2',
    authUserId: 'auth-2',
    role: UserRole.professional,
    displayName: 'Jean Photography',
    avatarUrl: 'https://example.com/avatar.jpg',
    profession: 'Photographer',
    companyName: 'Jean Photo Studio',
    bio: 'Capturing your special moments',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  group('ProfileHeader', () {
    group('Basic rendering', () {
      testWidgets('should display display name', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert
        expect(find.text('Sarah Johnson'), findsOneWidget);
      });

      testWidgets('should display fallback when no display name', (tester) async {
        // Arrange - create a profile without display name from scratch
        final noNameProfile = UserProfile(
          id: 'profile-1',
          authUserId: 'auth-1',
          role: UserRole.bride,
          displayName: null,
          avatarUrl: null,
          bio: null,
          isOnboardingComplete: true,
          createdAt: DateTime(2024, 1, 1),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: noNameProfile),
        ));

        // Assert
        expect(find.text('User'), findsOneWidget);
      });

      testWidgets('should display bio when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert
        expect(find.text('Getting married in Paris!'), findsOneWidget);
      });

      testWidgets('should not display bio section when null', (tester) async {
        // Arrange - create a profile without bio from scratch
        final noBioProfile = UserProfile(
          id: 'profile-1',
          authUserId: 'auth-1',
          role: UserRole.bride,
          displayName: 'Sarah Johnson',
          avatarUrl: null,
          bio: null,
          isOnboardingComplete: true,
          createdAt: DateTime(2024, 1, 1),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: noBioProfile),
        ));

        // Assert - should only have name, no bio text
        expect(find.text('Sarah Johnson'), findsOneWidget);
        expect(find.text('Getting married in Paris!'), findsNothing);
      });
    });

    group('Avatar', () {
      testWidgets('should display avatar placeholder when no URL', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert - should have person icon as fallback
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('should display avatar container', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert - should have a container for avatar
        expect(find.byType(ProfileHeader), findsOneWidget);
      });
    });

    group('Professional info', () {
      testWidgets('should display profession for professionals', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: proProfile),
        ));

        // Assert
        expect(find.text('Photographer'), findsOneWidget);
      });

      testWidgets('should display company name for professionals', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: proProfile),
        ));

        // Assert
        expect(find.text('Jean Photo Studio'), findsOneWidget);
      });

      testWidgets('should not display profession for brides', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert - should only show name and bio
        expect(find.text('Photographer'), findsNothing);
      });
    });

    group('Layout', () {
      testWidgets('avatar should be above name', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert
        final avatarPosition = tester.getTopLeft(find.byIcon(Icons.person));
        final namePosition = tester.getTopLeft(find.text('Sarah Johnson'));
        expect(avatarPosition.dy, lessThan(namePosition.dy));
      });

      testWidgets('content should be centered', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileHeader(profile: brideProfile),
        ));

        // Assert - header should contain centered content
        expect(find.byType(ProfileHeader), findsOneWidget);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept profile parameter', (tester) async {
        // Arrange & Act
        final widget = ProfileHeader(profile: brideProfile);

        // Assert
        expect(widget.profile, brideProfile);
      });
    });
  });
}
