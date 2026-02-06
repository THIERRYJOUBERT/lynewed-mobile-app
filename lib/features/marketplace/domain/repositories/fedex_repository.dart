/// Abstract repository interface for FedEx shipping operations.
///
/// Provides methods for calculating shipping rates, creating shipments,
/// and retrieving tracking events.
library;

import '../entities/shipping_address.dart';
import '../entities/shipping_label.dart';
import '../entities/shipping_rate.dart';
import '../entities/tracking_event.dart';

/// Repository interface for FedEx shipping operations.
abstract class FedExRepository {
  /// Calculates shipping rates between two addresses for a given category.
  ///
  /// Returns a list of available [ShippingRate] options.
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
  });

  /// Creates a shipment and generates a shipping label.
  ///
  /// Returns a [ShippingLabel] with tracking number and PDF URL.
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  });

  /// Gets tracking events for a given transaction.
  ///
  /// Returns a list of [TrackingEvent] ordered by timestamp ascending.
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId);

  /// Cancels a shipment (voids the shipping label).
  ///
  /// Only works when transaction status is 'label_created'.
  /// Reverts transaction to 'paid' status and clears FedEx fields.
  Future<void> cancelShipment(String transactionId);
}
