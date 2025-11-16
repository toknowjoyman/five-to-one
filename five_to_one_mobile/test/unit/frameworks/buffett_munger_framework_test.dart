import 'package:flutter_test/flutter_test.dart';
import 'package:five_to_one/models/item.dart';
import 'package:five_to_one/frameworks/buffett_munger_framework.dart';

void main() {
  group('BuffettMungerFramework', () {
    late BuffettMungerFramework framework;
    late DateTime testDate;

    setUp(() {
      framework = BuffettMungerFramework();
      testDate = DateTime.parse('2024-01-01T00:00:00Z');
    });

    group('Framework Properties', () {
      test('has correct metadata', () {
        expect(framework.id, 'buffett-munger');
        expect(framework.name, 'Buffett-Munger 5/25');
        expect(framework.shortName, 'BM 5/25');
        expect(framework.description, 'Focus on your top 5, avoid the rest');
      });
    });

    group('canApplyToTask', () {
      test('returns true when task has 5+ incomplete children', () {
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
          ),
        );

        expect(framework.canApplyToTask(task, children), true);
      });

      test('returns true when task has more than 5 incomplete children', () {
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

      test('returns false when task has fewer than 5 incomplete children', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          4,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            parentId: 'task1',
            title: 'Child $i',
            createdAt: testDate,
          ),
        );

        expect(framework.canApplyToTask(task, children), false);
      });

      test('excludes completed children from count', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        // 7 total children: 4 incomplete + 3 completed = only 4 incomplete
        final children = [
          ...List.generate(
            4,
            (i) => Item(
              id: 'incomplete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Incomplete $i',
              createdAt: testDate,
            ),
          ),
          ...List.generate(
            3,
            (i) => Item(
              id: 'complete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Complete $i',
              createdAt: testDate,
              completedAt: testDate,
            ),
          ),
        ];

        expect(framework.canApplyToTask(task, children), false);
      });

      test('returns true when exactly 5 incomplete children (some completed)', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        // 8 total children: 5 incomplete + 3 completed
        final children = [
          ...List.generate(
            5,
            (i) => Item(
              id: 'incomplete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Incomplete $i',
              createdAt: testDate,
            ),
          ),
          ...List.generate(
            3,
            (i) => Item(
              id: 'complete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Complete $i',
              createdAt: testDate,
              completedAt: testDate,
            ),
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
      test('returns null when task has 5+ incomplete children', () {
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
          ),
        );

        expect(framework.getRequirementMessage(task, children), isNull);
      });

      test('returns message when fewer than 5 incomplete children', () {
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
            parentId: 'task1',
            title: 'Child $i',
            createdAt: testDate,
          ),
        );

        final message = framework.getRequirementMessage(task, children);
        expect(message, isNotNull);
        expect(message, contains('Requires at least 5 subtasks'));
        expect(message, contains('you have 3'));
      });

      test('shows correct count in message', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        for (int count = 0; count < 5; count++) {
          final children = List.generate(
            count,
            (i) => Item(
              id: 'child$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Child $i',
              createdAt: testDate,
            ),
          );

          final message = framework.getRequirementMessage(task, children);
          expect(message, contains('you have $count'));
        }
      });

      test('excludes completed children from count in message', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        // 6 total: 2 incomplete + 4 completed
        final children = [
          ...List.generate(
            2,
            (i) => Item(
              id: 'incomplete$i',
              userId: 'user1',
              parentId: 'task1',
              title: 'Incomplete $i',
              createdAt: testDate,
            ),
          ),
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
        ];

        final message = framework.getRequirementMessage(task, children);
        expect(message, contains('you have 2'));
      });
    });

    group('filterForPriority', () {
      test('returns only items with priority 1-5', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Priority 1',
            priority: 1,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Priority 3',
            priority: 3,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'No Priority',
            createdAt: testDate,
          ),
          Item(
            id: '4',
            userId: 'user1',
            title: 'Priority 5',
            priority: 5,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 3);
        expect(filtered.every((item) => item.priority != null), true);
        expect(filtered.every((item) => item.priority! <= 5), true);
      });

      test('sorts items by priority ascending', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Priority 5',
            priority: 5,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Priority 2',
            priority: 2,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'Priority 1',
            priority: 1,
            createdAt: testDate,
          ),
          Item(
            id: '4',
            userId: 'user1',
            title: 'Priority 4',
            priority: 4,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 4);
        expect(filtered[0].priority, 1);
        expect(filtered[1].priority, 2);
        expect(filtered[2].priority, 4);
        expect(filtered[3].priority, 5);
      });

      test('excludes items with priority > 5', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'Priority 1',
            priority: 1,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Priority 6',
            priority: 6,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'Priority 10',
            priority: 10,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 1);
        expect(filtered[0].priority, 1);
      });

      test('returns empty list when no priorities', () {
        final items = List.generate(
          5,
          (i) => Item(
            id: 'item$i',
            userId: 'user1',
            title: 'No Priority $i',
            createdAt: testDate,
          ),
        );

        final filtered = framework.filterForPriority(items);

        expect(filtered, isEmpty);
      });

      test('handles empty input list', () {
        final filtered = framework.filterForPriority([]);

        expect(filtered, isEmpty);
      });
    });

    group('getInsights', () {
      test('calculates correct insights for typical scenario', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          // Top 5 priorities (2 completed, 3 incomplete)
          Item(
            id: '1',
            userId: 'user1',
            title: 'Priority 1',
            priority: 1,
            createdAt: testDate,
            completedAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Priority 2',
            priority: 2,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'Priority 3',
            priority: 3,
            createdAt: testDate,
            completedAt: testDate,
          ),
          Item(
            id: '4',
            userId: 'user1',
            title: 'Priority 4',
            priority: 4,
            createdAt: testDate,
          ),
          Item(
            id: '5',
            userId: 'user1',
            title: 'Priority 5',
            priority: 5,
            createdAt: testDate,
          ),
          // Avoid list
          Item(
            id: '6',
            userId: 'user1',
            title: 'Avoided 1',
            isAvoided: true,
            createdAt: testDate,
          ),
          Item(
            id: '7',
            userId: 'user1',
            title: 'Avoided 2',
            isAvoided: true,
            createdAt: testDate,
          ),
        ];

        final insights = framework.getInsights(task, children);

        expect(insights, isNotNull);
        expect(insights!['total_priorities'], 5);
        expect(insights['completed_priorities'], 2);
        expect(insights['completion_rate'], 0.4); // 2/5
        expect(insights['avoid_list_count'], 2);
      });

      test('calculates 100% completion rate when all top 5 done', () {
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
            title: 'Priority ${i + 1}',
            priority: i + 1,
            createdAt: testDate,
            completedAt: testDate,
          ),
        );

        final insights = framework.getInsights(task, children);

        expect(insights!['total_priorities'], 5);
        expect(insights['completed_priorities'], 5);
        expect(insights['completion_rate'], 1.0);
      });

      test('calculates 0% completion rate when none completed', () {
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
            title: 'Priority ${i + 1}',
            priority: i + 1,
            createdAt: testDate,
          ),
        );

        final insights = framework.getInsights(task, children);

        expect(insights!['total_priorities'], 5);
        expect(insights['completed_priorities'], 0);
        expect(insights['completion_rate'], 0.0);
      });

      test('handles empty top 5 list', () {
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
            title: 'No Priority',
            createdAt: testDate,
          ),
        ];

        final insights = framework.getInsights(task, children);

        expect(insights!['total_priorities'], 0);
        expect(insights['completed_priorities'], 0);
        expect(insights['completion_rate'], 0.0);
      });

      test('counts avoid list correctly', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          ...List.generate(
            5,
            (i) => Item(
              id: 'priority$i',
              userId: 'user1',
              title: 'Priority ${i + 1}',
              priority: i + 1,
              createdAt: testDate,
            ),
          ),
          ...List.generate(
            20,
            (i) => Item(
              id: 'avoided$i',
              userId: 'user1',
              title: 'Avoided ${i + 1}',
              isAvoided: true,
              createdAt: testDate,
            ),
          ),
        ];

        final insights = framework.getInsights(task, children);

        expect(insights!['avoid_list_count'], 20);
      });

      test('ignores items with priority > 5 in total_priorities', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = [
          ...List.generate(
            3,
            (i) => Item(
              id: 'priority$i',
              userId: 'user1',
              title: 'Priority ${i + 1}',
              priority: i + 1,
              createdAt: testDate,
            ),
          ),
          Item(
            id: 'low_priority',
            userId: 'user1',
            title: 'Priority 10',
            priority: 10,
            createdAt: testDate,
          ),
        ];

        final insights = framework.getInsights(task, children);

        expect(insights!['total_priorities'], 3);
      });
    });

    group('Business Logic - Priority Assignment', () {
      test('top 5 items should have priorities 1-5', () {
        final rankedItems = List.generate(
          25,
          (i) => Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Item ${i + 1}',
            position: i,
            priority: i < 5 ? i + 1 : null,
            isAvoided: i >= 5,
            createdAt: testDate,
          ),
        );

        final topFive = rankedItems.take(5).toList();

        expect(topFive[0].priority, 1);
        expect(topFive[1].priority, 2);
        expect(topFive[2].priority, 3);
        expect(topFive[3].priority, 4);
        expect(topFive[4].priority, 5);
        expect(topFive.every((item) => !item.isAvoided), true);
      });

      test('items beyond top 5 should be marked as avoided', () {
        final rankedItems = List.generate(
          25,
          (i) => Item(
            id: 'item$i',
            userId: 'user1',
            title: 'Item ${i + 1}',
            position: i,
            priority: i < 5 ? i + 1 : null,
            isAvoided: i >= 5,
            createdAt: testDate,
          ),
        );

        final avoided = rankedItems.skip(5).toList();

        expect(avoided.length, 20);
        expect(avoided.every((item) => item.isAvoided), true);
        expect(avoided.every((item) => item.priority == null), true);
      });
    });

    group('Edge Cases', () {
      test('handles exactly 5 children', () {
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
            title: 'Child $i',
            createdAt: testDate,
          ),
        );

        expect(framework.canApplyToTask(task, children), true);
        expect(framework.getRequirementMessage(task, children), isNull);
      });

      test('handles 25 children (full Buffett list)', () {
        final task = Item(
          id: 'task1',
          userId: 'user1',
          title: 'Parent Task',
          createdAt: testDate,
        );

        final children = List.generate(
          25,
          (i) => Item(
            id: 'child$i',
            userId: 'user1',
            title: 'Child $i',
            priority: i < 5 ? i + 1 : null,
            isAvoided: i >= 5,
            createdAt: testDate,
          ),
        );

        final insights = framework.getInsights(task, children);

        expect(insights!['total_priorities'], 5);
        expect(insights['avoid_list_count'], 20);
      });

      test('filterForPriority handles duplicate priorities gracefully', () {
        final items = [
          Item(
            id: '1',
            userId: 'user1',
            title: 'First Priority 1',
            priority: 1,
            createdAt: testDate,
          ),
          Item(
            id: '2',
            userId: 'user1',
            title: 'Second Priority 1',
            priority: 1,
            createdAt: testDate,
          ),
          Item(
            id: '3',
            userId: 'user1',
            title: 'Priority 2',
            priority: 2,
            createdAt: testDate,
          ),
        ];

        final filtered = framework.filterForPriority(items);

        expect(filtered.length, 3);
        expect(filtered[0].priority, 1);
        expect(filtered[1].priority, 1);
        expect(filtered[2].priority, 2);
      });
    });
  });
}
