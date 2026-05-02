import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum DecisionNavItem { explore, groups, history, settings }

class DecisionBottomNav extends StatelessWidget {
  const DecisionBottomNav({super.key, required this.current});

  final DecisionNavItem current;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.navHeight,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavButton(
            label: 'Pickers',
            icon: Icons.explore,
            selected: current == DecisionNavItem.explore,
            onTap: () => context.go('/'),
          ),
          _NavButton(
            label: 'Saved',
            icon: Icons.grid_view,
            selected: current == DecisionNavItem.groups,
            onTap: () => context.go('/'),
          ),
          _NavButton(
            label: 'History',
            icon: Icons.history,
            selected: current == DecisionNavItem.history,
            onTap: () => context.go('/history'),
          ),
          _NavButton(
            label: 'Settings',
            icon: Icons.settings,
            selected: current == DecisionNavItem.settings,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Colors.blueGrey.shade300;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: selected ? 28 : 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
