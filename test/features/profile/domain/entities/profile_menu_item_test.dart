/// Tests for ProfileMenuItemData entity.
///
/// Verifies the profile menu item data entity:
/// - Constructor with required and optional parameters
/// - Equality and hashCode
/// - String representation
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/profile/domain/entities/profile_menu_item.dart';

void main() {
  group('ProfileMenuItemData', () {
    group('Constructor', () {
      test('should create with required parameters only', () {
        // Arrange & Act
        final item = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Assert
        expect(item.icon, Icons.settings);
        expect(item.title, 'Settings');
        expect(item.onTap, isNull);
        expect(item.subtitle, isNull);
        expect(item.trailing, isNull);
      });

      test('should create with all parameters', () {
        // Arrange
        void onTapCallback() {}
        const trailingWidget = Icon(Icons.chevron_right);

        // Act
        final item = ProfileMenuItemData(
          icon: Icons.person,
          title: 'Profile',
          onTap: onTapCallback,
          subtitle: 'View your profile',
          trailing: trailingWidget,
        );

        // Assert
        expect(item.icon, Icons.person);
        expect(item.title, 'Profile');
        expect(item.onTap, onTapCallback);
        expect(item.subtitle, 'View your profile');
        expect(item.trailing, trailingWidget);
      });

      test('should store onTap callback correctly', () {
        // Arrange
        var tapped = false;
        void onTapCallback() {
          tapped = true;
        }

        // Act
        final item = ProfileMenuItemData(
          icon: Icons.logout,
          title: 'Logout',
          onTap: onTapCallback,
        );

        // Assert
        expect(item.onTap, isNotNull);
        item.onTap!();
        expect(tapped, isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App settings',
        );

        // Assert
        expect(item1, equals(item2));
      });

      test('should not be equal when icon differs', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.person,
          title: 'Settings',
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('should not be equal when title differs', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Preferences',
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('should not be equal when subtitle differs', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'User settings',
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });
    });

    group('hashCode', () {
      test('should have same hashCode for equal objects', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App settings',
        );

        // Assert
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('should have different hashCode for different objects', () {
        // Arrange
        final item1 = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );
        final item2 = ProfileMenuItemData(
          icon: Icons.person,
          title: 'Profile',
        );

        // Assert
        expect(item1.hashCode, isNot(equals(item2.hashCode)));
      });
    });

    group('toString', () {
      test('should return descriptive string', () {
        // Arrange
        final item = ProfileMenuItemData(
          icon: Icons.settings,
          title: 'Settings',
        );

        // Act
        final result = item.toString();

        // Assert
        expect(result, contains('ProfileMenuItemData'));
        expect(result, contains('Settings'));
      });
    });
  });
}
