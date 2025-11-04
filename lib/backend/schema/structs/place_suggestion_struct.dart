// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlaceSuggestionStruct extends BaseStruct {
  PlaceSuggestionStruct({
    String? placeId,
    String? primaryText,
    String? secondaryText,
  })  : _placeId = placeId,
        _primaryText = primaryText,
        _secondaryText = secondaryText;

  // "placeId" field.
  String? _placeId;
  String get placeId => _placeId ?? '';
  set placeId(String? val) => _placeId = val;

  bool hasPlaceId() => _placeId != null;

  // "primaryText" field.
  String? _primaryText;
  String get primaryText => _primaryText ?? '';
  set primaryText(String? val) => _primaryText = val;

  bool hasPrimaryText() => _primaryText != null;

  // "secondaryText" field.
  String? _secondaryText;
  String get secondaryText => _secondaryText ?? '';
  set secondaryText(String? val) => _secondaryText = val;

  bool hasSecondaryText() => _secondaryText != null;

  static PlaceSuggestionStruct fromMap(Map<String, dynamic> data) =>
      PlaceSuggestionStruct(
        placeId: data['placeId'] as String?,
        primaryText: data['primaryText'] as String?,
        secondaryText: data['secondaryText'] as String?,
      );

  static PlaceSuggestionStruct? maybeFromMap(dynamic data) => data is Map
      ? PlaceSuggestionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'placeId': _placeId,
        'primaryText': _primaryText,
        'secondaryText': _secondaryText,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'placeId': serializeParam(
          _placeId,
          ParamType.String,
        ),
        'primaryText': serializeParam(
          _primaryText,
          ParamType.String,
        ),
        'secondaryText': serializeParam(
          _secondaryText,
          ParamType.String,
        ),
      }.withoutNulls;

  static PlaceSuggestionStruct fromSerializableMap(Map<String, dynamic> data) =>
      PlaceSuggestionStruct(
        placeId: deserializeParam(
          data['placeId'],
          ParamType.String,
          false,
        ),
        primaryText: deserializeParam(
          data['primaryText'],
          ParamType.String,
          false,
        ),
        secondaryText: deserializeParam(
          data['secondaryText'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PlaceSuggestionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PlaceSuggestionStruct &&
        placeId == other.placeId &&
        primaryText == other.primaryText &&
        secondaryText == other.secondaryText;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([placeId, primaryText, secondaryText]);
}

PlaceSuggestionStruct createPlaceSuggestionStruct({
  String? placeId,
  String? primaryText,
  String? secondaryText,
}) =>
    PlaceSuggestionStruct(
      placeId: placeId,
      primaryText: primaryText,
      secondaryText: secondaryText,
    );
