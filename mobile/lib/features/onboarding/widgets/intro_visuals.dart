import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/initials_avatar.dart';

/// Visuals for the three introduction pages. Each is composed from real UI
/// elements (cards, chips, avatars) rather than illustrations, so the intro
/// previews the product itself.

/// Page 1 — discovery: a profile summary with a compatibility signal.
class DiscoverVisual extends StatelessWidget {
  const DiscoverVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _VisualFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const InitialsAvatar(
                      name: 'Ishaan',
                      size: 52,
                      background: AppColors.plumSoft,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ishaan, 28', style: text.titleMedium),
                          Text('Architect · Pune', style: text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'I’m weirdly competitive about',
                  style: text.labelSmall?.copyWith(color: AppColors.plum),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Finding the best vada pav in any city.',
                  style: text.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _Pill(
            icon: Icons.auto_awesome_rounded,
            label: 'High compatibility · You both value family',
          ),
        ],
      ),
    );
  }
}

/// Page 2 — shared interests: chips with the overlap highlighted.
class InterestsVisual extends StatelessWidget {
  const InterestsVisual({super.key});

  static const _interests = [
    ('Cricket', true),
    ('Indie music', true),
    ('Street food', false),
    ('Trekking', true),
    ('Board games', false),
    ('Photography', false),
    ('Bollywood', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _VisualFrame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const InitialsAvatar(name: 'You', size: 44, ring: true),
              Transform.translate(
                offset: const Offset(-10, 0),
                child: const InitialsAvatar(
                  name: 'Riya',
                  size: 44,
                  ring: true,
                  background: AppColors.plumSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final (label, shared) in _interests)
                _InterestChip(label: label, shared: shared),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page 3 — optional social rooms: a small live room card.
class RoomsVisual extends StatelessWidget {
  const RoomsVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const people = ['Neha', 'Arjun', 'Sana', 'Dev'];
    return _VisualFrame(
      child: _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.plum,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'LIVE ROOM',
                  style: text.labelSmall?.copyWith(color: AppColors.plum),
                ),
                const Spacer(),
                Text('12 listening', style: text.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Sunday chai & hot takes', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < people.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: InitialsAvatar(
                      name: people[i],
                      size: 40,
                      background: i.isEven
                          ? AppColors.plumSoft
                          : AppColors.sand,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Join to listen, play a game, or just say hi — or skip rooms '
              'entirely.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualFrame extends StatelessWidget {
  const _VisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: 320, child: child),
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.plumSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.plum),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.body,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.plum,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label, required this.shared});

  final String label;
  final bool shared;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: shared ? AppColors.plum : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: shared ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.body,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: shared ? AppColors.onPlum : AppColors.inkMuted,
        ),
      ),
    );
  }
}
