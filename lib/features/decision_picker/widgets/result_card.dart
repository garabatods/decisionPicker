import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ResultCard extends StatefulWidget {
  const ResultCard({super.key, required this.result});

  final String result;

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : AppColors.result,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.24)
                  : const Color(0xFFFFC857),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : const Color(0xFFFFC857).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _Confetti(
                progress: _controller.value,
                top: 4,
                left: 12,
                dx: -12,
                dy: -18,
                color: const Color(0xFF4343D5),
                size: 8,
              ),
              _Confetti(
                progress: _controller.value,
                top: 20,
                right: 24,
                dx: 16,
                dy: -16,
                color: const Color(0xFFFF7FA3),
                size: 9,
              ),
              _Confetti(
                progress: _controller.value,
                bottom: 12,
                left: 34,
                dx: -18,
                dy: 14,
                color: const Color(0xFF116A5E),
                size: 7,
              ),
              _Confetti(
                progress: _controller.value,
                bottom: 18,
                right: 12,
                dx: 18,
                dy: 16,
                color: const Color(0xFFFFA23A),
                size: 8,
              ),
              _Confetti(
                progress: _controller.value,
                top: -6,
                left: 122,
                dx: 2,
                dy: -22,
                color: const Color(0xFF67D3F5),
                size: 7,
              ),
              child!,
            ],
          ),
        );
      },
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: isDark ? Colors.white : AppColors.primary,
            size: 34,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Picked',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.result,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              height: 1.18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.progress,
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
  });

  final double progress;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double dx;
  final double dy;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final curved = Curves.easeOutBack.transform(progress.clamp(0, 1));
    final fade = (1 - Curves.easeIn.transform(progress.clamp(0, 1))).clamp(
      0.0,
      1.0,
    );

    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Opacity(
        opacity: fade,
        child: Transform.translate(
          offset: Offset(dx * curved, dy * curved),
          child: Transform.rotate(
            angle: progress * 1.8,
            child: Container(
              width: size,
              height: size * 1.5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
