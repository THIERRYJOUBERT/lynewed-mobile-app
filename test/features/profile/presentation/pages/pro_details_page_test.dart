/// Tests for ProDetailsPage.
///
/// Verifies the professional details page route configuration.
/// Note: Widget rendering tests require Supabase and DI mocking.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/profile/presentation/pages/pro_details_page.dart';

void main() {
  group('ProDetailsPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(ProDetailsPage.routeName, 'proDetails');
      });

      test('should have correct route path', () {
        expect(ProDetailsPage.routePath, '/pro/:profileId');
      });
    });

    group('Widget configuration', () {
      test('should accept profileId parameter', () {
        // Arrange
        const widget = ProDetailsPage(profileId: 'test-profile-id');

        // Assert
        expect(widget.profileId, 'test-profile-id');
      });
    });

    // Note: Widget rendering tests are in integration tests.
    // ProDetailsPage requires:
    // - Supabase.instance.client to be initialized
    // - sl<ReviewRepository>() to be registered
    // These dependencies need proper mocking for unit tests.
  });
}
