/// Tests for SupabaseMarketplaceChatRepository - Name Fallback.
///
/// Verifies the extractDisplayName static method handles all fallback cases.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/repositories/supabase_marketplace_chat_repository.dart';

void main() {
  group('SupabaseMarketplaceChatRepository - extractDisplayName', () {
    test('should return full_name when available', () {
      final profile = {
        'id': 'user-1',
        'full_name': 'Sarah Johnson',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role': 'bride',
      };

      final result =
          SupabaseMarketplaceChatRepository.extractDisplayName(profile);
      expect(result, 'Sarah Johnson');
    });

    test('should return "User" when full_name is null', () {
      final profile = {
        'id': 'user-1',
        'full_name': null,
        'avatar_url': null,
        'role': 'bride',
      };

      final result =
          SupabaseMarketplaceChatRepository.extractDisplayName(profile);
      expect(result, 'User');
    });

    test('should return "User" when full_name is empty string', () {
      final profile = {
        'id': 'user-1',
        'full_name': '',
        'avatar_url': null,
        'role': 'professional',
      };

      final result =
          SupabaseMarketplaceChatRepository.extractDisplayName(profile);
      expect(result, 'User');
    });

    test('should return "User" when profile is null', () {
      final result =
          SupabaseMarketplaceChatRepository.extractDisplayName(null);
      expect(result, 'User');
    });

    test('should return "User" when full_name key is missing', () {
      final profile = <String, dynamic>{
        'id': 'user-1',
        'avatar_url': null,
      };

      final result =
          SupabaseMarketplaceChatRepository.extractDisplayName(profile);
      expect(result, 'User');
    });
  });
}
