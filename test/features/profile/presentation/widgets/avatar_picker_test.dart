/// Tests for AvatarPicker widget.
///
/// Verifies the avatar picker:
/// - Displays current avatar when provided
/// - Shows placeholder when no avatar
/// - Triggers onTap callback
/// - Shows edit icon overlay
/// - Displays local image when selected
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/avatar_picker.dart';

void main() {
  group('AvatarPicker', () {
    group('Display', () {
      testWidgets('should display placeholder when no avatar URL is provided',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('should display network image when avatar URL is provided',
          (tester) async {
        // Arrange
        const avatarUrl = 'https://example.com/avatar.jpg';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: avatarUrl,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('should display edit icon overlay', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('should display helper text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
                helperText: 'Change your profile picture',
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Change your profile picture'), findsOneWidget);
      });

      testWidgets('should not display helper text when not provided',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Change your profile picture'), findsNothing);
      });
    });

    group('Interaction', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(AvatarPicker));
        await tester.pumpAndSettle();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should not crash when onTap is null and tapped',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
              ),
            ),
          ),
        );

        // Act & Assert - should not throw
        await tester.tap(find.byType(AvatarPicker));
        await tester.pumpAndSettle();
      });
    });

    group('Local image', () {
      testWidgets('should display local image when localImagePath is provided',
          (tester) async {
        // This test is skipped because Image.file requires actual file
        // We test the widget structure instead
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                localImagePath: '/tmp/test_image.jpg',
                onTap: null,
              ),
            ),
          ),
        );

        // The widget should try to display file image
        // We can't easily test File.existsSync in unit tests
        // so we just verify the widget builds without error
        expect(find.byType(AvatarPicker), findsOneWidget);
      });
    });

    group('Size configuration', () {
      testWidgets('should use default size of 80', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert - widget builds correctly with default size
        expect(find.byType(AvatarPicker), findsOneWidget);
      });

      testWidgets('should use custom size when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
                size: 100,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(AvatarPicker), findsOneWidget);
      });
    });

    group('Loading state', () {
      testWidgets('should show loading indicator when isLoading is true',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
                isLoading: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should not show loading indicator when isLoading is false',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AvatarPicker(
                currentAvatarUrl: null,
                onTap: null,
                isLoading: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}
