/// Tests for SettingsTile widget.
///
/// Verifies the settings tile widget:
/// - Renders icon, title, subtitle correctly
/// - Handles tap callback
/// - Displays trailing widget
/// - Supports destructive style
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/settings/presentation/widgets/settings_tile.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('SettingsTile', () {
    group('Basic rendering', () {
      testWidgets('should display icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });

      testWidgets('should display title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Manage your preferences',
          ),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Manage your preferences'), findsOneWidget);
      });

      testWidgets('should not display subtitle when not provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert
        expect(find.text('Settings'), findsOneWidget);
        // No subtitle should exist
        expect(find.text('Manage your preferences'), findsNothing);
      });

      testWidgets('should display trailing widget when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            trailing: Icon(Icons.arrow_forward, key: Key('custom_trailing')),
          ),
        ));

        // Assert
        expect(find.byKey(const Key('custom_trailing')), findsOneWidget);
      });

      testWidgets('should display default chevron when no trailing provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => tapped = true,
          ),
        ));
        await tester.tap(find.byType(SettingsTile));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should not crash when onTap is null', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));
        await tester.tap(find.byType(SettingsTile));
        await tester.pump();

        // Assert - should not crash
        expect(find.byType(SettingsTile), findsOneWidget);
      });
    });

    group('Destructive style', () {
      testWidgets('should apply destructive style when isDestructive is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.delete,
            title: 'Delete Account',
            isDestructive: true,
          ),
        ));

        // Assert - find title and verify it exists
        final titleFinder = find.text('Delete Account');
        expect(titleFinder, findsOneWidget);

        // Find Text widget
        final textWidget = tester.widget<Text>(titleFinder);

        // Verify destructive color is applied (error color)
        expect(textWidget.style?.color, equals(const Color(0xFFFF5963)));
      });

      testWidgets('should apply normal style when isDestructive is false', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            isDestructive: false,
          ),
        ));

        // Assert - title should not have error color
        final titleFinder = find.text('Settings');
        expect(titleFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(titleFinder);

        // Should not be error color
        expect(textWidget.style?.color, isNot(equals(const Color(0xFFFF5963))));
      });

      testWidgets('should use red icon color when isDestructive is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.delete,
            title: 'Delete Account',
            isDestructive: true,
          ),
        ));

        // Assert - find the delete icon
        final iconFinder = find.byIcon(Icons.delete);
        expect(iconFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.color, equals(const Color(0xFFFF5963)));
      });
    });

    group('Layout', () {
      testWidgets('icon should be on the left', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert
        final iconPosition = tester.getTopLeft(find.byIcon(Icons.settings));
        final titlePosition = tester.getTopLeft(find.text('Settings'));
        expect(iconPosition.dx, lessThan(titlePosition.dx));
      });

      testWidgets('trailing should be on the right', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            trailing: Icon(Icons.arrow_forward, key: Key('trailing')),
          ),
        ));

        // Assert
        final titlePosition = tester.getTopRight(find.text('Settings'));
        final trailingPosition = tester.getTopLeft(find.byKey(const Key('trailing')));
        expect(titlePosition.dx, lessThanOrEqualTo(trailingPosition.dx));
      });

      testWidgets('title should be above subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Manage preferences',
          ),
        ));

        // Assert
        final titlePosition = tester.getTopLeft(find.text('Settings'));
        final subtitlePosition = tester.getTopLeft(find.text('Manage preferences'));
        expect(titlePosition.dy, lessThan(subtitlePosition.dy));
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept all required parameters', (tester) async {
        // Arrange & Act
        const widget = SettingsTile(
          icon: Icons.person,
          title: 'Profile',
        );

        // Assert
        expect(widget.icon, Icons.person);
        expect(widget.title, 'Profile');
      });

      testWidgets('should accept all optional parameters', (tester) async {
        // Arrange
        void tapCallback() {}
        const trailingWidget = Icon(Icons.check);

        // Act
        final widget = SettingsTile(
          icon: Icons.person,
          title: 'Profile',
          subtitle: 'Edit your profile',
          onTap: tapCallback,
          isDestructive: true,
          trailing: trailingWidget,
        );

        // Assert
        expect(widget.icon, Icons.person);
        expect(widget.title, 'Profile');
        expect(widget.subtitle, 'Edit your profile');
        expect(widget.onTap, tapCallback);
        expect(widget.isDestructive, true);
        expect(widget.trailing, trailingWidget);
      });

      testWidgets('isDestructive should default to false', (tester) async {
        // Arrange & Act
        const widget = SettingsTile(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Assert
        expect(widget.isDestructive, false);
      });
    });

    group('Accessibility', () {
      testWidgets('should be tappable with sufficient size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SettingsTile(
            icon: Icons.settings,
            title: 'Settings',
          ),
        ));

        // Assert - widget should have reasonable tap target
        final size = tester.getSize(find.byType(SettingsTile));
        expect(size.height, greaterThanOrEqualTo(48)); // Minimum touch target
      });
    });
  });
}
