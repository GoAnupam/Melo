import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/form_step_scaffold.dart';
import '../../../core/widgets/melo_button.dart';
import '../models/profile_draft.dart';
import '../widgets/photo_placeholder.dart';
import 'setup_progress.dart';

enum _PhotoSource { camera, library }

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  bool _uploading = false;

  Future<void> _addPhoto(ProfileDraft draft) async {
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      backgroundColor: AppColors.ivory,
      showDragHandle: true,
      builder: (context) => const _SourceSheet(),
    );
    if (source == null || !mounted) return;

    // Mock upload. Real picking (image_picker) and S3 upload come later.
    setState(() => _uploading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final nextId = draft.photos.fold(0, (m, p) => p.id > m ? p.id : m) + 1;
    draft.addPhoto(
      ProfilePhoto(
        id: nextId,
        tone: mockPhotoTones[nextId % mockPhotoTones.length],
      ),
    );
    setState(() => _uploading = false);
  }

  void _removePhoto(ProfileDraft draft, int index) {
    final photo = draft.photos[index];
    draft.removePhoto(photo.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Photo removed'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.plumMuted,
            onPressed: () => draft.insertPhoto(index, photo),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ProfileDraftScope.of(context);
    final photos = draft.photos;
    final missing = ProfileDraft.minPhotos - photos.length;

    return FormStepScaffold(
      progress: SetupStep.photos.progress,
      title: 'Add your photos',
      subtitle: const Text(
        'Add at least ${ProfileDraft.minPhotos}. Your first photo is the '
        'one people see first.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
            children: [
              for (var i = 0; i < ProfileDraft.maxPhotos; i++)
                if (i < photos.length)
                  _FilledSlot(
                    key: ValueKey(photos[i].id),
                    index: i,
                    photo: photos[i],
                    onRemove: () => _removePhoto(draft, i),
                    onMove: draft.movePhoto,
                  )
                else if (i == photos.length && _uploading)
                  const _UploadingSlot()
                else
                  _EmptySlot(onTap: _uploading ? null : () => _addPhoto(draft)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.drag_indicator_rounded,
                size: 18,
                color: AppColors.inkSubtle,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  'Long-press and drag a photo to reorder.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      action: MeloButton(
        label: missing > 0
            ? 'Add $missing more photo${missing == 1 ? '' : 's'}'
            : 'Continue',
        onPressed: missing > 0 || _uploading
            ? null
            : () => context.push(AppRoutes.setupPrompts),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({
    super.key,
    required this.index,
    required this.photo,
    required this.onRemove,
    required this.onMove,
  });

  final int index;
  final ProfilePhoto photo;
  final VoidCallback onRemove;
  final void Function(int from, int to) onMove;

  static const _radius = BorderRadius.all(Radius.circular(AppRadii.md));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = _tile(context, highlighted: false);
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) => onMove(details.data, index),
          builder: (context, candidates, _) => LongPressDraggable<int>(
            data: index,
            feedback: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Material(
                elevation: 8,
                shadowColor: AppColors.ink.withValues(alpha: 0.3),
                borderRadius: _radius,
                child: PhotoPlaceholder(photo: photo, borderRadius: _radius),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: tile),
            child: candidates.isEmpty
                ? tile
                : _tile(context, highlighted: true),
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext context, {required bool highlighted}) {
    return Semantics(
      label: index == 0 ? 'Main photo' : 'Photo ${index + 1}',
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          borderRadius: _radius,
          border: Border.all(
            color: highlighted ? AppColors.plum : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PhotoPlaceholder(photo: photo, borderRadius: _radius),
            if (index == 0)
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    'Main',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: AppColors.onPlum, letterSpacing: 0.4),
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: onRemove,
                tooltip: 'Remove photo',
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add photo',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.plumSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.plum),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadingSlot extends StatelessWidget {
  const _UploadingSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.plum,
          ),
        ),
      ),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              AppSpacing.xs,
            ),
            child: Text('Add a photo', style: text.headlineSmall),
          ),
          ListTile(
            contentPadding: AppSpacing.screenPadding,
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.plum,
            ),
            title: Text('Take a photo', style: text.titleMedium),
            onTap: () => Navigator.of(context).pop(_PhotoSource.camera),
          ),
          ListTile(
            contentPadding: AppSpacing.screenPadding,
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.plum,
            ),
            title: Text('Choose from library', style: text.titleMedium),
            onTap: () => Navigator.of(context).pop(_PhotoSource.library),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
