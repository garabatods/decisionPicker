import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/decision_picker/screens/ai_assistant_screen.dart';
import 'features/decision_picker/screens/create_picker_screen.dart';
import 'features/decision_picker/screens/group_details_screen.dart';
import 'features/decision_picker/screens/history_screen.dart';
import 'features/decision_picker/screens/home_screen.dart';
import 'features/decision_picker/screens/picker_screen.dart';
import 'features/decision_picker/screens/settings_screen.dart';
import 'features/decision_picker/state/decision_groups_controller.dart';

class DecisionMakerApp extends StatefulWidget {
  const DecisionMakerApp({super.key, required this.controller});

  final DecisionGroupsController controller;

  @override
  State<DecisionMakerApp> createState() => _DecisionMakerAppState();
}

class _DecisionMakerAppState extends State<DecisionMakerApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreatePickerScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? '';
          return CreatePickerScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/group/:id',
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? '';
          return GroupDetailsScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/picker/:id',
        builder: (context, state) {
          final groupId = state.pathParameters['id'] ?? '';
          final extra = state.extra;
          final filteredChoices = extra is List<String>
              ? List<String>.from(extra)
              : null;
          return PickerScreen(
            groupId: groupId,
            filteredChoices: filteredChoices,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DecisionGroupsScope(
      controller: widget.controller,
      child: MaterialApp.router(
        title: 'Pickers',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}

class DecisionGroupsScope extends InheritedNotifier<DecisionGroupsController> {
  const DecisionGroupsScope({
    super.key,
    required DecisionGroupsController controller,
    required super.child,
  }) : super(notifier: controller);

  static DecisionGroupsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DecisionGroupsScope>();
    assert(scope != null, 'No DecisionGroupsScope found in context.');
    return scope!.notifier!;
  }
}
