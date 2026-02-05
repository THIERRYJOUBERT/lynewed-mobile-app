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

  group('DeepLinkHandler.extractStripeConnectReturn', () {
    test('should detect success return', () {
      final uri =
          Uri.parse('lynewed://stripe-connect-return?success=true');
      final result = DeepLinkHandler.extractStripeConnectReturn(uri);

      expect(result, isNotNull);
      expect(result!['success'], true);
      expect(result['error'], isNull);
    });

    test('should detect error return with refresh required', () {
      final uri = Uri.parse(
        'lynewed://stripe-connect-return?error=refresh_required',
      );
      final result = DeepLinkHandler.extractStripeConnectReturn(uri);

      expect(result, isNotNull);
      expect(result!['success'], false);
      expect(result['error'], 'refresh_required');
    });

    test('should detect error return without specific reason', () {
      final uri = Uri.parse('lynewed://stripe-connect-return');
      final result = DeepLinkHandler.extractStripeConnectReturn(uri);

      expect(result, isNotNull);
      expect(result!['success'], false);
      expect(result['error'], isNull);
    });

    test('should return null for non-stripe-connect URI', () {
      final uri = Uri.parse('lynewed://join/ABCD1234');
      final result = DeepLinkHandler.extractStripeConnectReturn(uri);

      expect(result, isNull);
    });

    test('should return null for HTTPS URI', () {
      final uri = Uri.parse(
        'https://lynewed.app/stripe-connect-return?success=true',
      );
      final result = DeepLinkHandler.extractStripeConnectReturn(uri);

      expect(result, isNull);
    });
  });

  group('DeepLinkHandler.extractMagazineOrderSuccess', () {
    test('should extract session_id from valid URI', () {
      final uri = Uri.parse(
        'lynewed://magazine-order-success?session_id=cs_test_abc123',
      );
      final result = DeepLinkHandler.extractMagazineOrderSuccess(uri);

      expect(result, isNotNull);
      expect(result!['session_id'], 'cs_test_abc123');
    });

    test('should return map with null session_id when missing', () {
      final uri = Uri.parse('lynewed://magazine-order-success');
      final result = DeepLinkHandler.extractMagazineOrderSuccess(uri);

      expect(result, isNotNull);
      expect(result!['session_id'], isNull);
    });

    test('should return null for non-magazine-order-success URI', () {
      final uri = Uri.parse('lynewed://join/ABCD1234');
      final result = DeepLinkHandler.extractMagazineOrderSuccess(uri);

      expect(result, isNull);
    });

    test('should return null for HTTPS URI', () {
      final uri = Uri.parse(
        'https://lynewed.app/magazine-order-success?session_id=cs_test',
      );
      final result = DeepLinkHandler.extractMagazineOrderSuccess(uri);

      expect(result, isNull);
    });

    test('should return null for wrong custom scheme host', () {
      final uri = Uri.parse('lynewed://stripe-connect-return?session_id=cs_test');
      final result = DeepLinkHandler.extractMagazineOrderSuccess(uri);

      expect(result, isNull);
    });
  });

  group('DeepLinkHandler.extractMarketplacePaymentSuccess', () {
    test('should extract session_id from valid URI', () {
      final uri = Uri.parse(
        'lynewed://marketplace/payment-success?session_id=cs_test_abc123',
      );
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNotNull);
      expect(result!['session_id'], 'cs_test_abc123');
    });

    test('should return map with null session_id when missing', () {
      final uri = Uri.parse('lynewed://marketplace/payment-success');
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNotNull);
      expect(result!['session_id'], isNull);
    });

    test('should return null for non-marketplace URI', () {
      final uri = Uri.parse('lynewed://join/ABCD1234');
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNull);
    });

    test('should return null for HTTPS URI', () {
      final uri = Uri.parse(
        'https://lynewed.app/marketplace/payment-success?session_id=cs_test',
      );
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNull);
    });

    test('should return null for wrong path', () {
      final uri = Uri.parse('lynewed://marketplace/payment-cancel');
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNull);
    });

    test('should return null for wrong host', () {
      final uri = Uri.parse(
        'lynewed://magazine-order-success?session_id=cs_test',
      );
      final result = DeepLinkHandler.extractMarketplacePaymentSuccess(uri);

      expect(result, isNull);
    });
  });

  group('DeepLinkHandler.extractMarketplacePaymentCancel', () {
    test('should detect cancel URI', () {
      final uri = Uri.parse('lynewed://marketplace/payment-cancel');
      final result = DeepLinkHandler.extractMarketplacePaymentCancel(uri);

      expect(result, isNotNull);
    });

    test('should return null for non-cancel path', () {
      final uri = Uri.parse('lynewed://marketplace/payment-success');
      final result = DeepLinkHandler.extractMarketplacePaymentCancel(uri);

      expect(result, isNull);
    });

    test('should return null for non-marketplace URI', () {
      final uri = Uri.parse('lynewed://join/ABCD1234');
      final result = DeepLinkHandler.extractMarketplacePaymentCancel(uri);

      expect(result, isNull);
    });

    test('should return null for HTTPS URI', () {
      final uri = Uri.parse(
        'https://lynewed.app/marketplace/payment-cancel',
      );
      final result = DeepLinkHandler.extractMarketplacePaymentCancel(uri);

      expect(result, isNull);
    });
  });
}
