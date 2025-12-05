// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Represents an upcoming travel for a professional
class UpcomingTravelStruct extends BaseStruct {
  UpcomingTravelStruct({
    String? id,
    String? location,
    String? startDate,
    String? endDate,
    String? createdAt,
  })  : _id = id,
        _location = location,
        _startDate = startDate,
        _endDate = endDate,
        _createdAt = createdAt;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;
  bool hasId() => _id != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  set location(String? val) => _location = val;
  bool hasLocation() => _location != null;

  // "startDate" field.
  String? _startDate;
  String get startDate => _startDate ?? '';
  set startDate(String? val) => _startDate = val;
  bool hasStartDate() => _startDate != null;

  // "endDate" field.
  String? _endDate;
  String get endDate => _endDate ?? '';
  set endDate(String? val) => _endDate = val;
  bool hasEndDate() => _endDate != null;

  // "createdAt" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;
  bool hasCreatedAt() => _createdAt != null;

  static UpcomingTravelStruct fromMap(Map<String, dynamic> data) =>
      UpcomingTravelStruct(
        id: data['id'] as String?,
        location: data['location'] as String?,
        startDate: data['start_date'] as String?,
        endDate: data['end_date'] as String?,
        createdAt: data['created_at'] as String?,
      );

  static UpcomingTravelStruct? maybeFromMap(dynamic data) => data is Map
      ? UpcomingTravelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'location': _location,
        'start_date': _startDate,
        'end_date': _endDate,
        'created_at': _createdAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.String),
        'location': serializeParam(_location, ParamType.String),
        'startDate': serializeParam(_startDate, ParamType.String),
        'endDate': serializeParam(_endDate, ParamType.String),
        'createdAt': serializeParam(_createdAt, ParamType.String),
      }.withoutNulls;

  static UpcomingTravelStruct fromSerializableMap(Map<String, dynamic> data) =>
      UpcomingTravelStruct(
        id: deserializeParam(data['id'], ParamType.String, false),
        location: deserializeParam(data['location'], ParamType.String, false),
        startDate: deserializeParam(data['startDate'], ParamType.String, false),
        endDate: deserializeParam(data['endDate'], ParamType.String, false),
        createdAt: deserializeParam(data['createdAt'], ParamType.String, false),
      );

  @override
  String toString() => 'UpcomingTravelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UpcomingTravelStruct &&
        id == other.id &&
        location == other.location &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(id, location, startDate, endDate, createdAt);
}

UpcomingTravelStruct createUpcomingTravelStruct({
  String? id,
  String? location,
  String? startDate,
  String? endDate,
  String? createdAt,
}) =>
    UpcomingTravelStruct(
      id: id,
      location: location,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
    );
