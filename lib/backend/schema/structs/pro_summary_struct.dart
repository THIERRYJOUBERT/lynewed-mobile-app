// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProSummaryStruct extends BaseStruct {
  ProSummaryStruct({
    String? proProfileId,
    String? fullName,
    String? avatarUrl,
    String? businessName,
    Profession? profession,
    int? budgetMin,
    int? budgetMax,
    String? currency,
    SubscriptionTierType? subscriptionTier,
    double? distanceKm,
    String? locationLabel,
    String? coverImageUrl,
    bool? isFavorited,
    bool? isLive,
  })  : _proProfileId = proProfileId,
        _fullName = fullName,
        _avatarUrl = avatarUrl,
        _businessName = businessName,
        _profession = profession,
        _budgetMin = budgetMin,
        _budgetMax = budgetMax,
        _currency = currency,
        _subscriptionTier = subscriptionTier,
        _distanceKm = distanceKm,
        _locationLabel = locationLabel,
        _coverImageUrl = coverImageUrl,
        _isFavorited = isFavorited,
        _isLive = isLive;

  // "proProfileId" field.
  String? _proProfileId;
  String get proProfileId => _proProfileId ?? '';
  set proProfileId(String? val) => _proProfileId = val;

  bool hasProProfileId() => _proProfileId != null;

  // "fullName" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "avatarUrl" field.
  String? _avatarUrl;
  String get avatarUrl => _avatarUrl ?? '';
  set avatarUrl(String? val) => _avatarUrl = val;

  bool hasAvatarUrl() => _avatarUrl != null;

  // "businessName" field.
  String? _businessName;
  String get businessName => _businessName ?? '';
  set businessName(String? val) => _businessName = val;

  bool hasBusinessName() => _businessName != null;

  // "profession" field.
  Profession? _profession;
  Profession? get profession => _profession;
  set profession(Profession? val) => _profession = val;

  bool hasProfession() => _profession != null;

  // "budgetMin" field.
  int? _budgetMin;
  int get budgetMin => _budgetMin ?? 0;
  set budgetMin(int? val) => _budgetMin = val;

  void incrementBudgetMin(int amount) => budgetMin = budgetMin + amount;

  bool hasBudgetMin() => _budgetMin != null;

  // "budgetMax" field.
  int? _budgetMax;
  int get budgetMax => _budgetMax ?? 0;
  set budgetMax(int? val) => _budgetMax = val;

  void incrementBudgetMax(int amount) => budgetMax = budgetMax + amount;

  bool hasBudgetMax() => _budgetMax != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  set currency(String? val) => _currency = val;

  bool hasCurrency() => _currency != null;

  // "subscriptionTier" field.
  SubscriptionTierType? _subscriptionTier;
  SubscriptionTierType? get subscriptionTier => _subscriptionTier;
  set subscriptionTier(SubscriptionTierType? val) => _subscriptionTier = val;

  bool hasSubscriptionTier() => _subscriptionTier != null;

  // "distanceKm" field.
  double? _distanceKm;
  double get distanceKm => _distanceKm ?? 0.0;
  set distanceKm(double? val) => _distanceKm = val;

  void incrementDistanceKm(double amount) => distanceKm = distanceKm + amount;

  bool hasDistanceKm() => _distanceKm != null;

  // "locationLabel" field.
  String? _locationLabel;
  String get locationLabel => _locationLabel ?? '';
  set locationLabel(String? val) => _locationLabel = val;

  bool hasLocationLabel() => _locationLabel != null;

  // "coverImageUrl" field.
  String? _coverImageUrl;
  String get coverImageUrl => _coverImageUrl ?? '';
  set coverImageUrl(String? val) => _coverImageUrl = val;

  bool hasCoverImageUrl() => _coverImageUrl != null;

  // "isFavorited" field.
  bool? _isFavorited;
  bool get isFavorited => _isFavorited ?? false;
  set isFavorited(bool? val) => _isFavorited = val;

  bool hasIsFavorited() => _isFavorited != null;

  // "isLive" field.
  bool? _isLive;
  bool get isLive => _isLive ?? false;
  set isLive(bool? val) => _isLive = val;

  bool hasIsLive() => _isLive != null;

  static ProSummaryStruct fromMap(Map<String, dynamic> data) =>
      ProSummaryStruct(
        proProfileId: data['proProfileId'] as String?,
        fullName: data['fullName'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
        businessName: data['businessName'] as String?,
        profession: data['profession'] is Profession
            ? data['profession']
            : deserializeEnum<Profession>(data['profession']),
        budgetMin: castToType<int>(data['budgetMin']),
        budgetMax: castToType<int>(data['budgetMax']),
        currency: data['currency'] as String?,
        subscriptionTier: data['subscriptionTier'] is SubscriptionTierType
            ? data['subscriptionTier']
            : deserializeEnum<SubscriptionTierType>(data['subscriptionTier']),
        distanceKm: castToType<double>(data['distanceKm']),
        locationLabel: data['locationLabel'] as String?,
        coverImageUrl: data['coverImageUrl'] as String?,
        isFavorited: data['isFavorited'] as bool?,
        isLive: data['isLive'] as bool?,
      );

  static ProSummaryStruct? maybeFromMap(dynamic data) => data is Map
      ? ProSummaryStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'proProfileId': _proProfileId,
        'fullName': _fullName,
        'avatarUrl': _avatarUrl,
        'businessName': _businessName,
        'profession': _profession?.serialize(),
        'budgetMin': _budgetMin,
        'budgetMax': _budgetMax,
        'currency': _currency,
        'subscriptionTier': _subscriptionTier?.serialize(),
        'distanceKm': _distanceKm,
        'locationLabel': _locationLabel,
        'coverImageUrl': _coverImageUrl,
        'isFavorited': _isFavorited,
        'isLive': _isLive,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'proProfileId': serializeParam(
          _proProfileId,
          ParamType.String,
        ),
        'fullName': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'avatarUrl': serializeParam(
          _avatarUrl,
          ParamType.String,
        ),
        'businessName': serializeParam(
          _businessName,
          ParamType.String,
        ),
        'profession': serializeParam(
          _profession,
          ParamType.Enum,
        ),
        'budgetMin': serializeParam(
          _budgetMin,
          ParamType.int,
        ),
        'budgetMax': serializeParam(
          _budgetMax,
          ParamType.int,
        ),
        'currency': serializeParam(
          _currency,
          ParamType.String,
        ),
        'subscriptionTier': serializeParam(
          _subscriptionTier,
          ParamType.Enum,
        ),
        'distanceKm': serializeParam(
          _distanceKm,
          ParamType.double,
        ),
        'locationLabel': serializeParam(
          _locationLabel,
          ParamType.String,
        ),
        'coverImageUrl': serializeParam(
          _coverImageUrl,
          ParamType.String,
        ),
        'isFavorited': serializeParam(
          _isFavorited,
          ParamType.bool,
        ),
        'isLive': serializeParam(
          _isLive,
          ParamType.bool,
        ),
      }.withoutNulls;

  static ProSummaryStruct fromSerializableMap(Map<String, dynamic> data) =>
      ProSummaryStruct(
        proProfileId: deserializeParam(
          data['proProfileId'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['fullName'],
          ParamType.String,
          false,
        ),
        avatarUrl: deserializeParam(
          data['avatarUrl'],
          ParamType.String,
          false,
        ),
        businessName: deserializeParam(
          data['businessName'],
          ParamType.String,
          false,
        ),
        profession: deserializeParam<Profession>(
          data['profession'],
          ParamType.Enum,
          false,
        ),
        budgetMin: deserializeParam(
          data['budgetMin'],
          ParamType.int,
          false,
        ),
        budgetMax: deserializeParam(
          data['budgetMax'],
          ParamType.int,
          false,
        ),
        currency: deserializeParam(
          data['currency'],
          ParamType.String,
          false,
        ),
        subscriptionTier: deserializeParam<SubscriptionTierType>(
          data['subscriptionTier'],
          ParamType.Enum,
          false,
        ),
        distanceKm: deserializeParam(
          data['distanceKm'],
          ParamType.double,
          false,
        ),
        locationLabel: deserializeParam(
          data['locationLabel'],
          ParamType.String,
          false,
        ),
        coverImageUrl: deserializeParam(
          data['coverImageUrl'],
          ParamType.String,
          false,
        ),
        isFavorited: deserializeParam(
          data['isFavorited'],
          ParamType.bool,
          false,
        ),
        isLive: deserializeParam(
          data['isLive'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'ProSummaryStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ProSummaryStruct &&
        proProfileId == other.proProfileId &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        businessName == other.businessName &&
        profession == other.profession &&
        budgetMin == other.budgetMin &&
        budgetMax == other.budgetMax &&
        currency == other.currency &&
        subscriptionTier == other.subscriptionTier &&
        distanceKm == other.distanceKm &&
        locationLabel == other.locationLabel &&
        coverImageUrl == other.coverImageUrl &&
        isFavorited == other.isFavorited &&
        isLive == other.isLive;
  }

  @override
  int get hashCode => const ListEquality().hash([
        proProfileId,
        fullName,
        avatarUrl,
        businessName,
        profession,
        budgetMin,
        budgetMax,
        currency,
        subscriptionTier,
        distanceKm,
        locationLabel,
        coverImageUrl,
        isFavorited,
        isLive
      ]);
}

ProSummaryStruct createProSummaryStruct({
  String? proProfileId,
  String? fullName,
  String? avatarUrl,
  String? businessName,
  Profession? profession,
  int? budgetMin,
  int? budgetMax,
  String? currency,
  SubscriptionTierType? subscriptionTier,
  double? distanceKm,
  String? locationLabel,
  String? coverImageUrl,
  bool? isFavorited,
  bool? isLive,
}) =>
    ProSummaryStruct(
      proProfileId: proProfileId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      businessName: businessName,
      profession: profession,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      currency: currency,
      subscriptionTier: subscriptionTier,
      distanceKm: distanceKm,
      locationLabel: locationLabel,
      coverImageUrl: coverImageUrl,
      isFavorited: isFavorited,
      isLive: isLive,
    );
