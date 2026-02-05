import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/backend/schema/enums/enums.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_type_config.dart';

void main() {
  // ==============================================================
  // AC2: NOTIFICATION TYPE CONFIG TESTS
  // ==============================================================

  group('NotificationTypeConfig', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create with required fields only', () {
        const config = NotificationTypeConfig(
          type: 'testType',
          titleKey: 'Test Title',
          descriptionBrideKey: 'Description for Bride',
          descriptionProKey: 'Description for Pro',
        );

        expect(config.type, 'testType');
        expect(config.titleKey, 'Test Title');
        expect(config.descriptionBrideKey, 'Description for Bride');
        expect(config.descriptionProKey, 'Description for Pro');
      });

      test('should use default values for optional fields', () {
        const config = NotificationTypeConfig(
          type: 'testType',
          titleKey: 'Test Title',
          descriptionBrideKey: 'Bride description',
          descriptionProKey: 'Pro description',
        );

        // Verify defaults
        expect(config.visibleForBride, true);
        expect(config.visibleForPro, true);
        expect(config.requiredTier, isNull);
        expect(config.isActive, true);
      });

      test('should create with all fields specified', () {
        const config = NotificationTypeConfig(
          type: 'premiumFeature',
          titleKey: 'Premium Feature',
          descriptionBrideKey: 'Not for brides',
          descriptionProKey: 'Only for Ultimate pros',
          visibleForBride: false,
          visibleForPro: true,
          requiredTier: SubscriptionTierType.ultimateAccess,
          isActive: true,
        );

        expect(config.visibleForBride, false);
        expect(config.visibleForPro, true);
        expect(config.requiredTier, SubscriptionTierType.ultimateAccess);
        expect(config.isActive, true);
      });

      test('should create inactive config', () {
        const config = NotificationTypeConfig(
          type: 'deprecated',
          titleKey: 'Deprecated',
          descriptionBrideKey: '',
          descriptionProKey: '',
          isActive: false,
        );

        expect(config.isActive, false);
      });
    });

    // ==============================================================
    // GETDESCRIPTION TESTS
    // ==============================================================

    group('getDescription', () {
      test('should return bride description for bride role', () {
        const config = NotificationTypeConfig(
          type: 'chat',
          titleKey: 'Chat',
          descriptionBrideKey: 'Bride gets this message',
          descriptionProKey: 'Pro gets this message',
        );

        final description = config.getDescription(UserRole.bride);

        expect(description, 'Bride gets this message');
      });

      test('should return pro description for professional role', () {
        const config = NotificationTypeConfig(
          type: 'chat',
          titleKey: 'Chat',
          descriptionBrideKey: 'Bride gets this message',
          descriptionProKey: 'Pro gets this message',
        );

        final description = config.getDescription(UserRole.professional);

        expect(description, 'Pro gets this message');
      });
    });

    // ==============================================================
    // ISVISIBLEFOR TESTS
    // ==============================================================

    group('isVisibleFor', () {
      test('should return false for inactive config', () {
        const config = NotificationTypeConfig(
          type: 'inactive',
          titleKey: 'Inactive',
          descriptionBrideKey: '',
          descriptionProKey: '',
          isActive: false,
        );

        final visibleForBride = config.isVisibleFor(role: UserRole.bride);
        final visibleForPro = config.isVisibleFor(role: UserRole.professional);

        expect(visibleForBride, false);
        expect(visibleForPro, false);
      });

      test('should return false for bride when visibleForBride is false', () {
        const config = NotificationTypeConfig(
          type: 'proOnly',
          titleKey: 'Pro Only',
          descriptionBrideKey: '',
          descriptionProKey: 'Pro description',
          visibleForBride: false,
          visibleForPro: true,
        );

        final visible = config.isVisibleFor(role: UserRole.bride);

        expect(visible, false);
      });

      test('should return false for pro when visibleForPro is false', () {
        const config = NotificationTypeConfig(
          type: 'brideOnly',
          titleKey: 'Bride Only',
          descriptionBrideKey: 'Bride description',
          descriptionProKey: '',
          visibleForBride: true,
          visibleForPro: false,
        );

        final visible = config.isVisibleFor(role: UserRole.professional);

        expect(visible, false);
      });

      test('should return true when no tier requirement', () {
        const config = NotificationTypeConfig(
          type: 'allUsers',
          titleKey: 'All Users',
          descriptionBrideKey: 'Bride',
          descriptionProKey: 'Pro',
        );

        final visibleForBride = config.isVisibleFor(role: UserRole.bride);
        final visibleForPro = config.isVisibleFor(role: UserRole.professional);

        expect(visibleForBride, true);
        expect(visibleForPro, true);
      });

      test('should return true when user tier meets requirement', () {
        const config = NotificationTypeConfig(
          type: 'premium',
          titleKey: 'Premium',
          descriptionBrideKey: '',
          descriptionProKey: 'For premium pros',
          visibleForBride: false,
          visibleForPro: true,
          requiredTier: SubscriptionTierType.premiumVisibility,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.premiumVisibility,
        );

        expect(visible, true);
      });

      test('should return true when user tier exceeds requirement', () {
        const config = NotificationTypeConfig(
          type: 'premium',
          titleKey: 'Premium',
          descriptionBrideKey: '',
          descriptionProKey: 'For premium pros',
          visibleForBride: false,
          visibleForPro: true,
          requiredTier: SubscriptionTierType.premiumVisibility,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.ultimateAccess,
        );

        expect(visible, true);
      });

      test('should return false when user tier is below requirement', () {
        const config = NotificationTypeConfig(
          type: 'ultimate',
          titleKey: 'Ultimate',
          descriptionBrideKey: '',
          descriptionProKey: 'Ultimate only',
          visibleForBride: false,
          visibleForPro: true,
          requiredTier: SubscriptionTierType.ultimateAccess,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.premiumVisibility,
        );

        expect(visible, false);
      });

      test('should return true when requiredTier is set but subscriptionTier is null', () {
        // Edge case: when user's subscription tier is not provided
        const config = NotificationTypeConfig(
          type: 'premium',
          titleKey: 'Premium',
          descriptionBrideKey: '',
          descriptionProKey: 'Pro',
          requiredTier: SubscriptionTierType.premiumVisibility,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: null,
        );

        // Based on implementation: if subscriptionTier is null, tier check is skipped
        expect(visible, true);
      });
    });

    // ==============================================================
    // TIER ORDERING TESTS
    // ==============================================================

    group('tier ordering', () {
      test('inactive tier should be lowest', () {
        const config = NotificationTypeConfig(
          type: 'trial',
          titleKey: 'Trial',
          descriptionBrideKey: '',
          descriptionProKey: '',
          requiredTier: SubscriptionTierType.trial,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.inactive,
        );

        expect(visible, false);
      });

      test('trial should be higher than inactive', () {
        const config = NotificationTypeConfig(
          type: 'inactiveOnly',
          titleKey: 'Inactive',
          descriptionBrideKey: '',
          descriptionProKey: '',
          requiredTier: SubscriptionTierType.inactive,
        );

        final visible = config.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.trial,
        );

        expect(visible, true);
      });

      test('earlyAccess should be between trial and premium', () {
        const configForEarlyAccess = NotificationTypeConfig(
          type: 'earlyAccess',
          titleKey: 'Early Access',
          descriptionBrideKey: '',
          descriptionProKey: '',
          requiredTier: SubscriptionTierType.earlyAccess,
        );

        // Trial should not meet earlyAccess requirement
        final trialVisible = configForEarlyAccess.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.trial,
        );
        expect(trialVisible, false);

        // earlyAccess should meet earlyAccess requirement
        final earlyAccessVisible = configForEarlyAccess.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.earlyAccess,
        );
        expect(earlyAccessVisible, true);

        // premium should exceed earlyAccess requirement
        final premiumVisible = configForEarlyAccess.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.premiumVisibility,
        );
        expect(premiumVisible, true);
      });

      test('ultimateAccess should be highest tier', () {
        const configForUltimate = NotificationTypeConfig(
          type: 'ultimate',
          titleKey: 'Ultimate',
          descriptionBrideKey: '',
          descriptionProKey: '',
          requiredTier: SubscriptionTierType.ultimateAccess,
        );

        // Premium should not meet ultimate requirement
        final premiumVisible = configForUltimate.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.premiumVisibility,
        );
        expect(premiumVisible, false);

        // Ultimate should meet ultimate requirement
        final ultimateVisible = configForUltimate.isVisibleFor(
          role: UserRole.professional,
          subscriptionTier: SubscriptionTierType.ultimateAccess,
        );
        expect(ultimateVisible, true);
      });
    });
  });

  // ==============================================================
  // AC2: NOTIFICATION TYPES CONFIG (STATIC LIST) TESTS
  // ==============================================================

  group('NotificationTypesConfig', () {
    test('all list should contain expected notification types', () {
      final types = NotificationTypesConfig.all.map((c) => c.type).toList();

      expect(types, contains('chatMessage'));
      expect(types, contains('connectionRequest'));
      expect(types, contains('connectionRequestAccepted'));
      expect(types, contains('wishlistAdd'));
      expect(types, contains('videoIncoming'));
      expect(types, contains('marketplaceNewMessage'));
      expect(types, contains('wedPublished'));
      expect(types, contains('replayPublished'));
    });

    test('getVisibleTypes should return empty list for null role', () {
      final types = NotificationTypesConfig.getVisibleTypes(role: null);

      expect(types, isEmpty);
    });

    test('getVisibleTypes should filter by bride role', () {
      final types = NotificationTypesConfig.getVisibleTypes(
        role: UserRole.bride,
      );

      // chatMessage, connectionRequest, videoIncoming, marketplaceNewMessage, wedPublished, replayPublished should be visible
      expect(types.any((c) => c.type == 'chatMessage'), true);
      expect(types.any((c) => c.type == 'connectionRequest'), true);
      expect(types.any((c) => c.type == 'videoIncoming'), true);
      expect(types.any((c) => c.type == 'marketplaceNewMessage'), true);
      expect(types.any((c) => c.type == 'wedPublished'), true);
      expect(types.any((c) => c.type == 'replayPublished'), true);

      // connectionRequestAccepted and wishlistAdd should not be visible for bride
      expect(types.any((c) => c.type == 'connectionRequestAccepted'), false);
      expect(types.any((c) => c.type == 'wishlistAdd'), false);
    });

    test('getVisibleTypes should filter by professional role', () {
      final types = NotificationTypesConfig.getVisibleTypes(
        role: UserRole.professional,
        subscriptionTier: SubscriptionTierType.trial,
      );

      // Most types should be visible for pro
      expect(types.any((c) => c.type == 'chatMessage'), true);
      expect(types.any((c) => c.type == 'connectionRequest'), true);
      expect(types.any((c) => c.type == 'connectionRequestAccepted'), true);
      expect(types.any((c) => c.type == 'videoIncoming'), true);
      expect(types.any((c) => c.type == 'marketplaceNewMessage'), true);

      // wishlistAdd requires Ultimate tier, so should not be visible for trial
      expect(types.any((c) => c.type == 'wishlistAdd'), false);
    });

    test('getVisibleTypes should include tier-gated types for Ultimate users', () {
      final types = NotificationTypesConfig.getVisibleTypes(
        role: UserRole.professional,
        subscriptionTier: SubscriptionTierType.ultimateAccess,
      );

      // wishlistAdd should be visible for Ultimate tier
      expect(types.any((c) => c.type == 'wishlistAdd'), true);
    });

    test('wishlistAdd should require ultimate tier', () {
      final wishlistConfig = NotificationTypesConfig.all.firstWhere(
        (c) => c.type == 'wishlistAdd',
      );

      expect(wishlistConfig.requiredTier, SubscriptionTierType.ultimateAccess);
      expect(wishlistConfig.visibleForBride, false);
      expect(wishlistConfig.visibleForPro, true);
    });

    test('all configs should have non-empty titleKey', () {
      for (final config in NotificationTypesConfig.all) {
        expect(config.titleKey, isNotEmpty,
            reason: 'Type ${config.type} should have a titleKey');
      }
    });

    test('all configs should be active', () {
      for (final config in NotificationTypesConfig.all) {
        expect(config.isActive, true,
            reason: 'Type ${config.type} should be active');
      }
    });
  });
}
