# Subtask-First: Framework Plugin Architecture

## Product Vision

**Subtask** is a task management app that helps users **dominate their task lists** through fractal task decomposition and pluggable productivity frameworks.

### Core Philosophy
- **Fractal tasks**: Every task can have subtasks, infinitely deep
- **Framework-agnostic**: The task data is neutral
- **Multiple strategies**: Users can apply different frameworks to the same tasks
- **No lock-in**: Switch frameworks or use multiple at once

---

## Core Features

### 1. Fractal Task Management (Always On)
- Create tasks
- Add subtasks to any task (infinite depth)
- Complete/uncomplete tasks
- Swipe gestures
- Tree navigation
- Progress tracking (completion bubbles up)

### 2. Framework Plugins (Optional)
Users can enable one or more frameworks to organize their tasks:

| Framework | What It Does | When to Use |
|-----------|-------------|-------------|
| **Buffett-Munger 5/25** | Limits you to 5 priorities, locks the rest | Overwhelmed by too many goals |
| **Eisenhower Matrix** | Tags tasks as Urgent/Important | Need to triage by deadline vs value |
| **GTD (Future)** | Contexts, next actions, waiting-for | Complex workflow management |
| **Time Blocking (Future)** | Schedule tasks to calendar slots | Need time allocation |

---

## Architecture

### Data Model (Unchanged)

```dart
class Item {
  final String id;
  final String? parentId;  // Fractal structure
  final String title;

  // Framework-specific metadata (optional)
  final int? priority;        // Used by: Buffett-Munger
  final bool isAvoided;       // Used by: Buffett-Munger
  final bool isUrgent;        // Used by: Eisenhower
  final bool isImportant;     // Used by: Eisenhower
  final String? context;      // Used by: GTD
  final DateTime? scheduledFor; // Used by: Time Blocking
}
```

**Key insight**: All fields are nullable. Each framework uses only what it needs.

### Framework Interface

```dart
abstract class TaskFramework {
  String get name;
  String get description;
  IconData get icon;

  // Can this framework work with current tasks?
  bool canApply(List<Item> tasks);

  // Setup flow (onboarding for this framework)
  Widget setupFlow(BuildContext context, OnSetupComplete onComplete);

  // Dashboard view for this framework
  Widget dashboard(BuildContext context);

  // Apply framework logic to tasks
  Future<void> applyToTasks(List<Item> tasks);

  // Remove framework (cleanup metadata)
  Future<void> removeFromTasks(List<Item> tasks);
}
```

### Concrete Frameworks

```dart
class BuffettMungerFramework implements TaskFramework {
  @override
  String get name => 'Buffett-Munger 5/25';

  @override
  bool canApply(List<Item> tasks) {
    // Need at least 5 root tasks
    return tasks.where((t) => t.parentId == null).length >= 5;
  }

  @override
  Widget setupFlow(context, onComplete) {
    return OnboardingFlow(
      onComplete: () async {
        // Prioritization flow
        // Sets priority & isAvoided fields
        onComplete();
      },
    );
  }

  @override
  Widget dashboard(context) {
    return PrioritizedDashboard(); // Pentagon wheel
  }
}

class EisenhowerMatrixFramework implements TaskFramework {
  @override
  String get name => 'Eisenhower Matrix';

  @override
  bool canApply(List<Item> tasks) => true; // Always applicable

  @override
  Widget setupFlow(context, onComplete) {
    return EisenhowerOnboarding(
      onComplete: () {
        // Explain urgent vs important
        // User tags existing tasks
        onComplete();
      },
    );
  }

  @override
  Widget dashboard(context) {
    return EisenhowerDashboard(); // 2x2 matrix
  }
}
```

---

## User Flows

### First Time User

```
1. Auth
2. Simple task list (fractal mode)
   - "Add your first task"
   - Tap to add subtasks
   - Clean, minimal
3. After 5+ tasks → Suggest frameworks
   - "Try a framework to organize your tasks"
   - Show framework gallery
```

### Enabling a Framework

```
Settings → Frameworks → Browse
  ├─ Buffett-Munger 5/25
  │   └─ [Enable] → Setup flow → Dashboard changes
  ├─ Eisenhower Matrix
  │   └─ [Enable] → Tag your tasks → Dashboard changes
  └─ Coming Soon: GTD, Time Blocking...
```

### Multiple Frameworks

```
User can enable both:
- Buffett-Munger: Limits to 5 root goals
- Eisenhower: Tags tasks within those goals

Dashboard shows:
  ├─ Buffett-Munger wheel (5 goals)
  └─ Tap goal → Tasks tagged Urgent/Important
```

---

## Dashboard Variations

### No Frameworks (Default)
```
┌─────────────────────────────┐
│ My Tasks                 ⚙️ │
├─────────────────────────────┤
│ ○ Launch website            │
│ ○ Write blog post           │
│ ○ Learn Flutter             │
│   ○ Build todo app      ← subtask
│ ○ Call mom                  │
│                             │
│ [+] Add task                │
└─────────────────────────────┘
```

### Buffett-Munger Enabled
```
┌─────────────────────────────┐
│ Five to One              ⚙️ │
├─────────────────────────────┤
│                             │
│        ╱────────╲           │
│      ╱   [1]     ╲          │ Pentagon wheel
│     │   [2] [3]   │         │
│      ╲   [4] [5]  ╱          │
│        ╲────────╱           │
│                             │
│ [🔒 Avoid List (20)]        │
└─────────────────────────────┘
```

### Eisenhower Enabled
```
┌─────────────────────────────┐
│ Eisenhower Matrix        ⚙️ │
├─────────────┬───────────────┤
│ URGENT &    │ NOT URGENT &  │
│ IMPORTANT   │ IMPORTANT     │
│ ○ Fix bug   │ ○ Learn code  │
│ ○ Call boss │               │
├─────────────┼───────────────┤
│ URGENT &    │ NOT URGENT &  │
│ NOT IMPORT  │ NOT IMPORT    │
│ ○ Email     │ ○ Browse web  │
└─────────────┴───────────────┘
```

### Both Enabled
```
Tabs or bottom nav:
[5/25] [Matrix] [Tasks]

Each view is a different lens on same tasks
```

---

## Implementation Plan

### Phase 1: Refactor to Framework-Agnostic Core
- [ ] Create `TaskFramework` interface
- [ ] Build simple task list dashboard (no frameworks)
- [ ] Extract Buffett-Munger code into `BuffettMungerFramework`
- [ ] Add framework enable/disable in settings

### Phase 2: Add Eisenhower Matrix
- [ ] Create `EisenhowerMatrixFramework`
- [ ] Build 2x2 matrix dashboard
- [ ] Add tagging UI for urgent/important
- [ ] Support filtering by quadrant

### Phase 3: Framework Gallery
- [ ] Framework browsing screen
- [ ] Setup flows for each
- [ ] Multiple framework support
- [ ] Framework analytics/insights

---

## Database Schema (No Changes!)

Same `items` table works for all frameworks:

```sql
items:
  id, user_id, parent_id, title, position,
  priority, is_avoided,      -- Buffett-Munger
  is_urgent, is_important,   -- Eisenhower
  context, waiting_for,      -- GTD
  scheduled_for, duration    -- Time Blocking
```

Each framework uses only the fields it needs. Unused fields stay null.

---

## Settings UI

```
Settings
├─ Frameworks
│   ├─ Enabled
│   │   ├─ Buffett-Munger 5/25 [Disable]
│   │   └─ Eisenhower Matrix [Disable]
│   └─ Available
│       ├─ GTD (Coming Soon)
│       └─ Time Blocking (Coming Soon)
├─ Account
└─ About
```

---

## Benefits

✅ **Flexibility**: Users choose frameworks that work for them
✅ **No lock-in**: Disable frameworks without losing tasks
✅ **Composable**: Mix frameworks (5/25 + Eisenhower)
✅ **Extensible**: Easy to add new frameworks
✅ **Simpler onboarding**: Start with plain tasks
✅ **Broader appeal**: Not forcing one methodology

---

## Product Positioning

**Before**: "Buffett-Munger 5/25 app with fractal tasks"
**After**: "Fractal task manager with pluggable productivity frameworks"

Tagline: **"Dominate your task list, your way"**
