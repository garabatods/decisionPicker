import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/result_card.dart';
import '../widgets/slot_picker_view.dart';

enum PickerStatus { idle, spinning, result, invalid }

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key, required this.groupId, this.filteredChoices});

  final String groupId;
  final List<String>? filteredChoices;

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final Random _random = Random();

  PickerStatus _status = PickerStatus.idle;
  String? _selectedChoice;
  bool _hasRecordedCurrentPick = false;

  Future<void> _pick(DecisionGroup group, List<String> choices) async {
    if (_status == PickerStatus.spinning || choices.length < 2) {
      return;
    }

    final choice = choices[_random.nextInt(choices.length)];
    setState(() {
      _selectedChoice = choice;
      _status = PickerStatus.spinning;
      _hasRecordedCurrentPick = false;
    });
  }

  void _onSpinComplete(DecisionGroup group) {
    HapticFeedback.selectionClick();
    if (!mounted) {
      return;
    }

    if (_selectedChoice != null && !_hasRecordedCurrentPick) {
      DecisionGroupsScope.of(
        context,
      ).recordPick(group: group, choice: _selectedChoice!);
      _hasRecordedCurrentPick = true;
    }

    setState(() {
      _status = PickerStatus.result;
    });
  }

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

    final choices = _activeChoices(group);
    final effectiveStatus = choices.length < 2 ? PickerStatus.invalid : _status;
    final isSpinning = effectiveStatus == PickerStatus.spinning;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const BrandTopBar(showBack: true),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface
                : AppColors.background.withValues(alpha: 0.96),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: isSpinning || effectiveStatus == PickerStatus.invalid
                    ? null
                    : () => _pick(group, choices),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.primary : AppColors.primary,
                  foregroundColor: isDark ? Colors.white : AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                ),
                child: Text(
                  effectiveStatus == PickerStatus.result
                      ? 'Pick again'
                      : 'Pick for me',
                  style: TextStyle(
                    color: isDark ? Colors.white : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: isSpinning ? null : () => context.go('/'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : AppColors.surfaceContainerLow,
                  foregroundColor: isDark ? AppColors.primary : null,
                  side: isDark
                      ? BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.24),
                        )
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.buttonRadius,
                    ),
                  ),
                ),
                child: Text(
                  'Back to pickers',
                  style: TextStyle(
                    color: isDark ? AppColors.primary : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            _PickerHeader(group: group, status: effectiveStatus),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 520),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final scale = Tween<double>(
                  begin: 0.96,
                  end: 1,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: scale, child: child),
                );
              },
              child:
                  effectiveStatus == PickerStatus.result &&
                      _selectedChoice != null
                  ? ResultCard(
                      key: ValueKey('result-$_selectedChoice'),
                      result: _selectedChoice!,
                    )
                  : effectiveStatus != PickerStatus.invalid
                  ? SlotPickerView(
                      key: const ValueKey('slot-picker'),
                      choices: choices,
                      selectedChoice: _selectedChoice,
                      isSpinning: isSpinning,
                      onSpinComplete: () => _onSpinComplete(group),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty-picker')),
            ),
            if (effectiveStatus == PickerStatus.invalid)
              const EmptyState(
                icon: Icons.info_outline,
                title: 'Not enough choices',
                message: 'Add at least 2 choices to start picking.',
              ),
          ],
        ),
      ),
    );
  }

  List<String> _activeChoices(DecisionGroup group) {
    final filteredChoices = widget.filteredChoices;
    if (filteredChoices == null) {
      return group.choices;
    }

    return filteredChoices
        .where((choice) => group.choices.contains(choice))
        .toList();
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.group, required this.status});

  final DecisionGroup group;
  final PickerStatus status;

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
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF4ED6C9)
                          : AppColors.tertiary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _statusText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.85)
                          : null,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF4DD9CC)
                : AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            group.emoji,
            style: const TextStyle(fontSize: 34, letterSpacing: 0),
          ),
        ),
      ],
    );
  }

  String get _statusText {
    return switch (status) {
      PickerStatus.idle => 'Ready when you are.',
      PickerStatus.spinning => 'Choosing...',
      PickerStatus.result => 'Here is your pick.',
      PickerStatus.invalid => 'Add at least 2 choices to start picking.',
    };
  }
}
