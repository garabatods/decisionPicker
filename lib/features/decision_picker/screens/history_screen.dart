import 'package:flutter/material.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/decision_bottom_nav.dart';
import '../widgets/empty_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DecisionGroupsScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final cardColor = isDark
            ? theme.colorScheme.surfaceContainerHigh
            : Colors.white;
        final shadowColor = isDark
            ? Colors.black.withValues(alpha: 0.18)
            : AppColors.primary.withValues(alpha: 0.08);

        return Scaffold(
          appBar: const BrandTopBar(showBack: true),
          bottomNavigationBar: const DecisionBottomNav(
            current: DecisionNavItem.history,
          ),
          body: SafeArea(
            top: false,
            child: controller.history.isEmpty
                ? const EmptyState(
                    icon: Icons.history,
                    title: 'No history yet',
                    message: 'Make a pick and it will show up here.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 116),
                    children: [
                      Row(
                        children: [
                          Text(
                            'History',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const Spacer(),
                          Text(
                            'Recent',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final item in controller.history)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primaryFixed,
                                  child: Text(
                                    item.groupEmoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.groupName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.choice,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
