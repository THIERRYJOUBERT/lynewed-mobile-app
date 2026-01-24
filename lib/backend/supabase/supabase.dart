import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../../config/app_secrets.dart';

export 'database/database.dart';

// SECURITY: Secrets loaded via --dart-define-from-file (compile-time constants)
// ROBUSTNESS: Validation added to ensure required env vars are present
String get _kSupabaseUrl {
  const url = AppSecrets.supabaseUrl;
  if (url.isEmpty) {
    if (kDebugMode) {
      debugPrint(
        '[Supabase] ERROR: SUPABASE_URL is not set. '
        'Run with --dart-define-from-file=secrets.json',
      );
    }
    throw StateError(
      'SUPABASE_URL is not configured. '
      'Please run with --dart-define-from-file=secrets.json',
    );
  }
  return url;
}

String get _kSupabaseAnonKey {
  const key = AppSecrets.supabaseAnonKey;
  if (key.isEmpty) {
    if (kDebugMode) {
      debugPrint(
        '[Supabase] ERROR: SUPABASE_ANON_KEY is not set. '
        'Run with --dart-define-from-file=secrets.json',
      );
    }
    throw StateError(
      'SUPABASE_ANON_KEY is not configured. '
      'Please run with --dart-define-from-file=secrets.json',
    );
  }
  return key;
}

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future<void> initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
          autoRefreshToken: true,
        ),
      );
}
