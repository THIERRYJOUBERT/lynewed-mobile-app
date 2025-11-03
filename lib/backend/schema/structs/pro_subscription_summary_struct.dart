// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProSubscriptionSummaryStruct extends BaseStruct {
  ProSubscriptionSummaryStruct({
    String? profileId,
    SubscriptionTierType? subscriptionTier,
    DateTime? trialEndsAt,
    int? fixedLocationsQuota,
    Profession? profession,
  })  : _profileId = profileId,
        _subscriptionTier = subscriptionTier,
        _trialEndsAt = trialEndsAt,
        _fixedLocationsQuota = fixedLocationsQuota,
        _profession = profession;

  // "profileId" field.
  String? _profileId;
  String get profileId => _profileId ?? '';
  set profileId(String? val) => _profileId = val;

  bool hasProfileId() => _profileId != null;

  // "subscriptionTier" field.
  SubscriptionTierType? _subscriptionTier;
  SubscriptionTierType? get subscriptionTier => _subscriptionTier;
  set subscriptionTier(SubscriptionTierType? val) => _subscriptionTier = val;

  bool hasSubscriptionTier() => _subscriptionTier != null;

  // "trialEndsAt" field.
  DateTime? _trialEndsAt;
  DateTime? get trialEndsAt => _trialEndsAt;
  set trialEndsAt(DateTime? val) => _trialEndsAt = val;

  bool hasTrialEndsAt() => _trialEndsAt != null;

  // "fixedLocationsQuota" field.
  int? _fixedLocationsQuota;
  int get fixedLocationsQuota => _fixedLocationsQuota ?? 0;
  set fixedLocationsQuota(int? val) => _fixedLocationsQuota = val;

  void incrementFixedLocationsQuota(int amount) =>
      fixedLocationsQuota = fixedLocationsQuota + amount;

  bool hasFixedLocationsQuota() => _fixedLocationsQuota != null;

  // "profession" field.
  Profession? _profession;
  Profession? get profession => _profession;
  set profession(Profession? val) => _profession = val;

  bool hasProfession() => _profession != null;

  static ProSubscriptionSummaryStruct fromMap(Map<String, dynamic> data) =>
      ProSubscriptionSummaryStruct(
        profileId: data['profileId'] as String?,
        subscriptionTier: data['subscriptionTier'] is SubscriptionTierType
            ? data['subscriptionTier']
            : deserializeEnum<SubscriptionTierType>(data['subscriptionTier']),
        trialEndsAt: data['trialEndsAt'] as DateTime?,
        fixedLocationsQuota: castToType<int>(data['fixedLocationsQuota']),
        profession: data['profession'] is Profession
            ? data['profession']
            : deserializeEnum<Profession>(data['profession']),
      );

  static ProSubscriptionSummaryStruct? maybeFromMap(dynamic data) => data is Map
      ? ProSubscriptionSummaryStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'profileId': _profileId,
        'subscriptionTier': _subscriptionTier?.serialize(),
        'trialEndsAt': _trialEndsAt,
        'fixedLocationsQuota': _fixedLocationsQuota,
        'profession': _profession?.serialize(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'profileId': serializeParam(
          _profileId,
          ParamType.String,
        ),
        'subscriptionTier': serializeParam(
          _subscriptionTier,
          ParamType.Enum,
        ),
        'trialEndsAt': serializeParam(
          _trialEndsAt,
          ParamType.DateTime,
        ),
        'fixedLocationsQuota': serializeParam(
          _fixedLocationsQuota,
          ParamType.int,
        ),
        'profession': serializeParam(
          _profession,
          ParamType.Enum,
        ),
      }.withoutNulls;

  static ProSubscriptionSummaryStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ProSubscriptionSummaryStruct(
        profileId: deserializeParam(
          data['profileId'],
          ParamType.String,
          false,
        ),
        subscriptionTier: deserializeParam<SubscriptionTierType>(
          data['subscriptionTier'],
          ParamType.Enum,
          false,
        ),
        trialEndsAt: deserializeParam(
          data['trialEndsAt'],
          ParamType.DateTime,
          false,
        ),
        fixedLocationsQuota: deserializeParam(
          data['fixedLocationsQuota'],
          ParamType.int,
          false,
        ),
        profession: deserializeParam<Profession>(
          data['profession'],
          ParamType.Enum,
          false,
        ),
      );

  @override
  String toString() => 'ProSubscriptionSummaryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ProSubscriptionSummaryStruct &&
        profileId == other.profileId &&
        subscriptionTier == other.subscriptionTier &&
        trialEndsAt == other.trialEndsAt &&
        fixedLocationsQuota == other.fixedLocationsQuota &&
        profession == other.profession;
  }

  @override
  int get hashCode => const ListEquality().hash([
        profileId,
        subscriptionTier,
        trialEndsAt,
        fixedLocationsQuota,
        profession
      ]);
}

ProSubscriptionSummaryStruct createProSubscriptionSummaryStruct({
  String? profileId,
  SubscriptionTierType? subscriptionTier,
  DateTime? trialEndsAt,
  int? fixedLocationsQuota,
  Profession? profession,
}) =>
    ProSubscriptionSummaryStruct(
      profileId: profileId,
      subscriptionTier: subscriptionTier,
      trialEndsAt: trialEndsAt,
      fixedLocationsQuota: fixedLocationsQuota,
      profession: profession,
    );
