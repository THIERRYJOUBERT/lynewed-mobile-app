import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/route_guards.dart';
import 'package:lynewed_beta/core/navigation/routes.dart';

void main() {
  group('RouteGuards', () {
    group('AuthGuard', () {
      test('publicRoutes should contain auth-related paths', () {
        expect(AuthGuard.publicRoutes, contains(AppRoutes.authWelcome));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.signIn));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.signUp));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.forgotPassword));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.signInPro));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.setPasswordPro));
        expect(AuthGuard.publicRoutes, contains(AppRoutes.resetPassword));
      });

      test('isPublicRoute should return true for public routes', () {
        expect(AuthGuard.isPublicRoute(AppRoutes.authWelcome), isTrue);
        expect(AuthGuard.isPublicRoute(AppRoutes.signIn), isTrue);
        expect(AuthGuard.isPublicRoute(AppRoutes.signUp), isTrue);
        expect(AuthGuard.isPublicRoute(AppRoutes.forgotPassword), isTrue);
      });

      test('isPublicRoute should return false for protected routes', () {
        expect(AuthGuard.isPublicRoute(AppRoutes.homeBrides), isFalse);
        expect(AuthGuard.isPublicRoute(AppRoutes.dashboardPro), isFalse);
        expect(AuthGuard.isPublicRoute(AppRoutes.chatDetails), isFalse);
        expect(AuthGuard.isPublicRoute(AppRoutes.myWedding), isFalse);
      });

      test('isPublicRoute should handle path with query parameters', () {
        expect(AuthGuard.isPublicRoute('/signInEmailPage?redirect=/home'),
            isTrue);
        expect(AuthGuard.isPublicRoute('/homeBrides?tab=1'), isFalse);
      });

      test('defaultRedirectPath should be authWelcome', () {
        expect(AuthGuard.defaultRedirectPath, equals(AppRoutes.authWelcome));
      });

      test('getRedirectPath returns authWelcome for unauthenticated users', () {
        final redirect =
            AuthGuard.getRedirectPath(isLoggedIn: false, currentPath: '/home');
        expect(redirect, equals(AppRoutes.authWelcome));
      });

      test(
          'getRedirectPath returns null for authenticated users on protected routes',
          () {
        final redirect = AuthGuard.getRedirectPath(
            isLoggedIn: true, currentPath: AppRoutes.homeBrides);
        expect(redirect, isNull);
      });

      test('getRedirectPath returns null for public routes', () {
        final redirect = AuthGuard.getRedirectPath(
            isLoggedIn: false, currentPath: AppRoutes.signIn);
        expect(redirect, isNull);
      });
    });

    group('NavigationPatterns', () {
      test('should document FFRoute pattern', () {
        expect(NavigationPatterns.ffRouteDescription, isNotEmpty);
        expect(NavigationPatterns.ffRouteDescription, contains('go_router'));
      });

      test('should document parameter handling pattern', () {
        expect(NavigationPatterns.parameterHandlingDescription, isNotEmpty);
        expect(NavigationPatterns.parameterHandlingDescription,
            contains('FFParameters'));
      });

      test('should document transition pattern', () {
        expect(NavigationPatterns.transitionDescription, isNotEmpty);
        expect(
            NavigationPatterns.transitionDescription, contains('TransitionInfo'));
      });

      test('should document auth redirect pattern', () {
        expect(NavigationPatterns.authRedirectDescription, isNotEmpty);
        expect(NavigationPatterns.authRedirectDescription, contains('redirect'));
      });

      test('supportedParamTypes should list all FlutterFlow param types', () {
        expect(NavigationPatterns.supportedParamTypes, contains('String'));
        expect(NavigationPatterns.supportedParamTypes, contains('int'));
        expect(NavigationPatterns.supportedParamTypes, contains('bool'));
        expect(NavigationPatterns.supportedParamTypes, contains('double'));
        expect(NavigationPatterns.supportedParamTypes, contains('DateTime'));
        expect(NavigationPatterns.supportedParamTypes, contains('LatLng'));
        expect(NavigationPatterns.supportedParamTypes, contains('DataStruct'));
        expect(NavigationPatterns.supportedParamTypes, contains('Enum'));
      });
    });
  });

  group('DeepLinkSchemes', () {
    test('scheme should be lynewed', () {
      expect(DeepLinkSchemes.scheme, equals('lynewed'));
    });

    test('chatPath should match pattern', () {
      expect(DeepLinkSchemes.chatPath, equals('chat'));
    });

    test('profilePath should match pattern', () {
      expect(DeepLinkSchemes.profilePath, equals('profile'));
    });

    test('weddingPath should match pattern', () {
      expect(DeepLinkSchemes.weddingPath, equals('wedding'));
    });

    test('buildDeepLink should create correct URI for chat', () {
      final uri = DeepLinkSchemes.buildDeepLink(DeepLinkSchemes.chatPath,
          pathParams: {'roomId': 'abc123'});
      expect(uri, equals('lynewed://chat/abc123'));
    });

    test('buildDeepLink should create correct URI for profile', () {
      final uri = DeepLinkSchemes.buildDeepLink(DeepLinkSchemes.profilePath,
          pathParams: {'profileId': 'user456'});
      expect(uri, equals('lynewed://profile/user456'));
    });

    test('parseDeepLink should extract path and params from chat link', () {
      final result = DeepLinkSchemes.parseDeepLink('lynewed://chat/room123');
      expect(result, isNotNull);
      expect(result!.path, equals('chat'));
      expect(result.params['id'], equals('room123'));
    });

    test('parseDeepLink should extract path and params from profile link', () {
      final result =
          DeepLinkSchemes.parseDeepLink('lynewed://profile/userABC');
      expect(result, isNotNull);
      expect(result!.path, equals('profile'));
      expect(result.params['id'], equals('userABC'));
    });

    test('parseDeepLink should return null for invalid scheme', () {
      final result = DeepLinkSchemes.parseDeepLink('https://example.com/chat');
      expect(result, isNull);
    });

    test('parseDeepLink should return null for malformed URI', () {
      final result = DeepLinkSchemes.parseDeepLink('not-a-valid-uri');
      expect(result, isNull);
    });

    test('toAppRoute should convert chat deep link to app route', () {
      final route = DeepLinkSchemes.toAppRoute('lynewed://chat/room123');
      expect(route, isNotNull);
      expect(route, contains(AppRoutes.chatDetails));
      expect(route, contains('roomId=room123'));
    });

    test('toAppRoute should convert profile deep link to app route', () {
      final route = DeepLinkSchemes.toAppRoute('lynewed://profile/user456');
      expect(route, isNotNull);
      expect(route, contains(AppRoutes.proDetails));
      expect(route, contains('profileId=user456'));
    });

    test('toAppRoute should return null for unknown path', () {
      final route = DeepLinkSchemes.toAppRoute('lynewed://unknown/123');
      expect(route, isNull);
    });
  });
}
