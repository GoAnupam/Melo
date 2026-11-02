import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/field_label.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import '../../../core/widgets/melo_button.dart';
import '../../../core/widgets/selectable_chip.dart';
import '../data/profile_catalog.dart';
import '../models/profile_draft.dart';
import 'setup_progress.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  void _toggle(BuildContext context, ProfileDraft draft, String interest) {
    if (draft.toggleInterest(interest)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'You can pick up to ${ProfileDraft.maxInterests}. '
            'Remove one to add another.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ProfileDraftScope.of(context);
    final count = draft.interests.length;
    final atLimit = count >= ProfileDraft.maxInterests;
    final enough = count >= ProfileDraft.minInterests;

    return FormStepScaffold(
      progress: SetupStep.interests.progress,
      title: 'What are you into?',
      subtitle: const Text(
        'Pick ${ProfileDraft.minInterests} to ${ProfileDraft.maxInterests}. '
        "They help us find people you'll click with.",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final MapEntry(key: group, value: items)
              in ProfileCatalog.interestGroups.entries) ...[
            FieldLabel(group),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final interest in items)
                  SelectableChip(
                    label: interest,
                    selected: draft.interests.contains(interest),
                    muted: atLimit && !draft.interests.contains(interest),
                    onTap: () => _toggle(context, draft, interest),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
      action: MeloButton(
        label: enough
            ? 'Continue  ·  $count/${ProfileDraft.maxInterests}'
            : 'Pick ${ProfileDraft.minInterests - count} more',
        onPressed: enough ? () => context.push(AppRoutes.setupPhotos) : null,
      ),
    );
  }
}
