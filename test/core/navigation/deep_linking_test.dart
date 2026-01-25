import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/navigation.dart';

/// Comprehensive deep linking tests for the Lynewed application.
///
/// Verifies that all deep link patterns work correctly for:
/// - lynewed://chat/{roomId}
/// - lynewed://profile/{profileId}
/// - lynewed://wedding/{weddingId}
void main() {
  group('Deep Linking', () {
    group('lynewed://chat/{roomId}', () {
      test('parses valid chat deep link', () {
        const link = 'lynewed://chat/room123';
        final result = DeepLinkSchemes.parseDeepLink(link);

        expect(result, isNotNull);
        expect(result!.path, equals('chat'));
        expect(result.params['id'], equals('room123'));
      });

      test('converts chat deep link to app route', () {
        const link = 'lynewed://chat/room123';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, isNotNull);
        expect(route, equals('/chatDetailsPage?roomId=room123'));
      });

      test('handles complex room IDs with UUIDs', () {
        const link = 'lynewed://chat/550e8400-e29b-41d4-a716-446655440000';
        final result = DeepLinkSchemes.parseDeepLink(link);

        expect(result, isNotNull);
        expect(result!.params['id'],
            equals('550e8400-e29b-41d4-a716-446655440000'));
      });

      test('route includes correct query parameter', () {
        const link = 'lynewed://chat/abc123';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, contains('roomId=abc123'));
        expect(route, startsWith(AppRoutes.chatDetails));
      });
    });

    group('lynewed://profile/{profileId}', () {
      test('parses valid profile deep link', () {
        const link = 'lynewed://profile/user456';
        final result = DeepLinkSchemes.parseDeepLink(link);

        expect(result, isNotNull);
        expect(result!.path, equals('profile'));
        expect(result.params['id'], equals('user456'));
      });

      test('converts profile deep link to app route', () {
        const link = 'lynewed://profile/user456';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, isNotNull);
        expect(route, equals('/proDetails?profileId=user456'));
      });

      test('handles complex profile IDs', () {
        const link = 'lynewed://profile/pro_abc123_def';
        final result = DeepLinkSchemes.parseDeepLink(link);

        expect(result, isNotNull);
        expect(result!.params['id'], equals('pro_abc123_def'));
      });

      test('route points to proDetails page', () {
        const link = 'lynewed://profile/xyz';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, startsWith(AppRoutes.proDetails));
        expect(route, contains('profileId=xyz'));
      });
    });

    group('lynewed://wedding/{weddingId}', () {
      test('parses valid wedding deep link', () {
        const link = 'lynewed://wedding/wed789';
        final result = DeepLinkSchemes.parseDeepLink(link);

        expect(result, isNotNull);
        expect(result!.path, equals('wedding'));
        expect(result.params['id'], equals('wed789'));
      });

      test('converts wedding deep link to app route', () {
        const link = 'lynewed://wedding/wed789';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, isNotNull);
        expect(route, equals('/myWedding?weddingId=wed789'));
      });

      test('route points to myWedding page', () {
        const link = 'lynewed://wedding/wedding_2024_01';
        final route = DeepLinkSchemes.toAppRoute(link);

        expect(route, startsWith(AppRoutes.myWedding));
        expect(route, contains('weddingId=wedding_2024_01'));
      });
    });

    group('Deep link building', () {
      test('builds chat deep link correctly', () {
        final link = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.chatPath,
          pathParams: {'roomId': 'room123'},
        );

        expect(link, equals('lynewed://chat/room123'));
      });

      test('builds profile deep link correctly', () {
        final link = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.profilePath,
          pathParams: {'profileId': 'user456'},
        );

        expect(link, equals('lynewed://profile/user456'));
      });

      test('builds wedding deep link correctly', () {
        final link = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.weddingPath,
          pathParams: {'weddingId': 'wed789'},
        );

        expect(link, equals('lynewed://wedding/wed789'));
      });
    });

    group('Edge cases and error handling', () {
      test('rejects non-lynewed scheme', () {
        const links = [
          'https://example.com/chat/room123',
          'http://chat/room123',
          'custom://chat/room123',
        ];

        for (final link in links) {
          final result = DeepLinkSchemes.parseDeepLink(link);
          expect(result, isNull, reason: 'Should reject: $link');
        }
      });

      test('rejects malformed URIs', () {
        const malformed = [
          '',
          'not-a-uri',
          'lynewed://', // Missing path
        ];

        for (final link in malformed) {
          final result = DeepLinkSchemes.parseDeepLink(link);
          // Either null or empty params for missing ID
          if (result != null) {
            expect(result.params['id'], isNull);
          }
        }
      });

      test('returns null route for unknown paths', () {
        const unknownLinks = [
          'lynewed://unknown/123',
          'lynewed://settings/privacy',
          'lynewed://search/query',
        ];

        for (final link in unknownLinks) {
          final route = DeepLinkSchemes.toAppRoute(link);
          expect(route, isNull, reason: 'Should not route: $link');
        }
      });

      test('handles deep link without ID', () {
        const link = 'lynewed://chat';
        final route = DeepLinkSchemes.toAppRoute(link);

        // Should return null since no roomId
        expect(route, isNull);
      });
    });

    group('AppRoutes deep link helpers', () {
      test('chatDeepLink generates correct route', () {
        final route = AppRoutes.chatDeepLink('room123');
        expect(route, equals('/chatDetailsPage?roomId=room123'));
      });

      test('profileDeepLink generates correct route', () {
        final route = AppRoutes.profileDeepLink('user456');
        expect(route, equals('/proDetails?profileId=user456'));
      });

      test('weddingDeepLink generates correct route', () {
        final route = AppRoutes.weddingDeepLink('wed789');
        expect(route, equals('/myWedding?weddingId=wed789'));
      });
    });

    group('Round-trip verification', () {
      test('chat: build -> parse -> toAppRoute maintains data', () {
        const roomId = 'room_abc_123';

        // Build the deep link
        final deepLink = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.chatPath,
          pathParams: {'roomId': roomId},
        );

        // Parse it back
        final parsed = DeepLinkSchemes.parseDeepLink(deepLink);
        expect(parsed, isNotNull);
        expect(parsed!.params['id'], equals(roomId));

        // Convert to app route
        final route = DeepLinkSchemes.toAppRoute(deepLink);
        expect(route, contains('roomId=$roomId'));
      });

      test('profile: build -> parse -> toAppRoute maintains data', () {
        const profileId = 'profile_xyz_789';

        final deepLink = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.profilePath,
          pathParams: {'profileId': profileId},
        );

        final parsed = DeepLinkSchemes.parseDeepLink(deepLink);
        expect(parsed, isNotNull);
        expect(parsed!.params['id'], equals(profileId));

        final route = DeepLinkSchemes.toAppRoute(deepLink);
        expect(route, contains('profileId=$profileId'));
      });

      test('wedding: build -> parse -> toAppRoute maintains data', () {
        const weddingId = 'wedding_2024_spring';

        final deepLink = DeepLinkSchemes.buildDeepLink(
          DeepLinkSchemes.weddingPath,
          pathParams: {'weddingId': weddingId},
        );

        final parsed = DeepLinkSchemes.parseDeepLink(deepLink);
        expect(parsed, isNotNull);
        expect(parsed!.params['id'], equals(weddingId));

        final route = DeepLinkSchemes.toAppRoute(deepLink);
        expect(route, contains('weddingId=$weddingId'));
      });
    });
  });
}
