// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlacePredictionsResultStruct extends BaseStruct {
  PlacePredictionsResultStruct({
    List<PlaceSuggestionStruct>? suggestions,
    String? newSessionToken,
  })  : _suggestions = suggestions,
        _newSessionToken = newSessionToken;

  // "suggestions" field.
  List<PlaceSuggestionStruct>? _suggestions;
  List<PlaceSuggestionStruct> get suggestions => _suggestions ?? const [];
  set suggestions(List<PlaceSuggestionStruct>? val) => _suggestions = val;

  void updateSuggestions(Function(List<PlaceSuggestionStruct>) updateFn) {
    updateFn(_suggestions ??= []);
  }

  bool hasSuggestions() => _suggestions != null;

  // "newSessionToken" field.
  String? _newSessionToken;
  String get newSessionToken => _newSessionToken ?? '';
  set newSessionToken(String? val) => _newSessionToken = val;

  bool hasNewSessionToken() => _newSessionToken != null;

  static PlacePredictionsResultStruct fromMap(Map<String, dynamic> data) =>
      PlacePredictionsResultStruct(
        suggestions: getStructList(
          data['suggestions'],
          PlaceSuggestionStruct.fromMap,
        ),
        newSessionToken: data['newSessionToken'] as String?,
      );

  static PlacePredictionsResultStruct? maybeFromMap(dynamic data) => data is Map
      ? PlacePredictionsResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'suggestions': _suggestions?.map((e) => e.toMap()).toList(),
        'newSessionToken': _newSessionToken,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'suggestions': serializeParam(
          _suggestions,
          ParamType.DataStruct,
          isList: true,
        ),
        'newSessionToken': serializeParam(
          _newSessionToken,
          ParamType.String,
        ),
      }.withoutNulls;

  static PlacePredictionsResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      PlacePredictionsResultStruct(
        suggestions: deserializeStructParam<PlaceSuggestionStruct>(
          data['suggestions'],
          ParamType.DataStruct,
          true,
          structBuilder: PlaceSuggestionStruct.fromSerializableMap,
        ),
        newSessionToken: deserializeParam(
          data['newSessionToken'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PlacePredictionsResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PlacePredictionsResultStruct &&
        listEquality.equals(suggestions, other.suggestions) &&
        newSessionToken == other.newSessionToken;
  }

  @override
  int get hashCode => const ListEquality().hash([suggestions, newSessionToken]);
}

PlacePredictionsResultStruct createPlacePredictionsResultStruct({
  String? newSessionToken,
}) =>
    PlacePredictionsResultStruct(
      newSessionToken: newSessionToken,
    );
