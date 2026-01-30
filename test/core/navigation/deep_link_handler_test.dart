/// Tests for DeepLinkHandler.
///
/// Verifies deep link URL parsing and code extraction for:
/// - HTTPS links: https://lynewed.app/join/{code}
/// - Custom scheme: lynewed://join/{code}
/// - Query parameter format: /join?code={code}
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/deep_link_handler.dart';

void main() {
  group('DeepLinkHandler.extractInviteCode', () {
    group('HTTPS deep links', () {
      test('should extract code from lynewed.app/join/{code}', () {
        final uri = Uri.parse('https://lynewed.app/join/ABCD1234');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });

      test('should extract code from www.lynewed.app/join/{code}', () {
        final uri = Uri.parse('https://www.lynewed.app/join/WXYZ5678');
        expect(DeepLinkHandler.extractInviteCode(uri), 'WXYZ5678');
      });

      test('should convert lowercase code to uppercase', () {
        final uri = Uri.parse('https://lynewed.app/join/abcd1234');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });

      test('should convert mixed case code to uppercase', () {
        final uri = Uri.parse('https://lynewed.app/join/AbCd1234');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });
    });

    group('Custom scheme deep links', () {
      test('should extract code from lynewed://join/{code}', () {
        final uri = Uri.parse('lynewed://join/ABCD1234');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });

      test('should extract code from query parameter', () {
        final uri = Uri.parse('lynewed://join?code=WXYZ5678');
        expect(DeepLinkHandler.extractInviteCode(uri), 'WXYZ5678');
      });
    });

    group('Invalid URLs', () {
      test('should return null for empty path', () {
        final uri = Uri.parse('https://lynewed.app');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for non-join path', () {
        final uri = Uri.parse('https://lynewed.app/profile/user123');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for join path without code', () {
        final uri = Uri.parse('https://lynewed.app/join');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for code shorter than 8 characters', () {
        final uri = Uri.parse('https://lynewed.app/join/ABC123');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for code longer than 8 characters', () {
        final uri = Uri.parse('https://lynewed.app/join/ABCD12345');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for code with special characters', () {
        final uri = Uri.parse('https://lynewed.app/join/ABC-1234');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });

      test('should return null for code with spaces', () {
        final uri = Uri.parse('https://lynewed.app/join/ABC%201234');
        expect(DeepLinkHandler.extractInviteCode(uri), isNull);
      });
    });

    group('Edge cases', () {
      test('should handle trailing slash', () {
        final uri = Uri.parse('https://lynewed.app/join/ABCD1234/');
        // Path segments: ['join', 'ABCD1234', '']
        // Should still extract code from index 1
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });

      test('should prefer path over query parameter', () {
        final uri = Uri.parse('https://lynewed.app/join/AAAA1111?code=BBBB2222');
        // Path should take precedence
        expect(DeepLinkHandler.extractInviteCode(uri), 'AAAA1111');
      });

      test('should handle query parameter when path code is empty', () {
        // This is an edge case where the URL might be malformed
        // /join/?code=ABCD1234 has pathSegments ['join', '']
        final uri = Uri.parse('https://lynewed.app/join/?code=ABCD1234');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCD1234');
      });

      test('should accept all alphanumeric characters', () {
        // Test all types of valid characters
        final uri = Uri.parse('https://lynewed.app/join/A1B2C3D4');
        expect(DeepLinkHandler.extractInviteCode(uri), 'A1B2C3D4');
      });

      test('should accept codes with all numbers', () {
        final uri = Uri.parse('https://lynewed.app/join/12345678');
        expect(DeepLinkHandler.extractInviteCode(uri), '12345678');
      });

      test('should accept codes with all letters', () {
        final uri = Uri.parse('https://lynewed.app/join/ABCDEFGH');
        expect(DeepLinkHandler.extractInviteCode(uri), 'ABCDEFGH');
      });
    });
  });
}
