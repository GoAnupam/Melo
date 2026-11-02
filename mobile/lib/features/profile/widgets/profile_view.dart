import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../models/profile_draft.dart';
import 'photo_placeholder.dart';

/// A profile as other people see it: name and essentials up top, then photos
/// and prompts interleaved so the profile reads like a story rather than a
/// gallery. Interests sit after the second photo.
///
/// Built from a [ProfileDraft] for now; discovery will reuse it with real
/// profiles. [onReact] is called when someone taps the like button on a photo
/// or prompt.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.profile, required this.onReact});

  final ProfileDraft profile;
  final void Function(String itemLabel) onReact;

  @override
  Widget build(BuildContext context) {
    final photos = profile.photos;
    final prompts = profile.prompts;

    final sections = <Widget>[];
    final longest = photos.length > prompts.length
        ? photos.length
        : prompts.length;
    for (var i = 0; i < longest; i++) {
      if (i < photos.length) {
        sections.add(
          _PhotoCard(
            photo: photos[i],
            onLike: () => onReact(i == 0 ? 'main photo' : 'photo'),
          ),
        );
      }
      if (i == 1 && profile.interests.isNotEmpty) {
        sections.add(_InterestsCard(interests: profile.interests));
      }
      if (i < prompts.length) {
        sections.add(
          _PromptCard(prompt: prompts[i], onLike: () => onReact('prompt')),
        );
      }
    }
    if (photos.length < 2 && profile.interests.isNotEmpty) {
      sections.add(_InterestsCard(interests: profile.interests));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        for (final section in sections) ...[
          section,
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final ProfileDraft profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final age = profile.age;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          age == null ? profile.firstName : '${profile.firstName}, $age',
          style: text.displaySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (profile.city.isNotEmpty)
              _InfoPill(icon: Icons.location_on_outlined, label: profile.city),
            if (profile.intention != null)
              _InfoPill(
                icon: profile.intention!.icon,
                label: profile.intention!.label,
              ),
            if (profile.gender != null)
              _InfoPill(
                icon: Icons.person_outline_rounded,
                label: profile.gender!.label,
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.plum),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.photo, required this.onLike});

  final ProfilePhoto photo;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PhotoPlaceholder(photo: photo, borderRadius: AppRadii.card),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: _LikeButton(onPressed: onLike),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.prompt, required this.onLike});

  final PromptAnswer prompt;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(
              prompt.question,
              style: text.titleSmall?.copyWith(color: AppColors.plum),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(prompt.answer, style: text.headlineMedium),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _LikeButton(onPressed: onLike),
          ),
        ],
      ),
    );
  }
}

class _InterestsCard extends StatelessWidget {
  const _InterestsCard({required this.interests});

  final Set<String> interests;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Into', style: text.titleSmall?.copyWith(color: AppColors.plum)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final interest in interests)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.plumSoft,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    interest,
                    style: text.titleSmall?.copyWith(color: AppColors.plum),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Like',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size(48, 48),
      ),
      icon: const Icon(Icons.favorite_border_rounded, color: AppColors.plum),
    );
  }
}
