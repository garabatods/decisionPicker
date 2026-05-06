import 'package:decision_picker/app.dart';
import 'package:decision_picker/features/decision_picker/data/decision_repository.dart';
import 'package:decision_picker/features/decision_picker/data/local_decision_storage.dart';
import 'package:decision_picker/features/decision_picker/screens/group_details_screen.dart';
import 'package:decision_picker/features/decision_picker/state/decision_groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows default pickers on launch', (tester) async {
    final controller = await _createController();

    await tester.pumpWidget(DecisionMakerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Pickers'), findsWidgets);
    expect(find.text('Food Picker'), findsOneWidget);
    expect(find.text('Movie Genre Picker'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('create picker saves valid custom picker', (tester) async {
    _useTallTestViewport(tester);
    final controller = await _createController();

    await tester.pumpWidget(DecisionMakerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('group-name-input')),
      'Lunch Picker',
    );
    await tester.enterText(
      find.byKey(const ValueKey('choice-input-0')),
      'Soup',
    );
    await tester.enterText(
      find.byKey(const ValueKey('choice-input-1')),
      'Salad',
    );
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'Save picker');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      controller.groups.any((group) => group.name == 'Lunch Picker'),
      true,
    );
    expect(controller.groups.first.name, 'Lunch Picker');

    controller.dispose();
  });

  testWidgets('create picker hides idea assist and exposes icon picker', (
    tester,
  ) async {
    _useTallTestViewport(tester);
    final controller = await _createController();

    await tester.pumpWidget(DecisionMakerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Try Idea Assist'), findsNothing);
    expect(find.text('Icon'), findsOneWidget);
    expect(find.text('🎯'), findsWidgets);

    controller.dispose();
  });

  testWidgets('create picker blocks duplicate choices', (tester) async {
    _useTallTestViewport(tester);
    final controller = await _createController();

    await tester.pumpWidget(DecisionMakerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('group-name-input')),
      'Dinner Picker',
    );
    await tester.enterText(
      find.byKey(const ValueKey('choice-input-0')),
      'Pizza',
    );
    await tester.enterText(
      find.byKey(const ValueKey('choice-input-1')),
      'pizza',
    );
    await tester.pumpAndSettle();

    expect(find.text('Duplicate choices are not allowed.'), findsOneWidget);
    final saveButton = find.widgetWithText(FilledButton, 'Save picker');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    controller.dispose();
  });

  testWidgets('edit picker updates an existing custom picker', (tester) async {
    _useTallTestViewport(tester);
    final controller = await _createController();
    final group = await controller.addCustomGroup(
      name: 'Picnic Picker',
      emoji: '📍',
      choices: ['Park', 'Beach'],
    );

    await tester.pumpWidget(DecisionMakerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Picnic Picker'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit picker'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Picker'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('group-name-input')),
      'Dinner Picker',
    );
    await tester.enterText(find.byKey(const ValueKey('choice-input-0')), 'Pho');
    await tester.enterText(
      find.byKey(const ValueKey('choice-input-1')),
      'Ramen',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    final updatedGroup = controller.findById(group.id);
    expect(updatedGroup?.name, 'Dinner Picker');
    expect(updatedGroup?.choices, ['Pho', 'Ramen']);
    expect(find.text('Dinner Picker'), findsOneWidget);

    controller.dispose();
  });

  test('edit picker saves a predefined picker override', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = DecisionGroupsController(
      repository: DecisionRepository(
        storage: LocalDecisionStorage(preferences: preferences),
      ),
    );
    await controller.loadGroups();

    await controller.updateCustomGroup(
      id: 'default-food',
      name: 'Quick Lunch',
      emoji: '🥗',
      choices: ['Salad', 'Soup'],
    );
    controller.dispose();

    final reloadedController = DecisionGroupsController(
      repository: DecisionRepository(
        storage: LocalDecisionStorage(preferences: preferences),
      ),
    );
    await reloadedController.loadGroups();

    final foodPickers = reloadedController.groups
        .where((group) => group.id == 'default-food')
        .toList();
    expect(foodPickers, hasLength(1));
    expect(foodPickers.single.name, 'Quick Lunch');
    expect(foodPickers.single.emoji, '🥗');
    expect(foodPickers.single.choices, ['Salad', 'Soup']);
    expect(foodPickers.single.isDefault, isFalse);

    reloadedController.dispose();
  });

  testWidgets('picker details toggles choices and requires two selected', (
    tester,
  ) async {
    final controller = await _createController();

    await tester.pumpWidget(
      DecisionGroupsScope(
        controller: controller,
        child: const MaterialApp(
          home: GroupDetailsScreen(groupId: 'default-movie-genre'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final choice in ['Action', 'Comedy', 'Horror', 'Sci-Fi', 'Drama']) {
      final choiceRow = find.byKey(ValueKey('choice-toggle-$choice'));
      await tester.ensureVisible(choiceRow);
      await tester.tap(choiceRow);
      await tester.pumpAndSettle();
    }

    expect(find.text('Select at least 2 choices'), findsOneWidget);
    final disabledStart = find.widgetWithText(FilledButton, 'Start picking');
    expect(tester.widget<FilledButton>(disabledStart).onPressed, isNull);

    final comedyRow = find.byKey(const ValueKey('choice-toggle-Comedy'));
    await tester.ensureVisible(comedyRow);
    await tester.tap(comedyRow);
    await tester.pumpAndSettle();

    expect(find.text('Select at least 2 choices'), findsNothing);
    final enabledStart = find.widgetWithText(FilledButton, 'Start picking');
    expect(tester.widget<FilledButton>(enabledStart).onPressed, isNotNull);

    controller.dispose();
  });
}

Future<DecisionGroupsController> _createController() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final controller = DecisionGroupsController(
    repository: DecisionRepository(
      storage: LocalDecisionStorage(preferences: preferences),
    ),
  );
  await controller.loadGroups();
  return controller;
}

void _useTallTestViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 2200);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
