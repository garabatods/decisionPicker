import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class ChoiceInputRow extends StatelessWidget {
  const ChoiceInputRow({
    super.key,
    required this.controller,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    this.focusNode,
  });

  final TextEditingController controller;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              key: ValueKey('choice-input-$index'),
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Choice ${index + 1}'),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'Remove choice',
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
