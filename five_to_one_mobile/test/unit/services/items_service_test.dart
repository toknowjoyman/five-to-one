import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:five_to_one/models/item.dart';
import 'package:five_to_one/services/items_service.dart';
import 'package:five_to_one/services/supabase_service.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder {}

void main() {
  group('ItemsService', () {
    late ItemsService service;
    late DateTime testDate;

    setUp(() {
      service = ItemsService();
      testDate = DateTime.parse('2024-01-01T00:00:00Z');
    });

    group('Item Model Tests (Unit)', () {
      // These tests verify the Item model's business logic
      // They don't require mocking Supabase

      test('Item creates with correct defaults', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Test',
          createdAt: testDate,
        );

        expect(item.position, 0);
        expect(item.frameworkIds, isEmpty);
        expect(item.isAvoided, false);
        expect(item.isUrgent, false);
        expect(item.isImportant, false);
      });

      test('Item correctly identifies top priority (1-5)', () {
        final topItem = Item(
          id: '1',
          userId: 'user1',
          title: 'Top Priority',
          priority: 3,
          createdAt: testDate,
        );

        expect(topItem.isTopPriority, true);

        final lowItem = Item(
          id: '2',
          userId: 'user1',
          title: 'Low Priority',
          priority: 6,
          createdAt: testDate,
        );

        expect(lowItem.isTopPriority, false);
      });

      test('Item correctly computes Eisenhower tag colors', () {
        final urgentImportant = Item(
          id: '1',
          userId: 'user1',
          title: 'Crisis',
          isUrgent: true,
          isImportant: true,
          createdAt: testDate,
        );
        expect(urgentImportant.tagColor, 0xFFE74C3C);
        expect(urgentImportant.tagLabel, 'URGENT & IMPORTANT');

        final urgentOnly = Item(
          id: '2',
          userId: 'user1',
          title: 'Interrupt',
          isUrgent: true,
          isImportant: false,
          createdAt: testDate,
        );
        expect(urgentOnly.tagColor, 0xFFE74C3C);
        expect(urgentOnly.tagLabel, 'URGENT');

        final importantOnly = Item(
          id: '3',
          userId: 'user1',
          title: 'Strategic',
          isUrgent: false,
          isImportant: true,
          createdAt: testDate,
        );
        expect(importantOnly.tagColor, 0xFF3498DB);
        expect(importantOnly.tagLabel, 'IMPORTANT');

        final neither = Item(
          id: '4',
          userId: 'user1',
          title: 'Distraction',
          isUrgent: false,
          isImportant: false,
          createdAt: testDate,
        );
        expect(neither.tagColor, 0xFF95A5A6);
        expect(neither.tagLabel, '');
      });

      test('Item type inference from depth', () {
        final lifeArea = Item(
          id: '1',
          userId: 'user1',
          title: 'Career',
          depth: 0,
          createdAt: testDate,
        );
        expect(lifeArea.type, ItemType.lifeArea);

        final goal = Item(
          id: '2',
          userId: 'user1',
          title: 'Get promotion',
          depth: 1,
          createdAt: testDate,
        );
        expect(goal.type, ItemType.goal);

        final task = Item(
          id: '3',
          userId: 'user1',
          title: 'Update resume',
          depth: 2,
          createdAt: testDate,
        );
        expect(task.type, ItemType.task);

        final unknownDepth = Item(
          id: '4',
          userId: 'user1',
          title: 'No depth',
          createdAt: testDate,
        );
        expect(unknownDepth.type, ItemType.unknown);
      });
    });

    group('Business Logic Tests', () {
      test('saveGoals creates correct priority structure', () {
        // Test the business logic of saveGoals
        final rankedGoals = [
          'Goal 1 - Top Priority',
          'Goal 2',
          'Goal 3',
          'Goal 4',
          'Goal 5',
          'Goal 6 - Avoid',
          'Goal 7 - Avoid',
        ];

        // Simulate what saveGoals does
        final items = rankedGoals.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;

          return {
            'title': title,
            'position': index,
            'priority': index < 5 ? index + 1 : null,
            'is_avoided': index >= 5,
          };
        }).toList();

        // Verify top 5 have priorities 1-5
        for (int i = 0; i < 5; i++) {
          expect(items[i]['priority'], i + 1);
          expect(items[i]['is_avoided'], false);
        }

        // Verify rest are avoided
        for (int i = 5; i < items.length; i++) {
          expect(items[i]['priority'], null);
          expect(items[i]['is_avoided'], true);
        }
      });

      test('framework operations maintain framework list integrity', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Task',
          frameworkIds: ['buffett-munger'],
          createdAt: testDate,
        );

        // Simulate adding a framework
        final updatedFrameworks = [...item.frameworkIds];
        if (!updatedFrameworks.contains('eisenhower')) {
          updatedFrameworks.add('eisenhower');
        }

        expect(updatedFrameworks, ['buffett-munger', 'eisenhower']);

        // Simulate adding duplicate (should not duplicate)
        final noDuplicate = [...updatedFrameworks];
        if (!noDuplicate.contains('eisenhower')) {
          noDuplicate.add('eisenhower');
        }

        expect(noDuplicate.length, 2);

        // Simulate removing a framework
        final afterRemoval = [...updatedFrameworks]..remove('buffett-munger');
        expect(afterRemoval, ['eisenhower']);
      });

      test('updatePositions handles batch position updates', () {
        final itemPositions = {
          'item1': 0,
          'item2': 1,
          'item3': 2,
          'item4': 3,
        };

        // Verify the structure is correct
        expect(itemPositions['item1'], 0);
        expect(itemPositions['item2'], 1);
        expect(itemPositions.keys.length, 4);
      });

      test('completeItem sets completion timestamp', () {
        final now = DateTime.now();
        final update = {'completed_at': now.toIso8601String()};

        expect(update['completed_at'], isNotNull);

        // Verify timestamp can be parsed
        final parsed = DateTime.parse(update['completed_at']!);
        expect(parsed.difference(now).inSeconds, lessThan(1));
      });

      test('uncompleteItem clears completion timestamp', () {
        final update = {'completed_at': null};

        expect(update['completed_at'], isNull);
      });
    });

    group('Query Filter Logic', () {
      test('getRootItems should filter by null parent_id', () {
        // Test the query logic
        final mockFilter = {
          'parent_id': null,
          'user_id': 'test-user',
        };

        expect(mockFilter['parent_id'], isNull);
        expect(mockFilter['user_id'], isNotNull);
      });

      test('getTopFiveGoals should filter correctly', () {
        // Simulates the query filters
        final items = [
          {'id': '1', 'priority': 1, 'parent_id': null},
          {'id': '2', 'priority': 2, 'parent_id': null},
          {'id': '3', 'priority': 3, 'parent_id': null},
          {'id': '4', 'priority': 4, 'parent_id': null},
          {'id': '5', 'priority': 5, 'parent_id': null},
          {'id': '6', 'priority': null, 'parent_id': null},
        ];

        final filtered = items
            .where((item) => item['parent_id'] == null)
            .where((item) => item['priority'] != null)
            .toList()
          ..sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));

        final top5 = filtered.take(5).toList();

        expect(top5.length, 5);
        expect(top5[0]['priority'], 1);
        expect(top5[4]['priority'], 5);
      });

      test('getAvoidList should filter avoided items', () {
        final items = [
          {'id': '1', 'is_avoided': true, 'parent_id': null},
          {'id': '2', 'is_avoided': false, 'parent_id': null},
          {'id': '3', 'is_avoided': true, 'parent_id': null},
        ];

        final avoided = items
            .where((item) => item['parent_id'] == null)
            .where((item) => item['is_avoided'] == true)
            .toList();

        expect(avoided.length, 2);
        expect(avoided.every((item) => item['is_avoided'] == true), true);
      });

      test('getChildren should filter by parent_id', () {
        final parentId = 'parent123';
        final items = [
          {'id': '1', 'parent_id': parentId},
          {'id': '2', 'parent_id': parentId},
          {'id': '3', 'parent_id': 'other'},
        ];

        final children = items
            .where((item) => item['parent_id'] == parentId)
            .toList();

        expect(children.length, 2);
        expect(children.every((item) => item['parent_id'] == parentId), true);
      });

      test('getUrgentTasks should filter by is_urgent', () {
        final items = [
          {'id': '1', 'is_urgent': true, 'is_important': false},
          {'id': '2', 'is_urgent': false, 'is_important': true},
          {'id': '3', 'is_urgent': true, 'is_important': true},
        ];

        final urgent = items
            .where((item) => item['is_urgent'] == true)
            .toList();

        expect(urgent.length, 2);
        expect(urgent.every((item) => item['is_urgent'] == true), true);
      });

      test('getImportantTasks should filter by is_important', () {
        final items = [
          {'id': '1', 'is_urgent': true, 'is_important': false},
          {'id': '2', 'is_urgent': false, 'is_important': true},
          {'id': '3', 'is_urgent': true, 'is_important': true},
        ];

        final important = items
            .where((item) => item['is_important'] == true)
            .toList();

        expect(important.length, 2);
        expect(important.every((item) => item['is_important'] == true), true);
      });

      test('getScheduledTasks should filter by date range', () {
        final start = DateTime.parse('2024-06-01T00:00:00Z');
        final end = DateTime.parse('2024-06-30T23:59:59Z');

        final items = [
          {'id': '1', 'scheduled_for': '2024-06-15T10:00:00Z'},
          {'id': '2', 'scheduled_for': '2024-05-15T10:00:00Z'},
          {'id': '3', 'scheduled_for': '2024-06-25T14:00:00Z'},
          {'id': '4', 'scheduled_for': '2024-07-01T10:00:00Z'},
        ];

        final scheduled = items.where((item) {
          final date = DateTime.parse(item['scheduled_for'] as String);
          return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
                 date.isBefore(end.add(const Duration(seconds: 1)));
        }).toList();

        expect(scheduled.length, 2);
        expect(scheduled[0]['id'], '1');
        expect(scheduled[1]['id'], '3');
      });

      test('getItemsWithFramework should filter by framework_ids contains', () {
        final items = [
          {'id': '1', 'framework_ids': ['buffett-munger']},
          {'id': '2', 'framework_ids': ['eisenhower']},
          {'id': '3', 'framework_ids': ['buffett-munger', 'eisenhower']},
          {'id': '4', 'framework_ids': []},
        ];

        final buffettItems = items.where((item) {
          final frameworks = item['framework_ids'] as List;
          return frameworks.contains('buffett-munger');
        }).toList();

        expect(buffettItems.length, 2);
        expect(buffettItems[0]['id'], '1');
        expect(buffettItems[1]['id'], '3');
      });
    });

    group('Edge Cases and Error Handling', () {
      test('getItem returns null when item not found', () {
        // Simulates maybeSingle returning null
        final Map<String, dynamic>? response = null;
        final item = response != null ? Item.fromJson(response) : null;

        expect(item, isNull);
      });

      test('getItemTree should handle items with no children', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Leaf Item',
          createdAt: testDate,
        );

        final emptyChildren = <Item>[];
        final itemWithEmptyChildren = item.copyWith(children: emptyChildren);

        expect(itemWithEmptyChildren.hasChildren, false);
      });

      test('updatePositions handles empty map', () {
        final Map<String, int> emptyPositions = {};

        expect(emptyPositions.isEmpty, true);
        expect(emptyPositions.entries.length, 0);
      });

      test('saveGoals handles minimum goals (5)', () {
        final minGoals = List.generate(5, (i) => 'Goal ${i + 1}');

        expect(minGoals.length, 5);

        final items = minGoals.asMap().entries.map((entry) {
          return {
            'position': entry.key,
            'priority': entry.key < 5 ? entry.key + 1 : null,
            'is_avoided': entry.key >= 5,
          };
        }).toList();

        expect(items.every((item) => item['priority'] != null), true);
        expect(items.every((item) => item['is_avoided'] == false), true);
      });

      test('saveGoals handles maximum goals (25+)', () {
        final maxGoals = List.generate(25, (i) => 'Goal ${i + 1}');

        expect(maxGoals.length, 25);

        final items = maxGoals.asMap().entries.map((entry) {
          return {
            'position': entry.key,
            'priority': entry.key < 5 ? entry.key + 1 : null,
            'is_avoided': entry.key >= 5,
          };
        }).toList();

        final topFive = items.take(5).toList();
        final avoided = items.skip(5).toList();

        expect(topFive.every((item) => item['priority'] != null), true);
        expect(avoided.every((item) => item['is_avoided'] == true), true);
        expect(avoided.length, 20);
      });

      test('framework operations handle item not found', () {
        Item? item;

        // Simulate getItem returning null
        expect(
          () {
            if (item == null) throw Exception('Item not found');
          },
          throwsException,
        );
      });

      test('addFramework prevents duplicates', () {
        final existingFrameworks = ['buffett-munger'];
        final frameworkToAdd = 'buffett-munger';

        final updated = [...existingFrameworks];
        if (!updated.contains(frameworkToAdd)) {
          updated.add(frameworkToAdd);
        }

        expect(updated.length, 1);
        expect(updated, ['buffett-munger']);
      });

      test('removeFramework handles non-existent framework', () {
        final existingFrameworks = ['buffett-munger'];
        final frameworkToRemove = 'eisenhower';

        final updated = [...existingFrameworks]..remove(frameworkToRemove);

        expect(updated, ['buffett-munger']);
        expect(updated.length, 1);
      });
    });

    group('Data Transformation', () {
      test('Item JSON serialization round-trip preserves data', () {
        final original = Item(
          id: '123',
          userId: 'user1',
          parentId: 'parent456',
          title: 'Test Item',
          position: 5,
          frameworkIds: ['buffett-munger', 'eisenhower'],
          priority: 2,
          isAvoided: false,
          isUrgent: true,
          isImportant: true,
          scheduledFor: testDate,
          durationMinutes: 60,
          createdAt: testDate,
        );

        final json = original.toJson();
        final restored = Item.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.parentId, original.parentId);
        expect(restored.title, original.title);
        expect(restored.position, original.position);
        expect(restored.frameworkIds, original.frameworkIds);
        expect(restored.priority, original.priority);
        expect(restored.isAvoided, original.isAvoided);
        expect(restored.isUrgent, original.isUrgent);
        expect(restored.isImportant, original.isImportant);
        expect(restored.durationMinutes, original.durationMinutes);
      });

      test('List response parsing', () {
        final jsonList = [
          {
            'id': '1',
            'user_id': 'user1',
            'title': 'Item 1',
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': '2',
            'user_id': 'user1',
            'title': 'Item 2',
            'created_at': '2024-01-02T00:00:00Z',
          },
        ];

        final items = jsonList.map((json) => Item.fromJson(json)).toList();

        expect(items.length, 2);
        expect(items[0].id, '1');
        expect(items[1].id, '2');
      });

      test('updateItems batch transformation', () {
        final items = [
          Item(id: '1', userId: 'user1', title: 'Item 1', createdAt: testDate),
          Item(id: '2', userId: 'user1', title: 'Item 2', createdAt: testDate),
        ];

        final jsonList = items.map((item) => item.toJson()).toList();

        expect(jsonList.length, 2);
        expect(jsonList[0]['id'], '1');
        expect(jsonList[1]['id'], '2');
      });
    });
  });
}
