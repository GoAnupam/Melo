import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Circular avatar showing a person's initial on a tonal background.
/// Used for mock data until real profile photos exist.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.background = AppColors.sand,
    this.foreground = AppColors.plum,
    this.ring = false,
  });

  final String name;
  final double size;
  final Color background;
  final Color foreground;

  /// Draws an ivory ring, useful when avatars overlap.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: AppColors.ivory, width: 3) : null,
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTypography.display,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.42,
          height: 1,
          color: foreground,
        ),
      ),
    );
  }
}
