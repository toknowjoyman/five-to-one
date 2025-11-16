// Supabase Configuration Template
//
// 1. Copy this file to supabase_config.dart
// 2. Replace the values with your actual Supabase credentials
// 3. Get credentials from: https://app.supabase.com → Your Project → Settings → API
//
// IMPORTANT: Never commit supabase_config.dart to git if it contains real credentials!

class SupabaseConfig {
  // Your Supabase project URL
  // Example: 'https://abcdefghijklmnop.supabase.co'
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';

  // Your Supabase anon/public key (safe for client-side use)
  // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
