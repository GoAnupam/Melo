import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/melo_wordmark.dart';

/// Brand moment shown at launch: the wordmark settles in, the plum spark pops,
/// then the tagline fades up before handing off to the welcome screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Pause on the finished composition before navigating away.
  static const holdDuration = Duration(milliseconds: 700);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final _wordmarkOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.easeOut),
  );
  late final _wordmarkScale = Tween(begin: 0.94, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: AppMotion.curve),
    ),
  );
  late final _dotScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
  );
  late final _taglineOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1, curve: Curves.easeOut),
  );

  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      _navigateTimer = Timer(SplashScreen.holdDuration, _goNext);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  void _goNext() {
    if (mounted) context.go(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: _wordmarkOpacity.value,
                child: Transform.scale(
                  scale: _wordmarkScale.value,
                  child: MeloWordmark(size: 64, dotScale: _dotScale.value),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Opacity(
                opacity: _taglineOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, 6 * (1 - _taglineOpacity.value)),
                  child: Text(
                    'Meet naturally. Match intentionally.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
