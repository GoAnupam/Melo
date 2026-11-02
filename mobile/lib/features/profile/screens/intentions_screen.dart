import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import '../../../core/widgets/melo_button.dart';
import '../../../core/widgets/option_tile.dart';
import '../models/profile_draft.dart';
import 'setup_progress.dart';

class IntentionsScreen extends StatelessWidget {
  const IntentionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = ProfileDraftScope.of(context);

    return FormStepScaffold(
      progress: SetupStep.intentions.progress,
      title: 'What are you looking for?',
      subtitle: const Text(
        "It's shown on your profile so expectations are clear from the "
        'start. You can change it anytime.',
      ),
      body: Column(
        children: [
          for (final intention in DatingIntention.values) ...[
            OptionTile(
              title: intention.label,
              description: intention.description,
              icon: intention.icon,
              selected: draft.intention == intention,
              onTap: () => draft.setIntention(intention),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
      action: MeloButton(
        label: 'Continue',
        onPressed: draft.intention == null
            ? null
            : () => context.push(AppRoutes.setupInterests),
      ),
    );
  }
}
