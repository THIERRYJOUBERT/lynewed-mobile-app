import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/payments/domain/entities/product_type.dart';

void main() {
  group('ProductType', () {
    group('fromString', () {
      test('should return marketplaceItem for "marketplace_item"', () {
        expect(ProductType.fromString('marketplace_item'),
            ProductType.marketplaceItem);
      });

      test('should return magazine for "magazine"', () {
        expect(ProductType.fromString('magazine'), ProductType.magazine);
      });

      test('should return album for "album"', () {
        expect(ProductType.fromString('album'), ProductType.album);
      });

      test('should return print for "print"', () {
        expect(ProductType.fromString('print'), ProductType.print);
      });

      test('should return subscription for "subscription"', () {
        expect(
            ProductType.fromString('subscription'), ProductType.subscription);
      });

      test('should return marketplaceItem for unknown value', () {
        expect(ProductType.fromString('unknown'), ProductType.marketplaceItem);
      });
    });

    group('toJson', () {
      test('should return "marketplace_item" for marketplaceItem', () {
        expect(ProductType.marketplaceItem.toJson(), 'marketplace_item');
      });

      test('should return "magazine" for magazine', () {
        expect(ProductType.magazine.toJson(), 'magazine');
      });

      test('should return "album" for album', () {
        expect(ProductType.album.toJson(), 'album');
      });

      test('should return "print" for print', () {
        expect(ProductType.print.toJson(), 'print');
      });

      test('should return "subscription" for subscription', () {
        expect(ProductType.subscription.toJson(), 'subscription');
      });
    });

    group('hasSeller', () {
      test('should return true for marketplaceItem', () {
        expect(ProductType.marketplaceItem.hasSeller, true);
      });

      test('should return false for magazine', () {
        expect(ProductType.magazine.hasSeller, false);
      });

      test('should return false for album', () {
        expect(ProductType.album.hasSeller, false);
      });

      test('should return false for subscription', () {
        expect(ProductType.subscription.hasSeller, false);
      });
    });

    group('isDigital', () {
      test('should return true for magazine', () {
        expect(ProductType.magazine.isDigital, true);
      });

      test('should return true for album', () {
        expect(ProductType.album.isDigital, true);
      });

      test('should return true for subscription', () {
        expect(ProductType.subscription.isDigital, true);
      });

      test('should return false for marketplaceItem', () {
        expect(ProductType.marketplaceItem.isDigital, false);
      });

      test('should return false for print', () {
        expect(ProductType.print.isDigital, false);
      });
    });

    group('requiresShipping', () {
      test('should return true for marketplaceItem', () {
        expect(ProductType.marketplaceItem.requiresShipping, true);
      });

      test('should return true for print', () {
        expect(ProductType.print.requiresShipping, true);
      });

      test('should return false for magazine', () {
        expect(ProductType.magazine.requiresShipping, false);
      });

      test('should return false for album', () {
        expect(ProductType.album.requiresShipping, false);
      });

      test('should return false for subscription', () {
        expect(ProductType.subscription.requiresShipping, false);
      });
    });

    group('displayName', () {
      test('should return correct display names', () {
        expect(ProductType.marketplaceItem.displayName, 'Marketplace Item');
        expect(ProductType.magazine.displayName, 'Magazine');
        expect(ProductType.album.displayName, 'Album');
        expect(ProductType.print.displayName, 'Print');
        expect(ProductType.subscription.displayName, 'Subscription');
      });
    });
  });
}
