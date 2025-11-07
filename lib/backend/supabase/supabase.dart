import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

export 'database/database.dart';

// ✅ SECURITY: Secrets loaded from .env instead of hardcoded
// ✅ ROBUSTNESS: Validation added to ensure required env vars are present
String get _kSupabaseUrl {
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  if (url.isEmpty) {
    throw StateError(
      '❌ SUPABASE_URL is not set in .env file. '
      'Please add SUPABASE_URL=https://your-project.supabase.co to your .env file.',
    );
  }
  return url;
}

String get _kSupabaseAnonKey {
  final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (key.isEmpty) {
    throw StateError(
      '❌ SUPABASE_ANON_KEY is not set in .env file. '
      'Please add your Supabase anonymous key to your .env file.',
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

  static Future initialize() => Supabase.initialize(
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
