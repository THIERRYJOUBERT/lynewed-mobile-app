import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/navigation/routes.dart';

void main() {
  group('AppRoutes', () {
    group('Auth routes', () {
      test('signUp route should start with /', () {
        expect(AppRoutes.signUp, startsWith('/'));
      });

      test('signIn route should start with /', () {
        expect(AppRoutes.signIn, startsWith('/'));
      });

      test('forgotPassword route should start with /', () {
        expect(AppRoutes.forgotPassword, startsWith('/'));
      });

      test('authWelcome route should start with /', () {
        expect(AppRoutes.authWelcome, startsWith('/'));
      });

      test('resetPassword route should start with /', () {
        expect(AppRoutes.resetPassword, startsWith('/'));
      });

      test('signInPro route should start with /', () {
        expect(AppRoutes.signInPro, startsWith('/'));
      });

      test('setPasswordPro route should start with /', () {
        expect(AppRoutes.setPasswordPro, startsWith('/'));
      });

      test('startupGate route should start with /', () {
        expect(AppRoutes.startupGate, startsWith('/'));
      });

      test('onboardingBridesWizard route should start with /', () {
        expect(AppRoutes.onboardingBridesWizard, startsWith('/'));
      });
    });

    group('Bride routes', () {
      test('homeBrides route should start with /', () {
        expect(AppRoutes.homeBrides, startsWith('/'));
      });

      test('feedBrides route should start with /', () {
        expect(AppRoutes.feedBrides, startsWith('/'));
      });

      test('messagesBrides route should start with /', () {
        expect(AppRoutes.messagesBrides, startsWith('/'));
      });

      test('mapBrides route should start with /', () {
        expect(AppRoutes.mapBrides, startsWith('/'));
      });

      test('editProfileBrides route should start with /', () {
        expect(AppRoutes.editProfileBrides, startsWith('/'));
      });

      test('favProList route should start with /', () {
        expect(AppRoutes.favProList, startsWith('/'));
      });

      test('feedDetailViewer route should start with /', () {
        expect(AppRoutes.feedDetailViewer, startsWith('/'));
      });
    });

    group('Pro routes', () {
      test('dashboardPro route should start with /', () {
        expect(AppRoutes.dashboardPro, startsWith('/'));
      });

      test('messagesPro route should start with /', () {
        expect(AppRoutes.messagesPro, startsWith('/'));
      });

      test('mapPro route should start with /', () {
        expect(AppRoutes.mapPro, startsWith('/'));
      });

      test('publicProProfileView route should start with /', () {
        expect(AppRoutes.publicProProfileView, startsWith('/'));
      });

      test('wishlistPro route should start with /', () {
        expect(AppRoutes.wishlistPro, startsWith('/'));
      });

      test('weddingsHubPro route should start with /', () {
        expect(AppRoutes.weddingsHubPro, startsWith('/'));
      });
    });

    group('Shared routes', () {
      test('proDetails route should start with /', () {
        expect(AppRoutes.proDetails, startsWith('/'));
      });

      test('profileBridesAndPro route should start with /', () {
        expect(AppRoutes.profileBridesAndPro, startsWith('/'));
      });

      test('preference route should start with /', () {
        expect(AppRoutes.preference, startsWith('/'));
      });

      test('settingsPermissions route should start with /', () {
        expect(AppRoutes.settingsPermissions, startsWith('/'));
      });

      test('weddingOfTheWeek route should start with /', () {
        expect(AppRoutes.weddingOfTheWeek, startsWith('/'));
      });

      test('support route should start with /', () {
        expect(AppRoutes.support, startsWith('/'));
      });

      test('contentReplay route should start with /', () {
        expect(AppRoutes.contentReplay, startsWith('/'));
      });

      test('replayPlayerPage route should start with /', () {
        expect(AppRoutes.replayPlayerPage, startsWith('/'));
      });

      test('portfolioImageViewer route should start with /', () {
        expect(AppRoutes.portfolioImageViewer, startsWith('/'));
      });

      test('videoCallPage route should start with /', () {
        expect(AppRoutes.videoCallPage, startsWith('/'));
      });

      test('wowViewerCarrousel route should start with /', () {
        expect(AppRoutes.wowViewerCarrousel, startsWith('/'));
      });

      test('wowSimpleViewer route should start with /', () {
        expect(AppRoutes.wowSimpleViewer, startsWith('/'));
      });
    });

    group('Feature routes', () {
      test('notifications route should start with /', () {
        expect(AppRoutes.notifications, startsWith('/'));
      });

      test('notificationSettings route should start with /', () {
        expect(AppRoutes.notificationSettings, startsWith('/'));
      });

      test('chatDetails route should start with /', () {
        expect(AppRoutes.chatDetails, startsWith('/'));
      });

      test('messages route should start with /', () {
        expect(AppRoutes.messages, startsWith('/'));
      });

      test('myWedding route should start with /', () {
        expect(AppRoutes.myWedding, startsWith('/'));
      });

      test('budget route should start with /', () {
        expect(AppRoutes.budget, startsWith('/'));
      });

      test('agenda route should start with /', () {
        expect(AppRoutes.agenda, startsWith('/'));
      });

      test('inspirations route should start with /', () {
        expect(AppRoutes.inspirations, startsWith('/'));
      });

      test('guests route should start with /', () {
        expect(AppRoutes.guests, startsWith('/'));
      });

      test('map route should start with /', () {
        expect(AppRoutes.map, startsWith('/'));
      });

      test('stripeSetup route should start with /', () {
        expect(AppRoutes.stripeSetup, startsWith('/'));
      });

      test('checkout route should start with /', () {
        expect(AppRoutes.checkout, startsWith('/'));
      });

      test('orderConfirmation route should start with /', () {
        expect(AppRoutes.orderConfirmation, startsWith('/'));
      });

      test('transactionDetail route should start with /', () {
        expect(AppRoutes.transactionDetail, startsWith('/'));
      });

      test('buyerTransaction route should start with /', () {
        expect(AppRoutes.buyerTransaction, startsWith('/'));
      });
    });

    group('Route naming conventions', () {
      test('all routes should be unique', () {
        final allRoutes = [
          // Auth
          AppRoutes.signUp,
          AppRoutes.signIn,
          AppRoutes.forgotPassword,
          AppRoutes.authWelcome,
          AppRoutes.resetPassword,
          AppRoutes.signInPro,
          AppRoutes.setPasswordPro,
          AppRoutes.startupGate,
          AppRoutes.onboardingBridesWizard,
          // Bride
          AppRoutes.homeBrides,
          AppRoutes.feedBrides,
          AppRoutes.messagesBrides,
          AppRoutes.mapBrides,
          AppRoutes.editProfileBrides,
          AppRoutes.favProList,
          AppRoutes.feedDetailViewer,
          // Pro
          AppRoutes.dashboardPro,
          AppRoutes.messagesPro,
          AppRoutes.mapPro,
          AppRoutes.publicProProfileView,
          AppRoutes.wishlistPro,
          AppRoutes.weddingsHubPro,
          // Shared
          AppRoutes.proDetails,
          AppRoutes.profileBridesAndPro,
          AppRoutes.preference,
          AppRoutes.settingsPermissions,
          AppRoutes.weddingOfTheWeek,
          AppRoutes.support,
          AppRoutes.contentReplay,
          AppRoutes.replayPlayerPage,
          AppRoutes.portfolioImageViewer,
          AppRoutes.videoCallPage,
          AppRoutes.wowViewerCarrousel,
          AppRoutes.wowSimpleViewer,
          // Features
          AppRoutes.notifications,
          AppRoutes.notificationSettings,
          AppRoutes.chatDetails,
          AppRoutes.messages,
          AppRoutes.myWedding,
          AppRoutes.budget,
          AppRoutes.agenda,
          AppRoutes.inspirations,
          AppRoutes.guests,
          AppRoutes.map,
          AppRoutes.stripeSetup,
          AppRoutes.checkout,
          AppRoutes.orderConfirmation,
          AppRoutes.transactionDetail,
          AppRoutes.buyerTransaction,
        ];

        final uniqueRoutes = allRoutes.toSet();
        expect(uniqueRoutes.length, equals(allRoutes.length),
            reason: 'All routes should be unique');
      });

      test('routes should not contain spaces', () {
        final allRoutes = [
          AppRoutes.signUp,
          AppRoutes.signIn,
          AppRoutes.chatDetails,
          AppRoutes.myWedding,
          AppRoutes.dashboardPro,
        ];

        for (final route in allRoutes) {
          expect(route, isNot(contains(' ')),
              reason: 'Route $route should not contain spaces');
        }
      });
    });
  });

  group('RouteNames', () {
    test('signUp name should match route convention', () {
      expect(RouteNames.signUp, equals('SignUpEmailPage'));
    });

    test('chatDetails name should match route convention', () {
      expect(RouteNames.chatDetails, equals('ChatDetailsPage'));
    });

    test('myWedding name should match route convention', () {
      expect(RouteNames.myWedding, equals('myWedding'));
    });

    test('stripeSetup name should match route convention', () {
      expect(RouteNames.stripeSetup, equals('StripeSetup'));
    });

    test('all names should not be empty', () {
      expect(RouteNames.signUp, isNotEmpty);
      expect(RouteNames.chatDetails, isNotEmpty);
      expect(RouteNames.myWedding, isNotEmpty);
      expect(RouteNames.stripeSetup, isNotEmpty);
    });

    test('checkout name should match route convention', () {
      expect(RouteNames.checkout, equals('Checkout'));
    });

    test('orderConfirmation name should match route convention', () {
      expect(RouteNames.orderConfirmation, equals('OrderConfirmation'));
    });

    test('transactionDetail name should match route convention', () {
      expect(RouteNames.transactionDetail, equals('TransactionDetail'));
    });

    test('buyerTransaction name should match route convention', () {
      expect(RouteNames.buyerTransaction, equals('BuyerTransaction'));
    });
  });
}
