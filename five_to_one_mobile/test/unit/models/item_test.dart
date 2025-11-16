import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/models/item.dart';

void main() {
  group('Item Model', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('2024-01-01T00:00:00Z');
    });

    group('Constructor', () {
      test('creates item with required fields', () {
        final item = Item(
          id: '123',
          userId: 'user1',
          title: 'Test Item',
          createdAt: testDate,
        );

        expect(item.id, '123');
        expect(item.userId, 'user1');
        expect(item.title, 'Test Item');
        expect(item.createdAt, testDate);
        expect(item.parentId, isNull);
        expect(item.position, 0);
        expect(item.frameworkIds, isEmpty);
        expect(item.isAvoided, false);
        expect(item.isUrgent, false);
        expect(item.isImportant, false);
      });

      test('creates item with all optional fields', () {
        final scheduled = DateTime.parse('2024-12-31T10:00:00Z');
        final completed = DateTime.parse('2024-06-15T15:30:00Z');

        final item = Item(
          id: '456',
          userId: 'user2',
          parentId: 'parent123',
          title: 'Complex Item',
          position: 5,
          frameworkIds: ['buffett-munger', 'eisenhower'],
          priority: 3,
          isAvoided: true,
          isUrgent: true,
          isImportant: true,
          scheduledFor: scheduled,
          durationMinutes: 60,
          kanbanColumn: 'in-progress',
          columnPosition: 2,
          color: '#FF5733',
          icon: 'star',
          completedAt: completed,
          createdAt: testDate,
          children: [],
          depth: 2,
        );

        expect(item.id, '456');
        expect(item.parentId, 'parent123');
        expect(item.position, 5);
        expect(item.frameworkIds, ['buffett-munger', 'eisenhower']);
        expect(item.priority, 3);
        expect(item.isAvoided, true);
        expect(item.isUrgent, true);
        expect(item.isImportant, true);
        expect(item.scheduledFor, scheduled);
        expect(item.durationMinutes, 60);
        expect(item.kanbanColumn, 'in-progress');
        expect(item.columnPosition, 2);
        expect(item.color, '#FF5733');
        expect(item.icon, 'star');
        expect(item.completedAt, completed);
        expect(item.depth, 2);
      });
    });

    group('Computed Properties', () {
      test('isCompleted returns true when completedAt is set', () {
        final completed = Item(
          id: '1',
          userId: 'user1',
          title: 'Done',
          createdAt: testDate,
          completedAt: testDate,
        );

        expect(completed.isCompleted, true);
      });

      test('isCompleted returns false when completedAt is null', () {
        final incomplete = Item(
          id: '1',
          userId: 'user1',
          title: 'Not Done',
          createdAt: testDate,
        );

        expect(incomplete.isCompleted, false);
      });

      test('isRoot returns true when parentId is null', () {
        final root = Item(
          id: '1',
          userId: 'user1',
          title: 'Root Item',
          createdAt: testDate,
        );

        expect(root.isRoot, true);
      });

      test('isRoot returns false when parentId is set', () {
        final child = Item(
          id: '1',
          userId: 'user1',
          parentId: 'parent123',
          title: 'Child Item',
          createdAt: testDate,
        );

        expect(child.isRoot, false);
      });

      test('hasChildren returns true when children list is not empty', () {
        final child = Item(
          id: '2',
          userId: 'user1',
          title: 'Child',
          createdAt: testDate,
        );

        final parent = Item(
          id: '1',
          userId: 'user1',
          title: 'Parent',
          createdAt: testDate,
          children: [child],
        );

        expect(parent.hasChildren, true);
      });

      test('hasChildren returns false when children is null', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'No Children',
          createdAt: testDate,
        );

        expect(item.hasChildren, false);
      });

      test('hasChildren returns false when children list is empty', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Empty Children',
          createdAt: testDate,
          children: [],
        );

        expect(item.hasChildren, false);
      });

      test('isTopPriority returns true for priority 1-5', () {
        for (int i = 1; i <= 5; i++) {
          final item = Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Priority $i',
            priority: i,
            createdAt: testDate,
          );
          expect(item.isTopPriority, true, reason: 'Priority $i should be top priority');
        }
      });

      test('isTopPriority returns false for priority > 5', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Low Priority',
          priority: 6,
          createdAt: testDate,
        );

        expect(item.isTopPriority, false);
      });

      test('isTopPriority returns false when priority is null', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'No Priority',
          createdAt: testDate,
        );

        expect(item.isTopPriority, false);
      });
    });

    group('ItemType Inference', () {
      test('returns unknown when depth is null', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Unknown Depth',
          createdAt: testDate,
        );

        expect(item.type, ItemType.unknown);
      });

      test('returns lifeArea for depth 0', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Life Area',
          createdAt: testDate,
          depth: 0,
        );

        expect(item.type, ItemType.lifeArea);
      });

      test('returns goal for depth 1', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Goal',
          createdAt: testDate,
          depth: 1,
        );

        expect(item.type, ItemType.goal);
      });

      test('returns task for depth 2+', () {
        for (int i = 2; i <= 5; i++) {
          final item = Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Task at depth $i',
            createdAt: testDate,
            depth: i,
          );
          expect(item.type, ItemType.task, reason: 'Depth $i should be task type');
        }
      });
    });

    group('Eisenhower Matrix Tags', () {
      test('tagColor is red when both urgent and important', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Crisis',
          isUrgent: true,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFFE74C3C);
      });

      test('tagColor is red when urgent only', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Urgent',
          isUrgent: true,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFFE74C3C);
      });

      test('tagColor is blue when important only', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Important',
          isUrgent: false,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFF3498DB);
      });

      test('tagColor is gray when neither urgent nor important', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Neither',
          isUrgent: false,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFF95A5A6);
      });

      test('tagLabel shows URGENT & IMPORTANT for both', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Crisis',
          isUrgent: true,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagLabel, 'URGENT & IMPORTANT');
      });

      test('tagLabel shows URGENT when only urgent', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Urgent',
          isUrgent: true,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagLabel, 'URGENT');
      });

      test('tagLabel shows IMPORTANT when only important', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Important',
          isUrgent: false,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagLabel, 'IMPORTANT');
      });

      test('tagLabel is empty when neither urgent nor important', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Neither',
          isUrgent: false,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagLabel, '');
      });
    });

    group('JSON Serialization', () {
      test('fromJson deserializes minimal item correctly', () {
        final json = {
          'id': '123',
          'user_id': 'user1',
          'parent_id': null,
          'title': 'Test Item',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final item = Item.fromJson(json);

        expect(item.id, '123');
        expect(item.userId, 'user1');
        expect(item.parentId, isNull);
        expect(item.title, 'Test Item');
        expect(item.position, 0);
        expect(item.frameworkIds, isEmpty);
        expect(item.isAvoided, false);
        expect(item.isUrgent, false);
        expect(item.isImportant, false);
        expect(item.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
      });

      test('fromJson deserializes complete item correctly', () {
        final json = {
          'id': '456',
          'user_id': 'user2',
          'parent_id': 'parent123',
          'title': 'Complex Item',
          'position': 5,
          'framework_ids': ['buffett-munger', 'eisenhower'],
          'priority': 3,
          'is_avoided': true,
          'is_urgent': true,
          'is_important': true,
          'scheduled_for': '2024-12-31T10:00:00Z',
          'duration_minutes': 60,
          'kanban_column': 'in-progress',
          'column_position': 2,
          'color': '#FF5733',
          'icon': 'star',
          'completed_at': '2024-06-15T15:30:00Z',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final item = Item.fromJson(json);

        expect(item.id, '456');
        expect(item.userId, 'user2');
        expect(item.parentId, 'parent123');
        expect(item.title, 'Complex Item');
        expect(item.position, 5);
        expect(item.frameworkIds, ['buffett-munger', 'eisenhower']);
        expect(item.priority, 3);
        expect(item.isAvoided, true);
        expect(item.isUrgent, true);
        expect(item.isImportant, true);
        expect(item.scheduledFor, DateTime.parse('2024-12-31T10:00:00Z'));
        expect(item.durationMinutes, 60);
        expect(item.kanbanColumn, 'in-progress');
        expect(item.columnPosition, 2);
        expect(item.color, '#FF5733');
        expect(item.icon, 'star');
        expect(item.completedAt, DateTime.parse('2024-06-15T15:30:00Z'));
        expect(item.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
      });

      test('toJson serializes minimal item correctly', () {
        final item = Item(
          id: '123',
          userId: 'user1',
          title: 'Test Item',
          createdAt: testDate,
        );

        final json = item.toJson();

        expect(json['id'], '123');
        expect(json['user_id'], 'user1');
        expect(json['parent_id'], isNull);
        expect(json['title'], 'Test Item');
        expect(json['position'], 0);
        expect(json['framework_ids'], isEmpty);
        expect(json['priority'], isNull);
        expect(json['is_avoided'], false);
        expect(json['is_urgent'], false);
        expect(json['is_important'], false);
        expect(json['created_at'], '2024-01-01T00:00:00.000Z');
      });

      test('toJson serializes complete item correctly', () {
        final scheduled = DateTime.parse('2024-12-31T10:00:00Z');
        final completed = DateTime.parse('2024-06-15T15:30:00Z');

        final item = Item(
          id: '456',
          userId: 'user2',
          parentId: 'parent123',
          title: 'Complex Item',
          position: 5,
          frameworkIds: ['buffett-munger', 'eisenhower'],
          priority: 3,
          isAvoided: true,
          isUrgent: true,
          isImportant: true,
          scheduledFor: scheduled,
          durationMinutes: 60,
          kanbanColumn: 'in-progress',
          columnPosition: 2,
          color: '#FF5733',
          icon: 'star',
          completedAt: completed,
          createdAt: testDate,
        );

        final json = item.toJson();

        expect(json['id'], '456');
        expect(json['user_id'], 'user2');
        expect(json['parent_id'], 'parent123');
        expect(json['title'], 'Complex Item');
        expect(json['position'], 5);
        expect(json['framework_ids'], ['buffett-munger', 'eisenhower']);
        expect(json['priority'], 3);
        expect(json['is_avoided'], true);
        expect(json['is_urgent'], true);
        expect(json['is_important'], true);
        expect(json['scheduled_for'], '2024-12-31T10:00:00.000Z');
        expect(json['duration_minutes'], 60);
        expect(json['kanban_column'], 'in-progress');
        expect(json['column_position'], 2);
        expect(json['color'], '#FF5733');
        expect(json['icon'], 'star');
        expect(json['completed_at'], '2024-06-15T15:30:00.000Z');
        expect(json['created_at'], '2024-01-01T00:00:00.000Z');
      });

      test('round-trip serialization preserves data', () {
        final original = Item(
          id: '789',
          userId: 'user3',
          parentId: 'parent456',
          title: 'Round Trip Test',
          position: 10,
          frameworkIds: ['eisenhower'],
          priority: 1,
          isUrgent: true,
          isImportant: false,
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
        expect(restored.isUrgent, original.isUrgent);
        expect(restored.isImportant, original.isImportant);
        expect(restored.createdAt, original.createdAt);
      });
    });

    group('copyWith', () {
      late Item original;

      setUp(() {
        original = Item(
          id: '123',
          userId: 'user1',
          parentId: 'parent1',
          title: 'Original',
          position: 5,
          frameworkIds: ['buffett-munger'],
          priority: 3,
          isAvoided: false,
          isUrgent: true,
          isImportant: false,
          createdAt: testDate,
        );
      });

      test('returns identical item when no parameters provided', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.userId, original.userId);
        expect(copy.parentId, original.parentId);
        expect(copy.title, original.title);
        expect(copy.position, original.position);
        expect(copy.frameworkIds, original.frameworkIds);
        expect(copy.priority, original.priority);
        expect(copy.isAvoided, original.isAvoided);
        expect(copy.isUrgent, original.isUrgent);
        expect(copy.isImportant, original.isImportant);
      });

      test('updates title only', () {
        final copy = original.copyWith(title: 'Updated Title');

        expect(copy.title, 'Updated Title');
        expect(copy.id, original.id);
        expect(copy.userId, original.userId);
      });

      test('updates priority only', () {
        final copy = original.copyWith(priority: 1);

        expect(copy.priority, 1);
        expect(copy.title, original.title);
        expect(copy.position, original.position);
      });

      test('updates multiple fields', () {
        final copy = original.copyWith(
          title: 'New Title',
          priority: 2,
          isUrgent: false,
          isImportant: true,
        );

        expect(copy.title, 'New Title');
        expect(copy.priority, 2);
        expect(copy.isUrgent, false);
        expect(copy.isImportant, true);
        expect(copy.id, original.id);
      });

      test('updates frameworkIds with new list', () {
        final copy = original.copyWith(
          frameworkIds: ['eisenhower', 'kanban'],
        );

        expect(copy.frameworkIds, ['eisenhower', 'kanban']);
        expect(copy.title, original.title);
      });

      test('updates completedAt to mark as completed', () {
        final completionDate = DateTime.parse('2024-06-15T10:00:00Z');
        final copy = original.copyWith(completedAt: completionDate);

        expect(copy.completedAt, completionDate);
        expect(copy.isCompleted, true);
        expect(original.isCompleted, false);
      });

      test('updates children list', () {
        final child1 = Item(
          id: 'child1',
          userId: 'user1',
          title: 'Child 1',
          createdAt: testDate,
        );

        final child2 = Item(
          id: 'child2',
          userId: 'user1',
          title: 'Child 2',
          createdAt: testDate,
        );

        final copy = original.copyWith(children: [child1, child2]);

        expect(copy.hasChildren, true);
        expect(copy.children!.length, 2);
        expect(original.hasChildren, false);
      });

      test('updates depth', () {
        final copy = original.copyWith(depth: 2);

        expect(copy.depth, 2);
        expect(copy.type, ItemType.task);
      });
    });

    group('Edge Cases', () {
      test('handles empty framework_ids array in JSON', () {
        final json = {
          'id': '1',
          'user_id': 'user1',
          'title': 'Test',
          'framework_ids': [],
          'created_at': '2024-01-01T00:00:00Z',
        };

        final item = Item.fromJson(json);
        expect(item.frameworkIds, isEmpty);
      });

      test('handles missing optional fields in JSON', () {
        final json = {
          'id': '1',
          'user_id': 'user1',
          'title': 'Minimal',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final item = Item.fromJson(json);

        expect(item.priority, isNull);
        expect(item.scheduledFor, isNull);
        expect(item.durationMinutes, isNull);
        expect(item.kanbanColumn, isNull);
        expect(item.completedAt, isNull);
        expect(item.color, isNull);
        expect(item.icon, isNull);
      });

      test('handles zero position', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Zero Position',
          position: 0,
          createdAt: testDate,
        );

        expect(item.position, 0);
      });

      test('handles negative depth (edge case)', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Negative Depth',
          createdAt: testDate,
          depth: -1,
        );

        // Depth -1 doesn't match any case, so returns default (task)
        expect(item.type, ItemType.task);
      });
    });
  });
}
