import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Shared layout for single-question form steps (authentication, profile
/// setup): back button, optional progress bar, headline, supporting text,
/// a scrollable body, and a primary action pinned above the keyboard.
class FormStepScaffold extends StatelessWidget {
  const FormStepScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.action,
    this.footer,
    this.progress,
  });

  final String title;
  final Widget subtitle;
  final Widget body;
  final Widget action;
  final Widget? footer;

  /// 0–1. When set, a progress bar is shown in the app bar.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();

    return GestureDetector(
      // Tap outside a field to dismiss the keyboard.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: canPop ? const BackButton() : null,
          titleSpacing: canPop ? 0 : AppSpacing.screenH,
          title: progress == null ? null : _ProgressBar(value: progress!),
          actions: progress == null || !canPop
              ? null
              : const [SizedBox(width: AppSpacing.screenH + 32)],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.xs,
                    AppSpacing.screenH,
                    AppSpacing.lg,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      DefaultTextStyle.merge(
                        style: text.bodyLarge?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                        child: subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      body,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.xs,
                  AppSpacing.screenH,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    action,
                    if (footer != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      footer!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step progress',
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value),
          duration: AppMotion.slow,
          curve: AppMotion.curve,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            minHeight: 5,
            backgroundColor: AppColors.sandDeep,
            color: AppColors.plum,
          ),
        ),
      ),
    );
  }
}
