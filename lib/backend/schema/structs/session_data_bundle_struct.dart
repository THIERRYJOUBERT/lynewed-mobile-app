// ignore_for_file: unnecessary_getters_setters


import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SessionDataBundleStruct extends BaseStruct {
  SessionDataBundleStruct({
    PublicProfileStruct? profile,
    UserPreferencesStruct? preferences,
    ProSubscriptionSummaryStruct? proSubscription,
  })  : _profile = profile,
        _preferences = preferences,
        _proSubscription = proSubscription;

  // "profile" field.
  PublicProfileStruct? _profile;
  PublicProfileStruct get profile => _profile ?? PublicProfileStruct();
  set profile(PublicProfileStruct? val) => _profile = val;

  void updateProfile(Function(PublicProfileStruct) updateFn) {
    updateFn(_profile ??= PublicProfileStruct());
  }

  bool hasProfile() => _profile != null;

  // "preferences" field.
  UserPreferencesStruct? _preferences;
  UserPreferencesStruct get preferences =>
      _preferences ?? UserPreferencesStruct();
  set preferences(UserPreferencesStruct? val) => _preferences = val;

  void updatePreferences(Function(UserPreferencesStruct) updateFn) {
    updateFn(_preferences ??= UserPreferencesStruct());
  }

  bool hasPreferences() => _preferences != null;

  // "proSubscription" field.
  ProSubscriptionSummaryStruct? _proSubscription;
  ProSubscriptionSummaryStruct get proSubscription =>
      _proSubscription ?? ProSubscriptionSummaryStruct();
  set proSubscription(ProSubscriptionSummaryStruct? val) =>
      _proSubscription = val;

  void updateProSubscription(Function(ProSubscriptionSummaryStruct) updateFn) {
    updateFn(_proSubscription ??= ProSubscriptionSummaryStruct());
  }

  bool hasProSubscription() => _proSubscription != null;

  static SessionDataBundleStruct fromMap(Map<String, dynamic> data) =>
      SessionDataBundleStruct(
        profile: data['profile'] is PublicProfileStruct
            ? data['profile']
            : PublicProfileStruct.maybeFromMap(data['profile']),
        preferences: data['preferences'] is UserPreferencesStruct
            ? data['preferences']
            : UserPreferencesStruct.maybeFromMap(data['preferences']),
        proSubscription: data['proSubscription'] is ProSubscriptionSummaryStruct
            ? data['proSubscription']
            : ProSubscriptionSummaryStruct.maybeFromMap(
                data['proSubscription']),
      );

  static SessionDataBundleStruct? maybeFromMap(dynamic data) => data is Map
      ? SessionDataBundleStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'profile': _profile?.toMap(),
        'preferences': _preferences?.toMap(),
        'proSubscription': _proSubscription?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'profile': serializeParam(
          _profile,
          ParamType.DataStruct,
        ),
        'preferences': serializeParam(
          _preferences,
          ParamType.DataStruct,
        ),
        'proSubscription': serializeParam(
          _proSubscription,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static SessionDataBundleStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SessionDataBundleStruct(
        profile: deserializeStructParam(
          data['profile'],
          ParamType.DataStruct,
          false,
          structBuilder: PublicProfileStruct.fromSerializableMap,
        ),
        preferences: deserializeStructParam(
          data['preferences'],
          ParamType.DataStruct,
          false,
          structBuilder: UserPreferencesStruct.fromSerializableMap,
        ),
        proSubscription: deserializeStructParam(
          data['proSubscription'],
          ParamType.DataStruct,
          false,
          structBuilder: ProSubscriptionSummaryStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'SessionDataBundleStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SessionDataBundleStruct &&
        profile == other.profile &&
        preferences == other.preferences &&
        proSubscription == other.proSubscription;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([profile, preferences, proSubscription]);
}

SessionDataBundleStruct createSessionDataBundleStruct({
  PublicProfileStruct? profile,
  UserPreferencesStruct? preferences,
  ProSubscriptionSummaryStruct? proSubscription,
}) =>
    SessionDataBundleStruct(
      profile: profile ?? PublicProfileStruct(),
      preferences: preferences ?? UserPreferencesStruct(),
      proSubscription: proSubscription ?? ProSubscriptionSummaryStruct(),
    );
