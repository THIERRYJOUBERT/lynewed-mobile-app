import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_professional.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';

void main() {
  group('FeedProfessional', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create FeedProfessional with required fields', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        expect(professional.profileId, 'pro-123');
        expect(professional.displayName, 'Jane Photography');
        expect(professional.profession, 'photographer');
        expect(professional.avatarUrl, isNull);
        expect(professional.portfolioItems, isEmpty);
        expect(professional.isFavorited, false);
      });

      test('should create FeedProfessional with all optional fields', () {
        final items = [
          PortfolioItem(
            id: 'item-1',
            imageUrl: 'https://example.com/1.jpg',
            professionalId: 'pro-123',
            createdAt: DateTime(2025, 1, 24),
          ),
        ];

        final professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          avatarUrl: 'https://example.com/avatar.jpg',
          profession: 'photographer',
          portfolioItems: items,
          isFavorited: true,
        );

        expect(professional.avatarUrl, 'https://example.com/avatar.jpg');
        expect(professional.portfolioItems, hasLength(1));
        expect(professional.isFavorited, true);
      });

      test('should create FeedProfessional with empty portfolio', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          portfolioItems: [],
        );

        expect(professional.portfolioItems, isEmpty);
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES
    // ==============================================================

    group('computed properties', () {
      test('hasPortfolio should return true when items exist', () {
        final professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          portfolioItems: [
            PortfolioItem(
              id: 'item-1',
              imageUrl: 'https://example.com/1.jpg',
              professionalId: 'pro-123',
              createdAt: DateTime(2025, 1, 24),
            ),
          ],
        );

        expect(professional.hasPortfolio, true);
      });

      test('hasPortfolio should return false when items empty', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          portfolioItems: [],
        );

        expect(professional.hasPortfolio, false);
      });

      test('portfolioCount should return correct count', () {
        final professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          portfolioItems: [
            PortfolioItem(
              id: 'item-1',
              imageUrl: 'https://example.com/1.jpg',
              professionalId: 'pro-123',
              createdAt: DateTime(2025, 1, 24),
            ),
            PortfolioItem(
              id: 'item-2',
              imageUrl: 'https://example.com/2.jpg',
              professionalId: 'pro-123',
              createdAt: DateTime(2025, 1, 24),
            ),
          ],
        );

        expect(professional.portfolioCount, 2);
      });

      test('displayProfession should capitalize first letter', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        expect(professional.displayProfession, 'Photographer');
      });

      test('displayProfession should handle multi-word profession', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'John Events',
          profession: 'wedding_planner',
        );

        expect(professional.displayProfession, 'Wedding planner');
      });

      test('displayProfession should return empty string for empty profession', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: '',
        );

        expect(professional.displayProfession, '');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse FeedProfessional with all fields', () {
        final json = {
          'profile_id': 'pro-123',
          'display_name': 'Jane Photography',
          'avatar_url': 'https://example.com/avatar.jpg',
          'profession': 'photographer',
          'portfolio_items': [
            {
              'id': 'item-1',
              'image_url': 'https://example.com/1.jpg',
              'professional_id': 'pro-123',
              'caption': 'Wedding shot',
              'created_at': '2025-01-24T10:00:00Z',
            },
          ],
          'is_favorited': true,
        };

        final professional = FeedProfessional.fromJson(json);

        expect(professional.profileId, 'pro-123');
        expect(professional.displayName, 'Jane Photography');
        expect(professional.avatarUrl, 'https://example.com/avatar.jpg');
        expect(professional.profession, 'photographer');
        expect(professional.portfolioItems, hasLength(1));
        expect(professional.isFavorited, true);
      });

      test('should parse FeedProfessional with minimal fields', () {
        final json = {
          'profile_id': 'pro-123',
          'display_name': 'Jane Photography',
          'profession': 'photographer',
        };

        final professional = FeedProfessional.fromJson(json);

        expect(professional.profileId, 'pro-123');
        expect(professional.displayName, 'Jane Photography');
        expect(professional.avatarUrl, isNull);
        expect(professional.profession, 'photographer');
        expect(professional.portfolioItems, isEmpty);
        expect(professional.isFavorited, false);
      });

      test('should handle null avatar_url', () {
        final json = {
          'profile_id': 'pro-123',
          'display_name': 'Jane Photography',
          'avatar_url': null,
          'profession': 'photographer',
        };

        final professional = FeedProfessional.fromJson(json);

        expect(professional.avatarUrl, isNull);
      });

      test('should handle empty portfolio_items', () {
        final json = {
          'profile_id': 'pro-123',
          'display_name': 'Jane Photography',
          'profession': 'photographer',
          'portfolio_items': <Map<String, dynamic>>[],
        };

        final professional = FeedProfessional.fromJson(json);

        expect(professional.portfolioItems, isEmpty);
      });

      test('should default is_favorited to false when null', () {
        final json = {
          'profile_id': 'pro-123',
          'display_name': 'Jane Photography',
          'profession': 'photographer',
          'is_favorited': null,
        };

        final professional = FeedProfessional.fromJson(json);

        expect(professional.isFavorited, false);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          avatarUrl: 'https://example.com/avatar.jpg',
          profession: 'photographer',
          portfolioItems: [
            PortfolioItem(
              id: 'item-1',
              imageUrl: 'https://example.com/1.jpg',
              professionalId: 'pro-123',
              caption: 'Wedding shot',
              createdAt: DateTime.utc(2025, 1, 24, 10, 0, 0),
            ),
          ],
          isFavorited: true,
        );

        final json = professional.toJson();

        expect(json['profile_id'], 'pro-123');
        expect(json['display_name'], 'Jane Photography');
        expect(json['avatar_url'], 'https://example.com/avatar.jpg');
        expect(json['profession'], 'photographer');
        expect(json['portfolio_items'], isA<List>());
        expect((json['portfolio_items'] as List).length, 1);
        expect(json['is_favorited'], true);
      });

      test('should serialize null optional fields', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        final json = professional.toJson();

        expect(json['avatar_url'], isNull);
        expect(json['portfolio_items'], isEmpty);
        expect(json['is_favorited'], false);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final items = [
          PortfolioItem(
            id: 'item-1',
            imageUrl: 'https://example.com/1.jpg',
            professionalId: 'pro-123',
            createdAt: DateTime(2025, 1, 24),
          ),
        ];

        final original = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          avatarUrl: 'https://example.com/avatar.jpg',
          profession: 'photographer',
          portfolioItems: items,
          isFavorited: true,
        );

        final copied = original.copyWith(displayName: 'Jane Photo Studio');

        expect(copied.profileId, 'pro-123');
        expect(copied.displayName, 'Jane Photo Studio');
        expect(copied.avatarUrl, 'https://example.com/avatar.jpg');
        expect(copied.profession, 'photographer');
        expect(copied.portfolioItems, hasLength(1));
        expect(copied.isFavorited, true);
      });

      test('should update isFavorited', () {
        const original = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          isFavorited: false,
        );

        final copied = original.copyWith(isFavorited: true);

        expect(copied.isFavorited, true);
      });

      test('should not modify original', () {
        const original = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Original Name',
          profession: 'photographer',
        );

        original.copyWith(displayName: 'Modified');

        expect(original.displayName, 'Original Name');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const pro1 = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          isFavorited: true,
        );
        const pro2 = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          isFavorited: true,
        );

        expect(pro1, equals(pro2));
        expect(pro1.hashCode, equals(pro2.hashCode));
      });

      test('should not be equal when profileId differs', () {
        const pro1 = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );
        const pro2 = FeedProfessional(
          profileId: 'pro-456',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        expect(pro1, isNot(equals(pro2)));
      });

      test('should not be equal when isFavorited differs', () {
        const pro1 = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          isFavorited: false,
        );
        const pro2 = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
          isFavorited: true,
        );

        expect(pro1, isNot(equals(pro2)));
      });

      test('should return identical for same instance', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        expect(professional == professional, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const professional = FeedProfessional(
          profileId: 'pro-123',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );

        final result = professional.toString();

        expect(result, contains('pro-123'));
        expect(result, contains('Jane Photography'));
      });
    });
  });
}
