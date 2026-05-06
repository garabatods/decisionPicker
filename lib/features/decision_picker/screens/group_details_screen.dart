import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/empty_state.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  String? _loadedGroupId;
  Set<String> _selectedChoices = {};

  @override
  Widget build(BuildContext context) {
    final controller = DecisionGroupsScope.of(context);
    final group = controller.findById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: const BrandTopBar(showBack: true),
        body: const SafeArea(
          child: EmptyState(
            icon: Icons.search_off,
            title: 'Picker not found',
            message: 'That picker may have been deleted.',
          ),
        ),
      );
    }

    _syncSelectedChoices(group);

    final selectedChoices = group.choices
        .where(_selectedChoices.contains)
        .toList();
    final canStart = selectedChoices.length >= 2;

    return Scaffold(
      appBar: BrandTopBar(
        showBack: true,
        trailing: IconButton(
          tooltip: 'Edit picker',
          onPressed: () => context.push('/edit/${group.id}'),
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.96),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: canStart
                    ? () => context.push(
                        '/picker/${group.id}',
                        extra: selectedChoices,
                      )
                    : null,
                icon: const Icon(Icons.casino),
                label: const Text('Start picking'),
              ),
              if (!canStart) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Select at least 2 choices',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          children: [
            _PickerDetailsHeader(
              group: group,
              selectedCount: selectedChoices.length,
              totalCount: group.choices.length,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Choices', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            for (final choice in group.choices)
              _ChoiceToggleRow(
                choice: choice,
                isSelected: _selectedChoices.contains(choice),
                onTap: () => _toggleChoice(choice),
              ),
          ],
        ),
      ),
    );
  }

  void _syncSelectedChoices(DecisionGroup group) {
    if (_loadedGroupId == group.id) {
      return;
    }

    _loadedGroupId = group.id;
    _selectedChoices = group.choices.toSet();
  }

  void _toggleChoice(String choice) {
    setState(() {
      if (_selectedChoices.contains(choice)) {
        _selectedChoices.remove(choice);
      } else {
        _selectedChoices.add(choice);
      }
    });
  }
}

class _PickerDetailsHeader extends StatelessWidget {
  const _PickerDetailsHeader({
    required this.group,
    required this.selectedCount,
    required this.totalCount,
  });

  final DecisionGroup group;
  final int selectedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$selectedCount of $totalCount choices selected',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 78,
          height: 78,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            group.emoji,
            style: const TextStyle(fontSize: 38, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}

class _ChoiceToggleRow extends StatelessWidget {
  const _ChoiceToggleRow({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  final String choice;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        key: ValueKey('choice-toggle-$choice'),
        color: Colors.white.withValues(alpha: isSelected ? 1 : 0.58),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.secondary : AppColors.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    choice,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
