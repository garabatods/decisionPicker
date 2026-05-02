import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/brand_top_bar.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController(
    text: 'Dinner ideas under 30 minutes',
  );

  final List<String> _suggestions = const [
    'Homemade pizza',
    'Veggie stir fry',
    'Tapas night',
    'Pasta and salad',
    'Breakfast for dinner',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final controller = DecisionGroupsScope.of(context);
    await controller.addCustomGroup(
      name: 'Suggested Ideas',
      emoji: '✨',
      choices: _suggestions,
    );

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandTopBar(title: 'Idea Assist', showBack: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 42),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryFixed,
                  child: Icon(Icons.auto_awesome, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Describe the decision',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What options would you like help with?',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate ideas'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Suggestions',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final suggestion in _suggestions)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _createGroup,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Create picker with suggestions'),
            ),
          ],
        ),
      ),
    );
  }
}
