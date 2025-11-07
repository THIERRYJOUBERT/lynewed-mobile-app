import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = const FlutterSecureStorage();
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_currentUserPreferences') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_currentUserPreferences') ??
                  '{}';
          _currentUserPreferences = UserPreferencesStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          debugPrint("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      _userPrefsLastSyncedAt =
          await secureStorage.read(key: 'ff_userPrefsLastSyncedAt') != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  (await secureStorage.getInt('ff_userPrefsLastSyncedAt'))!)
              : _userPrefsLastSyncedAt;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  UserRole? _currentUserRole = UserRole.bride;
  UserRole? get currentUserRole => _currentUserRole;
  set currentUserRole(UserRole? value) {
    _currentUserRole = value;
  }

  UserPreferencesStruct _currentUserPreferences =
      UserPreferencesStruct.fromSerializableMap(jsonDecode(
          '{"distanceUnit":"km","mapToggles":"{\\"showPros\\":\\"true\\",\\"showProRecent\\":\\"true\\",\\"showFixedLocations\\":\\"true\\",\\"showBridePrivatePoi\\":\\"true\\",\\"showWeddingPins\\":\\"true\\",\\"showProAlerts\\":\\"true\\",\\"showSearchTarget\\":\\"true\\"}"}'));
  UserPreferencesStruct get currentUserPreferences => _currentUserPreferences;
  set currentUserPreferences(UserPreferencesStruct value) {
    _currentUserPreferences = value;
    secureStorage.setString('ff_currentUserPreferences', value.serialize());
  }

  void deleteCurrentUserPreferences() {
    secureStorage.delete(key: 'ff_currentUserPreferences');
  }

  void updateCurrentUserPreferencesStruct(
      Function(UserPreferencesStruct) updateFn) {
    updateFn(_currentUserPreferences);
    secureStorage.setString(
        'ff_currentUserPreferences', _currentUserPreferences.serialize());
  }

  PublicProfileStruct _selfPublicProfile =
      PublicProfileStruct.fromSerializableMap(jsonDecode(
          '{"role":"bride","avatarUrl":"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png"}'));
  PublicProfileStruct get selfPublicProfile => _selfPublicProfile;
  set selfPublicProfile(PublicProfileStruct value) {
    _selfPublicProfile = value;
  }

  void updateSelfPublicProfileStruct(Function(PublicProfileStruct) updateFn) {
    updateFn(_selfPublicProfile);
  }

  ProSubscriptionSummaryStruct _selfProSubscription =
      ProSubscriptionSummaryStruct();
  ProSubscriptionSummaryStruct get selfProSubscription => _selfProSubscription;
  set selfProSubscription(ProSubscriptionSummaryStruct value) {
    _selfProSubscription = value;
  }

  void updateSelfProSubscriptionStruct(
      Function(ProSubscriptionSummaryStruct) updateFn) {
    updateFn(_selfProSubscription);
  }

  DateTime? _userPrefsLastSyncedAt =
      DateTime.fromMillisecondsSinceEpoch(1758536940000);
  DateTime? get userPrefsLastSyncedAt => _userPrefsLastSyncedAt;
  set userPrefsLastSyncedAt(DateTime? value) {
    _userPrefsLastSyncedAt = value;
    value != null
        ? secureStorage.setInt(
            'ff_userPrefsLastSyncedAt', value.millisecondsSinceEpoch)
        : secureStorage.remove('ff_userPrefsLastSyncedAt');
  }

  void deleteUserPrefsLastSyncedAt() {
    secureStorage.delete(key: 'ff_userPrefsLastSyncedAt');
  }

  int _unreadMessagesCount = 0;
  int get unreadMessagesCount => _unreadMessagesCount;
  set unreadMessagesCount(int value) {
    _unreadMessagesCount = value;
  }

  int _unreadNotificationsCount = 0;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  set unreadNotificationsCount(int value) {
    _unreadNotificationsCount = value;
  }

  bool _hasUnreadNotifications = false;
  bool get hasUnreadNotifications => _hasUnreadNotifications;
  set hasUnreadNotifications(bool value) {
    _hasUnreadNotifications = value;
  }

  bool _isFirebaseMessagingInitialized = false;
  bool get isFirebaseMessagingInitialized => _isFirebaseMessagingInitialized;
  set isFirebaseMessagingInitialized(bool value) {
    _isFirebaseMessagingInitialized = value;
  }

  bool _isListenerInitialized = false;
  bool get isListenerInitialized => _isListenerInitialized;
  set isListenerInitialized(bool value) {
    _isListenerInitialized = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return const CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: const ListToCsvConverter().convert([value]));
}
