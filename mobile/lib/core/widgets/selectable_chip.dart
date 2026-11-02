import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Pill-shaped toggle used for interests, gender and similar choices.
///
/// [muted] dims an unselected chip (e.g. when a selection limit is reached)
/// while keeping it tappable so the screen can explain the limit.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? AppColors.onPlum
        : muted
        ? AppColors.inkSubtle
        : AppColors.ink;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.plum : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? AppColors.plum : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedPadding(
            duration: AppMotion.fast,
            padding: EdgeInsets.fromLTRB(selected ? 12 : 16, 10, 16, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check_rounded, size: 16, color: foreground),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.body,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
