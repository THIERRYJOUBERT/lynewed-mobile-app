// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AlertItemDataStruct extends BaseStruct {
  AlertItemDataStruct({
    String? alertId,
    String? motifCode,
    String? motifLabel,
    String? message,
    String? locationLabel,
    DateTime? startAt,
    DateTime? endAt,
    String? authorProfileId,
    String? authorAvatarUrl,
    String? authorFullName,
    Profession? authorProfession,
    bool? isOwn,
    bool? isContactable,
  })  : _alertId = alertId,
        _motifCode = motifCode,
        _motifLabel = motifLabel,
        _message = message,
        _locationLabel = locationLabel,
        _startAt = startAt,
        _endAt = endAt,
        _authorProfileId = authorProfileId,
        _authorAvatarUrl = authorAvatarUrl,
        _authorFullName = authorFullName,
        _authorProfession = authorProfession,
        _isOwn = isOwn,
        _isContactable = isContactable;

  // "alertId" field.
  String? _alertId;
  String get alertId => _alertId ?? '';
  set alertId(String? val) => _alertId = val;

  bool hasAlertId() => _alertId != null;

  // "motifCode" field.
  String? _motifCode;
  String get motifCode => _motifCode ?? '';
  set motifCode(String? val) => _motifCode = val;

  bool hasMotifCode() => _motifCode != null;

  // "motifLabel" field.
  String? _motifLabel;
  String get motifLabel => _motifLabel ?? '';
  set motifLabel(String? val) => _motifLabel = val;

  bool hasMotifLabel() => _motifLabel != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  set message(String? val) => _message = val;

  bool hasMessage() => _message != null;

  // "locationLabel" field.
  String? _locationLabel;
  String get locationLabel => _locationLabel ?? '';
  set locationLabel(String? val) => _locationLabel = val;

  bool hasLocationLabel() => _locationLabel != null;

  // "startAt" field.
  DateTime? _startAt;
  DateTime? get startAt => _startAt;
  set startAt(DateTime? val) => _startAt = val;

  bool hasStartAt() => _startAt != null;

  // "endAt" field.
  DateTime? _endAt;
  DateTime? get endAt => _endAt;
  set endAt(DateTime? val) => _endAt = val;

  bool hasEndAt() => _endAt != null;

  // "authorProfileId" field.
  String? _authorProfileId;
  String get authorProfileId => _authorProfileId ?? '';
  set authorProfileId(String? val) => _authorProfileId = val;

  bool hasAuthorProfileId() => _authorProfileId != null;

  // "authorAvatarUrl" field.
  String? _authorAvatarUrl;
  String get authorAvatarUrl => _authorAvatarUrl ?? '';
  set authorAvatarUrl(String? val) => _authorAvatarUrl = val;

  bool hasAuthorAvatarUrl() => _authorAvatarUrl != null;

  // "authorFullName" field.
  String? _authorFullName;
  String get authorFullName => _authorFullName ?? '';
  set authorFullName(String? val) => _authorFullName = val;

  bool hasAuthorFullName() => _authorFullName != null;

  // "authorProfession" field.
  Profession? _authorProfession;
  Profession? get authorProfession => _authorProfession;
  set authorProfession(Profession? val) => _authorProfession = val;

  bool hasAuthorProfession() => _authorProfession != null;

  // "isOwn" field.
  bool? _isOwn;
  bool get isOwn => _isOwn ?? false;
  set isOwn(bool? val) => _isOwn = val;

  bool hasIsOwn() => _isOwn != null;

  // "isContactable" field.
  bool? _isContactable;
  bool get isContactable => _isContactable ?? false;
  set isContactable(bool? val) => _isContactable = val;

  bool hasIsContactable() => _isContactable != null;

  static AlertItemDataStruct fromMap(Map<String, dynamic> data) =>
      AlertItemDataStruct(
        alertId: data['alertId'] as String?,
        motifCode: data['motifCode'] as String?,
        motifLabel: data['motifLabel'] as String?,
        message: data['message'] as String?,
        locationLabel: data['locationLabel'] as String?,
        startAt: data['startAt'] as DateTime?,
        endAt: data['endAt'] as DateTime?,
        authorProfileId: data['authorProfileId'] as String?,
        authorAvatarUrl: data['authorAvatarUrl'] as String?,
        authorFullName: data['authorFullName'] as String?,
        authorProfession: data['authorProfession'] is Profession
            ? data['authorProfession']
            : deserializeEnum<Profession>(data['authorProfession']),
        isOwn: data['isOwn'] as bool?,
        isContactable: data['isContactable'] as bool?,
      );

  static AlertItemDataStruct? maybeFromMap(dynamic data) => data is Map
      ? AlertItemDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'alertId': _alertId,
        'motifCode': _motifCode,
        'motifLabel': _motifLabel,
        'message': _message,
        'locationLabel': _locationLabel,
        'startAt': _startAt,
        'endAt': _endAt,
        'authorProfileId': _authorProfileId,
        'authorAvatarUrl': _authorAvatarUrl,
        'authorFullName': _authorFullName,
        'authorProfession': _authorProfession?.serialize(),
        'isOwn': _isOwn,
        'isContactable': _isContactable,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'alertId': serializeParam(
          _alertId,
          ParamType.String,
        ),
        'motifCode': serializeParam(
          _motifCode,
          ParamType.String,
        ),
        'motifLabel': serializeParam(
          _motifLabel,
          ParamType.String,
        ),
        'message': serializeParam(
          _message,
          ParamType.String,
        ),
        'locationLabel': serializeParam(
          _locationLabel,
          ParamType.String,
        ),
        'startAt': serializeParam(
          _startAt,
          ParamType.DateTime,
        ),
        'endAt': serializeParam(
          _endAt,
          ParamType.DateTime,
        ),
        'authorProfileId': serializeParam(
          _authorProfileId,
          ParamType.String,
        ),
        'authorAvatarUrl': serializeParam(
          _authorAvatarUrl,
          ParamType.String,
        ),
        'authorFullName': serializeParam(
          _authorFullName,
          ParamType.String,
        ),
        'authorProfession': serializeParam(
          _authorProfession,
          ParamType.Enum,
        ),
        'isOwn': serializeParam(
          _isOwn,
          ParamType.bool,
        ),
        'isContactable': serializeParam(
          _isContactable,
          ParamType.bool,
        ),
      }.withoutNulls;

  static AlertItemDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      AlertItemDataStruct(
        alertId: deserializeParam(
          data['alertId'],
          ParamType.String,
          false,
        ),
        motifCode: deserializeParam(
          data['motifCode'],
          ParamType.String,
          false,
        ),
        motifLabel: deserializeParam(
          data['motifLabel'],
          ParamType.String,
          false,
        ),
        message: deserializeParam(
          data['message'],
          ParamType.String,
          false,
        ),
        locationLabel: deserializeParam(
          data['locationLabel'],
          ParamType.String,
          false,
        ),
        startAt: deserializeParam(
          data['startAt'],
          ParamType.DateTime,
          false,
        ),
        endAt: deserializeParam(
          data['endAt'],
          ParamType.DateTime,
          false,
        ),
        authorProfileId: deserializeParam(
          data['authorProfileId'],
          ParamType.String,
          false,
        ),
        authorAvatarUrl: deserializeParam(
          data['authorAvatarUrl'],
          ParamType.String,
          false,
        ),
        authorFullName: deserializeParam(
          data['authorFullName'],
          ParamType.String,
          false,
        ),
        authorProfession: deserializeParam<Profession>(
          data['authorProfession'],
          ParamType.Enum,
          false,
        ),
        isOwn: deserializeParam(
          data['isOwn'],
          ParamType.bool,
          false,
        ),
        isContactable: deserializeParam(
          data['isContactable'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'AlertItemDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AlertItemDataStruct &&
        alertId == other.alertId &&
        motifCode == other.motifCode &&
        motifLabel == other.motifLabel &&
        message == other.message &&
        locationLabel == other.locationLabel &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        authorProfileId == other.authorProfileId &&
        authorAvatarUrl == other.authorAvatarUrl &&
        authorFullName == other.authorFullName &&
        authorProfession == other.authorProfession &&
        isOwn == other.isOwn &&
        isContactable == other.isContactable;
  }

  @override
  int get hashCode => const ListEquality().hash([
        alertId,
        motifCode,
        motifLabel,
        message,
        locationLabel,
        startAt,
        endAt,
        authorProfileId,
        authorAvatarUrl,
        authorFullName,
        authorProfession,
        isOwn,
        isContactable
      ]);
}

AlertItemDataStruct createAlertItemDataStruct({
  String? alertId,
  String? motifCode,
  String? motifLabel,
  String? message,
  String? locationLabel,
  DateTime? startAt,
  DateTime? endAt,
  String? authorProfileId,
  String? authorAvatarUrl,
  String? authorFullName,
  Profession? authorProfession,
  bool? isOwn,
  bool? isContactable,
}) =>
    AlertItemDataStruct(
      alertId: alertId,
      motifCode: motifCode,
      motifLabel: motifLabel,
      message: message,
      locationLabel: locationLabel,
      startAt: startAt,
      endAt: endAt,
      authorProfileId: authorProfileId,
      authorAvatarUrl: authorAvatarUrl,
      authorFullName: authorFullName,
      authorProfession: authorProfession,
      isOwn: isOwn,
      isContactable: isContactable,
    );
