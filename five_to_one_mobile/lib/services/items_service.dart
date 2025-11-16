import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import 'supabase_service.dart';

class ItemsService {
  final SupabaseClient _client = SupabaseService.client;

  /// Create a new item
  Future<Item> createItem(Item item) async {
    final response = await _client
        .from('items')
        .insert(item.toJson())
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Get all root items (goals in V1, life areas in V2)
  Future<List<Item>> getRootItems() async {
    final response = await _client
        .from('items')
        .select()
        .isFilter('parent_id', null)
        .eq('user_id', SupabaseService.userId)
        .order('position');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get top 5 priority goals (V1)
  Future<List<Item>> getTopFiveGoals() async {
    final response = await _client
        .from('items')
        .select()
        .isFilter('parent_id', null)
        .not('priority', 'is', null)
        .eq('user_id', SupabaseService.userId)
        .order('priority')
        .limit(5);

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get avoid list (the 20 deprioritized goals)
  Future<List<Item>> getAvoidList() async {
    final response = await _client
        .from('items')
        .select()
        .isFilter('parent_id', null)
        .eq('is_avoided', true)
        .eq('user_id', SupabaseService.userId)
        .order('position');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get children of a specific item
  Future<List<Item>> getChildren(String parentId) async {
    final response = await _client
        .from('items')
        .select()
        .eq('parent_id', parentId)
        .eq('user_id', SupabaseService.userId)
        .order('position');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get item by ID
  Future<Item?> getItem(String itemId) async {
    final response = await _client
        .from('items')
        .select()
        .eq('id', itemId)
        .eq('user_id', SupabaseService.userId)
        .maybeSingle();

    return response != null ? Item.fromJson(response) : null;
  }

  /// Update an item
  Future<Item> updateItem(Item item) async {
    final response = await _client
        .from('items')
        .update(item.toJson())
        .eq('id', item.id)
        .eq('user_id', SupabaseService.userId)
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Delete an item (and all its children due to CASCADE)
  Future<void> deleteItem(String itemId) async {
    await _client
        .from('items')
        .delete()
        .eq('id', itemId)
        .eq('user_id', SupabaseService.userId);
  }

  /// Mark item as completed
  Future<Item> completeItem(String itemId) async {
    final response = await _client
        .from('items')
        .update({'completed_at': DateTime.now().toIso8601String()})
        .eq('id', itemId)
        .eq('user_id', SupabaseService.userId)
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Mark item as incomplete
  Future<Item> uncompleteItem(String itemId) async {
    final response = await _client
        .from('items')
        .update({'completed_at': null})
        .eq('id', itemId)
        .eq('user_id', SupabaseService.userId)
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Save user's 25 goals after prioritization
  Future<void> saveGoals(List<String> rankedGoals) async {
    final userId = SupabaseService.userId;

    // Create items for all goals
    final items = rankedGoals.asMap().entries.map((entry) {
      final index = entry.key;
      final title = entry.value;

      return {
        'user_id': userId,
        'parent_id': null, // Root level (goals)
        'title': title,
        'position': index,
        'priority': index < 5 ? index + 1 : null, // Top 5 get priority 1-5
        'is_avoided': index >= 5, // Rest are avoided
        'created_at': DateTime.now().toIso8601String(),
      };
    }).toList();

    // Batch insert
    await _client.from('items').insert(items);
  }

  /// Get entire tree for an item (recursive)
  Future<Item> getItemTree(String itemId) async {
    final item = await getItem(itemId);
    if (item == null) {
      throw Exception('Item not found');
    }

    // Recursively load children
    final children = await getChildren(itemId);
    final childrenWithTrees = await Future.wait(
      children.map((child) => getItemTree(child.id)),
    );

    return item.copyWith(children: childrenWithTrees);
  }

  /// Delete all items for current user (for testing/reset)
  Future<void> deleteAllItems() async {
    await _client
        .from('items')
        .delete()
        .eq('user_id', SupabaseService.userId);
  }

  // ============================================
  // Framework Operations
  // ============================================

  /// Add a framework to a task
  ///
  /// Adds frameworkId to the task's frameworkIds array.
  Future<Item> addFramework(String taskId, String frameworkId) async {
    final item = await getItem(taskId);
    if (item == null) throw Exception('Item not found');

    final updatedFrameworks = [...item.frameworkIds];
    if (!updatedFrameworks.contains(frameworkId)) {
      updatedFrameworks.add(frameworkId);
    }

    final response = await _client
        .from('items')
        .update({'framework_ids': updatedFrameworks})
        .eq('id', taskId)
        .eq('user_id', SupabaseService.userId)
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Remove a framework from a task
  ///
  /// Removes frameworkId from the task's frameworkIds array.
  Future<Item> removeFramework(String taskId, String frameworkId) async {
    final item = await getItem(taskId);
    if (item == null) throw Exception('Item not found');

    final updatedFrameworks = [...item.frameworkIds]
      ..remove(frameworkId);

    final response = await _client
        .from('items')
        .update({'framework_ids': updatedFrameworks})
        .eq('id', taskId)
        .eq('user_id', SupabaseService.userId)
        .select()
        .single();

    return Item.fromJson(response);
  }

  /// Update multiple items at once
  ///
  /// Useful for batch updates during framework application.
  Future<List<Item>> updateItems(List<Item> items) async {
    final updates = items.map((item) => item.toJson()).toList();

    final response = await _client
        .from('items')
        .upsert(updates)
        .select();

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get all items with a specific framework
  ///
  /// Uses PostgreSQL array contains operator.
  Future<List<Item>> getItemsWithFramework(String frameworkId) async {
    final response = await _client
        .from('items')
        .select()
        .contains('framework_ids', [frameworkId])
        .eq('user_id', SupabaseService.userId)
        .order('created_at');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get all urgent tasks (Eisenhower framework)
  Future<List<Item>> getUrgentTasks() async {
    final response = await _client
        .from('items')
        .select()
        .eq('is_urgent', true)
        .eq('user_id', SupabaseService.userId)
        .order('created_at');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get all important tasks (Eisenhower framework)
  Future<List<Item>> getImportantTasks() async {
    final response = await _client
        .from('items')
        .select()
        .eq('is_important', true)
        .eq('user_id', SupabaseService.userId)
        .order('created_at');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get scheduled tasks for a date range (Time Blocking framework)
  Future<List<Item>> getScheduledTasks(DateTime start, DateTime end) async {
    final response = await _client
        .from('items')
        .select()
        .gte('scheduled_for', start.toIso8601String())
        .lte('scheduled_for', end.toIso8601String())
        .eq('user_id', SupabaseService.userId)
        .order('scheduled_for');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }
}
