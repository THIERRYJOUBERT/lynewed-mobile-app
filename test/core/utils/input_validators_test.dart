/// Input Validators Tests
///
/// Tests for the centralized input validation utility class.
/// Covers: email, password, name, bio/description, chat messages, and search queries.
/// Security tests: XSS, SQL-like injection, unicode malicious, long inputs.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/input_validators.dart';

void main() {
  group('InputValidators', () {
    group('validateEmail', () {
      test('returns error for null value', () {
        expect(InputValidators.validateEmail(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(InputValidators.validateEmail(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(InputValidators.validateEmail('   '), isNotNull);
      });

      test('returns null for valid email', () {
        expect(InputValidators.validateEmail('test@example.com'), isNull);
        expect(InputValidators.validateEmail('user.name@domain.co.uk'), isNull);
        expect(InputValidators.validateEmail('user+tag@example.org'), isNull);
      });

      test('returns error for invalid email format', () {
        expect(InputValidators.validateEmail('notanemail'), isNotNull);
        expect(InputValidators.validateEmail('missing@'), isNotNull);
        expect(InputValidators.validateEmail('@nodomain.com'), isNotNull);
        expect(InputValidators.validateEmail('spaces in@email.com'), isNotNull);
      });

      test('returns error for email exceeding max length (254 chars)', () {
        final longEmail = '${'a' * 246}@test.com'; // 256 chars (exceeds 254)
        expect(InputValidators.validateEmail(longEmail), isNotNull);
      });

      test('accepts email at max length (254 chars)', () {
        final maxEmail = '${'a' * 240}@test.com'; // 250 chars
        expect(InputValidators.validateEmail(maxEmail), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for null value', () {
        expect(InputValidators.validatePassword(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(InputValidators.validatePassword(''), isNotNull);
      });

      test('returns error for password too short (< 8 chars)', () {
        expect(InputValidators.validatePassword('Pass1!'), isNotNull);
      });

      test('returns error for password exceeding max length (128 chars)', () {
        final longPassword = 'A' * 129;
        expect(InputValidators.validatePassword(longPassword), isNotNull);
      });

      test('returns null for valid password', () {
        expect(InputValidators.validatePassword('SecureP@ss123'), isNull);
        expect(InputValidators.validatePassword('MyPassword1!'), isNull);
      });

      test('returns error for password without uppercase', () {
        expect(InputValidators.validatePassword('lowercase1!'), isNotNull);
      });

      test('returns error for password without lowercase', () {
        expect(InputValidators.validatePassword('UPPERCASE1!'), isNotNull);
      });

      test('returns error for password without digit', () {
        expect(InputValidators.validatePassword('NoDigits!!'), isNotNull);
      });
    });

    group('validateName', () {
      test('returns error for null value', () {
        expect(InputValidators.validateName(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(InputValidators.validateName(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(InputValidators.validateName('   '), isNotNull);
      });

      test('returns null for valid name', () {
        expect(InputValidators.validateName('John'), isNull);
        expect(InputValidators.validateName('Jean-Pierre'), isNull);
        expect(InputValidators.validateName("O'Brien"), isNull);
        expect(InputValidators.validateName('Marie Claire'), isNull);
      });

      test('returns null for name with accents', () {
        expect(InputValidators.validateName('Francois'), isNull);
        expect(InputValidators.validateName('Helene'), isNull);
        expect(InputValidators.validateName('Bjork'), isNull);
      });

      test('returns error for name exceeding max length (100 chars)', () {
        final longName = 'A' * 101;
        expect(InputValidators.validateName(longName), isNotNull);
      });

      test('returns error for name with invalid characters', () {
        expect(InputValidators.validateName('John123'), isNotNull);
        expect(InputValidators.validateName('John@Doe'), isNotNull);
        expect(InputValidators.validateName('John<script>'), isNotNull);
      });
    });

    group('validateBio', () {
      test('returns null for null value (optional field)', () {
        expect(InputValidators.validateBio(null), isNull);
      });

      test('returns null for empty string (optional field)', () {
        expect(InputValidators.validateBio(''), isNull);
      });

      test('returns null for valid bio', () {
        expect(InputValidators.validateBio('I love weddings!'), isNull);
        expect(InputValidators.validateBio('Professional photographer based in Paris.'), isNull);
      });

      test('returns error for bio exceeding max length (500 chars)', () {
        final longBio = 'A' * 501;
        expect(InputValidators.validateBio(longBio), isNotNull);
      });

      test('returns error for bio with HTML tags (XSS prevention)', () {
        expect(InputValidators.validateBio('<script>alert("xss")</script>'), isNotNull);
        expect(InputValidators.validateBio('<img src=x onerror=alert(1)>'), isNotNull);
        expect(InputValidators.validateBio('<a href="javascript:void(0)">click</a>'), isNotNull);
      });
    });

    group('validateMessage', () {
      test('returns error for null value', () {
        expect(InputValidators.validateMessage(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(InputValidators.validateMessage(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(InputValidators.validateMessage('   '), isNotNull);
      });

      test('returns null for valid message', () {
        expect(InputValidators.validateMessage('Hello!'), isNull);
        expect(InputValidators.validateMessage('Nice to meet you :)'), isNull);
      });

      test('returns error for message exceeding max length (2000 chars)', () {
        final longMessage = 'A' * 2001;
        expect(InputValidators.validateMessage(longMessage), isNotNull);
      });

      test('accepts message at custom max length', () {
        final message = 'A' * 500;
        expect(InputValidators.validateMessage(message, maxLength: 500), isNull);
        expect(InputValidators.validateMessage('${message}A', maxLength: 500), isNotNull);
      });
    });

    group('validatePhone', () {
      test('returns null for null value (optional)', () {
        expect(InputValidators.validatePhone(null), isNull);
      });

      test('returns null for empty string (optional)', () {
        expect(InputValidators.validatePhone(''), isNull);
      });

      test('returns null for whitespace only (optional)', () {
        expect(InputValidators.validatePhone('   '), isNull);
      });

      test('returns null for valid phone numbers', () {
        expect(InputValidators.validatePhone('+33 6 12 34 56 78'), isNull);
        expect(InputValidators.validatePhone('(555) 123-4567'), isNull);
        expect(InputValidators.validatePhone('0612345678'), isNull);
        expect(InputValidators.validatePhone('+1-800-555-1234'), isNull);
      });

      test('returns error for phone with invalid characters', () {
        expect(InputValidators.validatePhone('abc123'), isNotNull);
        expect(InputValidators.validatePhone('123@456'), isNotNull);
        expect(InputValidators.validatePhone('<script>'), isNotNull);
      });

      test('returns error for phone exceeding max length (20 chars)', () {
        final longPhone = '1' * 21;
        expect(InputValidators.validatePhone(longPhone), isNotNull);
      });
    });

    group('validateSearchQuery', () {
      test('returns null for null value (optional)', () {
        expect(InputValidators.validateSearchQuery(null), isNull);
      });

      test('returns null for empty string (optional)', () {
        expect(InputValidators.validateSearchQuery(''), isNull);
      });

      test('returns null for valid search query', () {
        expect(InputValidators.validateSearchQuery('Paris'), isNull);
        expect(InputValidators.validateSearchQuery('New York'), isNull);
        expect(InputValidators.validateSearchQuery('123 Main St'), isNull);
      });

      test('returns error for search query exceeding max length (200 chars)', () {
        final longQuery = 'A' * 201;
        expect(InputValidators.validateSearchQuery(longQuery), isNotNull);
      });
    });

    group('sanitizeForDisplay', () {
      test('escapes HTML special characters', () {
        expect(InputValidators.sanitizeForDisplay('<script>'), equals('&lt;script&gt;'));
        expect(InputValidators.sanitizeForDisplay('a & b'), equals('a &amp; b'));
        expect(InputValidators.sanitizeForDisplay('"quoted"'), equals('&quot;quoted&quot;'));
        expect(InputValidators.sanitizeForDisplay("it's"), equals('it&#x27;s'));
      });

      test('handles empty string', () {
        expect(InputValidators.sanitizeForDisplay(''), equals(''));
      });

      test('preserves safe characters', () {
        expect(InputValidators.sanitizeForDisplay('Hello World!'), equals('Hello World!'));
        expect(InputValidators.sanitizeForDisplay('123-456'), equals('123-456'));
      });

      test('handles complex XSS payloads', () {
        const xss = '<script>alert("XSS")</script>';
        final sanitized = InputValidators.sanitizeForDisplay(xss);
        expect(sanitized.contains('<'), isFalse);
        expect(sanitized.contains('>'), isFalse);
      });
    });

    group('containsHtmlTags', () {
      test('detects script tags', () {
        expect(InputValidators.containsHtmlTags('<script>alert(1)</script>'), isTrue);
      });

      test('detects img tags', () {
        expect(InputValidators.containsHtmlTags('<img src=x>'), isTrue);
      });

      test('detects various HTML tags', () {
        expect(InputValidators.containsHtmlTags('<div>test</div>'), isTrue);
        expect(InputValidators.containsHtmlTags('<a href="">link</a>'), isTrue);
        expect(InputValidators.containsHtmlTags('<iframe src="">'), isTrue);
      });

      test('returns false for safe text', () {
        expect(InputValidators.containsHtmlTags('Hello World'), isFalse);
        expect(InputValidators.containsHtmlTags('5 < 10'), isFalse); // Math comparison, not tag
        expect(InputValidators.containsHtmlTags('a > b'), isFalse);
      });

      test('returns false for empty string', () {
        expect(InputValidators.containsHtmlTags(''), isFalse);
      });
    });

    group('Security - XSS Prevention', () {
      test('rejects script tags in name', () {
        expect(InputValidators.validateName('<script>alert("xss")</script>'), isNotNull);
      });

      test('rejects event handlers in bio', () {
        expect(InputValidators.validateBio('<img onerror="alert(1)" src=x>'), isNotNull);
      });

      test('rejects javascript: URLs in bio', () {
        expect(InputValidators.validateBio('<a href="javascript:alert(1)">click</a>'), isNotNull);
      });

      test('sanitizeForDisplay neutralizes XSS payloads', () {
        final payloads = [
          '<script>alert(1)</script>',
          '<img src=x onerror=alert(1)>',
          '<svg onload=alert(1)>',
          '"><script>alert(1)</script>',
          "'-alert(1)-'",
        ];

        for (final payload in payloads) {
          final sanitized = InputValidators.sanitizeForDisplay(payload);
          // The sanitized version should not contain actual HTML-executable code
          // < and > are escaped to &lt; and &gt;
          expect(sanitized.contains('<'), isFalse, reason: 'Should not contain unescaped <');
          expect(sanitized.contains('>'), isFalse, reason: 'Should not contain unescaped >');
        }
      });
    });

    group('Security - SQL-like Injection Prevention', () {
      test('name validation rejects SQL-like patterns', () {
        expect(InputValidators.validateName("'; DROP TABLE users; --"), isNotNull);
        expect(InputValidators.validateName("1' OR '1'='1"), isNotNull);
        expect(InputValidators.validateName('admin"--'), isNotNull);
      });

      test('containsSqlInjectionPattern detects common patterns', () {
        expect(InputValidators.containsSqlInjectionPattern("'; DROP TABLE"), isTrue);
        expect(InputValidators.containsSqlInjectionPattern("1' OR '1'='1"), isTrue);
        expect(InputValidators.containsSqlInjectionPattern('UNION SELECT'), isTrue);
        expect(InputValidators.containsSqlInjectionPattern('admin"--'), isTrue);
      });

      test('containsSqlInjectionPattern allows safe inputs', () {
        expect(InputValidators.containsSqlInjectionPattern('John Doe'), isFalse);
        expect(InputValidators.containsSqlInjectionPattern("O'Brien"), isFalse);
        expect(InputValidators.containsSqlInjectionPattern('test@example.com'), isFalse);
      });
    });

    group('Security - Unicode Malicious Prevention', () {
      test('rejects invisible unicode characters in name', () {
        // Zero-width space (U+200B)
        expect(InputValidators.validateName('John\u200BDoe'), isNotNull);
        // Right-to-left override (U+202E)
        expect(InputValidators.validateName('John\u202EDoe'), isNotNull);
      });

      test('containsMaliciousUnicode detects dangerous characters', () {
        // Zero-width space
        expect(InputValidators.containsMaliciousUnicode('test\u200Btext'), isTrue);
        // Zero-width non-joiner
        expect(InputValidators.containsMaliciousUnicode('test\u200Ctext'), isTrue);
        // Right-to-left override
        expect(InputValidators.containsMaliciousUnicode('test\u202Etext'), isTrue);
        // Left-to-right override
        expect(InputValidators.containsMaliciousUnicode('test\u202Dtext'), isTrue);
      });

      test('allows zero-width joiner for emoji sequences', () {
        // U+200D (zero-width joiner) is needed for emoji sequences like family emojis
        // This should NOT be detected as malicious
        expect(InputValidators.containsMaliciousUnicode('test\u200Dtext'), isFalse);
      });

      test('allows safe unicode (accents, emojis)', () {
        expect(InputValidators.containsMaliciousUnicode('Helene'), isFalse);
        expect(InputValidators.containsMaliciousUnicode('Francois'), isFalse);
        // Note: emojis in messages are allowed
      });
    });

    group('Security - DoS via Long Inputs', () {
      test('email rejects inputs exceeding 254 chars', () {
        final longEmail = 'a' * 300;
        expect(InputValidators.validateEmail(longEmail), isNotNull);
      });

      test('password rejects inputs exceeding 128 chars', () {
        final longPassword = 'A' * 200;
        expect(InputValidators.validatePassword(longPassword), isNotNull);
      });

      test('name rejects inputs exceeding 100 chars', () {
        final longName = 'A' * 150;
        expect(InputValidators.validateName(longName), isNotNull);
      });

      test('bio rejects inputs exceeding 500 chars', () {
        final longBio = 'A' * 600;
        expect(InputValidators.validateBio(longBio), isNotNull);
      });

      test('message rejects inputs exceeding 2000 chars', () {
        final longMessage = 'A' * 3000;
        expect(InputValidators.validateMessage(longMessage), isNotNull);
      });

      test('search rejects inputs exceeding 200 chars', () {
        final longSearch = 'A' * 250;
        expect(InputValidators.validateSearchQuery(longSearch), isNotNull);
      });

      test('extremely long input (10000+ chars) is rejected quickly', () {
        final extremelyLong = 'A' * 10001;

        // Should not hang - test validates performance
        final stopwatch = Stopwatch()..start();
        InputValidators.validateEmail(extremelyLong);
        InputValidators.validatePassword(extremelyLong);
        InputValidators.validateName(extremelyLong);
        InputValidators.validateBio(extremelyLong);
        InputValidators.validateMessage(extremelyLong);
        InputValidators.validateSearchQuery(extremelyLong);
        stopwatch.stop();

        // All validations should complete in under 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Edge Cases', () {
      test('handles single character inputs', () {
        expect(InputValidators.validateEmail('a'), isNotNull);
        expect(InputValidators.validateName('A'), isNull); // Single letter name OK
        expect(InputValidators.validateMessage('A'), isNull);
      });

      test('handles unicode emoji in messages', () {
        // Emojis should be allowed in messages
        expect(InputValidators.validateMessage('Hello! Great wedding!'), isNull);
      });

      test('handles newlines in bio', () {
        expect(InputValidators.validateBio('Line 1\nLine 2'), isNull);
      });

      test('handles tabs and special whitespace', () {
        expect(InputValidators.validateMessage('Hello\tWorld'), isNull);
      });
    });
  });
}
