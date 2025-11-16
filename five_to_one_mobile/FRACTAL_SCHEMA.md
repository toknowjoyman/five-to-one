# Fractal Schema Design

## The Core Insight

**Life areas, goals, tasks, and subtasks are all the same thing** - just at different levels of hierarchy. Instead of separate tables, we use **one self-referential table** that can represent infinite depth.

## The Single `items` Table

```sql
items:
  - id
  - user_id
  - parent_id (references items.id) ← The magic!
  - title
  - position
  - [optional metadata fields]
```

The `parent_id` creates the fractal structure:
- `parent_id = NULL` → Root item (Life Area in V2, Goal in V1)
- `parent_id = some_id` → Child of that item

## How It Works: V1 vs V2

### **V1 (Current - No Life Areas)**

```
Root Items (parent_id = NULL) = GOALS
├─ priority: 1-5 → Top 5 goals
├─ is_avoided: true → Avoid list (the 20)
└─ Children (parent_id = goal_id) = TASKS
    └─ Children (parent_id = task_id) = SUBTASKS
        └─ Children (parent_id = subtask_id) = SUB-SUBTASKS
            └─ ...infinitely
```

**Example V1 Data:**

```json
// Goal 1 (Top Priority)
{
  "id": "goal-1",
  "parent_id": null,
  "title": "Get in shape",
  "priority": 1,
  "is_avoided": false
}

// Task under Goal 1
{
  "id": "task-1",
  "parent_id": "goal-1",
  "title": "Workout 3x per week",
  "is_urgent": true,
  "is_important": true
}

// Subtask under Task 1
{
  "id": "subtask-1",
  "parent_id": "task-1",
  "title": "Monday: Leg day"
}
```

### **V2 (Future - With Life Areas)**

```
Root Items (parent_id = NULL) = LIFE AREAS (5 of these)
├─ color: "#6B2E9E"
├─ icon: "work"
└─ Children (parent_id = life_area_id) = GOALS (5/25 per area)
    ├─ priority: 1-5 → Top 5 goals per area
    ├─ is_avoided: true → Avoid list per area
    └─ Children (parent_id = goal_id) = TASKS
        └─ Children (parent_id = task_id) = SUBTASKS
            └─ ...infinitely
```

**Example V2 Data:**

```json
// Life Area (Health)
{
  "id": "area-1",
  "parent_id": null,
  "title": "Health & Fitness",
  "color": "#E74C3C",
  "icon": "fitness"
}

// Goal under Life Area
{
  "id": "goal-1",
  "parent_id": "area-1",
  "title": "Get in shape",
  "priority": 1
}

// Task under Goal
{
  "id": "task-1",
  "parent_id": "goal-1",
  "title": "Workout 3x per week",
  "is_urgent": true
}

// Subtask under Task
{
  "id": "subtask-1",
  "parent_id": "task-1",
  "title": "Monday: Leg day"
}
```

## Field Usage by Level

Different fields are used at different hierarchy levels:

| Field | Life Area | Goal | Task | Subtask |
|-------|-----------|------|------|---------|
| `title` | ✅ | ✅ | ✅ | ✅ |
| `parent_id` | NULL | area_id / NULL | goal_id | task_id |
| `position` | ✅ | ✅ | ✅ | ✅ |
| `priority` | - | ✅ (1-5) | - | - |
| `is_avoided` | - | ✅ | - | - |
| `is_urgent` | - | - | ✅ | ✅ |
| `is_important` | - | - | ✅ | ✅ |
| `color` | ✅ | - | - | - |
| `icon` | ✅ | - | - | - |
| `completed_at` | - | ✅ | ✅ | ✅ |

## Common Queries

### Get Root Items (V1: Goals, V2: Life Areas)

```dart
final roots = await supabase
  .from('items')
  .select()
  .is_('parent_id', null)
  .eq('user_id', userId);
```

### Get Top 5 Goals (V1)

```dart
final topFive = await supabase
  .from('items')
  .select()
  .is_('parent_id', null)  // Root level
  .not('priority', 'is', null)
  .eq('user_id', userId)
  .order('priority')
  .limit(5);
```

### Get Avoid List (V1)

```dart
final avoidList = await supabase
  .from('items')
  .select()
  .is_('parent_id', null)
  .eq('is_avoided', true)
  .eq('user_id', userId);
```

### Get Children of Any Item

```dart
final children = await supabase
  .from('items')
  .select()
  .eq('parent_id', parentId)
  .order('position');
```

### Get Entire Tree (Recursive)

```dart
// Use the SQL function
final tree = await supabase
  .rpc('get_descendants', params: {'item_uuid': itemId});
```

### Get Breadcrumb Path

```dart
// Use the SQL function
final path = await supabase
  .rpc('get_ancestors', params: {'item_uuid': itemId});
```

## Benefits of This Design

### 1. **Simplicity**
- One table instead of 3+
- One model class instead of 3+
- Same CRUD operations at every level

### 2. **Flexibility**
- Add new hierarchy levels without schema changes
- User can organize however they want
- Future features (tags, templates) work at any level

### 3. **True Fractal**
```dart
// Same code works at ANY level
Future<List<Item>> getChildren(String parentId) async {
  return supabase.from('items')
    .select()
    .eq('parent_id', parentId);
}

// Works for:
// - Life Area → Goals
// - Goal → Tasks
// - Task → Subtasks
// - Subtask → Sub-subtasks
// - Forever!
```

### 4. **Performance**
- Single index on `parent_id` covers all lookups
- Recursive SQL functions for complex queries
- No JOINs needed for basic operations

### 5. **Migration-Friendly**
V1 to V2 migration is just:
```sql
-- Create 5 life areas
INSERT INTO items (user_id, title, color, icon)
VALUES (user_id, 'Work', '#6B2E9E', 'work');

-- Re-parent existing goals
UPDATE items
SET parent_id = 'life_area_id'
WHERE id IN (user_selected_goal_ids);
```

## UI Rendering Logic

The UI decides how to render based on depth:

```dart
Widget buildItem(Item item) {
  // Calculate depth from ancestors
  final depth = item.depth ?? 0;

  switch (depth) {
    case 0:
      // V2: Life Area or V1: Goal
      return item.color != null
        ? LifeAreaCard(item)  // Has color = life area
        : GoalCard(item);     // No color = V1 goal

    case 1:
      // V2: Goal under life area
      return GoalCard(item);

    default:
      // Tasks at any depth
      return TaskCard(item);
  }
}
```

## Example: Building a Tree

```dart
class ItemService {
  // Get item with all descendants (recursive)
  Future<Item> getItemTree(String itemId) async {
    final item = await supabase
      .from('items')
      .select()
      .eq('id', itemId)
      .single();

    // Get direct children
    final children = await supabase
      .from('items')
      .select()
      .eq('parent_id', itemId)
      .order('position');

    // Recursively load children's children
    item.children = await Future.wait(
      children.map((child) => getItemTree(child['id']))
    );

    return Item.fromJson(item);
  }

  // Get all roots with their first-level children
  Future<List<Item>> getRootsWithGoals(String userId) async {
    final roots = await supabase
      .from('items')
      .select()
      .is_('parent_id', null)
      .eq('user_id', userId)
      .order('position');

    for (var root in roots) {
      root.children = await supabase
        .from('items')
        .select()
        .eq('parent_id', root.id)
        .order('position');
    }

    return roots.map((r) => Item.fromJson(r)).toList();
  }
}
```

## Philosophy

This design embodies the app's core philosophy:
- **Everything breaks down the same way**
- **Complexity emerges from simple, repeated patterns**
- **One rule, infinite applications**

Just like the 5/25 method itself - one simple rule (prioritize 5, avoid 20) that works at every level of life.

---

*"Five to one, baby. One in five. No one here gets out alive."*

The fractal goes all the way down. 🎯
