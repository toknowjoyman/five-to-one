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
        .is_('parent_id', null)
        .eq('user_id', SupabaseService.userId)
        .order('position');

    return (response as List).map((json) => Item.fromJson(json)).toList();
  }

  /// Get top 5 priority goals (V1)
  Future<List<Item>> getTopFiveGoals() async {
    final response = await _client
        .from('items')
        .select()
        .is_('parent_id', null)
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
        .is_('parent_id', null)
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
}
