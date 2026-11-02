import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/melo_button.dart';
import '../../../core/widgets/page_dots.dart';
import '../widgets/intro_visuals.dart';

class _IntroPage {
  const _IntroPage({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.visual,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget visual;
}

const _pages = [
  _IntroPage(
    eyebrow: 'DISCOVER',
    title: 'People worth\nmeeting.',
    body:
        'Profiles built around prompts and personality, with '
        'compatibility picks that explain why you might click.',
    visual: DiscoverVisual(),
  ),
  _IntroPage(
    eyebrow: 'CONNECT',
    title: 'Start with what\nyou share.',
    body:
        'Like a photo or reply to a prompt. Shared interests make the '
        'first message easy.',
    visual: InterestsVisual(),
  ),
  _IntroPage(
    eyebrow: 'MEET NATURALLY',
    title: 'Social, only if\nyou want it.',
    body:
        'Drop into live rooms and games when you feel like it. Classic '
        'dating works perfectly without them.',
    visual: RoomsVisual(),
  ),
];

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: AppMotion.medium, curve: AppMotion.curve);
    }
  }

  void _finish() => context.push(AppRoutes.phoneLogin);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          AnimatedOpacity(
            opacity: _isLast ? 0 : 1,
            duration: AppMotion.fast,
            child: MeloButton.text(
              label: 'Skip',
              onPressed: _isLast ? null : _finish,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: page.visual),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          page.eyebrow,
                          style: text.labelSmall?.copyWith(
                            color: AppColors.plum,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(page.title, style: text.displaySmall),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          page.body,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.lg,
                AppSpacing.screenH,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  PageDots(count: _pages.length, index: _index),
                  const Spacer(),
                  SizedBox(
                    width: 168,
                    child: MeloButton(
                      label: _isLast ? 'Create account' : 'Next',
                      onPressed: _next,
                    ),
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
