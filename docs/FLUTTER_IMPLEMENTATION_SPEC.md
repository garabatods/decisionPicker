# Decision Maker App — Flutter Implementation Spec

## Tech Direction

Build a Flutter mobile app for iOS and Android.

The app should use:

- Flutter Material 3
- Local-first storage
- Simple state management
- Declarative routing
- Custom picker animation

Recommended MVP stack:

- `go_router` for routing
- `shared_preferences` for lightweight local JSON persistence
- `ChangeNotifier` for simple app state
- Flutter `HapticFeedback` for subtle haptic feedback

Keep the first version intentionally simple. Avoid backend, accounts, cloud sync, and complex architecture.

---

## Suggested Folder Structure

```txt
lib/
  main.dart
  app.dart

  core/
    theme/
      app_theme.dart
      app_colors.dart
      app_spacing.dart

  features/
    decision_picker/
      models/
        decision_group.dart
      data/
        default_decision_groups.dart
        decision_repository.dart
        local_decision_storage.dart
      state/
        decision_groups_controller.dart
      screens/
        home_screen.dart
        create_picker_screen.dart
        picker_screen.dart
      widgets/
        decision_group_card.dart
        choice_input_row.dart
        slot_picker_view.dart
        result_card.dart
        empty_state.dart
```

---

## Data Model

Create a model named `DecisionGroup`.

```dart
class DecisionGroup {
  final String id;
  final String name;
  final String emoji;
  final List<String> choices;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DecisionGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.choices,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();

  factory DecisionGroup.fromJson(Map<String, dynamic> json);
}
```

Rules:

- Default groups are seeded in code.
- User-created groups are saved locally.
- Default groups cannot be deleted.
- Custom groups can be deleted.
- Edit custom groups can wait until V2 unless easy to include.

---

## Local Persistence

For MVP, store custom groups as JSON using `shared_preferences`.

Suggested key:

```txt
decision_maker.custom_groups.v1
```

Repository responsibility:

- Load default groups.
- Load custom groups.
- Merge defaults + custom groups.
- Save custom groups.
- Add custom group.
- Delete custom group.
- Prevent default group deletion.

---

## Routing

Use `go_router`.

Suggested routes:

```txt
/
 /create
 /picker/:id
```

Screen mapping:

- `/` → `HomeScreen`
- `/create` → `CreatePickerScreen`
- `/picker/:id` → `PickerScreen`

---

## State Management

Use `ChangeNotifier` for MVP.

Create `DecisionGroupsController`.

Responsibilities:

- Load groups on app start.
- Expose list of groups.
- Add group.
- Delete custom group.
- Find group by id.
- Notify listeners after changes.
- Store loading/error states if needed.

Example state fields:

```dart
class DecisionGroupsController extends ChangeNotifier {
  List<DecisionGroup> groups = [];
  bool isLoading = false;
  String? errorMessage;
}
```

---

## Home Screen Requirements

The home screen should show:

- App title
- Short subtitle
- List/grid of pickers
- Create Picker CTA
- Default pickers
- Custom pickers

Suggested header:

Title:

> Decision Maker

Subtitle:

> No overthinking. Just pick.

Cards should show:

- Emoji/icon
- Picker name
- Number of choices
- Optional supporting line

For custom picker cards:

- Show delete option, preferably through long press or overflow menu.

---

## Create Picker Screen Requirements

Fields:

- Picker name input
- Emoji input or simple emoji selector
- Dynamic choice input rows
- Add Choice button
- Save Picker button

Validation:

- Name required.
- At least 2 choices required.
- Empty choices ignored.
- Duplicate choices are not allowed.
- Save button disabled until valid.

Default initial state:

- 1 empty name field
- 2 empty choice fields
- Default emoji: 🎯

After save:

- Add group to local storage.
- Navigate back to home.
- New custom picker should appear on home screen.

---

## Picker Screen Requirements

The picker screen should show:

- Picker name
- Slot picker area
- Current state text
- Pick button / Pick Again button
- Done or Back button

States:

```dart
enum PickerStatus {
  idle,
  spinning,
  result,
  invalid,
}
```

Behavior:

1. User taps Pick.
2. App randomly selects final choice first.
3. UI builds a repeated visual list of choices.
4. Animation scrolls fast, then slows down.
5. Final choice lands in the center highlight area.
6. Haptic feedback fires.
7. Result state displays.

Important:

- Do not let the animation determine the actual result.
- Pick the result first, then animate to match it.
- Disable buttons while spinning.
- Prevent double taps.

---

## Slot Picker Animation

Create a reusable widget:

```dart
class SlotPickerView extends StatefulWidget {
  final List<String> choices;
  final String? selectedChoice;
  final bool isSpinning;
  final VoidCallback? onSpinComplete;
}
```

Recommended animation approach:

- `AnimationController`
- `CurvedAnimation`
- `Tween<double>`
- `AnimatedBuilder`
- `Transform.translate`
- Center highlight container

Visual approach:

- Vertical list
- Center highlight band
- Non-selected items slightly faded or smaller
- Selected item bold and large
- Optional blur/motion effect implied visually

Avoid:

- Real casino slot machine visuals
- Curved wheel
- Random physics-based landing
- Overly complex scroll mechanics

---

## Haptics

When the final result lands, use a light haptic event.

Suggested:

```dart
HapticFeedback.selectionClick();
```

Optional:

- Small haptic ticks during slowing phase can wait until later.

---

## Theming

Use Material 3.

Design tokens:

- App background
- Surface/card color
- Primary accent
- Text primary
- Text secondary
- Border color
- Success/result accent

Keep colors centralized in:

```txt
core/theme/app_colors.dart
```

Spacing tokens in:

```txt
core/theme/app_spacing.dart
```

Use rounded corners consistently.

Suggested radii:

- Card radius: 20
- Button radius: 16
- Input radius: 14

---

## Accessibility

Minimum requirements:

- Large tap targets
- Buttons have clear labels
- Good contrast
- Animation should not be too long
- Result should be text-based, not only visual
- Avoid flashing effects

---

## Manual QA Checklist

Home:

- Default pickers appear on first launch.
- Custom picker appears after saving.
- Custom picker persists after app restart.
- Custom picker can be deleted.
- Default picker cannot be deleted.

Create:

- Cannot save empty name.
- Cannot save with fewer than 2 choices.
- Empty choices are ignored.
- Duplicate choices show validation error.
- Save returns to home.

Picker:

- Pick button starts animation.
- Buttons are disabled while spinning.
- Final result matches selected value.
- Pick Again works.
- Back/Done returns to home.
- Invalid picker state is handled.

Persistence:

- Closing and reopening app keeps custom pickers.
