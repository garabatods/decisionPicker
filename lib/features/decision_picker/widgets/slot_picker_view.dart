import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SlotPickerView extends StatefulWidget {
  const SlotPickerView({
    super.key,
    required this.choices,
    required this.selectedChoice,
    required this.isSpinning,
    this.onSpinComplete,
  });

  final List<String> choices;
  final String? selectedChoice;
  final bool isSpinning;
  final VoidCallback? onSpinComplete;

  @override
  State<SlotPickerView> createState() => _SlotPickerViewState();
}

class _SlotPickerViewState extends State<SlotPickerView>
    with SingleTickerProviderStateMixin {
  static const double _height = 320;
  static const double _itemHeight = 64;
  static const int _cycles = 12;

  late final AnimationController _controller;

  Animation<double> _offsetAnimation = const AlwaysStoppedAnimation(0);
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.isSpinning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isSpinning) {
          _startSpin();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SlotPickerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _startSpin();
    }

    if (widget.choices != oldWidget.choices && !widget.isSpinning) {
      _offset = 0;
      _offsetAnimation = AlwaysStoppedAnimation(_offset);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (widget.choices.isEmpty || widget.selectedChoice == null) {
      widget.onSpinComplete?.call();
      return;
    }

    final selectedIndex = widget.choices.indexOf(widget.selectedChoice!);
    final finalChoiceIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final targetIndex =
        widget.choices.length * (_cycles - 2) + finalChoiceIndex;
    final targetOffset = -targetIndex * _itemHeight;

    setState(() {
      _offsetAnimation = Tween<double>(begin: _offset, end: targetOffset)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
    });

    _controller
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) {
          return;
        }
        setState(() {
          _offset = targetOffset;
          _offsetAnimation = AlwaysStoppedAnimation(_offset);
        });
        widget.onSpinComplete?.call();
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.choices.isEmpty) {
      return const SizedBox(
        height: _height,
        child: Center(child: Text('No choices yet')),
      );
    }

    return Container(
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.16)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: _itemHeight,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: isDark ? 0.42 : 1),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                      alpha: isDark ? 0.12 : 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _offsetAnimation,
            builder: (context, child) {
              final offset = _offsetAnimation.value;
              return Stack(
                children: [
                  for (
                    var index = 0;
                    index < widget.choices.length * _cycles;
                    index++
                  )
                    _SlotChoice(
                      top:
                          (_height / 2) -
                          (_itemHeight / 2) +
                          (index * _itemHeight) +
                          offset,
                      height: _itemHeight,
                      label: widget.choices[index % widget.choices.length],
                      isSelected: _isCentered(
                        (_height / 2) -
                            (_itemHeight / 2) +
                            (index * _itemHeight) +
                            offset,
                      ),
                    ),
                ],
              );
            },
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? theme.colorScheme.surface
                        : AppColors.surfaceContainer,
                    isDark
                        ? theme.colorScheme.surface.withValues(alpha: 0)
                        : AppColors.surfaceContainer.withValues(alpha: 0),
                    isDark
                        ? theme.colorScheme.surface.withValues(alpha: 0)
                        : AppColors.surfaceContainer.withValues(alpha: 0),
                    isDark
                        ? theme.colorScheme.surface
                        : AppColors.surfaceContainer,
                  ],
                  stops: const [0, 0.22, 0.78, 1],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCentered(double top) {
    final itemCenter = top + (_itemHeight / 2);
    return (itemCenter - (_height / 2)).abs() < 1;
  }
}

class _SlotChoice extends StatelessWidget {
  const _SlotChoice({
    required this.top,
    required this.height,
    required this.label,
    required this.isSelected,
  });

  final double top;
  final double height;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      height: height,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: isSelected ? 1 : 0.55)
                : AppColors.textPrimary.withValues(
                    alpha: isSelected ? 1 : 0.48,
                  ),
            fontSize: isSelected ? 28 : 19,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 0,
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
