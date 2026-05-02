import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/decision_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandTopBar(showBack: true),
      bottomNavigationBar: const DecisionBottomNav(
        current: DecisionNavItem.settings,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 116),
          children: [
            const CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.primaryFixed,
              child: Icon(Icons.person, color: AppColors.primary, size: 54),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Alex Morgan',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'alex@example.com',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(label: 'Preferences'),
            _SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark mode',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ),
            _SettingsTile(
              icon: Icons.volume_up,
              title: 'Sound effects',
              trailing: Switch(
                value: _sound,
                onChanged: (value) => setState(() => _sound = value),
              ),
            ),
            const _SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              trailing: Icon(Icons.chevron_right, color: AppColors.border),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(label: 'Support & Info'),
            const _SettingsTile(
              icon: Icons.help,
              title: 'Help Center',
              trailing: Icon(Icons.chevron_right, color: AppColors.border),
            ),
            const _SettingsTile(
              icon: Icons.policy,
              title: 'Privacy Policy',
              trailing: Icon(Icons.chevron_right, color: AppColors.border),
            ),
            const _SettingsTile(
              icon: Icons.description,
              title: 'Terms of Service',
              trailing: Icon(Icons.chevron_right, color: AppColors.border),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryFixed,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          trailing,
        ],
      ),
    );
  }
}
