/// Implementation of [FedExRepository].
///
/// Delegates all operations to the [FedExRemoteDatasource].
library;

import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/shipping_label.dart';
import '../../domain/entities/shipping_rate.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/repositories/fedex_repository.dart';
import '../datasources/fedex_remote_datasource.dart';

/// Supabase implementation of [FedExRepository].
///
/// Delegates to [FedExRemoteDatasource] for Edge Function calls
/// and database queries.
class FedExRepositoryImpl implements FedExRepository {
  final FedExRemoteDatasource _datasource;

  /// Creates a repository with the given datasource.
  FedExRepositoryImpl(this._datasource);

  @override
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
  }) async {
    return _datasource.calculateRates(
      fromAddress: fromAddress,
      toAddress: toAddress,
      category: category,
    );
  }

  @override
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  }) async {
    return _datasource.createShipment(
      transactionId: transactionId,
      serviceType: serviceType,
    );
  }

  @override
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId) async {
    return _datasource.getTrackingEvents(transactionId);
  }

  @override
  Future<void> cancelShipment(String transactionId) async {
    return _datasource.cancelShipment(transactionId);
  }
}
