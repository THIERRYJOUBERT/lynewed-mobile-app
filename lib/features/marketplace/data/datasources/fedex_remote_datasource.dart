/// Datasource for FedEx operations via Supabase Edge Functions.
///
/// Handles communication with fedex-calculate-rate, fedex-create-shipment
/// Edge Functions and reads tracking events from the fedex_events table.
library;

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/shipping_label.dart';
import '../../domain/entities/shipping_rate.dart';
import '../../domain/entities/tracking_event.dart';

/// Abstract interface for FedEx datasource operations.
abstract class FedExRemoteDatasource {
  /// Calculates shipping rates for a package between two addresses.
  ///
  /// Calls the `fedex-calculate-rate` Edge Function.
  /// Returns a list of available shipping rate options.
  ///
  /// Throws [FunctionException] if the Edge Function call fails.
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
    double? weightKg,
  });

  /// Creates a shipment and generates a shipping label.
  ///
  /// Calls the `fedex-create-shipment` Edge Function.
  /// Returns the shipping label with tracking number and PDF URL.
  ///
  /// Throws [FunctionException] if the Edge Function call fails.
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  });

  /// Gets tracking events for a transaction from the fedex_events table.
  ///
  /// Reads from the `fedex_events` database table (NOT an Edge Function).
  /// Returns events ordered by event_timestamp ascending.
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId);

  /// Cancels a shipment (voids the shipping label).
  ///
  /// Calls the `fedex-cancel-shipment` Edge Function.
  /// Throws [FunctionException] if the Edge Function call fails.
  Future<void> cancelShipment(String transactionId);
}

/// Supabase implementation of [FedExRemoteDatasource].
///
/// Uses [SupabaseClient.functions] for Edge Function calls and
/// [SupabaseClient] table queries for tracking events.
class SupabaseFedExRemoteDatasource implements FedExRemoteDatasource {
  final SupabaseClient _supabase;

  /// Creates a datasource with the given Supabase client.
  SupabaseFedExRemoteDatasource(this._supabase);

  @override
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
    double? weightKg,
  }) async {
    final response = await _supabase.functions.invoke(
      'fedex-calculate-rate',
      body: {
        'from_address': fromAddress.toFedExJson(),
        'to_address': toAddress.toFedExJson(),
        'category': category,
        if (weightKg != null) 'package_weight_kg': weightKg,
      },
    );

    final data = _parseResponseData(response.data);
    final rates = data['rates'] as List;

    return rates
        .map(
          (r) => ShippingRate.fromJson(Map<String, dynamic>.from(r as Map)),
        )
        .toList();
  }

  @override
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  }) async {
    final response = await _supabase.functions.invoke(
      'fedex-create-shipment',
      body: {
        'transaction_id': transactionId,
        'service_type': serviceType,
      },
    );

    final data = _parseResponseData(response.data);
    return ShippingLabel.fromJson(data);
  }

  @override
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId) async {
    final rows = await _supabase
        .from('fedex_events')
        .select()
        .eq('transaction_id', transactionId)
        .order('event_timestamp', ascending: true);

    return rows
        .map(
          (row) => TrackingEvent.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  @override
  Future<void> cancelShipment(String transactionId) async {
    final response = await _supabase.functions.invoke(
      'fedex-cancel-shipment',
      body: {'transaction_id': transactionId},
    );

    final data = _parseResponseData(response.data);
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }
  }

  /// Parses response data that may be a JSON string or a Map.
  Map<String, dynamic> _parseResponseData(dynamic data) {
    if (data is String) {
      return Map<String, dynamic>.from(jsonDecode(data) as Map);
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Unexpected response format from FedEx Edge Function');
    }
  }
}
