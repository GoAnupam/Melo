import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/melo_button.dart';
import '../../../core/widgets/melo_wordmark.dart';
import '../widgets/prompt_card_stack.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              const MeloWordmark(size: 30),
              const Expanded(child: PromptCardStack()),
              Text.rich(
                const TextSpan(
                  text: 'Meet naturally.\n',
                  children: [
                    TextSpan(
                      text: 'Match intentionally.',
                      style: TextStyle(color: AppColors.plum),
                    ),
                  ],
                ),
                style: compact
                    ? textTheme.headlineMedium
                    : textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Thoughtful profiles, real conversations, and optional '
                'social rooms. Date at your own pace.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
              ),
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              MeloButton(
                label: 'Get started',
                onPressed: () => context.push(AppRoutes.intro),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account?',
                      style: textTheme.bodyMedium,
                    ),
                    MeloButton.text(
                      label: 'Log in',
                      onPressed: () => context.push(AppRoutes.phoneLogin),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
