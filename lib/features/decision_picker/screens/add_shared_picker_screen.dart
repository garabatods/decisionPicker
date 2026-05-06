import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';
import '../state/decision_groups_controller.dart';
import '../widgets/brand_top_bar.dart';

class AddSharedPickerScreen extends StatelessWidget {
  const AddSharedPickerScreen({super.key, required this.picker});

  final DecisionGroup picker;

  @override
  Widget build(BuildContext context) {
    final controller = DecisionGroupsScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const BrandTopBar(showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Shared Picker',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            picker.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              picker.name,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${picker.choices.length} choices',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: picker.choices.map((choice) {
                          return Chip(
                            label: Text(choice),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Would you like to add this picker to your collection?',
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _addPicker(context, controller),
                      child: const Text('Add Picker'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPicker(BuildContext context, DecisionGroupsController controller) {
    try {
      controller.addSharedPicker(picker);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picker added successfully!')),
      );
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add picker: $e')),
      );
    }
  }
}