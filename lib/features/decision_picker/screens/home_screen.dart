import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/decision_bottom_nav.dart';
import '../widgets/decision_group_card.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DecisionGroupsScope.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Scaffold(
          appBar: const BrandTopBar(showBack: true),
          bottomNavigationBar: const DecisionBottomNav(
            current: DecisionNavItem.explore,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/create'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 32),
          ),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Pickers',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                if (controller.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.groups.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.style_outlined,
                      title: 'No pickers yet',
                      message: 'Create a picker to start comparing options.',
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: controller.groups.length,
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            color: Colors.transparent,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 1,
                                end: 1.02,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        onReorder: controller.reorderGroups,
                        itemBuilder: (context, index) {
                          final group = controller.groups[index];
                          return Padding(
                            key: ValueKey(group.id),
                            padding: EdgeInsets.only(
                              bottom: index == controller.groups.length - 1
                                  ? 0
                                  : AppSpacing.md,
                            ),
                            child: ReorderableDelayedDragStartListener(
                              index: index,
                              child: DecisionGroupCard(
                                group: group,
                                colorIndex: index,
                                onTap: () => context.push('/group/${group.id}'),
                                onDelete: () => _confirmDelete(context, group),
                              ),
                            ),
                          );
                        },
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

  Future<void> _confirmDelete(BuildContext context, DecisionGroup group) async {
    final controller = DecisionGroupsScope.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete picker?'),
          content: Text('${group.name} will be removed from your pickers.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await controller.deleteCustomGroup(group.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Picker deleted.')));
      }
    }
  }
}
