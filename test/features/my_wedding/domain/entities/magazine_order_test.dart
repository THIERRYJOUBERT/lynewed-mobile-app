/// Tests for MagazineOrder entity.
///
/// Comprehensive tests for order entity and computed properties.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/design.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_order.dart';

void main() {
  group('MagazineOrder', () {
    final testJson = {
      'id': 'order-123',
      'wedding_id': 'wedding-456',
      'magazine_format': 'iconic',
      'magazine_price_cents': 5900,
      'shipping_cost_cents': 1500,
      'total_paid_cents': 7400,
      'currency': 'USD',
      'status': 'paid',
      'photo_count': 25,
      'magazine_title': 'John & Jane Wedding',
      'created_at': '2026-02-01T10:00:00',
      'paid_at': '2026-02-01T10:05:00',
      'production_started_at': null,
      'shipped_at': null,
      'delivered_at': null,
      'shipping_name': 'Jane Doe',
      'shipping_address_line1': '123 Main Street',
      'shipping_address_line2': 'Apt 4B',
      'shipping_city': 'New York',
      'shipping_zip': '10001',
      'shipping_country': 'US',
      'shipping_phone': '+1234567890',
      'tracking_number': null,
      'tracking_url': null,
    };

    group('fromJson', () {
      test('should parse all required fields', () {
        final order = MagazineOrder.fromJson(testJson);

        expect(order.id, 'order-123');
        expect(order.weddingId, 'wedding-456');
        expect(order.magazineFormat, 'iconic');
        expect(order.magazinePriceCents, 5900);
        expect(order.shippingCostCents, 1500);
        expect(order.totalPaidCents, 7400);
        expect(order.currency, 'USD');
        expect(order.status, 'paid');
        expect(order.photoCount, 25);
        expect(order.magazineTitle, 'John & Jane Wedding');
      });

      test('should parse timestamps', () {
        final order = MagazineOrder.fromJson(testJson);

        expect(order.createdAt, DateTime(2026, 2, 1, 10, 0));
        expect(order.paidAt, DateTime(2026, 2, 1, 10, 5));
        expect(order.productionStartedAt, isNull);
        expect(order.shippedAt, isNull);
        expect(order.deliveredAt, isNull);
      });

      test('should parse shipping info', () {
        final order = MagazineOrder.fromJson(testJson);

        expect(order.shippingName, 'Jane Doe');
        expect(order.shippingAddressLine1, '123 Main Street');
        expect(order.shippingAddressLine2, 'Apt 4B');
        expect(order.shippingCity, 'New York');
        expect(order.shippingZip, '10001');
        expect(order.shippingCountry, 'US');
        expect(order.shippingPhone, '+1234567890');
      });

      test('should handle null optional fields', () {
        final order = MagazineOrder.fromJson(testJson);

        expect(order.trackingNumber, isNull);
        expect(order.trackingUrl, isNull);
      });

      test('should default currency to USD when missing', () {
        final json = Map<String, dynamic>.from(testJson);
        json.remove('currency');
        final order = MagazineOrder.fromJson(json);

        expect(order.currency, 'USD');
      });
    });

    group('formatDisplayName', () {
      test('should return ICONIC for iconic format', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.formatDisplayName, 'ICONIC');
      });

      test('should return GUEST EDITION for guest_edition format', () {
        final json = Map<String, dynamic>.from(testJson);
        json['magazine_format'] = 'guest_edition';
        final order = MagazineOrder.fromJson(json);
        expect(order.formatDisplayName, 'GUEST EDITION');
      });

      test('should return MEMORY for memory format', () {
        final json = Map<String, dynamic>.from(testJson);
        json['magazine_format'] = 'memory';
        final order = MagazineOrder.fromJson(json);
        expect(order.formatDisplayName, 'MEMORY');
      });

      test('should return COLLECTOR for collector format', () {
        final json = Map<String, dynamic>.from(testJson);
        json['magazine_format'] = 'collector';
        final order = MagazineOrder.fromJson(json);
        expect(order.formatDisplayName, 'COLLECTOR');
      });

      test('should fallback to uppercase for unknown format', () {
        final json = Map<String, dynamic>.from(testJson);
        json['magazine_format'] = 'deluxe';
        final order = MagazineOrder.fromJson(json);
        expect(order.formatDisplayName, 'DELUXE');
      });
    });

    group('formatSize', () {
      test('should return 21x30cm for iconic', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.formatSize, '21x30cm');
      });

      test('should return 25x32cm for collector', () {
        final json = Map<String, dynamic>.from(testJson);
        json['magazine_format'] = 'collector';
        final order = MagazineOrder.fromJson(json);
        expect(order.formatSize, '25x32cm');
      });
    });

    group('statusLabel', () {
      test('should return Order Confirmed for paid', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.statusLabel, 'Order Confirmed');
      });

      test('should return In Production for in_production', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'in_production';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusLabel, 'In Production');
      });

      test('should return Shipped for shipped', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'shipped';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusLabel, 'Shipped');
      });

      test('should return Delivered for delivered', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'delivered';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusLabel, 'Delivered');
      });

      test('should return Cancelled for cancelled', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'cancelled';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusLabel, 'Cancelled');
      });
    });

    group('statusColor', () {
      test('should return success for paid', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.statusColor, LynewedColors.success);
      });

      test('should return primary for in_production', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'in_production';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusColor, LynewedColors.primary);
      });

      test('should return blue for shipped', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'shipped';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusColor, const Color(0xFF2196F3));
      });

      test('should return error for cancelled', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'cancelled';
        final order = MagazineOrder.fromJson(json);
        expect(order.statusColor, LynewedColors.error);
      });
    });

    group('formatted prices', () {
      test('should format total price', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.formattedTotal, r'$74.00');
      });

      test('should format magazine price', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.formattedMagazinePrice, r'$59.00');
      });

      test('should format shipping cost', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.formattedShippingCost, r'$15.00');
      });

      test('should handle prices with cents', () {
        final json = Map<String, dynamic>.from(testJson);
        json['total_paid_cents'] = 7450;
        final order = MagazineOrder.fromJson(json);
        expect(order.formattedTotal, r'$74.50');
      });
    });

    group('status progression flags', () {
      test('paid status should have isPaid true only', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.isPaid, true);
        expect(order.isInProduction, false);
        expect(order.isShipped, false);
        expect(order.isDelivered, false);
        expect(order.isCancelled, false);
      });

      test('in_production status should have isPaid and isInProduction true', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'in_production';
        final order = MagazineOrder.fromJson(json);
        expect(order.isPaid, true);
        expect(order.isInProduction, true);
        expect(order.isShipped, false);
        expect(order.isDelivered, false);
      });

      test('shipped status should have isPaid, isInProduction, isShipped true', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'shipped';
        final order = MagazineOrder.fromJson(json);
        expect(order.isPaid, true);
        expect(order.isInProduction, true);
        expect(order.isShipped, true);
        expect(order.isDelivered, false);
      });

      test('delivered status should have all progression flags true', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'delivered';
        final order = MagazineOrder.fromJson(json);
        expect(order.isPaid, true);
        expect(order.isInProduction, true);
        expect(order.isShipped, true);
        expect(order.isDelivered, true);
      });

      test('cancelled status should have only isCancelled true', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'cancelled';
        final order = MagazineOrder.fromJson(json);
        expect(order.isPaid, false);
        expect(order.isInProduction, false);
        expect(order.isShipped, false);
        expect(order.isDelivered, false);
        expect(order.isCancelled, true);
      });

      test('pending status should have no flags true', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'pending';
        final order = MagazineOrder.fromJson(json);
        expect(order.isPaid, false);
        expect(order.isInProduction, false);
        expect(order.isShipped, false);
        expect(order.isDelivered, false);
        expect(order.isCancelled, false);
      });
    });

    group('currentStepIndex', () {
      test('should return 0 for paid', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(order.currentStepIndex, 0);
      });

      test('should return 1 for in_production', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'in_production';
        final order = MagazineOrder.fromJson(json);
        expect(order.currentStepIndex, 1);
      });

      test('should return 2 for shipped', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'shipped';
        final order = MagazineOrder.fromJson(json);
        expect(order.currentStepIndex, 2);
      });

      test('should return 3 for delivered', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'delivered';
        final order = MagazineOrder.fromJson(json);
        expect(order.currentStepIndex, 3);
      });

      test('should return -1 for pending', () {
        final json = Map<String, dynamic>.from(testJson);
        json['status'] = 'pending';
        final order = MagazineOrder.fromJson(json);
        expect(order.currentStepIndex, -1);
      });
    });

    group('formattedShippingAddress', () {
      test('should format full address with all fields', () {
        final order = MagazineOrder.fromJson(testJson);
        expect(
          order.formattedShippingAddress,
          'Jane Doe\n123 Main Street\nApt 4B\n10001 New York, US',
        );
      });

      test('should omit line2 when null', () {
        final json = Map<String, dynamic>.from(testJson);
        json['shipping_address_line2'] = null;
        final order = MagazineOrder.fromJson(json);
        expect(
          order.formattedShippingAddress,
          'Jane Doe\n123 Main Street\n10001 New York, US',
        );
      });

      test('should omit line2 when empty', () {
        final json = Map<String, dynamic>.from(testJson);
        json['shipping_address_line2'] = '';
        final order = MagazineOrder.fromJson(json);
        expect(
          order.formattedShippingAddress,
          'Jane Doe\n123 Main Street\n10001 New York, US',
        );
      });

      test('should handle minimal address (name + city only)', () {
        final json = Map<String, dynamic>.from(testJson);
        json['shipping_address_line1'] = null;
        json['shipping_address_line2'] = null;
        json['shipping_zip'] = null;
        json['shipping_country'] = null;
        json['shipping_phone'] = null;
        final order = MagazineOrder.fromJson(json);
        expect(
          order.formattedShippingAddress,
          'Jane Doe\nNew York',
        );
      });
    });

    group('equality', () {
      test('should be equal when id and status match', () {
        final order1 = MagazineOrder.fromJson(testJson);
        final order2 = MagazineOrder.fromJson(testJson);
        expect(order1, equals(order2));
      });

      test('should not be equal when id differs', () {
        final json2 = Map<String, dynamic>.from(testJson);
        json2['id'] = 'order-999';
        final order1 = MagazineOrder.fromJson(testJson);
        final order2 = MagazineOrder.fromJson(json2);
        expect(order1, isNot(equals(order2)));
      });

      test('should have same hashCode for equal orders', () {
        final order1 = MagazineOrder.fromJson(testJson);
        final order2 = MagazineOrder.fromJson(testJson);
        expect(order1.hashCode, equals(order2.hashCode));
      });
    });
  });
}
