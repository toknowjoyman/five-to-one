// Supabase Configuration
// Replace these values with your actual Supabase credentials
// Get them from: https://app.supabase.com → Your Project → Settings → API
//
// For production deployment, set these environment variables:
// - SUPABASE_URL
// - SUPABASE_ANON_KEY

class SupabaseConfig {
  // Your Supabase project URL
  // In production, this can be overridden by environment variables
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://moynkekavontkrmuqbgg.supabase.co',
  );

  // Your Supabase anon/public key
  // In production, this can be overridden by environment variables
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1veW5rZWthdm9udGtybXVxYmdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNDc5MDksImV4cCI6MjA3ODgyMzkwOX0.gClIqgYG4fr-tBC9kjagFmTCK57r2hDY0rjndOv_Nx8',
  );
}
