import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// The Melo wordmark: lowercase "melo" set in Fraunces with a small plum
/// "spark" — a single point of colour that hints at a moment of connection.
///
/// [dotScale] lets the splash screen animate the spark independently.
class MeloWordmark extends StatelessWidget {
  const MeloWordmark({
    super.key,
    this.size = 40,
    this.color = AppColors.ink,
    this.dotScale = 1,
  });

  final double size;
  final Color color;
  final double dotScale;

  @override
  Widget build(BuildContext context) {
    final dot = size * 0.2;
    return Semantics(
      label: 'Melo',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'melo',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontWeight: FontWeight.w600,
              fontSize: size,
              height: 1,
              letterSpacing: -size * 0.035,
              color: color,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: size * 0.06, bottom: size * 0.1),
            child: Transform.scale(
              scale: dotScale,
              child: Container(
                width: dot,
                height: dot,
                decoration: const BoxDecoration(
                  color: AppColors.plum,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
