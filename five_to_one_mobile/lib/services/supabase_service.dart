import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static bool _initialized = false;

  /// Initialize Supabase
  /// Call this once at app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    _initialized = true;
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current user (or null if not logged in)
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Get current user ID (throws if not logged in)
  static String get userId {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.id;
  }
}
