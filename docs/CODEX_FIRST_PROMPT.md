# Codex First Prompt — Build Flutter Decision Maker MVP

You are working in a new Flutter project.

Build the MVP for a mobile app called **Decision Maker**.

Before coding, read these project docs:

- `docs/DECISION_MAKER_PRODUCT_BRIEF.md`
- `docs/FLUTTER_IMPLEMENTATION_SPEC.md`

## Goal

Create the first working version of the app with:

- Home screen
- Create Picker screen
- Picker screen
- Local persistence for custom pickers
- Vertical slot-style picker animation
- Pick again functionality
- Delete custom picker
- Basic validation
- Light haptic feedback when the result lands

Use Flutter Material 3.

## Recommended Stack

Use:

- `go_router` for navigation
- `shared_preferences` for local JSON persistence
- `ChangeNotifier` for simple app state

Do not add:

- Backend
- User accounts
- Cloud sync
- Firebase
- Supabase
- Sound effects
- Multiplayer
- Community templates

## Required Structure

Create or update the project using this structure:

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

## App Screens

### 1. HomeScreen

Show:

- App title: `Decision Maker`
- Subtitle: `No overthinking. Just pick.`
- List/grid of available pickers
- Default pickers
- Custom user-created pickers
- Create Picker button or FAB

Default pickers:

- Food Picker
- Movie Genre Picker
- Truth or Dare: Safe Edition
- Game Night Picker
- Weekend Activity Picker

Each picker card should show:

- Emoji
- Name
- Number of choices
- Short supporting text if useful

Custom picker cards should support delete through an overflow menu or long press.

Default pickers should not be deletable.

### 2. CreatePickerScreen

Fields:

- Picker name
- Emoji, default to 🎯
- Dynamic list of choices
- Add Choice button
- Save Picker button

Validation:

- Name is required
- At least 2 valid choices are required
- Empty choices are ignored
- Duplicate choices are not allowed
- Save button disabled until valid

On save:

- Create custom picker
- Persist it locally
- Navigate back to home
- Show the new picker in the list

### 3. PickerScreen

Show:

- Picker name
- Vertical slot picker area
- Center highlighted selection band
- Status text
- Primary button: `Pick for me` / `Pick Again`
- Secondary button: `Done`

Picker states:

- idle
- spinning
- result
- invalid

Behavior:

1. User taps `Pick for me`.
2. Randomly select the final choice first.
3. Animate the vertical picker so choices scroll fast, then slow down.
4. Land visually on the selected final choice.
5. Trigger light haptic feedback.
6. Show result state with copy: `The picker has spoken.`

Important:

- The animation must not decide the result.
- The result must be chosen first, then the animation should match it.
- Disable buttons while spinning.
- Prevent double taps.

## Data Model

Create this model:

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

## Persistence

Use `shared_preferences`.

Save only custom groups.

Suggested key:

```txt
decision_maker.custom_groups.v1
```

At runtime, merge:

- default groups from code
- custom groups from local storage

## Design Direction

Make the UI feel:

- Clean
- Modern
- Playful
- Minimal
- Friendly
- Mobile-first

Use:

- Rounded cards
- Bold result typography
- Smooth animation
- Soft shadows
- Material 3
- Centralized theme tokens

Avoid:

- Casino look
- Heavy slot machine graphics
- Overly complex design
- Backend dependencies

## Acceptance Criteria

The task is done when:

- The app runs without errors.
- Home screen shows default pickers.
- User can create a custom picker.
- Custom picker persists after app restart.
- User can delete custom pickers.
- Default pickers cannot be deleted.
- Picker animation works.
- Pick Again works.
- Result shown matches the selected random result.
- Buttons are disabled during animation.
- Invalid picker states are handled gracefully.
- Code is organized according to the requested structure.

After implementation, summarize:

1. What files you created or changed.
2. How to run the app.
3. Any limitations or TODOs.
