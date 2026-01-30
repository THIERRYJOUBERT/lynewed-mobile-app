/// Tests for GuestProfilePage.
///
/// Verifies the guest profile page displays correctly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/pages/guest_profile_page.dart';

void main() {
  group('GuestProfilePage', () {
    Widget buildTestWidget({
      String? guestName,
      String? email,
      VoidCallback? onUpgradeToBride,
      VoidCallback? onLogout,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GuestProfilePage(
            guestName: guestName,
            email: email,
            onUpgradeToBride: onUpgradeToBride,
            onLogout: onLogout,
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display guest name', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(guestName: 'Pierre'));

        // Assert
        expect(find.text('Pierre'), findsOneWidget);
      });

      testWidgets('should display default name when not provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Invité'), findsWidgets); // Name and badge
      });

      testWidgets('should display email', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(email: 'pierre@example.com'));

        // Assert
        expect(find.text('pierre@example.com'), findsOneWidget);
      });

      testWidgets('should display role badge', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - should have "Invité" somewhere
        expect(find.text('Invité'), findsWidgets);
      });

      testWidgets('should display avatar placeholder', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.person), findsWidgets);
      });
    });

    group('Upgrade section', () {
      testWidgets('should display upgrade promotion', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Vous organisez un mariage ?'), findsOneWidget);
      });

      testWidgets('should display upgrade button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Passer en compte Mariée'), findsOneWidget);
      });

      testWidgets('should display celebration icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });

      testWidgets('upgrade button should call callback when provided', (tester) async {
        // Arrange
        var upgradeCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onUpgradeToBride: () => upgradeCalled = true,
        ));

        // Act
        await tester.tap(find.text('Passer en compte Mariée'));
        await tester.pump();

        // Assert
        expect(upgradeCalled, isTrue);
      });

      testWidgets('upgrade button is disabled when no callback', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Assert - button exists but is disabled (null onPressed)
        final button = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Passer en compte Mariée'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(button.onPressed, isNull);
      });
    });

    group('Logout', () {
      testWidgets('should display logout button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Se déconnecter'), findsOneWidget);
      });

      testWidgets('logout button should call callback', (tester) async {
        // Arrange
        var logoutCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onLogout: () => logoutCalled = true,
        ));

        // Act
        await tester.tap(find.text('Se déconnecter'));
        await tester.pump();

        // Assert
        expect(logoutCalled, isTrue);
      });
    });
  });
}
