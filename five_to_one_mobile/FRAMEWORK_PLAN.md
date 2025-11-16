# Framework Implementation Plan

## Product Vision

**Subtask** - A personal productivity app where you can apply different task management frameworks to different tasks, and see unified views across all your work.

---

## Phase 1: Core Framework System (Current Sprint)

### **Launch Frameworks:**
1. **Buffett-Munger 5/25** - Your signature framework
2. **Eisenhower Matrix** - Universal triage system

### **Key Features:**
- ✅ Per-task framework selection
- ✅ Multiple frameworks can apply to same task (composable)
- ✅ Framework picker UI
- ✅ Framework-aware task detail views
- ✅ Simple default (no framework)

---

## Phase 2: Enhanced Frameworks (Next)

### **Additional Frameworks:**
3. **Time Blocking** - Schedule tasks to calendar slots
4. **Kanban Board** - Visual workflow (TBD based on usage)

### **Smart Features:**
- ✅ Hybrid views (e.g., "Show all Urgent tasks")
- ✅ Framework suggestions (AI-powered in future)
- ✅ Cross-framework analytics
- ✅ Quick filters

---

## Technical Architecture

### **1. Data Model Updates**

Add `framework_id` to track which framework applies to each item's children:

```dart
class Item {
  final String id;
  final String? parentId;
  final String title;

  // NEW: Which framework organizes this item's children?
  // Examples: null, 'buffett-munger', 'eisenhower', 'time-blocking'
  final String? frameworkId;

  // Framework-specific metadata (nullable, used based on frameworkId)

  // Buffett-Munger 5/25
  final int? priority;           // 1-5 for top priorities
  final bool isAvoided;          // true for the "avoid 20"

  // Eisenhower Matrix
  final bool isUrgent;
  final bool isImportant;

  // Time Blocking
  final DateTime? scheduledFor;
  final int? durationMinutes;

  // Kanban
  final String? kanbanColumn;    // 'todo', 'in-progress', 'done'
  final int? columnPosition;

  // Future frameworks...
}
```

### **2. Database Migration**

```sql
-- Add framework_id column
ALTER TABLE items ADD COLUMN framework_id TEXT;

-- Add Time Blocking fields
ALTER TABLE items ADD COLUMN scheduled_for TIMESTAMP;
ALTER TABLE items ADD COLUMN duration_minutes INT;

-- Add Kanban fields
ALTER TABLE items ADD COLUMN kanban_column TEXT;
ALTER TABLE items ADD COLUMN column_position INT;

-- Index for framework queries
CREATE INDEX idx_items_framework ON items(framework_id);
CREATE INDEX idx_items_scheduled ON items(scheduled_for) WHERE scheduled_for IS NOT NULL;
```

### **3. Framework Interface**

```dart
abstract class TaskFramework {
  // Identity
  String get id;              // 'buffett-munger', 'eisenhower'
  String get name;            // 'Buffett-Munger 5/25'
  String get shortName;       // 'BM 5/25' (for compact UI)
  String get description;     // 'Prioritize your top 5...'
  IconData get icon;
  Color get color;

  // Applicability
  bool canApplyToTask(Item task, List<Item> children);
  String? getRequirementMessage(Item task, List<Item> children);

  // Setup & Views
  Widget buildSetupFlow(BuildContext context, Item task, List<Item> children, VoidCallback onComplete);
  Widget buildSubtaskView(BuildContext context, Item task);
  Widget buildQuickInfo(BuildContext context, Item task); // Summary badge

  // Actions
  Future<void> applyToTask(Item task, List<Item> children);
  Future<void> removeFromTask(Item task, List<Item> children);

  // Smart Features
  List<Item> filterForPriority(List<Item> items); // For hybrid views
  Map<String, dynamic> getInsights(Item task, List<Item> children);
}
```

### **4. Framework Registry**

```dart
class FrameworkRegistry {
  static final Map<String, TaskFramework> _frameworks = {};

  static void register(TaskFramework framework) {
    _frameworks[framework.id] = framework;
  }

  static TaskFramework? get(String? id) {
    return id != null ? _frameworks[id] : null;
  }

  static List<TaskFramework> getAll() {
    return _frameworks.values.toList();
  }

  static List<TaskFramework> getApplicable(Item task, List<Item> children) {
    return _frameworks.values
        .where((f) => f.canApplyToTask(task, children))
        .toList();
  }
}

// Initialize on app start
void initializeFrameworks() {
  FrameworkRegistry.register(BuffettMungerFramework());
  FrameworkRegistry.register(EisenhowerMatrixFramework());
  // Future: FrameworkRegistry.register(TimeBlockingFramework());
}
```

---

## User Flows

### **Flow 1: First-Time User**

```
1. Sign up / Auth
2. See empty Simple Task List
3. Add tasks naturally
   - "Launch website"
   - "Write blog post"
   - "Learn Flutter"
4. Tap "Launch website"
5. Add 20+ subtasks (features, ideas)
6. See "Apply Framework" button
7. Tap → Framework Picker appears
8. Choose "Buffett-Munger 5/25"
9. Setup flow: Prioritize top 5
10. View changes to pentagon wheel
11. 15+ subtasks locked as avoid list
```

### **Flow 2: Power User with Multiple Frameworks**

```
Task: "Q1 Goals"
├─ Apply: Buffett-Munger 5/25
│   ├─ Priority 1: Launch product
│   ├─ Priority 2: Hire engineer
│   ├─ Priority 3: Revenue $10k
│   ├─ Priority 4: Build community
│   ├─ Priority 5: Content marketing
│   └─ Avoid List (20 nice-to-haves)

Drill into "Priority 1: Launch product"
├─ Apply: Eisenhower Matrix
│   ├─ Urgent & Important: Fix critical bug
│   ├─ Not Urgent & Important: Write docs
│   ├─ Urgent & Not Important: Design tweak
│   └─ Neither: Polish animations

Drill into "Urgent & Important: Fix critical bug"
├─ No framework (simple list)
│   ├─ Reproduce bug
│   ├─ Write test
│   ├─ Fix code
│   └─ Deploy
```

### **Flow 3: Hybrid View - "Show All Urgent"**

```
Dashboard → Filters → "Urgent Tasks"

View shows all tasks marked urgent across entire tree:
├─ [Q1 Goals > Launch product] Fix critical bug
├─ [Q1 Goals > Launch product] Design tweak
├─ [Daily Errands] Pay bills
└─ [Work] Reply to client email

Grouped by parent or flat list - user preference
```

---

## UI Mockups

### **Framework Picker**

```
┌─────────────────────────────────┐
│ Organize Subtasks               │
├─────────────────────────────────┤
│                                 │
│ ○ None (Simple List)            │
│   Default view                  │
│                                 │
│ ● Buffett-Munger 5/25  ⭐      │
│   Focus on 5, avoid the rest    │
│   Requires: 5+ subtasks ✓       │
│                                 │
│ ○ Eisenhower Matrix             │
│   Urgent vs Important triage    │
│   Requires: Any amount ✓        │
│                                 │
│ ○ Time Blocking 🔒              │
│   Schedule to calendar          │
│   [Coming Soon]                 │
│                                 │
│ [Apply Framework]               │
└─────────────────────────────────┘
```

### **Task Detail with Framework Applied**

```
┌─────────────────────────────────┐
│ ← Launch Website                │
│ 📊 Buffett-Munger 5/25          │ ← Framework badge
├─────────────────────────────────┤
│                                 │
│        ╱────────╲               │
│      ╱   [1]     ╲              │
│     │   [2] [3]   │             │ Pentagon view
│      ╲   [4] [5]  ╱              │
│        ╲────────╱               │
│                                 │
│ [🔒 Avoid List (15)]            │
│                                 │
│ [⚙️ Change Framework]           │
└─────────────────────────────────┘
```

### **Framework Badge on Task Card**

```
┌─────────────────────────────────┐
│ ○ Launch Website                │
│   📊 BM 5/25 · 3/5 done         │ ← Compact status
│                            →    │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ○ Daily Errands                 │
│   ⚡ Eisenhower · 2 urgent      │
│                            →    │
└─────────────────────────────────┘
```

---

## Framework-Specific Features

### **Buffett-Munger 5/25**

**Setup Flow:**
1. "You have 27 subtasks. Let's prioritize!"
2. Drag-to-rank interface
3. "Pick your top 5"
4. Lockdown screen: "These 5. Nothing else."
5. View avoid list (blurred, locked)

**View:**
- Pentagon wheel for top 5
- Progress: "3/5 completed"
- Avoid list button (locked)
- Can re-prioritize (warning: "Are you sure?")

**Insights:**
- "You've completed 60% of your priorities"
- "2 high-priority items due this week"

### **Eisenhower Matrix**

**Setup Flow:**
1. "Tag each task as Urgent and/or Important"
2. Swipe interface or quick-tag
3. Preview 2x2 matrix

**View:**
- 2x2 grid
- Quadrant counts
- Tap quadrant to expand

**Insights:**
- "You have 5 urgent tasks - tackle these first"
- "80% of your tasks are Important - good focus!"

### **Time Blocking** (Phase 2)

**Setup Flow:**
1. "When will you work on these?"
2. Calendar picker
3. Duration estimator
4. Visual schedule

**View:**
- Timeline/calendar view
- Draggable time blocks
- Color-coded by task
- Integration with device calendar (future)

**Insights:**
- "You've scheduled 12 hours this week"
- "3 tasks have no time allocated"

---

## Smart Features

### **1. Framework Suggestions (AI-Powered Future)**

```dart
class FrameworkSuggester {
  static FrameworkSuggestion? analyze(Item task, List<Item> children) {
    // Rule-based (now)
    if (children.length >= 20) {
      return FrameworkSuggestion(
        framework: 'buffett-munger',
        reason: 'You have ${children.length} subtasks. Try prioritizing your top 5!',
        confidence: 0.9,
      );
    }

    if (_hasDeadlineKeywords(task)) {
      return FrameworkSuggestion(
        framework: 'eisenhower',
        reason: 'This task has urgency. Tag subtasks to triage effectively.',
        confidence: 0.8,
      );
    }

    // AI-powered (future)
    // - Analyze task titles
    // - Learn from user patterns
    // - Suggest based on completion rates

    return null;
  }
}
```

**UI:**
```
┌─────────────────────────────────┐
│ Launch Website                  │
│ 27 subtasks                     │
├─────────────────────────────────┤
│ 💡 Suggestion                   │
│ Try Buffett-Munger 5/25         │
│ "You have many subtasks -       │
│  prioritize your top 5!"        │
│                                 │
│ [Try It] [Dismiss]              │
└─────────────────────────────────┘
```

### **2. Hybrid Views**

```dart
class HybridViews {
  // Show all urgent tasks across all frameworks
  static List<Item> getAllUrgent(List<Item> allItems) {
    return allItems.where((item) {
      // From Eisenhower
      if (item.isUrgent) return true;

      // From Buffett-Munger (top priorities are "urgent")
      if (item.priority != null && item.priority! <= 2) return true;

      // From Time Blocking (due soon)
      if (item.scheduledFor != null &&
          item.scheduledFor!.isBefore(DateTime.now().add(Duration(days: 1)))) {
        return true;
      }

      return false;
    }).toList();
  }

  // Show all high-value tasks
  static List<Item> getHighValue(List<Item> allItems) { ... }

  // Show incomplete tasks
  static List<Item> getIncomplete(List<Item> allItems) { ... }
}
```

**UI:**
```
Dashboard → Views

┌─────────────────────────────────┐
│ Smart Views                     │
├─────────────────────────────────┤
│ 🔥 Urgent (7)                   │
│ ⭐ High Priority (5)             │
│ 📅 Due Today (3)                │
│ ✅ Quick Wins (<2 min) (12)     │
│ 🎯 In Progress (4)              │
└─────────────────────────────────┘
```

### **3. Framework Analytics**

```
Settings → Framework Insights

Buffett-Munger 5/25:
- Used on 3 tasks
- 12/15 priorities completed (80%)
- Average time to complete priority: 5 days

Eisenhower Matrix:
- Used on 5 tasks
- 45% of tasks are Urgent & Important
- Suggestion: Reduce urgent tasks by planning ahead

Time Blocking:
- 18 hours scheduled this week
- 85% completion rate
- Best time: Mornings (9-11am)
```

---

## Implementation Checklist

### **Phase 1.1: Foundation (This Week)**
- [ ] Update Item model with `frameworkId`
- [ ] Update database schema (migration)
- [ ] Create FrameworkRegistry
- [ ] Build Framework interface
- [ ] Update ItemsService for framework metadata

### **Phase 1.2: Buffett-Munger Framework**
- [ ] Create BuffettMungerFramework class
- [ ] Extract existing onboarding/prioritization
- [ ] Build pentagon wheel view (per-task)
- [ ] Framework-specific setup flow
- [ ] Avoid list view

### **Phase 1.3: Eisenhower Framework**
- [ ] Create EisenhowerMatrixFramework class
- [ ] Build tagging UI
- [ ] Build 2x2 matrix view
- [ ] Quadrant expansion
- [ ] Quick filters

### **Phase 1.4: Framework Picker UI**
- [ ] Framework selection bottom sheet
- [ ] Applicability checks
- [ ] Setup flow triggers
- [ ] Framework badge on task cards
- [ ] "Change framework" option

### **Phase 1.5: Task Detail Integration**
- [ ] Framework-aware rendering
- [ ] Switch between framework views
- [ ] Framework info/stats
- [ ] Remove framework option

### **Phase 2: Advanced Features**
- [ ] Time Blocking framework
- [ ] Kanban framework (TBD)
- [ ] Hybrid views UI
- [ ] Framework suggestions (rule-based)
- [ ] Cross-framework analytics
- [ ] AI-powered suggestions (future)

---

## Success Metrics

### **User Engagement:**
- % of tasks with frameworks applied
- Average # of frameworks used per user
- Framework retention (do they keep using it?)

### **Effectiveness:**
- Task completion rate (with vs without framework)
- Time to complete tasks
- User satisfaction surveys

### **Feature Usage:**
- Most popular framework
- Framework combinations
- Hybrid view usage

---

## Open Questions

1. **Framework Composability:**
   - Can Buffett-Munger + Eisenhower apply to same task's children?
   - Or should they be mutually exclusive per task?

2. **Framework Inheritance:**
   - If parent has framework A, do grandchildren inherit it?
   - Or can each level have different framework?

3. **Framework Conflicts:**
   - What if Buffett-Munger says "avoid" but Eisenhower says "urgent"?
   - Precedence rules?

4. **Migration:**
   - What happens to existing tasks when adding framework?
   - Auto-suggest based on current state?

---

## Next Steps

Ready to implement! Suggested order:

1. **Data model + migration** (30 min)
2. **Framework interface + registry** (1 hour)
3. **Framework picker UI** (2 hours)
4. **Buffett-Munger framework** (3 hours)
5. **Eisenhower framework** (3 hours)
6. **Testing & refinement** (ongoing)

Total estimate: ~10-12 hours of focused work

**Shall we start with the data model updates?**
