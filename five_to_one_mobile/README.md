# Five to One - Mobile App

A cross-platform mobile app implementing Warren Buffett's 5/25 prioritization method with attitude, inspired by The Doors' "Five to One".

## Features

### ✅ Current (V1 - MVP)
- **Onboarding Flow**: Psychedelic, motivational 3-screen intro
- **25 Goals Input**: Flexible input (5-25 goals minimum)
- **Drag-to-Rank Prioritization**: Tactile, intentional goal ranking
- **Dramatic Lockdown**: Visual reveal of top 5 vs avoid list
- **Dashboard Wheel**: Pentagon layout of your 5 priority goals
- **Doors Quotes**: Motivational lyrics throughout the experience
- **Dark Mode**: Psychedelic purple/orange theme

### 🔮 Planned (V2)
- **Life Areas**: 5 areas × 5/25 goals each
- **Fractal Tasks**: Infinite subtask depth with parent-child relationships
- **Urgent vs Important**: Eisenhower matrix tagging
- **Swipe Gestures**: Complete tasks with satisfying animations
- **Timeline**: Daily activity tracking
- **Backend Integration**: Supabase for sync & persistence

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **State Management**: Provider
- **Animations**: flutter_animate

## Project Structure

```
lib/
├── main.dart                    # App entry & flow manager
├── theme/
│   └── app_theme.dart          # Color palette & styling
├── models/
│   └── item.dart               # Unified fractal model (life areas/goals/tasks)
├── screens/
│   ├── onboarding/
│   │   ├── hook_screen.dart    # "Five to one, baby"
│   │   ├── method_screen.dart  # Explain 5/25 method
│   │   ├── ready_screen.dart   # "No one gets out alive"
│   │   └── onboarding_flow.dart
│   ├── goals/
│   │   ├── goals_input_screen.dart
│   │   ├── prioritization_screen.dart
│   │   └── lockdown_screen.dart
│   └── dashboard/
│       └── dashboard_screen.dart
├── widgets/                     # Reusable components
└── utils/
    └── doors_quotes.dart       # The Doors lyrics
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- iOS Simulator / Android Emulator
- (Optional) Supabase account for backend

### Installation

1. **Clone the repository**
   ```bash
   cd five-to-one/five_to_one_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**iOS:**
```bash
flutter build ios
```

**Android:**
```bash
flutter build apk
flutter build appbundle  # For Play Store
```

## Data Model: Unified Fractal Schema

**Key Innovation:** Instead of separate tables for life areas, goals, and tasks, we use **one self-referential table** that represents all hierarchy levels.

```sql
-- Single table, infinite depth
items:
  id, user_id, parent_id (self-referential!),
  title, position,
  priority, is_avoided,          -- For goals
  is_urgent, is_important,        -- For tasks
  color, icon,                    -- For life areas
  completed_at, created_at
```

**How it works:**
- `parent_id = NULL` → Root item (Life Area in V2, Goal in V1)
- `parent_id = some_id` → Child of that item
- Same structure repeats infinitely: Item → Item → Item → ...

**See [FRACTAL_SCHEMA.md](FRACTAL_SCHEMA.md) for detailed explanation.**

## Design Philosophy

1. **Radical Simplicity**: Mobile forces focus
2. **Opinionated**: Locks distractions, enforces discipline
3. **Gesture-Driven**: Swipes feel more intentional
4. **Motivational**: Doors lyrics as micro-rewards
5. **Beautiful Constraints**: Small screen = natural limitation

## Screens Overview

1. **Onboarding** (3 screens): Hook → Method → Ready
2. **Goals Input**: Enter 5-25 goals
3. **Prioritization**: Drag to rank
4. **Lockdown**: Dramatic reveal of top 5 + avoid list
5. **Dashboard**: Pentagon wheel of 5 goals
6. *(Coming)* Goal Detail: Tasks + subtasks
7. *(Coming)* Avoid List: Locked, blurred view

## Color Palette

- **Primary Purple**: `#6B2E9E` - Deep, authoritative
- **Accent Orange**: `#FF6B35` - Energy, action
- **Accent Gold**: `#FFB344` - Motivation
- **Success Green**: `#2ECC71` - Completion
- **Urgent Red**: `#E74C3C` - Urgent tasks
- **Important Blue**: `#3498DB` - Important tasks
- **Avoid Gray**: `#95A5A6` - Locked items

## Contributing

This is a personal project inspired by productivity methodologies and The Doors.

## License

MIT

## Inspiration

- Warren Buffett & Charlie Munger's 5/25 Rule
- The Doors - "Five to One" (1968)
- Eisenhower Matrix (Urgent vs Important)

---

*"No one here gets out alive, now"* 🔥
