/// Use case for retrieving FedEx tracking events.
///
/// Calls the repository to get tracking events for a marketplace transaction
/// from the fedex_events table.
library;

import '../entities/tracking_event.dart';
import '../repositories/fedex_repository.dart';

/// Gets tracking events for a marketplace transaction.
///
/// Usage:
/// ```dart
/// final events = await getTrackingEvents(transaction.id);
/// for (final event in events) {
///   print('${event.eventType}: ${event.description}');
/// }
/// ```
class GetTrackingEventsUseCase {
  final FedExRepository _repository;

  /// Creates a use case with the given repository.
  GetTrackingEventsUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Returns a list of [TrackingEvent] ordered by timestamp ascending.
  Future<List<TrackingEvent>> call(String transactionId) async {
    return _repository.getTrackingEvents(transactionId);
  }
}
