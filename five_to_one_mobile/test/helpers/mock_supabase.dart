import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock SupabaseClient for testing
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock PostgrestFilterBuilder for testing queries
class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}

/// Mock PostgrestTransformBuilder for testing transformations
class MockPostgrestTransformBuilder<T> extends Mock implements PostgrestTransformBuilder<T> {}

/// Mock PostgrestBuilder for testing base builder
class MockPostgrestBuilder<T> extends Mock implements PostgrestBuilder<T> {}
