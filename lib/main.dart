import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'features/decision_picker/data/decision_repository.dart';
import 'features/decision_picker/data/local_decision_storage.dart';
import 'features/decision_picker/state/decision_groups_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final controller = DecisionGroupsController(
    repository: DecisionRepository(
      storage: LocalDecisionStorage(preferences: preferences),
    ),
  );
  final themeController = ThemeController(preferences: preferences);

  await controller.loadGroups();
  await themeController.loadThemeMode();

  runApp(
    DecisionMakerApp(
      controller: controller,
      themeController: themeController,
    ),
  );
}
