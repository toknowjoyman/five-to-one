import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/models/item.dart';
import 'package:five_to_one/frameworks/eisenhower_matrix_framework.dart';

void main() {
  group('EisenhowerMatrixFramework', () {
    late EisenhowerMatrixFramework framework;
    late DateTime testDate;

    setUp(() {
      framework = EisenhowerMatrixFramework();
      testDate = DateTime.parse('2024-01-01T00:00:00Z');
    });

    group('Framework Properties', () {
      test('has correct metadata', () {
        expect(framework.id, 'eisenhower');
        expect(framework.name, 'Eisenhower Matrix');
        expect(framework.shortName, 'Eisenhower');
        expect(framework.description, 'Urgent vs Important triage');
      });
    });

    group('canApplyToTask', () {
      test('returns true when task has at least 1 incomplete child', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          Item(
            id: 'child1',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child 1',
            createdAt: testDate,
          ),
        ];

        expect(framework.canApplyToTask(task, children), true);
      });

      test('returns true when task has multiple incomplete children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          10,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child $i',
            createdAt: testDate,
          ),
        );

        expect(framework.canApplyToTask(task, children), true);
      });

      test('returns false when all children are completed', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          5,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child $i',
            createdAt: testDate,
            completedAt: testDate,
          ),
        );

        expect(framework.canApplyToTask(task, children), false);
      });

      test('returns true when at least one child is incomplete', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          ...List.generate(
            4,
            (i) => Item(
              id: 'complete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Complete $i',
              createdAt: testDate,
              completedAt: testDate,
            ),
          ),
          Item(
            id: 'incomplete1',
            userId: 'user1',
            parentId: 'task1',
            title: 'Incomplete',
            createdAt: testDate,
          ),
        ];

        expect(framework.canApplyToTask(task, children), true);
      });

      test('returns false when no children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        expect(framework.canApplyToTask(task, []), false);
      });
    });

    group('getRequirementMessage', () {
      test('returns null when task has incomplete children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          Item(
            id: 'child1',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child 1',
            createdAt: testDate,
          ),
        ];

        expect(framework.getRequirementMessage(task, children), isNull);
      });

      test('returns message when no incomplete children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          Item(
            id: 'child1',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child 1',
            createdAt: testDate,
            completedAt: testDate,
          ),
        ];

        final message = framework.getRequirementMessage(task, children);
        expect(message, isNotNull);
        expect(message, 'Requires at least 1 subtask');
      });

      test('returns message when no children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final message = framework.getRequirementMessage(task, []);
        expect(message, 'Requires at least 1 subtask');
      });
    });

    group('filterForPriority', () {
      test('returns only urgent items', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Urgent & Important',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Important Only',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'Urgent Only',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
          Item(
            id: '4',
            userId: 'user1',
            title: 'Neither',
            isUrgent: false,
            isImportant: false,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 2);
        expect(filtered.every((item) => item.isUrgent), true);
        expect(filtered[0].id, '1');
        expect(filtered[1].id, '3');
      });

      test('returns empty list when no urgent items', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Important Only',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Neither',
            isUrgent: false,
            isImportant: false,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered, isEmpty);
      });

      test('handles empty input list', () {
        final filtered = framework.filterForPriority([]);

        expect(filtered, isEmpty);
      });

      test('includes all urgent items regardless of important status', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Urgent & Important',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Urgent but not Important',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 2);
        expect(filtered.every((item) => item.isUrgent), true);
      });
    });

    group('getInsights', () {
      test('calculates correct insights for all quadrants', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          // Quadrant 1: Urgent & Important (Do First)
          Item(
            id: '1',
            userId: 'user1',
            title: 'Crisis',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Deadline',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
          // Quadrant 2: Not Urgent & Important (Schedule)
          Item(
            id: '3',
            userId: 'user1',
            title: 'Planning',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '4',
            userId: 'user1',
            title: 'Strategic Work',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          Item(
            id: '5',
            userId: 'user1',
            title: 'Development',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          // Quadrant 3: Urgent & Not Important (Delegate)
          Item(
            id: '6',
            userId: 'user1',
            title: 'Interruption',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
          // Quadrant 4: Neither (Eliminate)
          Item(
            id: '7',
            userId: 'user1',
            title: 'Distraction',
            isUrgent: false,
            isImportant: false,
            createdAt: testDate,
          ),
        ];

        final insights = framework.getInsights(task, children);

        expect(insights, isNotNull);
        expect(insights!['urgent_count'], 3); // Q1 (2) + Q3 (1)
        expect(insights['important_count'], 5); // Q1 (2) + Q2 (3)
        expect(insights['urgent_and_important_count'], 2); // Q1 only
        expect(insights['total_count'], 7);
      });

      test('handles all tasks in one quadrant', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          5,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            title: 'Urgent & Important $i',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
        );

        final insights = framework.getInsights(task, children);

        expect(insights!['urgent_count'], 5);
        expect(insights['important_count'], 5);
        expect(insights['urgent_and_important_count'], 5);
        expect(insights['total_count'], 5);
      });

      test('handles empty children list', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final insights = framework.getInsights(task, []);

        expect(insights!['urgent_count'], 0);
        expect(insights['important_count'], 0);
        expect(insights['urgent_and_important_count'], 0);
        expect(insights['total_count'], 0);
      });

      test('handles tasks with no urgent or important flags', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          3,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            title: 'Neither $i',
            isUrgent: false,
            isImportant: false,
            createdAt: testDate,
          ),
        );

        final insights = framework.getInsights(task, children);

        expect(insights!['urgent_count'], 0);
        expect(insights['important_count'], 0);
        expect(insights['urgent_and_important_count'], 0);
        expect(insights['total_count'], 3);
      });
    });

    group('Eisenhower Matrix Quadrants', () {
      late List<Item> matrixItems;

      setUp(() {
        matrixItems = [
          // Q1: Urgent & Important - Do First
          Item(
            id: 'q1_1',
            userId: 'user1',
            title: 'Q1: Crisis',
            isUrgent: true,
            isImportant: true,
            createdAt: testDate,
          ),
          // Q2: Not Urgent & Important - Schedule
          Item(
            id: 'q2_1',
            userId: 'user1',
            title: 'Q2: Planning',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
          // Q3: Urgent & Not Important - Delegate
          Item(
            id: 'q3_1',
            userId: 'user1',
            title: 'Q3: Interruption',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
          // Q4: Neither - Eliminate
          Item(
            id: 'q4_1',
            userId: 'user1',
            title: 'Q4: Distraction',
            isUrgent: false,
            isImportant: false,
            createdAt: testDate,
          ),
        ];
      });

      test('identifies Quadrant 1 (Do First) correctly', () {
        final q1Items = matrixItems
            .where((item) => item.isUrgent && item.isImportant)
            .toList();

        expect(q1Items.length, 1);
        expect(q1Items[0].id, 'q1_1');
        expect(q1Items[0].tagLabel, 'URGENT & IMPORTANT');
        expect(q1Items[0].tagColor, 0xFFE74C3C);
      });

      test('identifies Quadrant 2 (Schedule) correctly', () {
        final q2Items = matrixItems
            .where((item) => !item.isUrgent && item.isImportant)
            .toList();

        expect(q2Items.length, 1);
        expect(q2Items[0].id, 'q2_1');
        expect(q2Items[0].tagLabel, 'IMPORTANT');
        expect(q2Items[0].tagColor, 0xFF3498DB);
      });

      test('identifies Quadrant 3 (Delegate) correctly', () {
        final q3Items = matrixItems
            .where((item) => item.isUrgent && !item.isImportant)
            .toList();

        expect(q3Items.length, 1);
        expect(q3Items[0].id, 'q3_1');
        expect(q3Items[0].tagLabel, 'URGENT');
        expect(q3Items[0].tagColor, 0xFFE74C3C);
      });

      test('identifies Quadrant 4 (Eliminate) correctly', () {
        final q4Items = matrixItems
            .where((item) => !item.isUrgent && !item.isImportant)
            .toList();

        expect(q4Items.length, 1);
        expect(q4Items[0].id, 'q4_1');
        expect(q4Items[0].tagLabel, '');
        expect(q4Items[0].tagColor, 0xFF95A5A6);
      });

      test('distributes items across all quadrants', () {
        final q1 = matrixItems.where((i) => i.isUrgent && i.isImportant).length;
        final q2 = matrixItems.where((i) => !i.isUrgent && i.isImportant).length;
        final q3 = matrixItems.where((i) => i.isUrgent && !i.isImportant).length;
        final q4 = matrixItems.where((i) => !i.isUrgent && !i.isImportant).length;

        expect(q1 + q2 + q3 + q4, matrixItems.length);
        expect(q1, 1);
        expect(q2, 1);
        expect(q3, 1);
        expect(q4, 1);
      });
    });

    group('Business Logic - Tag Colors and Labels', () {
      test('urgent and important tasks have red color', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Crisis',
          isUrgent: true,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFFE74C3C);
        expect(item.tagLabel, 'URGENT & IMPORTANT');
      });

      test('urgent only tasks have red color', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Interrupt',
          isUrgent: true,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFFE74C3C);
        expect(item.tagLabel, 'URGENT');
      });

      test('important only tasks have blue color', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Strategic',
          isUrgent: false,
          isImportant: true,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFF3498DB);
        expect(item.tagLabel, 'IMPORTANT');
      });

      test('neither urgent nor important tasks have gray color', () {
        final item = Item(
          id: '1',
          userId: 'user1',
          title: 'Distraction',
          isUrgent: false,
          isImportant: false,
          createdAt: testDate,
        );

        expect(item.tagColor, 0xFF95A5A6);
        expect(item.tagLabel, '');
      });
    });

    group('Edge Cases', () {
      test('handles mixed completion states', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Completed Urgent',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
            completedAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Incomplete Urgent',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
        ];

        // Insights count all items, regardless of completion
        final insights = framework.getInsights(task, children);
        expect(insights!['urgent_count'], 2);

        // canApplyToTask only counts incomplete
        expect(framework.canApplyToTask(task, children), true);
      });

      test('filterForPriority includes completed urgent items', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Completed Urgent',
            isUrgent: true,
            createdAt: testDate,
            completedAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Incomplete Urgent',
            isUrgent: true,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 2);
      });

      test('handles tasks with only urgent flag set', () {
        final items = List.generate(
          3,
          (i) => Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Urgent $i',
            isUrgent: true,
            isImportant: false,
            createdAt: testDate,
          ),
        );

        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent',
          createdAt: testDate,
        );

        final insights = framework.getInsights(task, items);

        expect(insights!['urgent_count'], 3);
        expect(insights['important_count'], 0);
        expect(insights['urgent_and_important_count'], 0);
      });

      test('handles tasks with only important flag set', () {
        final items = List.generate(
          3,
          (i) => Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Important $i',
            isUrgent: false,
            isImportant: true,
            createdAt: testDate,
          ),
        );

        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent',
          createdAt: testDate,
        );

        final insights = framework.getInsights(task, items);

        expect(insights!['urgent_count'], 0);
        expect(insights['important_count'], 3);
        expect(insights['urgent_and_important_count'], 0);
      });
    });
  });
}
