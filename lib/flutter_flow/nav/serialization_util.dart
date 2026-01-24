// ignore_for_file: constant_identifier_names
// FlutterFlow legacy: ParamType enum values match type names (PascalCase)

import 'dart:convert';

import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final startStr = dateTimeRange.start.millisecondsSinceEpoch.toString();
  final endStr = dateTimeRange.end.millisecondsSinceEpoch.toString();
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final serializedValues = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .where((p) => p != null)
          .map((p) => p!)
          .toList();
      return json.encode(serializedValues);
    }
    String? data;
    switch (paramType) {
      case ParamType.int:
        data = param.toString();
      case ParamType.double:
        data = param.toString();
      case ParamType.String:
        data = param;
      case ParamType.bool:
        data = param ? 'true' : 'false';
      case ParamType.DateTime:
        data = (param as DateTime).millisecondsSinceEpoch.toString();
      case ParamType.DateTimeRange:
        data = dateTimeRangeToString(param as DateTimeRange);
      case ParamType.LatLng:
        data = (param as LatLng).serialize();
      case ParamType.Color:
        data = (param as Color).toCssString();
      case ParamType.FFPlace:
        data = placeToString(param as FFPlace);
      case ParamType.FFUploadedFile:
        data = uploadedFileToString(param as FFUploadedFile);
      case ParamType.JSON:
        data = json.encode(param);

      case ParamType.DataStruct:
        data = param is BaseStruct ? param.serialize() : null;

      case ParamType.Enum:
        data = (param is Enum) ? param.serialize() : null;

      case ParamType.SupabaseRow:
        return json.encode((param as SupabaseDataRow).data);

      default:
        data = null;
    }
    return data;
  } catch (e) {
    return null;
  }
}

/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  return DateTimeRange(
    start: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.first)),
    end: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.last)),
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0.0, 0.0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  DateTimeRange,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,

  DataStruct,
  Enum,
  SupabaseRow,

  CustomClass,
  CustomEnum,
}

dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList, {
  StructBuilder<T>? structBuilder,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramValues = json.decode(param);
      if (paramValues is! Iterable || paramValues.isEmpty) {
        return null;
      }
      return paramValues
          .whereType<String>()
          .map((p) => p)
          .map((p) => deserializeParam<T>(
                p,
                paramType,
                false,
                structBuilder: structBuilder,
              ))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }
    switch (paramType) {
      case ParamType.int:
        return int.tryParse(param);
      case ParamType.double:
        return double.tryParse(param);
      case ParamType.String:
        return param;
      case ParamType.bool:
        return param == 'true';
      case ParamType.DateTime:
        final milliseconds = int.tryParse(param);
        return milliseconds != null
            ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
            : null;
      case ParamType.DateTimeRange:
        return dateTimeRangeFromString(param);
      case ParamType.LatLng:
        return latLngFromString(param);
      case ParamType.Color:
        return fromCssColor(param);
      case ParamType.FFPlace:
        return placeFromString(param);
      case ParamType.FFUploadedFile:
        return uploadedFileFromString(param);
      case ParamType.JSON:
        return json.decode(param);

      case ParamType.SupabaseRow:
        final data = json.decode(param) as Map<String, dynamic>;
        switch (T) {
          case const (ProfessionalAlertsRow):
            return ProfessionalAlertsRow(data);
          case const (SpatialRefSysRow):
            return SpatialRefSysRow(data);
          case const (VideoSessionsRow):
            return VideoSessionsRow(data);
          case const (WeddingPinsHistoryRow):
            return WeddingPinsHistoryRow(data);
          case const (ProRecentLocationsRow):
            return ProRecentLocationsRow(data);
          case const (NotificationSettingsRow):
            return NotificationSettingsRow(data);
          case const (ConnectionRequestsRow):
            return ConnectionRequestsRow(data);
          case const (ChatRoomsRow):
            return ChatRoomsRow(data);
          case const (ChatMessagesRow):
            return ChatMessagesRow(data);
          case const (PublicProfessionalsRow):
            return PublicProfessionalsRow(data);
          case const (SyncLogRow):
            return SyncLogRow(data);
          case const (UserPreferencesRow):
            return UserPreferencesRow(data);
          case const (GeometryColumnsRow):
            return GeometryColumnsRow(data);
          case const (BrideDetailsRow):
            return BrideDetailsRow(data);
          case const (UserPoisHistoryRow):
            return UserPoisHistoryRow(data);
          case const (AlertMotifsRow):
            return AlertMotifsRow(data);
          case const (StripeEventsLogRow):
            return StripeEventsLogRow(data);
          case const (ProfilesRow):
            return ProfilesRow(data);
          case const (ProfessionalDetailsRow):
            return ProfessionalDetailsRow(data);
          case const (WishlistItemsRow):
            return WishlistItemsRow(data);
          case const (ChatRoomParticipantsRow):
            return ChatRoomParticipantsRow(data);
          case const (SyncControlRow):
            return SyncControlRow(data);
          case const (ReplayGuestsRow):
            return ReplayGuestsRow(data);
          case const (ReportsRow):
            return ReportsRow(data);
          case const (NotificationsOutboxRow):
            return NotificationsOutboxRow(data);
          case const (CountriesRow):
            return CountriesRow(data);
          case const (ReplaysRow):
            return ReplaysRow(data);
          case const (FxRatesRow):
            return FxRatesRow(data);
          case const (ReplayGuestAssignmentsRow):
            return ReplayGuestAssignmentsRow(data);
          case const (ProfessionalSubscriptionsRow):
            return ProfessionalSubscriptionsRow(data);
          case const (PublicProfilesRow):
            return PublicProfilesRow(data);
          case const (GeographyColumnsRow):
            return GeographyColumnsRow(data);
          case const (ContentRow):
            return ContentRow(data);
          case const (PublicChatRoomsRow):
            return PublicChatRoomsRow(data);
          case const (PublicWeddingPinsRow):
            return PublicWeddingPinsRow(data);
          case const (DeviceTokensRow):
            return DeviceTokensRow(data);
          case const (DeletedUsersLogRow):
            return DeletedUsersLogRow(data);
          case const (UserBlocksRow):
            return UserBlocksRow(data);
          case const (ProfessionalFixedLocationsRow):
            return ProfessionalFixedLocationsRow(data);
          case const (UserPoisRow):
            return UserPoisRow(data);
          case const (UserLegalAcceptancesRow):
            return UserLegalAcceptancesRow(data);
          case const (WedArticlesRow):
            return WedArticlesRow(data);
          case const (NotificationsRow):
            return NotificationsRow(data);
          case const (WeddingPinsRow):
            return WeddingPinsRow(data);
          default:
            return null;
        }

      case ParamType.DataStruct:
        final data = json.decode(param) as Map<String, dynamic>? ?? {};
        return structBuilder != null ? structBuilder(data) : null;

      case ParamType.Enum:
        return deserializeEnum<T>(param);

      default:
        return null;
    }
  } catch (e) {
    return null;
  }
}
