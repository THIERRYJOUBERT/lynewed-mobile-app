import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/navigation.dart';

/// Tests for the navigation barrel export.
///
/// Verifies that all navigation components are properly exported and
/// accessible through the single import.
void main() {
  group('Navigation barrel export', () {
    group('Routes exports', () {
      test('AppRoutes should be accessible', () {
        expect(AppRoutes.chatDetails, isNotEmpty);
        expect(AppRoutes.myWedding, isNotEmpty);
        expect(AppRoutes.homeBrides, isNotEmpty);
      });

      test('RouteNames should be accessible', () {
        expect(RouteNames.chatDetails, isNotEmpty);
        expect(RouteNames.myWedding, isNotEmpty);
        expect(RouteNames.homeBrides, isNotEmpty);
      });
    });

    group('Route guards exports', () {
      test('AuthGuard should be accessible', () {
        expect(AuthGuard.publicRoutes, isNotEmpty);
        expect(AuthGuard.isPublicRoute(AppRoutes.signIn), isTrue);
      });

      test('NavigationPatterns should be accessible', () {
        expect(NavigationPatterns.ffRouteDescription, isNotEmpty);
        expect(NavigationPatterns.supportedParamTypes, isNotEmpty);
      });

      test('DeepLinkSchemes should be accessible', () {
        expect(DeepLinkSchemes.scheme, equals('lynewed'));
        expect(DeepLinkSchemes.chatPath, isNotEmpty);
      });

      test('DeepLinkResult should be accessible', () {
        const result = DeepLinkResult(path: 'test', params: {});
        expect(result.path, equals('test'));
      });
    });

    group('Page wrapper exports', () {
      test('WrapperConfig should be accessible', () {
        const config = WrapperConfig();
        expect(config.useScaffold, isFalse);
      });

      test('PageWrapperMixin should be accessible', () {
        expect(PageWrapperMixin.parseBoolean('true'), isTrue);
        expect(PageWrapperMixin.convertStringToNullable(''), isNull);
      });
    });
  });

  group('Navigation integration', () {
    test('route paths align with feature routes', () {
      // Verify Clean Architecture feature routes are in the constants
      expect(AppRoutes.chatDetails, equals('/chatDetailsPage'));
      expect(AppRoutes.notifications, equals('/notificationsPage'));
      expect(AppRoutes.notificationSettings, equals('/notificationSettings'));
      expect(AppRoutes.myWedding, equals('/myWedding'));
      expect(AppRoutes.messages, equals('/messages'));
      expect(AppRoutes.map, equals('/map'));
    });

    test('route names align with page widget conventions', () {
      // Verify route names match the static routeName in page widgets
      expect(RouteNames.chatDetails, equals('ChatDetailsPage'));
      expect(RouteNames.notifications, equals('NotificationsPage'));
      expect(RouteNames.notificationSettings, equals('NotificationSettings'));
      expect(RouteNames.myWedding, equals('myWedding'));
    });

    test('legacy FlutterFlow routes are preserved', () {
      // Verify FlutterFlow page routes maintain compatibility
      expect(AppRoutes.homeBrides, equals('/homeBrides'));
      expect(AppRoutes.dashboardPro, equals('/dashboardPro'));
      expect(AppRoutes.signIn, equals('/signInEmailPage'));
      expect(AppRoutes.signUp, equals('/signUpEmailPage'));
    });

    test('auth guard correctly identifies public vs protected routes', () {
      // Auth routes should be public
      expect(AuthGuard.isPublicRoute(AppRoutes.signIn), isTrue);
      expect(AuthGuard.isPublicRoute(AppRoutes.signUp), isTrue);
      expect(AuthGuard.isPublicRoute(AppRoutes.forgotPassword), isTrue);
      expect(AuthGuard.isPublicRoute(AppRoutes.authWelcome), isTrue);

      // Feature routes should be protected
      expect(AuthGuard.isPublicRoute(AppRoutes.chatDetails), isFalse);
      expect(AuthGuard.isPublicRoute(AppRoutes.myWedding), isFalse);
      expect(AuthGuard.isPublicRoute(AppRoutes.homeBrides), isFalse);
      expect(AuthGuard.isPublicRoute(AppRoutes.dashboardPro), isFalse);
    });

    test('deep links convert to correct app routes', () {
      // Chat deep link
      final chatRoute = DeepLinkSchemes.toAppRoute('lynewed://chat/room123');
      expect(chatRoute, contains(AppRoutes.chatDetails));
      expect(chatRoute, contains('roomId=room123'));

      // Profile deep link
      final profileRoute =
          DeepLinkSchemes.toAppRoute('lynewed://profile/user456');
      expect(profileRoute, contains(AppRoutes.proDetails));
      expect(profileRoute, contains('profileId=user456'));

      // Wedding deep link
      final weddingRoute =
          DeepLinkSchemes.toAppRoute('lynewed://wedding/wed789');
      expect(weddingRoute, contains(AppRoutes.myWedding));
      expect(weddingRoute, contains('weddingId=wed789'));
    });
  });

  group('Coexistence pattern verification', () {
    test('wrapper utilities handle FlutterFlow parameter formats', () {
      // Empty string -> null
      expect(PageWrapperMixin.convertStringToNullable(''), isNull);

      // 'null' string -> null
      expect(PageWrapperMixin.convertStringToNullable('null'), isNull);

      // Valid string preserved
      expect(
          PageWrapperMixin.convertStringToNullable('room123'), equals('room123'));

      // Boolean parsing from strings (FlutterFlow format)
      expect(PageWrapperMixin.parseBoolean('true'), isTrue);
      expect(PageWrapperMixin.parseBoolean('false'), isFalse);
    });

    test('wrapper config supports scaffold wrapping', () {
      const configWithScaffold = WrapperConfig(useScaffold: true);
      const configWithoutScaffold = WrapperConfig(useScaffold: false);

      expect(configWithScaffold.useScaffold, isTrue);
      expect(configWithoutScaffold.useScaffold, isFalse);
    });
  });
}
