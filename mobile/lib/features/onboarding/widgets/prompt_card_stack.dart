import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// Hero composition for the welcome screen: three fanned profile prompt cards
/// and a "liked your prompt" toast, which previews how Melo works — people
/// connect over what they say, not just a photo.
///
/// Sizes derive from the available space so it fits small and large phones.
class PromptCardStack extends StatefulWidget {
  const PromptCardStack({super.key});

  @override
  State<PromptCardStack> createState() => _PromptCardStackState();
}

class _PromptCardStackState extends State<PromptCardStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: AppMotion.curve),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Card width is bounded by both width and height so the composition
        // never overflows on short screens.
        final cardWidth = math.min(
          math.min(constraints.maxWidth * 0.78, 310.0),
          constraints.maxHeight * 0.62,
        );
        final cardHeight = cardWidth * 0.74;
        final scale = cardWidth / 300;

        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: math.min(constraints.maxHeight, cardHeight * 1.5),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Back cards are purely tonal shapes that give depth; text on
                // them would be cropped by the front card.
                _AnimatedCard(
                  animation: _interval(0.0, 0.6),
                  angle: -0.1,
                  offset: Offset(-cardWidth * 0.1, -cardHeight * 0.12),
                  child: _BackCard(
                    width: cardWidth,
                    height: cardHeight,
                    scale: scale,
                    color: AppColors.sand,
                  ),
                ),
                _AnimatedCard(
                  animation: _interval(0.12, 0.72),
                  angle: 0.08,
                  offset: Offset(cardWidth * 0.1, -cardHeight * 0.06),
                  child: _BackCard(
                    width: cardWidth,
                    height: cardHeight,
                    scale: scale,
                    color: AppColors.plumSoft,
                  ),
                ),
                _AnimatedCard(
                  animation: _interval(0.24, 0.84),
                  angle: -0.015,
                  offset: Offset(0, cardHeight * 0.06),
                  child: _PromptCard(
                    width: cardWidth,
                    height: cardHeight,
                    scale: scale,
                    background: AppColors.surface,
                    bordered: true,
                    label: 'MY IDEAL SUNDAY',
                    answer:
                        'Filter coffee, a long walk, and a playlist '
                        "that's mostly old Rahman.",
                    name: 'Aanya, 26',
                    meta: 'Bengaluru',
                    showLike: true,
                  ),
                ),
                _AnimatedCard(
                  animation: _interval(0.45, 0.9),
                  angle: 0.04,
                  offset: Offset(cardWidth * 0.36, -cardHeight * 0.56),
                  child: _SharedInterestsChip(scale: scale),
                ),
                _AnimatedCard(
                  animation: _interval(0.55, 1.0),
                  angle: 0,
                  offset: Offset(-cardWidth * 0.3, cardHeight * 0.6),
                  child: _LikeToast(scale: scale),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({
    required this.animation,
    required this.angle,
    required this.offset,
    required this.child,
  });

  final Animation<double> animation;
  final double angle;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: offset + Offset(0, 28 * (1 - t)),
            child: Transform.rotate(angle: angle * t, child: child),
          ),
        );
      },
    );
  }
}

class _BackCard extends StatelessWidget {
  const _BackCard({
    required this.width,
    required this.height,
    required this.scale,
    required this.color,
  });

  final double width;
  final double height;
  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.lg * scale),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.width,
    required this.height,
    required this.scale,
    required this.background,
    required this.label,
    required this.answer,
    required this.name,
    this.meta,
    this.bordered = false,
    this.showLike = false,
  });

  final double width;
  final double height;
  final double scale;
  final Color background;
  final String label;
  final String answer;
  final String name;
  final String? meta;
  final bool bordered;
  final bool showLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.lg * scale),
        border: bordered ? Border.all(color: AppColors.border) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 24 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.body,
              fontWeight: FontWeight.w700,
              fontSize: 10.5 * scale,
              letterSpacing: 1.1,
              color: AppColors.plum,
            ),
          ),
          SizedBox(height: 10 * scale),
          Expanded(
            child: Text(
              answer,
              maxLines: 4,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontFamily: AppTypography.display,
                fontWeight: FontWeight.w500,
                fontSize: 21 * scale,
                height: 1.22,
                letterSpacing: -0.2,
                color: AppColors.ink,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontSize: 13 * scale,
                    ),
                    children: [
                      if (meta != null)
                        TextSpan(
                          text: '  ·  $meta',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                  style: const TextStyle(fontFamily: AppTypography.body),
                ),
              ),
              if (showLike)
                Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: const BoxDecoration(
                    color: AppColors.plum,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 20 * scale,
                    color: AppColors.onPlum,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikeToast extends StatelessWidget {
  const _LikeToast({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 14 * scale,
            color: AppColors.plumMuted,
          ),
          SizedBox(width: 8 * scale),
          Text(
            'Rohan liked your prompt',
            style: TextStyle(
              fontFamily: AppTypography.body,
              fontWeight: FontWeight.w600,
              fontSize: 12.5 * scale,
              color: AppColors.onPlum,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedInterestsChip extends StatelessWidget {
  const _SharedInterestsChip({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 14 * scale,
            color: AppColors.plum,
          ),
          SizedBox(width: 6 * scale),
          Text(
            '3 shared interests',
            style: TextStyle(
              fontFamily: AppTypography.body,
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
