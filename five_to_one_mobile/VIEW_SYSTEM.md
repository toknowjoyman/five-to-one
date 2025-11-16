# View System Design

## Concept: Frameworks vs Views

### **Framework** = Logic/Organization
How tasks are organized, prioritized, and categorized.
Examples: Buffett-Munger 5/25, Eisenhower Matrix, Time Blocking

### **View** = Visual Representation
How tasks are displayed to the user.
Examples: List, Grid, Kanban, Calendar, Mind Map, Wheel

### **Key Insight:**
**Any framework can be rendered in multiple views!**

---

## Architecture

```
Task: "Launch Website"
  ├─ Framework: 'buffett-munger'  (the LOGIC)
  └─ View: 'wheel'                (the DISPLAY)
```

User can change view without changing framework:
- Same data (priority 1-5, avoid list)
- Different visualization (wheel → list → grid)

---

## View Types by Framework

### **Buffett-Munger 5/25 Views:**

#### **1. Wheel View** (Default)
```
┌─────────────────────────────────┐
│ Launch Website                  │
│ 📊 Buffett-Munger · Wheel       │
├─────────────────────────────────┤
│                                 │
│        ╱────────╲               │
│      ╱   [1]     ╲              │
│     │   [2] [3]   │             │ Pentagon
│      ╲   [4] [5]  ╱              │
│        ╲────────╱               │
│                                 │
│ 🔒 Avoid List (20)              │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **2. List View**
```
┌─────────────────────────────────┐
│ Launch Website                  │
│ 📊 Buffett-Munger · List        │
├─────────────────────────────────┤
│ TOP 5 PRIORITIES                │
│                                 │
│ 1️⃣ Design homepage              │
│    ✅ 80% complete              │
│                                 │
│ 2️⃣ Set up hosting               │
│    ○ Not started                │
│                                 │
│ 3️⃣ Write content                │
│    🔄 In progress               │
│                                 │
│ 4️⃣ SEO optimization             │
│ 5️⃣ Testing                      │
│                                 │
│ ─────────────────────           │
│ AVOID LIST (20) [Show ▼]        │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **3. Progress View**
```
┌─────────────────────────────────┐
│ Launch Website                  │
│ 📊 Buffett-Munger · Progress    │
├─────────────────────────────────┤
│                                 │
│ Priority 1: Design homepage     │
│ ████████████████░░░░ 80%       │
│                                 │
│ Priority 2: Set up hosting      │
│ ░░░░░░░░░░░░░░░░░░░░ 0%        │
│                                 │
│ Priority 3: Write content       │
│ ████████░░░░░░░░░░░░ 40%       │
│                                 │
│ Priority 4: SEO optimization    │
│ ██░░░░░░░░░░░░░░░░░░ 10%       │
│                                 │
│ Priority 5: Testing             │
│ ░░░░░░░░░░░░░░░░░░░░ 0%        │
│                                 │
│ Overall: 26% complete           │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **4. Focus View** (Minimize Distractions)
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│        PRIORITY 1               │
│                                 │
│     Design Homepage             │
│                                 │
│     [Mark Complete]             │
│                                 │
│     Next: Set up hosting        │
│                                 │
│                                 │
│                                 │
│ [Show All] [Change View ▼]     │
└─────────────────────────────────┘
```

---

### **Eisenhower Matrix Views:**

#### **1. Matrix View** (Default)
```
┌─────────────────────────────────┐
│ Daily Errands                   │
│ ⚡ Eisenhower · Matrix          │
├──────────────┬──────────────────┤
│ URGENT &     │ NOT URGENT &     │
│ IMPORTANT    │ IMPORTANT        │
│              │                  │
│ • Pay bills  │ • Exercise       │
│ • Call boss  │ • Read book      │
│              │                  │
├──────────────┼──────────────────┤
│ URGENT &     │ NOT URGENT &     │
│ NOT IMPORT   │ NOT IMPORT       │
│              │                  │
│ • Reply      │ • Browse web     │
│   emails     │ • Watch TV       │
│              │                  │
└──────────────┴──────────────────┘
```

#### **2. List View** (Grouped)
```
┌─────────────────────────────────┐
│ Daily Errands                   │
│ ⚡ Eisenhower · List            │
├─────────────────────────────────┤
│ 🔴 Urgent & Important (2)       │
│ • Pay bills                     │
│ • Call boss                     │
│                                 │
│ 🔵 Not Urgent & Important (2)   │
│ • Exercise                      │
│ • Read book                     │
│                                 │
│ 🟡 Urgent & Not Important (1)   │
│ • Reply emails                  │
│                                 │
│ ⚪ Neither (2)                  │
│ • Browse web                    │
│ • Watch TV                      │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **3. Priority Order View**
```
┌─────────────────────────────────┐
│ Daily Errands                   │
│ ⚡ Eisenhower · Priority        │
├─────────────────────────────────┤
│ DO FIRST                        │
│ 🔴 Pay bills                    │
│ 🔴 Call boss                    │
│                                 │
│ SCHEDULE                        │
│ 🔵 Exercise                     │
│ 🔵 Read book                    │
│                                 │
│ DELEGATE                        │
│ 🟡 Reply emails                 │
│                                 │
│ ELIMINATE                       │
│ ⚪ Browse web                   │
│ ⚪ Watch TV                     │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **4. Today View** (Time-based)
```
┌─────────────────────────────────┐
│ Daily Errands                   │
│ ⚡ Eisenhower · Today           │
├─────────────────────────────────┤
│ 🌅 Morning                      │
│ • Exercise (Not Urgent/Import)  │
│                                 │
│ ☀️ Afternoon                    │
│ • Pay bills (Urgent/Important)  │
│ • Call boss (Urgent/Important)  │
│                                 │
│ 🌙 Evening                      │
│ • Reply emails (Urgent/Not)     │
│ • Read book (Not Urgent/Import) │
│                                 │
│ 📅 Later                        │
│ • Browse web (Neither)          │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

---

### **Time Blocking Views:**

#### **1. Calendar View** (Default)
```
┌─────────────────────────────────┐
│ Work Projects                   │
│ 📅 Time Blocking · Calendar     │
├─────────────────────────────────┤
│ Monday, Jan 15                  │
│                                 │
│ 9:00 AM  ████████ 2h            │
│          Deep work: Design      │
│                                 │
│ 11:00 AM ░░░░░░░░ (Free)       │
│                                 │
│ 1:00 PM  ████ 1h                │
│          Team meeting           │
│                                 │
│ 2:00 PM  ████████████ 3h        │
│          Code review            │
│                                 │
│ 5:00 PM  ░░░░░░░░ (Free)       │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **2. Timeline View** (Horizontal)
```
┌─────────────────────────────────┐
│ Work Projects                   │
│ 📅 Time Blocking · Timeline     │
├─────────────────────────────────┤
│                                 │
│ 9am  10   11  12pm  1   2   3   │
│ ├────┼────┼────┼────┼────┼────┤ │
│ █████████████░░░░████░░░░░░░░░ │
│ Design      Free Meet Code      │
│                                 │
│ Tasks:                          │
│ • Design (9-11am) - 2h          │
│ • Meeting (1-2pm) - 1h          │
│ • Code (2-5pm) - 3h             │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **3. Unscheduled View** (To-do)
```
┌─────────────────────────────────┐
│ Work Projects                   │
│ 📅 Time Blocking · Unscheduled  │
├─────────────────────────────────┤
│ NEEDS SCHEDULING                │
│                                 │
│ • Write documentation           │
│   Est: 2 hours                  │
│   [Schedule →]                  │
│                                 │
│ • Bug fixes                     │
│   Est: 3 hours                  │
│   [Schedule →]                  │
│                                 │
│ • Email responses               │
│   Est: 30 min                   │
│   [Schedule →]                  │
│                                 │
│ Total unscheduled: 5.5 hours    │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

---

### **Framework-Agnostic Views:**

These views work with ANY framework (or no framework):

#### **1. Simple List**
```
┌─────────────────────────────────┐
│ Shopping List                   │
│ 📋 No Framework · List          │
├─────────────────────────────────┤
│ ○ Milk                          │
│ ○ Bread                         │
│ ✓ Eggs                          │
│ ○ Butter                        │
│ ○ Coffee                        │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **2. Kanban Board**
```
┌─────────────────────────────────┐
│ Shopping List                   │
│ 📋 No Framework · Kanban        │
├─────────────────────────────────┤
│ TO BUY │ IN CART │ BOUGHT       │
│────────┼─────────┼──────────    │
│ Milk   │ Bread   │ Eggs         │
│ Coffee │         │              │
│ Butter │         │              │
│        │         │              │
│ [+ Add]│         │              │
└────────┴─────────┴──────────────┘
```

#### **3. Mind Map**
```
┌─────────────────────────────────┐
│ Shopping List                   │
│ 📋 No Framework · Mind Map      │
├─────────────────────────────────┤
│                                 │
│          Shopping               │
│         /    |    \             │
│       /      |      \           │
│   Dairy   Bakery  Pantry        │
│    / \       |       |          │
│  Milk Eggs Bread  Coffee        │
│   |                             │
│ Butter                          │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **4. Grid View** (Compact)
```
┌─────────────────────────────────┐
│ Shopping List                   │
│ 📋 No Framework · Grid          │
├─────────────────────────────────┤
│ ┌─────┬─────┬─────┬─────┐      │
│ │ ○   │ ○   │ ✓   │ ○   │      │
│ │Milk │Bread│Eggs │Butte│      │
│ └─────┴─────┴─────┴─────┘      │
│ ┌─────┬─────┐                   │
│ │ ○   │     │                   │
│ │Coffe│ +   │                   │
│ └─────┴─────┘                   │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

#### **5. Checklist View** (Print-friendly)
```
┌─────────────────────────────────┐
│ Shopping List                   │
│ 📋 No Framework · Checklist     │
├─────────────────────────────────┤
│                                 │
│ □ Milk                          │
│ □ Bread                         │
│ ☑ Eggs                          │
│ □ Butter                        │
│ □ Coffee                        │
│                                 │
│ 1/5 items complete              │
│                                 │
│ [Print] [Share]                 │
│                                 │
│ [Change View ▼]                 │
└─────────────────────────────────┘
```

---

## View Selector UI

### **Quick Switcher** (Bottom sheet)
```
Tap "Change View ▼":

┌─────────────────────────────────┐
│ Choose View                     │
├─────────────────────────────────┤
│ RECOMMENDED FOR THIS FRAMEWORK  │
│                                 │
│ ● Wheel View                    │
│   Iconic pentagon display       │
│                                 │
│ ○ List View                     │
│   Simple numbered list          │
│                                 │
│ ○ Progress View                 │
│   Visual completion bars        │
│                                 │
│ OTHER VIEWS                     │
│                                 │
│ ○ Focus View                    │
│   One task at a time            │
│                                 │
│ ○ Kanban                        │
│   To Do / In Progress / Done    │
│                                 │
│ [Apply]                         │
└─────────────────────────────────┘
```

### **View Tabs** (Quick switch)
```
┌─────────────────────────────────┐
│ Launch Website                  │
│ [Wheel] [List] [Progress] [+]   │ ← View tabs
├─────────────────────────────────┤
│                                 │
│   (Current view content)        │
│                                 │
└─────────────────────────────────┘
```

### **View Gallery** (Visual preview)
```
┌─────────────────────────────────┐
│ Choose View                     │
├─────────────────────────────────┤
│ ┌─────┐  ┌─────┐  ┌─────┐      │
│ │     │  │ ═   │  │█    │      │
│ │  ●  │  │ ═   │  │█    │      │ Thumbnails
│ │ ●●  │  │ ═   │  │█    │      │
│ │ ●●  │  │ ═   │  │█    │      │
│ └─────┘  └─────┘  └─────┘      │
│  Wheel     List    Progress     │
│                                 │
│ ┌─────┐  ┌─────┐               │
│ │  1  │  │▓│▓│▓│               │
│ │     │  │ │ │ │               │
│ │Next │  │ │ │ │               │
│ └─────┘  └─────┘               │
│  Focus    Kanban                │
└─────────────────────────────────┘
```

---

## Data Model

```dart
class Item {
  final String id;
  final String? parentId;
  final String title;

  // Framework determines LOGIC
  final List<String> frameworkIds;  // ['buffett-munger', 'eisenhower']

  // View determines DISPLAY
  final String? preferredView;      // 'wheel', 'list', 'progress', 'focus'

  // Framework metadata (same as before)
  final int? priority;
  final bool isAvoided;
  final bool isUrgent;
  final bool isImportant;
  // ...
}
```

### **View Preferences Service**

```dart
class ViewPreferences {
  // Per-task view preference
  Future<void> setTaskView(String taskId, String viewId);
  Future<String?> getTaskView(String taskId);

  // Per-framework default view
  Future<void> setFrameworkDefaultView(String frameworkId, String viewId);
  Future<String?> getFrameworkDefaultView(String frameworkId);

  // User's global preferences
  Future<void> setGlobalDefaultView(String viewId);
  Future<String> getGlobalDefaultView(); // Default: 'list'
}
```

---

## View Resolution Logic

```dart
class ViewResolver {
  static String resolveView(Item task) {
    // 1. Task-specific preference (highest priority)
    if (task.preferredView != null) {
      return task.preferredView!;
    }

    // 2. Framework default view
    if (task.frameworkIds.isNotEmpty) {
      final framework = FrameworkRegistry.get(task.frameworkIds.first);
      final defaultView = framework?.defaultView;
      if (defaultView != null) return defaultView;
    }

    // 3. Global user preference
    final globalDefault = ViewPreferences.getGlobalDefaultView();
    return globalDefault; // 'list'
  }

  static List<String> getAvailableViews(Item task) {
    // Get views compatible with task's frameworks
    final views = <String>[];

    // Framework-specific views
    for (var frameworkId in task.frameworkIds) {
      final framework = FrameworkRegistry.get(frameworkId);
      views.addAll(framework?.supportedViews ?? []);
    }

    // Universal views (work with anything)
    views.addAll(['list', 'kanban', 'grid', 'checklist']);

    return views.toSet().toList(); // Remove duplicates
  }
}
```

---

## Implementation Examples

### **Buffett-Munger Framework**

```dart
class BuffettMungerFramework implements TaskFramework {
  @override
  String get defaultView => 'wheel';

  @override
  List<String> get supportedViews => [
    'wheel',      // Pentagon (signature view)
    'list',       // Numbered priorities
    'progress',   // Completion bars
    'focus',      // One at a time
  ];

  @override
  Widget buildView(BuildContext context, Item task, String viewId) {
    switch (viewId) {
      case 'wheel':
        return WheelView(task: task);
      case 'list':
        return PriorityListView(task: task);
      case 'progress':
        return ProgressBarView(task: task);
      case 'focus':
        return FocusView(task: task);
      default:
        return DefaultListView(task: task);
    }
  }
}
```

### **Eisenhower Framework**

```dart
class EisenhowerMatrixFramework implements TaskFramework {
  @override
  String get defaultView => 'matrix';

  @override
  List<String> get supportedViews => [
    'matrix',     // 2x2 grid (signature view)
    'list',       // Grouped by quadrant
    'priority',   // Do/Schedule/Delegate/Eliminate
    'today',      // Time-based grouping
  ];

  @override
  Widget buildView(BuildContext context, Item task, String viewId) {
    switch (viewId) {
      case 'matrix':
        return MatrixView(task: task);
      case 'list':
        return QuadrantListView(task: task);
      case 'priority':
        return PriorityOrderView(task: task);
      case 'today':
        return TodayView(task: task);
      default:
        return DefaultListView(task: task);
    }
  }
}
```

---

## Use Cases

### **Use Case 1: Different Views for Different Moods**

```
Morning (planning mode):
  → View: Wheel (strategic overview)

Afternoon (execution mode):
  → View: Focus (one task at a time)

Evening (review mode):
  → View: Progress (completion tracking)
```

### **Use Case 2: Different Views for Different Contexts**

```
On phone:
  → View: Focus (less screen space)

On tablet:
  → View: Wheel (more visual)

On desktop:
  → View: Kanban (more complex)
```

### **Use Case 3: Different Views for Different Tasks**

```
Big project:
  → View: Wheel or Mind Map (see relationships)

Daily tasks:
  → View: Simple list (quick scan)

Grocery shopping:
  → View: Checklist (print-friendly)
```

---

## Advanced: Custom Views

Future feature - let users create custom views:

```
Custom View Builder:
┌─────────────────────────────────┐
│ Create Custom View              │
├─────────────────────────────────┤
│ Name: My Work Dashboard         │
│                                 │
│ Layout:                         │
│ ○ List                          │
│ ● Grid                          │
│ ○ Kanban                        │
│                                 │
│ Group by:                       │
│ □ Priority                      │
│ ☑ Urgent/Important              │
│ □ Due Date                      │
│                                 │
│ Show:                           │
│ ☑ Completion %                  │
│ ☑ Due dates                     │
│ □ Tags                          │
│                                 │
│ [Save View]                     │
└─────────────────────────────────┘
```

---

## Summary

**Views = How you SEE tasks**
**Frameworks = How you ORGANIZE tasks**

Any framework can have multiple views:
- Buffett-Munger: Wheel, List, Progress, Focus
- Eisenhower: Matrix, List, Priority Order, Today
- Time Blocking: Calendar, Timeline, Unscheduled

Universal views work with any framework:
- List, Kanban, Grid, Checklist, Mind Map

Users can:
1. Set view per task
2. Set default view per framework
3. Set global default view
4. Quick-switch between views

**This gives ultimate flexibility in how users interact with their tasks!**
