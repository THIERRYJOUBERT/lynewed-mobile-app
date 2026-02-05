import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';

void main() {
  // ==============================================================
  // TEST FIXTURES
  // ==============================================================

  final testDateTime = DateTime.utc(2025, 1, 24, 10, 0, 0);
  final testReadDateTime = DateTime.utc(2025, 1, 24, 12, 0, 0);

  const testNotificationMap = {
    'id': 'notif-123',
    'type': 'chatMessage',
    'title': 'New Message',
    'body': 'You have a new message from John',
    'image_url': 'https://example.com/avatar.png',
    'data': {'chat_room_id': 'room-456', 'sender_id': 'user-789'},
    'created_at': '2025-01-24T10:00:00Z',
    'read_at': '2025-01-24T12:00:00Z',
  };

  // ==============================================================
  // NOTIFICATION TYPE ENUM TESTS
  // ==============================================================

  group('NotificationType', () {
    test('should have all required notification types', () {
      expect(NotificationType.values, contains(NotificationType.chatMessage));
      expect(NotificationType.values, contains(NotificationType.connectionRequest));
      expect(NotificationType.values, contains(NotificationType.connectionRequestAccepted));
      expect(NotificationType.values, contains(NotificationType.wishlistAdd));
      expect(NotificationType.values, contains(NotificationType.videoIncoming));
      expect(NotificationType.values, contains(NotificationType.wedPublished));
      expect(NotificationType.values, contains(NotificationType.replayPublished));
      expect(NotificationType.values, contains(NotificationType.marketplaceNewMessage));
    });

    test('should parse from string correctly', () {
      expect(NotificationTypeExtension.fromString('chatMessage'), NotificationType.chatMessage);
      expect(NotificationTypeExtension.fromString('connectionRequest'), NotificationType.connectionRequest);
      expect(NotificationTypeExtension.fromString('connectionRequestAccepted'), NotificationType.connectionRequestAccepted);
      expect(NotificationTypeExtension.fromString('wishlistAdd'), NotificationType.wishlistAdd);
      expect(NotificationTypeExtension.fromString('videoIncoming'), NotificationType.videoIncoming);
      expect(NotificationTypeExtension.fromString('wedPublished'), NotificationType.wedPublished);
      expect(NotificationTypeExtension.fromString('replayPublished'), NotificationType.replayPublished);
    });

    test('should return null for unknown type string', () {
      expect(NotificationTypeExtension.fromString('unknown'), isNull);
      expect(NotificationTypeExtension.fromString(''), isNull);
      expect(NotificationTypeExtension.fromString('CHAT_MESSAGE'), isNull);
    });

    test('should convert to string correctly', () {
      expect(NotificationType.chatMessage.value, 'chatMessage');
      expect(NotificationType.connectionRequest.value, 'connectionRequest');
      expect(NotificationType.wishlistAdd.value, 'wishlistAdd');
    });
  });

  // ==============================================================
  // APP NOTIFICATION CREATION TESTS
  // ==============================================================

  group('AppNotification', () {
    group('creation', () {
      test('should create with required fields', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
          data: const {},
          createdAt: testDateTime,
        );

        expect(notification.id, 'notif-123');
        expect(notification.type, NotificationType.chatMessage);
        expect(notification.title, 'New Message');
        expect(notification.body, 'You have a new message');
        expect(notification.data, isEmpty);
        expect(notification.createdAt, testDateTime);
        expect(notification.imageUrl, isNull);
        expect(notification.readAt, isNull);
      });

      test('should create with all fields', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.connectionRequest,
          title: 'Contact Request',
          body: 'John Doe wants to connect',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'sender_id': 'user-456'},
          createdAt: testDateTime,
          readAt: testReadDateTime,
        );

        expect(notification.imageUrl, 'https://example.com/avatar.png');
        expect(notification.readAt, testReadDateTime);
        expect(notification.data['sender_id'], 'user-456');
      });

      test('should correctly compute isRead', () {
        final unreadNotification = AppNotification(
          id: 'notif-1',
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
          readAt: null,
        );

        final readNotification = AppNotification(
          id: 'notif-2',
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
          readAt: testReadDateTime,
        );

        expect(unreadNotification.isRead, false);
        expect(readNotification.isRead, true);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse from JSON with all fields', () {
        final notification = AppNotification.fromJson(testNotificationMap);

        expect(notification.id, 'notif-123');
        expect(notification.type, NotificationType.chatMessage);
        expect(notification.title, 'New Message');
        expect(notification.body, 'You have a new message from John');
        expect(notification.imageUrl, 'https://example.com/avatar.png');
        expect(notification.data['chat_room_id'], 'room-456');
        expect(notification.createdAt, isA<DateTime>());
        expect(notification.readAt, isA<DateTime>());
        expect(notification.isRead, true);
      });

      test('should handle missing optional fields', () {
        const minimalMap = {
          'id': 'notif-123',
          'type': 'connectionRequest',
          'title': 'Title',
          'body': 'Body',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final notification = AppNotification.fromJson(minimalMap);

        expect(notification.id, 'notif-123');
        expect(notification.type, NotificationType.connectionRequest);
        expect(notification.imageUrl, isNull);
        expect(notification.data, isEmpty);
        expect(notification.readAt, isNull);
        expect(notification.isRead, false);
      });

      test('should handle null values gracefully', () {
        final mapWithNulls = <String, dynamic>{
          'id': null,
          'type': null,
          'title': null,
          'body': null,
          'image_url': null,
          'data': null,
          'created_at': null,
          'read_at': null,
        };

        final notification = AppNotification.fromJson(mapWithNulls);

        expect(notification.id, '');
        expect(notification.type, NotificationType.chatMessage); // default
        expect(notification.title, '');
        expect(notification.body, '');
        expect(notification.imageUrl, isNull);
        expect(notification.data, isEmpty);
      });

      test('should handle unknown notification type', () {
        const mapWithUnknownType = {
          'id': 'notif-123',
          'type': 'unknownType',
          'title': 'Title',
          'body': 'Body',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final notification = AppNotification.fromJson(mapWithUnknownType);

        // Should default to chatMessage
        expect(notification.type, NotificationType.chatMessage);
      });

      test('should handle malformed date strings', () {
        const mapWithBadDates = {
          'id': 'notif-123',
          'type': 'chatMessage',
          'title': 'Title',
          'body': 'Body',
          'created_at': 'not-a-date',
          'read_at': 'also-not-a-date',
        };

        final notification = AppNotification.fromJson(mapWithBadDates);

        expect(notification.createdAt, isNotNull); // Falls back to DateTime.now()
        expect(notification.readAt, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize to JSON with all fields', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'chat_room_id': 'room-456'},
          createdAt: testDateTime,
          readAt: testReadDateTime,
        );

        final json = notification.toJson();

        expect(json['id'], 'notif-123');
        expect(json['type'], 'chatMessage');
        expect(json['title'], 'New Message');
        expect(json['body'], 'You have a new message');
        expect(json['image_url'], 'https://example.com/avatar.png');
        expect(json['data'], {'chat_room_id': 'room-456'});
        expect(json['created_at'], '2025-01-24T10:00:00.000Z');
        expect(json['read_at'], '2025-01-24T12:00:00.000Z');
      });

      test('should not include null optional fields', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        final json = notification.toJson();

        expect(json.containsKey('image_url'), false);
        expect(json.containsKey('read_at'), false);
      });

      test('should be reversible with fromJson', () {
        final original = AppNotification(
          id: 'notif-123',
          type: NotificationType.connectionRequest,
          title: 'Contact Request',
          body: 'John wants to connect',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'sender_id': 'user-456'},
          createdAt: testDateTime,
          readAt: testReadDateTime,
        );

        final json = original.toJson();
        final restored = AppNotification.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(restored.imageUrl, original.imageUrl);
        expect(restored.data, original.data);
        expect(restored.createdAt, original.createdAt);
        expect(restored.readAt, original.readAt);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final notification = AppNotification.fromJson(testNotificationMap);

        final updated = notification.copyWith(title: 'Updated Title');

        expect(updated.id, notification.id);
        expect(updated.type, notification.type);
        expect(updated.body, notification.body);
        expect(updated.imageUrl, notification.imageUrl);
        expect(updated.data, notification.data);
        expect(updated.createdAt, notification.createdAt);
        expect(updated.readAt, notification.readAt);
        expect(updated.title, 'Updated Title');
      });

      test('should update multiple fields', () {
        final notification = AppNotification.fromJson(testNotificationMap);
        final newReadAt = DateTime.utc(2025, 1, 25);

        final updated = notification.copyWith(
          title: 'New Title',
          body: 'New Body',
          readAt: newReadAt,
        );

        expect(updated.title, 'New Title');
        expect(updated.body, 'New Body');
        expect(updated.readAt, newReadAt);
      });

      test('should not modify original instance', () {
        final original = AppNotification.fromJson(testNotificationMap);

        original.copyWith(title: 'Modified');

        expect(original.title, 'New Message');
      });

      test('should allow marking as read', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
          readAt: null,
        );

        expect(notification.isRead, false);

        final readNotification = notification.copyWith(
          readAt: DateTime.now(),
        );

        expect(readNotification.isRead, true);
      });
    });

    // ==============================================================
    // NAVIGATION TESTS
    // ==============================================================

    group('navigation', () {
      test('should return navigation for chatMessage with room_id', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'Body',
          data: const {'chat_room_id': 'room-456'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.chat);
        expect(nav.params['roomId'], 'room-456');
      });

      test('should return navigation for connectionRequest with profile_id', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.connectionRequest,
          title: 'Contact Request',
          body: 'Body',
          data: const {'sender_id': 'user-456'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'user-456');
      });

      test('should return navigation for videoIncoming with session data', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.videoIncoming,
          title: 'Incoming Call',
          body: 'Body',
          data: const {
            'session_id': 'session-789',
            'channel_name': 'video-channel',
          },
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.videoCall);
        expect(nav.params['sessionId'], 'session-789');
        expect(nav.params['channelName'], 'video-channel');
      });

      test('should return navigation for wedPublished', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.wedPublished,
          title: 'Wedding of the Week',
          body: 'Body',
          data: const {'wedding_id': 'wedding-123'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.weddingOfTheWeek);
        expect(nav.params['weddingId'], 'wedding-123');
      });

      test('should return null navigation when data is missing required params', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'Body',
          data: const {}, // Missing chat_room_id
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNull);
      });

      test('should return navigation for wishlistAdd with profile_id', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.wishlistAdd,
          title: 'Added to Wishlist',
          body: 'Body',
          data: const {'bride_id': 'bride-123'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'bride-123');
      });

      test('should return navigation for connectionRequestAccepted with accepted_by', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.connectionRequestAccepted,
          title: 'Request Accepted',
          body: 'Body',
          data: const {'accepted_by': 'bride-456'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'bride-456');
      });

      test('should return null for connectionRequestAccepted without accepted_by', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.connectionRequestAccepted,
          title: 'Request Accepted',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNull);
      });

      test('should return navigation for replayPublished with replay_id', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.replayPublished,
          title: 'New Replay',
          body: 'Body',
          data: const {'replay_id': 'replay-789'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.replays);
        expect(nav.params['replayId'], 'replay-789');
      });

      test('should return navigation for replayPublished without replay_id', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.replayPublished,
          title: 'New Replay',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        // replayPublished does not require replay_id, it navigates to replays list
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.replays);
        expect(nav.params['replayId'], isNull);
      });
    });

    // ==============================================================
    // MARKETPLACE NOTIFICATION TYPES TESTS
    // ==============================================================

    group('marketplace notification types', () {
      test('should have all marketplace notification types', () {
        expect(NotificationType.values,
            contains(NotificationType.marketplaceNewOffer));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceOfferAccepted));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceOfferRejected));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceItemSold));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceOrderConfirmed));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceLabelCreated));
        expect(NotificationType.values,
            contains(NotificationType.marketplacePackageShipped));
        expect(NotificationType.values,
            contains(NotificationType.marketplacePackageDelivered));
        expect(NotificationType.values,
            contains(NotificationType.marketplaceTransactionComplete));
      });

      test('should parse marketplace types from string', () {
        expect(
          NotificationTypeExtension.fromString('marketplaceNewOffer'),
          NotificationType.marketplaceNewOffer,
        );
        expect(
          NotificationTypeExtension.fromString('marketplaceOfferAccepted'),
          NotificationType.marketplaceOfferAccepted,
        );
        expect(
          NotificationTypeExtension.fromString('marketplaceOfferRejected'),
          NotificationType.marketplaceOfferRejected,
        );
        expect(
          NotificationTypeExtension.fromString('marketplaceItemSold'),
          NotificationType.marketplaceItemSold,
        );
        expect(
          NotificationTypeExtension.fromString('marketplaceOrderConfirmed'),
          NotificationType.marketplaceOrderConfirmed,
        );
        expect(
          NotificationTypeExtension.fromString('marketplaceLabelCreated'),
          NotificationType.marketplaceLabelCreated,
        );
        expect(
          NotificationTypeExtension.fromString('marketplacePackageShipped'),
          NotificationType.marketplacePackageShipped,
        );
        expect(
          NotificationTypeExtension.fromString('marketplacePackageDelivered'),
          NotificationType.marketplacePackageDelivered,
        );
        expect(
          NotificationTypeExtension.fromString(
              'marketplaceTransactionComplete'),
          NotificationType.marketplaceTransactionComplete,
        );
      });

      test('should create notification from JSON with marketplace type', () {
        final notification = AppNotification.fromJson(const {
          'id': 'notif-mp-1',
          'type': 'marketplaceNewOffer',
          'title': 'New offer received',
          'body': 'You received an offer on your listing',
          'data': {'listing_id': 'listing-abc'},
          'created_at': '2025-01-24T10:00:00Z',
        });

        expect(notification.type, NotificationType.marketplaceNewOffer);
        expect(notification.data['listing_id'], 'listing-abc');
      });
    });

    group('marketplace notification types - have all routes', () {
      test('should have marketplace routes', () {
        expect(NotificationRoute.values,
            contains(NotificationRoute.marketplaceSellerTransaction));
        expect(NotificationRoute.values,
            contains(NotificationRoute.marketplaceBuyerTransaction));
        expect(NotificationRoute.values,
            contains(NotificationRoute.marketplaceListing));
        expect(NotificationRoute.values,
            contains(NotificationRoute.marketplaceOffers));
        expect(NotificationRoute.values,
            contains(NotificationRoute.marketplaceChat));
      });
    });

    group('marketplace navigation', () {
      test(
          'marketplaceNewOffer should navigate to offers with listingId',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceNewOffer,
          title: 'New offer',
          body: 'Body',
          data: const {'listing_id': 'listing-abc'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceOffers);
        expect(nav.params['listingId'], 'listing-abc');
      });

      test('marketplaceNewOffer should return null when listing_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceNewOffer,
          title: 'New offer',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });

      test(
          'marketplaceOfferAccepted should navigate to listing with listingId',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceOfferAccepted,
          title: 'Offer accepted',
          body: 'Body',
          data: const {'listing_id': 'listing-xyz'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceListing);
        expect(nav.params['listingId'], 'listing-xyz');
      });

      test(
          'marketplaceOfferRejected should navigate to listing with listingId',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceOfferRejected,
          title: 'Offer rejected',
          body: 'Body',
          data: const {'listing_id': 'listing-xyz'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceListing);
        expect(nav.params['listingId'], 'listing-xyz');
      });

      test(
          'marketplaceOfferAccepted should return null when listing_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceOfferAccepted,
          title: 'Offer accepted',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });

      test(
          'marketplaceItemSold should navigate to seller transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceItemSold,
          title: 'Item sold',
          body: 'Body',
          data: const {'transaction_id': 'tx-123'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceSellerTransaction);
        expect(nav.params['transactionId'], 'tx-123');
      });

      test(
          'marketplaceLabelCreated should navigate to seller transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceLabelCreated,
          title: 'Label created',
          body: 'Body',
          data: const {'transaction_id': 'tx-456'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceSellerTransaction);
        expect(nav.params['transactionId'], 'tx-456');
      });

      test(
          'marketplaceItemSold should return null when transaction_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceItemSold,
          title: 'Item sold',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });

      test(
          'marketplaceOrderConfirmed should navigate to buyer transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceOrderConfirmed,
          title: 'Order confirmed',
          body: 'Body',
          data: const {'transaction_id': 'tx-789'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceBuyerTransaction);
        expect(nav.params['transactionId'], 'tx-789');
      });

      test(
          'marketplacePackageShipped should navigate to buyer transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplacePackageShipped,
          title: 'Package shipped',
          body: 'Body',
          data: const {'transaction_id': 'tx-ship'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceBuyerTransaction);
        expect(nav.params['transactionId'], 'tx-ship');
      });

      test(
          'marketplacePackageDelivered should navigate to buyer transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplacePackageDelivered,
          title: 'Package delivered',
          body: 'Body',
          data: const {'transaction_id': 'tx-deliv'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceBuyerTransaction);
        expect(nav.params['transactionId'], 'tx-deliv');
      });

      test(
          'marketplaceTransactionComplete should navigate to buyer transaction',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceTransactionComplete,
          title: 'Transaction complete',
          body: 'Body',
          data: const {'transaction_id': 'tx-done'},
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceBuyerTransaction);
        expect(nav.params['transactionId'], 'tx-done');
      });

      test(
          'marketplaceOrderConfirmed should return null when transaction_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceOrderConfirmed,
          title: 'Order confirmed',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });

      test(
          'marketplaceNewMessage should navigate to marketplace chat with listingId and otherUserId',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceNewMessage,
          title: 'New marketplace message',
          body: 'Body',
          data: const {
            'listing_id': 'listing-abc',
            'sender_profile_id': 'user-xyz',
          },
          createdAt: testDateTime,
        );

        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.marketplaceChat);
        expect(nav.params['listingId'], 'listing-abc');
        expect(nav.params['otherUserId'], 'user-xyz');
      });

      test(
          'marketplaceNewMessage should return null when listing_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceNewMessage,
          title: 'New marketplace message',
          body: 'Body',
          data: const {'sender_profile_id': 'user-xyz'},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });

      test(
          'marketplaceNewMessage should return null when sender_profile_id missing',
          () {
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.marketplaceNewMessage,
          title: 'New marketplace message',
          body: 'Body',
          data: const {'listing_id': 'listing-abc'},
          createdAt: testDateTime,
        );

        expect(notification.navigation, isNull);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final notification = AppNotification(
          id: 'notif-123',
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'Body',
          data: const {},
          createdAt: testDateTime,
        );

        final result = notification.toString();

        expect(result, contains('AppNotification'));
        expect(result, contains('notif-123'));
        expect(result, contains('chatMessage'));
      });
    });
  });
}
