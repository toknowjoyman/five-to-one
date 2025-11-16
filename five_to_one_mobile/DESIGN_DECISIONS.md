# Design Decisions & Answers to Open Questions

## Question 1: Framework Composability

**Can multiple frameworks apply to the same task's children?**

**ANSWER: YES** (Per user feedback)

### How It Works:

```
Task: "Launch Website"
  frameworkId: ['buffett-munger', 'eisenhower']  // Array, not single value!

  Children get BOTH frameworks:
  ├─ Priority 1 + Urgent & Important: Fix bug
  ├─ Priority 2 + Not Urgent & Important: Write docs
  ├─ Priority 3 + Urgent & Not Important: Design tweak
  └─ ... (rest in avoid list)
```

### Updated Data Model:

```dart
class Item {
  // Change from single framework to array
  final List<String> frameworkIds;  // ['buffett-munger', 'eisenhower']
}
```

### View Rendering:

```dart
// Multiple framework views can stack
Widget buildSubtaskView(Item task) {
  if (task.frameworkIds.isEmpty) {
    return SimpleListView();
  }

  if (task.frameworkIds.length == 1) {
    return FrameworkRegistry.get(task.frameworkIds[0]).buildView();
  }

  // Multiple frameworks - composite view
  return CompositeFrameworkView(
    frameworks: task.frameworkIds.map((id) => FrameworkRegistry.get(id)),
    task: task,
  );
}
```

### Example Composite Views:

**Buffett-Munger + Eisenhower:**
```
Pentagon wheel, but each goal is tagged:
├─ 🔴 [1] Fix critical bug (Urgent & Important)
├─ 🔵 [2] Write docs (Not Urgent & Important)
├─ 🔴 [3] Design tweak (Urgent & Not Important)
├─ 🔵 [4] SEO optimization (Not Urgent & Important)
└─ 🟢 [5] Analytics (Neither)
```

**Eisenhower + Time Blocking:**
```
2x2 Matrix with scheduled times:
┌─────────────────┬─────────────────┐
│ Urgent &        │ Not Urgent &    │
│ Important       │ Important       │
│ • Fix bug       │ • Write docs    │
│   📅 Today 2pm  │   📅 Fri 10am   │
├─────────────────┼─────────────────┤
│ Urgent &        │ Neither         │
│ Not Important   │                 │
│ • Email client  │ • Browse design │
│   📅 Today 4pm  │   (No time)     │
└─────────────────┴─────────────────┘
```

---

## Question 2: Framework Inheritance

**If parent has framework A, do grandchildren inherit it?**

**ANSWER: NO - Each level chooses independently**

### Rationale:
- More flexibility
- Different granularities need different approaches
- Natural decomposition (big framework at top, simple at bottom)

### Example:

```
Q1 Goals [Buffett-Munger]          ← Strategic level
  ├─ Launch Product [Eisenhower]   ← Tactical level
  │   └─ Fix Bug [None]            ← Execution level
  ├─ Hire Engineer [Time Blocking] ← Different approach
  └─ Revenue $10k [None]           ← Simple tracking
```

Each level is independent - no inheritance cascade.

---

## Question 3: Framework Conflicts

**What if Buffett-Munger says "avoid" but Eisenhower says "urgent"?**

**ANSWER: Frameworks are additive, user resolves conflicts**

### Resolution Strategy:

1. **No Automatic Precedence** - Both frameworks show their opinion
2. **User Decides** - Provide tools to surface conflicts
3. **Smart Warnings** - Highlight when frameworks disagree

### Conflict Detection:

```dart
class FrameworkConflict {
  static List<Conflict> detectConflicts(Item item) {
    List<Conflict> conflicts = [];

    // Buffett-Munger says "avoid" but Eisenhower says "urgent"
    if (item.isAvoided && item.isUrgent) {
      conflicts.add(Conflict(
        type: ConflictType.avoidedButUrgent,
        message: "This task is in your 'Avoid List' but marked Urgent!",
        suggestion: "Consider promoting to priority or removing urgency.",
        severity: ConflictSeverity.high,
      ));
    }

    // High priority but not important
    if (item.priority != null && item.priority! <= 2 && !item.isImportant) {
      conflicts.add(Conflict(
        type: ConflictType.priorityMismatch,
        message: "High priority but not marked Important?",
        suggestion: "Verify this is truly a priority.",
        severity: ConflictSeverity.medium,
      ));
    }

    return conflicts;
  }
}
```

### UI for Conflicts:

```
Task Detail:
┌─────────────────────────────────┐
│ Design Homepage                 │
│ ⚠️ Framework Conflict           │
├─────────────────────────────────┤
│ This task is:                   │
│ • In Avoid List (BM 5/25)       │
│ • Marked as Urgent (Eisenhower) │
│                                 │
│ Suggestion: Consider promoting  │
│ to your top 5 priorities.       │
│                                 │
│ [Promote] [Remove Urgent] [Keep]│
└─────────────────────────────────┘
```

---

## Question 4: Migration Strategy

**What happens to existing tasks when adding a framework?**

**ANSWER: Intelligent defaults + user confirmation**

### Migration Flow:

```
User taps "Apply Framework" on task with 20 existing subtasks:

1. Framework analyzes current state
2. Suggests default organization
3. User reviews and adjusts
4. Confirm to apply
```

### Example: Buffett-Munger Migration

```
"Launch Website" has 20 subtasks currently in simple list.

Framework analyzes:
- 5 most recently worked on → Suggested as priority
- Rest → Suggested for avoid list

┌─────────────────────────────────┐
│ Suggested Prioritization        │
├─────────────────────────────────┤
│ TOP 5 (based on recent activity)│
│ 1. ✓ Homepage design (3d ago)   │
│ 2. ○ Set up hosting (5d ago)    │
│ 3. ○ Write content (1w ago)     │
│ 4. ○ SEO (2w ago)               │
│ 5. ○ Testing (3w ago)           │
│                                 │
│ AVOID LIST (15 items)           │
│ • Email signup form             │
│ • Analytics dashboard           │
│ • ... (show more)               │
│                                 │
│ [Adjust] [Apply]                │
└─────────────────────────────────┘
```

### Smart Defaults:

```dart
class FrameworkMigration {
  static MigrationSuggestion suggestBuffettMunger(List<Item> items) {
    // Sort by various signals
    items.sort((a, b) {
      int scoreA = 0, scoreB = 0;

      // Recently worked on
      if (a.completedAt != null || a.updatedAt.isAfter(...)) scoreA += 10;
      if (b.completedAt != null || b.updatedAt.isAfter(...)) scoreB += 10;

      // Has subtasks (higher-level)
      if (a.children?.isNotEmpty) scoreA += 5;
      if (b.children?.isNotEmpty) scoreB += 5;

      // Keyword detection (e.g., "critical", "urgent")
      if (a.title.toLowerCase().contains('critical')) scoreA += 8;
      if (b.title.toLowerCase().contains('critical')) scoreB += 8;

      return scoreB.compareTo(scoreA);
    });

    return MigrationSuggestion(
      topFive: items.take(5).toList(),
      avoidList: items.skip(5).toList(),
      reasoning: "Based on recent activity and importance signals",
    );
  }
}
```

---

## Hybrid Views Architecture

**User wants to see "all urgent tasks across all goals/tasks"**

### Implementation:

```dart
class HybridView {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final FilterFunction filter;
  final GroupingStrategy? grouping;
}

// Pre-built hybrid views
class HybridViews {
  static final urgent = HybridView(
    id: 'urgent',
    name: 'Urgent Tasks',
    icon: Icons.warning,
    color: Colors.red,
    filter: (item) => item.isUrgent || (item.priority != null && item.priority! <= 2),
    grouping: GroupByParent(),
  );

  static final important = HybridView(
    id: 'important',
    name: 'Important Tasks',
    icon: Icons.star,
    color: Colors.amber,
    filter: (item) => item.isImportant || (item.priority != null && item.priority! <= 3),
  );

  static final dueToday = HybridView(
    id: 'due-today',
    name: 'Due Today',
    icon: Icons.today,
    color: Colors.blue,
    filter: (item) {
      if (item.scheduledFor == null) return false;
      return item.scheduledFor!.isSameDay(DateTime.now());
    },
    grouping: GroupByTime(),
  );

  static final inProgress = HybridView(
    id: 'in-progress',
    name: 'In Progress',
    icon: Icons.pending,
    color: Colors.orange,
    filter: (item) => !item.isCompleted && item.children?.any((c) => c.isCompleted) == true,
  );

  static final quickWins = HybridView(
    id: 'quick-wins',
    name: 'Quick Wins',
    icon: Icons.bolt,
    color: Colors.green,
    filter: (item) {
      // No children, not completed, in urgent or priority
      return item.children?.isEmpty == true &&
             !item.isCompleted &&
             (item.isUrgent || item.priority != null);
    },
  );
}
```

### UI:

```
Dashboard → [All] [Urgent] [Important] [Today] [Quick Wins]

When viewing "Urgent":
┌─────────────────────────────────┐
│ 🔥 Urgent Tasks (7)             │
├─────────────────────────────────┤
│ Q1 Goals > Launch Product       │
│ • Fix critical bug              │
│ • Reply to client               │
│                                 │
│ Daily Errands                   │
│ • Pay bills                     │
│ • Doctor appointment            │
│                                 │
│ Work Projects > Client ABC      │
│ • Deliver mockups               │
│ • Schedule call                 │
│                                 │
│ [Group by: Parent ▼]            │
└─────────────────────────────────┘

Tap "Group by" to switch:
- Parent (current)
- Priority
- Due Date
- Framework Type
- Flat (no grouping)
```

---

## AI-Powered Suggestions (Future)

**User confirmed this will be implemented, likely with AI**

### Approach:

```dart
class FrameworkSuggestionEngine {
  // Phase 1: Rule-based (now)
  static Suggestion? analyzeRuleBased(Item task, List<Item> children) {
    // Simple heuristics
    if (children.length >= 20) {
      return Suggestion(
        framework: 'buffett-munger',
        reason: 'Many subtasks detected',
        confidence: 0.9,
      );
    }
    // ...more rules
  }

  // Phase 2: ML-based (future)
  static Future<Suggestion?> analyzeWithML(Item task, List<Item> children) {
    // Features to extract:
    // - Task title keywords
    // - Number of subtasks
    // - Depth of tree
    // - User's historical patterns
    // - Completion rates with/without frameworks
    // - Time of day, day of week

    // Model predicts best framework
    return MLModel.predict(features);
  }

  // Phase 3: LLM-based (future)
  static Future<Suggestion?> analyzeWithLLM(Item task, List<Item> children) {
    final prompt = '''
    Analyze this task and suggest a productivity framework:

    Task: ${task.title}
    Subtasks: ${children.map((c) => c.title).join(', ')}

    Available frameworks:
    - Buffett-Munger 5/25 (prioritize top 5)
    - Eisenhower Matrix (urgent/important)
    - Time Blocking (schedule to calendar)

    Which framework would help most? Why?
    ''';

    return OpenAI.complete(prompt).then(parseSuggestion);
  }
}
```

### UI:

```
┌─────────────────────────────────┐
│ 🤖 AI Suggestion                │
├─────────────────────────────────┤
│ For "Launch Website":           │
│                                 │
│ Try: Buffett-Munger 5/25        │
│                                 │
│ Why: You have 27 subtasks and   │
│ seem overwhelmed. Focusing on   │
│ your top 5 will give clarity.   │
│                                 │
│ Based on similar tasks, users   │
│ complete 40% more with this     │
│ framework.                      │
│                                 │
│ [Apply Framework] [Not Now]     │
└─────────────────────────────────┘
```

---

## Summary of Design Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| Multiple frameworks per task? | **YES** - Array of framework IDs | User requested, adds flexibility |
| Framework inheritance? | **NO** - Each level independent | Cleaner, more flexible |
| Conflict resolution? | **User decides** - Show warnings | No magic, transparency |
| Migration strategy? | **Smart defaults + confirmation** | Helpful but not presumptuous |
| Hybrid views? | **YES** - Cross-framework filtering | User requested, high value |
| AI suggestions? | **YES** - Future feature | User confirmed, start with rules |

---

## Next: Implementation

Ready to start building! Recommended order:

1. **Update data model** (frameworkIds array)
2. **Database migration**
3. **Framework registry**
4. **Framework picker UI**
5. **Buffett-Munger framework**
6. **Eisenhower framework**
7. **Hybrid views**
8. **AI suggestions (rule-based)**

**Shall we proceed with implementation?**
