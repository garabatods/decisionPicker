import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/decision_group.dart';
import '../widgets/brand_top_bar.dart';
import '../widgets/choice_input_row.dart';
import '../widgets/empty_state.dart';

class CreatePickerScreen extends StatefulWidget {
  const CreatePickerScreen({super.key, this.groupId});

  final String? groupId;

  @override
  State<CreatePickerScreen> createState() => _CreatePickerScreenState();
}

class _CreatePickerScreenState extends State<CreatePickerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController(
    text: '🎯',
  );
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _choiceControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<FocusNode> _choiceFocusNodes = [FocusNode(), FocusNode()];
  final List<GlobalKey> _choiceKeys = [GlobalKey(), GlobalKey()];
  final GlobalKey _addChoiceKey = GlobalKey();
  bool _loadedExistingPicker = false;
  bool _isPopulatingFields = false;

  bool get _isEditing => widget.groupId != null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _emojiController.addListener(_refresh);
    for (var index = 0; index < _choiceControllers.length; index++) {
      _attachChoiceField(index);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isEditing || _loadedExistingPicker) {
      return;
    }

    _loadedExistingPicker = true;
    final group = DecisionGroupsScope.of(context).findById(widget.groupId!);
    if (group != null) {
      _isPopulatingFields = true;
      _loadExistingGroup(group);
      _isPopulatingFields = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _scrollController.dispose();
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    for (final focusNode in _choiceFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool get _hasDuplicateChoices {
    final seen = <String>{};
    for (final choice in _validChoices) {
      final normalized = choice.toLowerCase();
      if (seen.contains(normalized)) {
        return true;
      }
      seen.add(normalized);
    }
    return false;
  }

  List<String> get _validChoices => _choiceControllers
      .map((controller) => controller.text.trim())
      .where((choice) => choice.isNotEmpty)
      .toList();

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _validChoices.length >= 2 &&
      !_hasDuplicateChoices;

  String? get _validationMessage {
    if (_validChoices.length < 2) {
      return 'Add at least 2 choices.';
    }
    if (_hasDuplicateChoices) {
      return 'Duplicate choices are not allowed.';
    }
    return null;
  }

  String? get _pickerNameMessage {
    if (_nameController.text.trim().isEmpty) {
      return 'Add a picker name.';
    }
    return null;
  }

  String _sentenceCase(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  void _refresh() {
    if (_isPopulatingFields) {
      return;
    }
    setState(() {});
  }

  void _attachChoiceField(int index) {
    _choiceControllers[index].addListener(_refresh);
    final focusNode = _choiceFocusNodes[index];
    focusNode.addListener(() => _handleChoiceFocusChange(focusNode));
  }

  void _loadExistingGroup(DecisionGroup group) {
    _nameController.text = group.name;
    _emojiController.text = group.emoji;

    final choices = group.choices.length >= 2
        ? group.choices
        : [...group.choices, ...List.filled(2 - group.choices.length, '')];

    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    for (final focusNode in _choiceFocusNodes) {
      focusNode.dispose();
    }

    _choiceControllers
      ..clear()
      ..addAll(choices.map((choice) => TextEditingController(text: choice)));
    _choiceFocusNodes
      ..clear()
      ..addAll(List.generate(choices.length, (_) => FocusNode()));
    _choiceKeys
      ..clear()
      ..addAll(List.generate(choices.length, (_) => GlobalKey()));

    for (var index = 0; index < _choiceControllers.length; index++) {
      _attachChoiceField(index);
    }
  }

  void _addChoice() {
    final nextIndex = _choiceControllers.length;
    setState(() {
      final controller = TextEditingController();
      _choiceControllers.add(controller);
      final focusNode = FocusNode();
      _choiceFocusNodes.add(focusNode);
      _choiceKeys.add(GlobalKey());
      _attachChoiceField(nextIndex);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _choiceFocusNodes[nextIndex].requestFocus();
      _scrollChoiceIntoView(nextIndex);
      _scrollAddChoiceIntoView();
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (mounted) {
          _scrollChoiceIntoView(nextIndex);
          _scrollAddChoiceIntoView();
        }
      });
    });
  }

  void _removeChoice(int index) {
    setState(() {
      final controller = _choiceControllers.removeAt(index);
      controller.dispose();
      final focusNode = _choiceFocusNodes.removeAt(index);
      focusNode.dispose();
      _choiceKeys.removeAt(index);
    });
  }

  void _handleChoiceFocusChange(FocusNode focusNode) {
    final index = _choiceFocusNodes.indexOf(focusNode);
    if (index == -1 || !focusNode.hasFocus) {
      return;
    }
    _scrollChoiceIntoView(index);
    if (index >= _choiceControllers.length - 2) {
      _scrollAddChoiceIntoView();
    }
  }

  void _scrollChoiceIntoView(int index) {
    if (index >= _choiceKeys.length) {
      return;
    }

    final choiceContext = _choiceKeys[index].currentContext;
    if (choiceContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      choiceContext,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.56,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  void _scrollAddChoiceIntoView() {
    final addChoiceContext = _addChoiceKey.currentContext;
    if (addChoiceContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      addChoiceContext,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.94,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }

    final controller = DecisionGroupsScope.of(context);
    final groupId = widget.groupId;
    final formattedName = _sentenceCase(_nameController.text);
    final formattedChoices = _validChoices.map(_sentenceCase).toList();

    if (groupId == null) {
      await controller.addCustomGroup(
        name: formattedName,
        emoji: _emojiController.text,
        choices: formattedChoices,
      );
    } else {
      await controller.updateCustomGroup(
        id: groupId,
        name: formattedName,
        emoji: _emojiController.text,
        choices: formattedChoices,
      );
    }

    if (mounted) {
      if (groupId == null) {
        context.go('/');
      } else {
        context.go('/group/$groupId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final group = DecisionGroupsScope.of(context).findById(widget.groupId!);
      if (group == null) {
        return const Scaffold(
          appBar: BrandTopBar(title: 'Edit Picker', showBack: true),
          body: SafeArea(
            child: EmptyState(
              icon: Icons.edit_off,
              title: 'Picker not found',
              message: 'That picker may have been deleted.',
            ),
          ),
        );
      }
    }

    final validationMessage = _validationMessage;
    final title = _isEditing ? 'Edit Picker' : 'Create Picker';

    return Scaffold(
      appBar: BrandTopBar(title: title, showBack: true),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : AppColors.background.withValues(alpha: 0.96),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (validationMessage != null) ...[
                  Text(
                    validationMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                FilledButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: _canSave ? _save : null,
                  child: Text(_isEditing ? 'Save changes' : 'Save picker'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            _FormSection(
              title: 'Picker details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FocusedTextField(
                    fieldKey: const ValueKey('group-name-input'),
                    controller: _nameController,
                    label: 'Picker name',
                    message: _pickerNameMessage,
                    hintText: 'Friday Night Drinks',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _IconPickerField(controller: _emojiController),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormSection(
              title: 'Choices',
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < _choiceControllers.length;
                    index++
                  )
                    ChoiceInputRow(
                      key: _choiceKeys[index],
                      controller: _choiceControllers[index],
                      focusNode: _choiceFocusNodes[index],
                      index: index,
                      canRemove: _choiceControllers.length > 2,
                      onRemove: () => _removeChoice(index),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  KeyedSubtree(
                    key: _addChoiceKey,
                    child: _AddChoiceButton(onPressed: _addChoice),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.24)
                : theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _IconPickerField extends StatelessWidget {
  const _IconPickerField({required this.controller});

  final TextEditingController controller;

  static const List<String> _quickIcons = [
    '🎯',
    '🍕',
    '🎬',
    '🎲',
    '🎮',
    '🌤️',
    '✨',
    '📍',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Icon'),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quickIcons.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              if (index == _quickIcons.length) {
                return const _FutureIconButton();
              }

              final icon = _quickIcons[index];
              final isSelected = controller.text == icon;
              return _IconChoice(
                icon: icon,
                isSelected: isSelected,
                onTap: () => controller.text = icon,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FocusedTextField extends StatefulWidget {
  const _FocusedTextField({
    required this.controller,
    this.fieldKey,
    this.label,
    this.message,
    this.hintText,
    this.textInputAction,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String? label;
  final String? message;
  final String? hintText;
  final TextInputAction? textInputAction;

  @override
  State<_FocusedTextField> createState() => _FocusedTextFieldState();
}

class _FocusedTextFieldState extends State<_FocusedTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFocused = _focusNode.hasFocus;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _FieldLabel(label: widget.label!, message: widget.message),
          const SizedBox(height: AppSpacing.xs),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(
              color: isFocused
                  ? theme.colorScheme.primary
                  : isDark
                      ? theme.colorScheme.onSurface.withOpacity(0.06)
                      : theme.colorScheme.outline,
              width: isFocused ? 2 : 0,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            key: widget.fieldKey,
            focusNode: _focusNode,
            controller: widget.controller,            textCapitalization: TextCapitalization.sentences,            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 15,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.message});

  final String label;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _SectionLabel(label)),
        if (message != null) _InlineFieldMessage(message!),
      ],
    );
  }
}

class _InlineFieldMessage extends StatelessWidget {
  const _InlineFieldMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 13, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isDark
                      ? theme.colorScheme.onSurface.withOpacity(0.08)
                      : theme.colorScheme.outline,
              width: isSelected ? 2 : 0,
            ),
          ),
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 22,
              letterSpacing: 0,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _FutureIconButton extends StatelessWidget {
  const _FutureIconButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Tooltip(
      message: 'Custom images coming later',
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AddChoiceButton extends StatelessWidget {
  const _AddChoiceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.32),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        ),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add choice'),
    );
  }
}
