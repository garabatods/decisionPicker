import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';

class DecisionGroupCard extends StatelessWidget {
  const DecisionGroupCard({
    super.key,
    required this.group,
    required this.colorIndex,
    required this.onTap,
    this.onDelete,
  });

  final DecisionGroup group;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final supportingText = switch (group.id) {
      'default-food' => 'Choose a meal with less back-and-forth',
      'default-movie-genre' => 'Pick a direction for movie night',
      'default-truth-or-dare' => 'Choose a prompt for everyone',
      'default-game-night' => 'Decide what to play next',
      'default-weekend' => 'Pick an easy plan for your weekend',
      _ => '${group.choices.length} choices',
    };

    return Card(
      margin: EdgeInsets.zero,
      color: _palette.cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        onLongPress: group.isDefault ? null : onDelete,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _palette.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  group.emoji,
                  style: const TextStyle(fontSize: 21, letterSpacing: 0),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 21, height: 1.16),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      supportingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: group.isDefault ? null : onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.border,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CardPalette get _palette => _cardPalettes[colorIndex % _cardPalettes.length];

  String get _displayName {
    return switch (group.id) {
      'default-truth-or-dare' => 'Truth or Dare',
      _ => group.name,
    };
  }
}

class _CardPalette {
  const _CardPalette({required this.cardColor, required this.iconColor});

  final Color cardColor;
  final Color iconColor;
}

const List<_CardPalette> _cardPalettes = [
  _CardPalette(cardColor: Color(0xFFE2F8F5), iconColor: Color(0xFF96EAD8)),
  _CardPalette(cardColor: Color(0xFFE6F2FF), iconColor: Color(0xFFA8DDF8)),
  _CardPalette(cardColor: Color(0xFFEDE8FF), iconColor: Color(0xFFD2C7FF)),
  _CardPalette(cardColor: Color(0xFFFFECDE), iconColor: Color(0xFFFFC09E)),
  _CardPalette(cardColor: Color(0xFFFFF4C9), iconColor: Color(0xFFFFDF73)),
  _CardPalette(cardColor: Color(0xFFFFE5EF), iconColor: Color(0xFFFFB4CF)),
  _CardPalette(cardColor: Color(0xFFEAF7D8), iconColor: Color(0xFFBFEA80)),
  _CardPalette(cardColor: Color(0xFFE8EDFF), iconColor: Color(0xFFBFCBFF)),
];
