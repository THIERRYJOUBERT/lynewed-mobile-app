/// ProductType enum for categorizing purchases.
///
/// Represents the type of product being purchased.
/// Maps directly to the `product_type` column in the `purchases` table.
library;

/// Type of product in a purchase transaction.
enum ProductType {
  /// Item from the marketplace (resale, handmade, etc.).
  marketplaceItem,

  /// Photo magazine.
  magazine,

  /// Photo album.
  album,

  /// Printed photo or art.
  print,

  /// Subscription plan.
  subscription;

  /// Creates a ProductType from a database string value.
  static ProductType fromString(String value) {
    switch (value) {
      case 'marketplace_item':
        return ProductType.marketplaceItem;
      case 'magazine':
        return ProductType.magazine;
      case 'album':
        return ProductType.album;
      case 'print':
        return ProductType.print;
      case 'subscription':
        return ProductType.subscription;
      default:
        return ProductType.marketplaceItem;
    }
  }

  /// Converts to database string value.
  String toJson() {
    switch (this) {
      case ProductType.marketplaceItem:
        return 'marketplace_item';
      case ProductType.magazine:
        return 'magazine';
      case ProductType.album:
        return 'album';
      case ProductType.print:
        return 'print';
      case ProductType.subscription:
        return 'subscription';
    }
  }
}

/// Extension to add computed properties to ProductType.
extension ProductTypeExtension on ProductType {
  /// Whether this product type involves a seller (marketplace).
  bool get hasSeller => this == ProductType.marketplaceItem;

  /// Whether this is a digital product.
  bool get isDigital =>
      this == ProductType.magazine ||
      this == ProductType.album ||
      this == ProductType.subscription;

  /// Whether this requires shipping.
  bool get requiresShipping =>
      this == ProductType.marketplaceItem || this == ProductType.print;

  /// Display name for the product type.
  String get displayName {
    switch (this) {
      case ProductType.marketplaceItem:
        return 'Marketplace Item';
      case ProductType.magazine:
        return 'Magazine';
      case ProductType.album:
        return 'Album';
      case ProductType.print:
        return 'Print';
      case ProductType.subscription:
        return 'Subscription';
    }
  }
}
