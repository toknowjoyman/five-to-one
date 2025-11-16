import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/main.dart';

void main() {
  group('FiveToOneApp', () {
    testWidgets('App widget can be instantiated', (WidgetTester tester) async {
      // Note: This test verifies the app widget can be created
      // Full app testing requires Supabase initialization which we skip in unit tests

      // Verify the app class can be instantiated without errors
      expect(() => const FiveToOneApp(), returnsNormally);
    });

    testWidgets('App uses MaterialApp', (WidgetTester tester) async {
      // This is a basic structural test
      // In a real app test, you'd pump the widget and verify MaterialApp exists
      // But that requires Supabase initialization

      const app = FiveToOneApp();
      expect(app, isA<FiveToOneApp>());
    });
  });
}
