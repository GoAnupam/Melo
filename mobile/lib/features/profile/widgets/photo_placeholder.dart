import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/profile_draft.dart';

/// Tones used for mock photos until real images are picked.
const mockPhotoTones = [AppColors.plumSoft, AppColors.sand, AppColors.sandDeep];

/// Stand-in for a profile photo: a tonal block with a portrait glyph.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.photo,
    this.borderRadius = BorderRadius.zero,
  });

  final ProfilePhoto photo;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: photo.tone,
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: Icon(
              Icons.person_rounded,
              size: constraints.biggest.shortestSide * 0.5,
              color: AppColors.plum.withValues(alpha: 0.16),
            ),
          ),
        ),
      ),
    );
  }
}
