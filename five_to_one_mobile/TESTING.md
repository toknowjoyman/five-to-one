# Testing Guide for Five-to-One

This document provides a comprehensive guide to the testing infrastructure for the Five-to-One mobile application.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Writing New Tests](#writing-new-tests)
- [TDD Workflow](#tdd-workflow)
- [Best Practices](#best-practices)

## Overview

The Five-to-One project uses a comprehensive test-driven development (TDD) approach with three types of tests:

1. **Unit Tests** - Test individual components in isolation
2. **Widget Tests** - Test UI components and interactions
3. **Integration Tests** - Test complete user flows

### Testing Stack

- **flutter_test** - Flutter's built-in testing framework
- **mocktail** - Modern mocking library for Dart
- **fake_async** - Simulating async operations and time

## Test Structure

```
test/
├── unit/
│   ├── models/
│   │   └── item_test.dart              # Item model tests
│   ├── services/
│   │   ├── items_service_test.dart     # ItemsService tests
│   │   └── auth_service_test.dart      # AuthService tests
│   └── frameworks/
│       ├── buffett_munger_framework_test.dart
│       └── eisenhower_matrix_framework_test.dart
├── widget/
│   ├── screens/                        # Screen widget tests (future)
│   └── widgets/                        # Reusable widget tests (future)
├── integration/                        # End-to-end tests (future)
└── helpers/
    └── mock_supabase.dart              # Shared mocks
```

## Running Tests

### 🎯 Quick Start (With Failure Summary)

For easier debugging, use one of these test runners that summarize failures at the bottom:

**Option 1: Bash Script (macOS/Linux)**
```bash
./run_tests.sh                          # Run all tests
./run_tests.sh test/unit/models/item_test.dart  # Run specific file
```

**Option 2: Python Script (Cross-platform)**
```bash
python3 test_runner.py                  # Run all tests
python3 test_runner.py test/unit/models/item_test.dart  # Run specific file
```

**Option 3: Simple Output Redirect**
```bash
flutter test 2>&1 | tee test_output.txt
# Failures will be in test_output.txt
```

These scripts will show a "COPY HERE" section at the bottom with all failures summarized for easy debugging.

### Run All Tests (Standard)

```bash
cd five_to_one_mobile
flutter test
```

### Run Specific Test File

```bash
flutter test test/unit/models/item_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Tests in Watch Mode

```bash
flutter test --watch
```

### Run Tests with Verbose Output

```bash
flutter test --verbose
```

## Test Coverage

### Current Coverage

| Component | File | Tests | Coverage |
|-----------|------|-------|----------|
| **Models** |
| Item | `test/unit/models/item_test.dart` | 47 tests | ✅ Full |
| **Services** |
| ItemsService | `test/unit/services/items_service_test.dart` | 20 tests | ✅ Business Logic |
| AuthService | `test/unit/services/auth_service_test.dart` | 15 tests | ✅ Business Logic |
| **Frameworks** |
| BuffettMunger | `test/unit/frameworks/buffett_munger_framework_test.dart` | 29 tests | ✅ Core Logic |
| Eisenhower | `test/unit/frameworks/eisenhower_matrix_framework_test.dart` | 27 tests | ✅ Core Logic |

**Total: 138+ test cases**

### What's Tested

#### Item Model (`item_test.dart`)
- ✅ Constructor with required and optional fields
- ✅ Computed properties (isCompleted, isRoot, hasChildren, isTopPriority)
- ✅ Type inference from depth (lifeArea, goal, task)
- ✅ Eisenhower matrix tag colors and labels
- ✅ JSON serialization/deserialization
- ✅ copyWith method
- ✅ Edge cases and null handling

#### ItemsService (`items_service_test.dart`)
- ✅ Business logic for CRUD operations
- ✅ Query filter logic (root items, top 5, avoid list)
- ✅ Framework operations (add/remove framework)
- ✅ Priority assignment logic (saveGoals)
- ✅ Batch operations (updatePositions, updateItems)
- ✅ Data transformations
- ✅ Edge cases and error handling

#### AuthService (`auth_service_test.dart`)
- ✅ Service structure and methods
- ✅ Email and password validation
- ✅ Anonymous account upgrade logic
- ✅ Authentication state management
- ✅ Security best practices
- ✅ Input validation

#### BuffettMungerFramework (`buffett_munger_framework_test.dart`)
- ✅ Framework metadata
- ✅ canApplyToTask (requires 5+ incomplete children)
- ✅ getRequirementMessage
- ✅ filterForPriority (top 5 sorted)
- ✅ getInsights (completion rate, avoid list count)
- ✅ Priority assignment (1-5 for top items)
- ✅ Edge cases (exactly 5, full 25 list)

#### EisenhowerMatrixFramework (`eisenhower_matrix_framework_test.dart`)
- ✅ Framework metadata
- ✅ canApplyToTask (requires 1+ incomplete children)
- ✅ getRequirementMessage
- ✅ filterForPriority (urgent items)
- ✅ getInsights (quadrant counts)
- ✅ Quadrant logic (Q1-Q4)
- ✅ Tag colors and labels
- ✅ Edge cases

## Writing New Tests

### Test File Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/path/to/your/file.dart';

void main() {
  group('YourComponent', () {
    late YourComponent component;
    late DateTime testDate;

    setUp(() {
      component = YourComponent();
      testDate = DateTime.parse('2024-01-01T00:00:00Z');
    });

    tearDown(() {
      // Clean up if needed
    });

    group('Feature Name', () {
      test('should do something specific', () {
        // Arrange
        final input = 'test input';

        // Act
        final result = component.doSomething(input);

        // Assert
        expect(result, 'expected output');
      });
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/widgets/your_widget.dart';

void main() {
  testWidgets('YourWidget displays correctly', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: YourWidget(),
        ),
      ),
    );

    // Assert
    expect(find.byType(YourWidget), findsOneWidget);
    expect(find.text('Expected Text'), findsOneWidget);
  });

  testWidgets('YourWidget handles tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: YourWidget(onTap: () => tapped = true),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(YourWidget));
    await tester.pumpAndSettle();

    // Assert
    expect(tapped, true);
  });
}
```

## TDD Workflow

Follow the Red-Green-Refactor cycle:

### 1. Red - Write a Failing Test

```dart
test('Item marks as completed when completedAt is set', () {
  final item = Item(
    id: '1',
    userId: 'user1',
    title: 'Test',
    createdAt: DateTime.now(),
    completedAt: DateTime.now(),
  );

  expect(item.isCompleted, true);
});
```

**Run the test - it should fail** ❌

### 2. Green - Write Minimal Code to Pass

```dart
class Item {
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}
```

**Run the test - it should pass** ✅

### 3. Refactor - Improve Code Quality

```dart
class Item {
  final DateTime? completedAt;

  /// Returns true if this item has been completed
  bool get isCompleted => completedAt != null;
}
```

**Run the test - it should still pass** ✅

### 4. Repeat

Continue this cycle for each new feature or bug fix.

## Best Practices

### 1. Test Organization

- **Group related tests** using `group()`
- **Use descriptive test names** that explain what's being tested
- **One assertion per test** when possible
- **Arrange-Act-Assert** pattern for clarity

### 2. Test Independence

```dart
// ✅ Good - Each test is independent
test('test 1', () {
  final item = Item(...);
  expect(item.isCompleted, false);
});

test('test 2', () {
  final item = Item(...);
  expect(item.isCompleted, false);
});

// ❌ Bad - Tests depend on shared state
final item = Item(...);

test('test 1', () {
  expect(item.isCompleted, false);
});

test('test 2', () {
  item.complete();
  expect(item.isCompleted, true);
});
```

### 3. Use setUp and tearDown

```dart
group('MyTests', () {
  late MyClass instance;

  setUp(() {
    // Runs before each test
    instance = MyClass();
  });

  tearDown(() {
    // Runs after each test
    instance.dispose();
  });

  test('...', () {
    // Use instance
  });
});
```

### 4. Test Edge Cases

```dart
group('Edge Cases', () {
  test('handles empty list', () {
    expect(filterItems([]), isEmpty);
  });

  test('handles null values', () {
    final item = Item(id: '1', title: null);
    expect(item.title, isNull);
  });

  test('handles boundary values', () {
    expect(isPriority(5), true);   // Max valid
    expect(isPriority(6), false);  // Just above max
  });
});
```

### 5. Use Matchers Effectively

```dart
// Type checking
expect(result, isA<Item>());

// Collections
expect(list, isEmpty);
expect(list, hasLength(5));
expect(list, contains('value'));
expect(list, containsAll(['a', 'b']));

// Strings
expect(text, startsWith('Hello'));
expect(text, endsWith('World'));
expect(text, contains('middle'));

// Numbers
expect(value, greaterThan(5));
expect(value, lessThan(10));
expect(value, closeTo(3.14, 0.01));

// Null
expect(value, isNull);
expect(value, isNotNull);

// Booleans
expect(result, isTrue);
expect(result, isFalse);

// Exceptions
expect(() => throwError(), throwsException);
expect(() => throwSpecific(), throwsA(isA<CustomError>()));
```

### 6. Mock External Dependencies

```dart
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

test('service calls Supabase correctly', () {
  final mockClient = MockSupabaseClient();

  when(() => mockClient.from('items')).thenReturn(...);

  final service = ItemsService(client: mockClient);
  service.getItems();

  verify(() => mockClient.from('items')).called(1);
});
```

### 7. Test Async Code

```dart
test('async operation completes', () async {
  final result = await fetchData();
  expect(result, isNotNull);
});

test('stream emits values', () async {
  final stream = getDataStream();

  expect(
    stream,
    emitsInOrder([
      'value1',
      'value2',
      'value3',
    ]),
  );
});
```

## Common Testing Patterns

### Testing Computed Properties

```dart
test('isCompleted returns true when completedAt is set', () {
  final item = Item(
    id: '1',
    userId: 'user1',
    title: 'Test',
    createdAt: testDate,
    completedAt: testDate,
  );

  expect(item.isCompleted, true);
});
```

### Testing JSON Serialization

```dart
test('round-trip serialization preserves data', () {
  final original = Item(...);

  final json = original.toJson();
  final restored = Item.fromJson(json);

  expect(restored.id, original.id);
  expect(restored.title, original.title);
});
```

### Testing Filtering Logic

```dart
test('filters items by priority', () {
  final items = [
    Item(priority: 1),
    Item(priority: 5),
    Item(priority: 10),
  ];

  final topFive = items.where((i) => i.priority! <= 5).toList();

  expect(topFive.length, 2);
  expect(topFive.every((i) => i.priority! <= 5), true);
});
```

### Testing Business Logic

```dart
test('top 5 items get priorities 1-5', () {
  final rankedGoals = List.generate(25, (i) => 'Goal ${i + 1}');

  final items = rankedGoals.asMap().entries.map((entry) {
    return {
      'priority': entry.key < 5 ? entry.key + 1 : null,
      'is_avoided': entry.key >= 5,
    };
  }).toList();

  final topFive = items.take(5).toList();

  expect(topFive[0]['priority'], 1);
  expect(topFive[4]['priority'], 5);
  expect(topFive.every((i) => i['is_avoided'] == false), true);
});
```

## Continuous Integration

To run tests in CI/CD pipelines:

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Troubleshooting

### Tests Run Slow

- Use `flutter test --concurrency=4` to run tests in parallel
- Mock external dependencies instead of making real network calls
- Use `fake_async` for time-based tests

### Tests Are Flaky

- Ensure tests are independent (no shared state)
- Use `await tester.pumpAndSettle()` for widget tests
- Avoid real timers, use `fake_async` instead

### Coverage Is Low

- Run `flutter test --coverage` to see what's missing
- Focus on critical business logic first
- Don't aim for 100% - focus on value

## Future Enhancements

### Planned Test Additions

- [ ] Widget tests for screens
- [ ] Widget tests for custom widgets (PentagonWheel, FrameworkPicker)
- [ ] Integration tests for complete user flows
- [ ] Performance tests for recursive tree operations
- [ ] Accessibility tests

### Tools to Add

- [ ] Golden tests for visual regression
- [ ] Integration testing with Patrol or integration_test
- [ ] Performance profiling tests
- [ ] E2E tests with real Supabase test instance

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Test-Driven Development with Flutter](https://resocoder.com/category/flutter/testing/)

## Contributing

When adding new features:

1. **Write tests first** (TDD approach)
2. **Run existing tests** to ensure no regressions
3. **Add tests for edge cases**
4. **Update this documentation** if adding new test patterns

---

**Happy Testing! 🧪**
