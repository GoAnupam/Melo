import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import '../../../core/widgets/melo_button.dart';
import '../data/profile_catalog.dart';
import '../models/profile_draft.dart';
import 'setup_progress.dart';

class PromptsScreen extends StatelessWidget {
  const PromptsScreen({super.key});

  static const maxAnswerLength = 160;

  Future<void> _addPrompt(BuildContext context, ProfileDraft draft) async {
    final used = draft.prompts.map((p) => p.question).toSet();
    final question = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.ivory,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _PromptPickerSheet(
        options: [
          for (final q in ProfileCatalog.prompts)
            if (!used.contains(q)) q,
        ],
      ),
    );
    if (question == null || !context.mounted) return;
    await _editAnswer(context, draft, question, '');
  }

  Future<void> _editAnswer(
    BuildContext context,
    ProfileDraft draft,
    String question,
    String initial,
  ) async {
    final answer = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.ivory,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AnswerSheet(question: question, initial: initial),
    );
    if (answer != null) {
      draft.savePrompt(PromptAnswer(question: question, answer: answer));
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ProfileDraftScope.of(context);
    final prompts = draft.prompts;
    final canAdd = prompts.length < ProfileDraft.maxPrompts;

    return FormStepScaffold(
      progress: SetupStep.prompts.progress,
      title: 'Answer a few prompts',
      subtitle: const Text(
        'Pick up to ${ProfileDraft.maxPrompts}. Specific answers give people '
        'something easy to reply to.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (prompts.isEmpty) const _EmptyPrompts(),
          for (final p in prompts) ...[
            _PromptCard(
              prompt: p,
              onEdit: () => _editAnswer(context, draft, p.question, p.answer),
              onRemove: () => draft.removePrompt(p.question),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (canAdd) ...[
            const SizedBox(height: AppSpacing.xs),
            MeloButton.secondary(
              label: prompts.isEmpty ? 'Choose a prompt' : 'Add another prompt',
              icon: Icons.add_rounded,
              onPressed: () => _addPrompt(context, draft),
            ),
          ],
        ],
      ),
      action: MeloButton(
        label: prompts.isEmpty ? 'Answer at least 1 prompt' : 'Preview profile',
        onPressed: prompts.isEmpty
            ? null
            : () => context.push(AppRoutes.setupPreview),
      ),
    );
  }
}

class _EmptyPrompts extends StatelessWidget {
  const _EmptyPrompts();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXAMPLE',
            style: text.labelSmall?.copyWith(color: AppColors.plum),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('A perfect first date', style: text.titleSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Street food crawl, then arguing about which stall won.',
            style: text.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.prompt,
    required this.onEdit,
    required this.onRemove,
  });

  final PromptAnswer prompt;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg - 4,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.lg - 4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.question,
                        style: text.titleSmall?.copyWith(color: AppColors.plum),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(prompt.answer, style: text.headlineSmall),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'Remove prompt',
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptPickerSheet extends StatelessWidget {
  const _PromptPickerSheet({required this.options});

  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              AppSpacing.sm,
            ),
            child: Text('Choose a prompt', style: text.headlineSmall),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemCount: options.length,
              separatorBuilder: (_, _) => const Divider(
                indent: AppSpacing.screenH,
                endIndent: AppSpacing.screenH,
              ),
              itemBuilder: (context, i) => ListTile(
                contentPadding: AppSpacing.screenPadding,
                title: Text(options[i], style: text.titleMedium),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkSubtle,
                ),
                onTap: () => Navigator.of(context).pop(options[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSheet extends StatefulWidget {
  const _AnswerSheet({required this.question, required this.initial});

  final String question;
  final String initial;

  @override
  State<_AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends State<_AnswerSheet> {
  late final _controller = TextEditingController(text: widget.initial)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final answer = _controller.text.trim();

    return Padding(
      // Keep the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            0,
            AppSpacing.screenH,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question,
                style: text.titleSmall?.copyWith(color: AppColors.plum),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: PromptsScreen.maxAnswerLength,
                textCapitalization: TextCapitalization.sentences,
                style: text.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Write your answer',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              MeloButton(
                label: 'Save answer',
                onPressed: answer.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(answer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
