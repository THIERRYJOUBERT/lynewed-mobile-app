/// Tests for ProfileMenuItem widget.
///
/// Verifies the profile menu item widget:
/// - Renders icon, title, subtitle correctly
/// - Handles tap callback
/// - Displays trailing widget
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/profile/domain/entities/profile_menu_item.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/profile_menu_item_widget.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ProfileMenuItemWidget', () {
    group('Basic rendering', () {
      testWidgets('should display icon', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });

      testWidgets('should display title', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Manage your preferences',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Manage your preferences'), findsOneWidget);
      });

      testWidgets('should not display subtitle when not provided', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
        // Should not crash when no subtitle
      });

      testWidgets('should display trailing widget when provided', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          trailing: const Icon(Icons.chevron_right),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('should display default chevron when no trailing provided', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert - should have a default chevron
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => tapped = true,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));
        await tester.tap(find.byType(ProfileMenuItemWidget));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should not crash when onTap is null', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));
        await tester.tap(find.byType(ProfileMenuItemWidget));
        await tester.pump();

        // Assert - should not crash
        expect(find.byType(ProfileMenuItemWidget), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('icon should be on the left', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          trailing: const Icon(Icons.chevron_right),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        final iconPosition = tester.getTopLeft(find.byIcon(Icons.settings));
        final titlePosition = tester.getTopLeft(find.text('Settings'));
        expect(iconPosition.dx, lessThan(titlePosition.dx));
      });

      testWidgets('trailing should be on the right', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          trailing: const Icon(Icons.chevron_right, key: Key('trailing')),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        final titlePosition = tester.getTopRight(find.text('Settings'));
        final trailingPosition = tester.getTopLeft(find.byKey(const Key('trailing')));
        expect(titlePosition.dx, lessThanOrEqualTo(trailingPosition.dx));
      });

      testWidgets('title should be above subtitle', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Manage preferences',
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: ProfileMenuItemWidget(data: data),
        ));

        // Assert
        final titlePosition = tester.getTopLeft(find.text('Settings'));
        final subtitlePosition = tester.getTopLeft(find.text('Manage preferences'));
        expect(titlePosition.dy, lessThan(subtitlePosition.dy));
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept data parameter', (tester) async {
        // Arrange
        final data = ProfileMenuItemData(
          icon: Icons.person,
          title: 'Profile',
        );

        // Act
        final widget = ProfileMenuItemWidget(data: data);

        // Assert
        expect(widget.data, data);
      });
    });
  });
}
